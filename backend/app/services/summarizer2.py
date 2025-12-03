"""
Hybrid Summarization Service
Combines extractive and abstractive summarization
"""

import os
import json
import logging
import warnings
from typing import Dict, Optional, Any
import torch
import nltk
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, pipeline
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import networkx as nx
import numpy as np

# Suppress warnings
warnings.filterwarnings('ignore')
logger = logging.getLogger(__name__)

# Download NLTK data quietly
def download_nltk_data():
    """Download required NLTK data"""
    resources = ['punkt', 'punkt_tab', 'stopwords']
    for resource in resources:
        try:
            nltk.data.find(f'tokenizers/{resource}')
        except LookupError:
            try:
                nltk.download(resource, quiet=True)
            except:
                pass

download_nltk_data()


class HybridSummarizer:
    """Complete hybrid summarization system"""
    
    def __init__(self):
        logger.info("Initializing Hybrid Summarizer...")
        
        # Load document classifier (if available)
        try:
            self.doc_classifier = pipeline(
                "text-classification",
                model="./doc_classifier",
                tokenizer="./doc_classifier"
            )
            with open('./doc_classifier/label_mappings.json', 'r') as f:
                self.label_mappings = json.load(f)
            logger.info("✅ Document classifier loaded")
        except:
            logger.warning("⚠️ Document classifier not available, using keyword fallback")
            self.doc_classifier = None
            self.label_mappings = None
        
        # Load sentence transformer for extractive summarization
        self.sentence_model = SentenceTransformer('all-MiniLM-L6-v2')
        logger.info("✅ Sentence transformer loaded")
        
        # Load abstractive summarization model
        self.abs_tokenizer = AutoTokenizer.from_pretrained("google/flan-t5-base")
        self.abs_model = AutoModelForSeq2SeqLM.from_pretrained("google/flan-t5-base")
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.abs_model.to(self.device)
        logger.info(f"✅ Abstractive model loaded on {self.device}")
    
    def classify_document(self, text: str) -> str:
        """Classify document type"""
        if self.doc_classifier:
            try:
                result = self.doc_classifier(text[:512])
                return result[0]['label']
            except:
                return self.classify_document_by_keyword(text)
        else:
            return self.classify_document_by_keyword(text)
    
    def classify_document_by_keyword(self, text: str) -> str:
        """Fallback keyword-based classifier"""
        text_lower = text.lower()
        
        keywords = {
            'resume': ['experience', 'skills', 'qualifications', 'education', 'certifications'],
            'legal': ['agreement', 'contract', 'shall', 'pursuant to', 'testament'],
            'academic': ['research', 'study', 'methodology', 'abstract', 'hypothesis'],
            'news': ['breaking news', 'announced', 'reported', 'authorities said'],
            'financial': ['invoice', 'earnings', 'balance', 'fiscal year', 'revenue'],
            'technical': ['install', 'api', 'server', 'database', 'configure'],
            'email': ['subject:', 'dear', 'best regards', 'sincerely'],
            'review': ['stars', 'recommend', 'rating', 'customer service'],
            'story': ['chapter', 'once upon a time', 'character', 'plot']
        }
        
        for doc_type, words in keywords.items():
            if any(word in text_lower for word in words):
                return doc_type
        
        return 'unknown'
    
    def extractive_summarize(self, text: str, num_sentences: int = 5) -> str:
        """Extract key sentences using graph-based ranking"""
        try:
            sentences = nltk.sent_tokenize(text)
        except:
            sentences = [s.strip() + '.' for s in text.split('.') if s.strip()]
        
        if len(sentences) <= num_sentences:
            return ' '.join(sentences)
        
        cleaned_sentences = [s.strip() for s in sentences if len(s.split()) > 5]
        if len(cleaned_sentences) < 2:
            return ' '.join(sentences[:num_sentences])
        
        # Encode sentences
        embeddings = self.sentence_model.encode(cleaned_sentences)
        similarity_matrix = cosine_similarity(embeddings)
        
        # PageRank on similarity graph
        nx_graph = nx.from_numpy_array(similarity_matrix)
        
        try:
            scores = nx.pagerank(nx_graph)
            top_indices = sorted(
                range(len(cleaned_sentences)),
                key=lambda i: scores[i],
                reverse=True
            )[:num_sentences]
            top_indices.sort()  # Keep original order
            return ' '.join([cleaned_sentences[i] for i in top_indices])
        except:
            return ' '.join(cleaned_sentences[:num_sentences])
    
    def build_context_prompt(
        self,
        doc_type: str,
        profession: str,
        purpose: str,
        extractive_summary: str
    ) -> str:
        """Build contextual prompt for abstractive summarization"""
        template = f"Summarize this {doc_type} document for a {profession} focusing on {purpose}: {extractive_summary}"
        
        # Ensure prompt fits in token limit
        tokens = self.abs_tokenizer.encode(template)
        if len(tokens) > 512:
            template = self.abs_tokenizer.decode(tokens[:510])
        
        return template
    
    def abstractive_summarize(self, prompt: str, max_length: int = 150) -> str:
        """Generate abstractive summary using T5"""
        inputs = self.abs_tokenizer(
            prompt,
            max_length=512,
            truncation=True,
            padding=True,
            return_tensors="pt"
        ).to(self.device)
        
        with torch.no_grad():
            outputs = self.abs_model.generate(
                **inputs,
                max_length=max_length,
                min_length=40,
                num_beams=4,
                no_repeat_ngram_size=2,
                early_stopping=True
            )
        
        summary = self.abs_tokenizer.decode(outputs[0], skip_special_tokens=True)
        return summary.strip()
    
    def summarize(
        self,
        text: str,
        profession: str,
        purpose: str = "overview",
        num_sentences: int = 5,
        document_type: str = "auto"
    ) -> Dict[str, Any]:
        """Complete hybrid summarization pipeline"""
        
        # Validate input
        if len(text.split()) < 20:
            return {"error": "Input text is too short. Please provide at least 20 words."}
        
        # Truncate if too long
        text = text[:10000]
        
        # Classify document
        doc_type = self.classify_document(text) if document_type.lower() == "auto" else document_type.lower()
        
        # Extractive summarization
        extractive_summary = self.extractive_summarize(text, num_sentences)
        
        if not extractive_summary.strip():
            return {"error": "Could not extract key sentences from the document."}
        
        # Build prompt and generate abstractive summary
        context_prompt = self.build_context_prompt(doc_type, profession, purpose, extractive_summary)
        final_summary = self.abstractive_summarize(context_prompt)
        
        return {
            "document_type": doc_type,
            "extractive_summary": extractive_summary,
            "context_prompt": context_prompt,
            "final_summary": final_summary,
            "metadata": {
                "profession": profession,
                "purpose": purpose,
                "num_sentences": num_sentences,
                "original_length": len(text),
                "extractive_length": len(extractive_summary),
                "final_length": len(final_summary)
            }
        }


# ============= GLOBAL INSTANCE =============
logger.info("Creating global summarizer instance...")
summarizer = HybridSummarizer()
logger.info("✅ Hybrid Summarizer ready!")


# ============= MODULE-LEVEL FUNCTION =============
def summarize(
    text: str,
    num_sentences: int = 5,
    profession: str = "general reader",
    purpose: str = "overview",
    document_type: str = "auto"
) -> str:
    """
    Module-level function for easy API access.
    Returns just the final summary text.
    """
    try:
        result = summarizer.summarize(
            text=text,
            profession=profession,
            purpose=purpose,
            num_sentences=num_sentences,
            document_type=document_type
        )
        
        if "error" in result:
            raise ValueError(result["error"])
        
        return result["final_summary"]
    
    except Exception as e:
        logger.error(f"Summarization failed: {str(e)}")
        raise Exception(f"Summarization failed: {str(e)}")