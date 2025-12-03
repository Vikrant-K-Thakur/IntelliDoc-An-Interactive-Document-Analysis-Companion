from transformers import pipeline
import re
from typing import List, Dict, Optional
import logging

logger = logging.getLogger(__name__)

# Lazy load models (only load when first used)
_qna_pipeline = None
_summarizer = None

def get_qna_pipeline():
    """Lazy load QnA pipeline"""
    global _qna_pipeline
    if _qna_pipeline is None:
        logger.info("Loading QnA generation model...")
        _qna_pipeline = pipeline("text2text-generation", model="valhalla/t5-base-qg-hl")
        logger.info("✅ QnA model loaded")
    return _qna_pipeline

def get_summarizer():
    """Lazy load summarizer"""
    global _summarizer
    if _summarizer is None:
        logger.info("Loading summarization model...")
        _summarizer = pipeline("summarization", model="facebook/bart-large-cnn")
        logger.info("✅ Summarizer loaded")
    return _summarizer


def split_into_topics(text: str) -> Dict[str, str]:
    """Split text into topic-wise blocks"""
    topic_blocks = {}
    current_topic = "Introduction"
    current_text = []

    lines = text.splitlines()
    for line in lines:
        # Detect new topic
        if re.match(r"^\d+\.?\s+[A-Z][\w\s\-]{2,}", line) or line.isupper():
            if current_text:
                topic_blocks[current_topic] = "\n".join(current_text).strip()
            current_topic = line.strip()
            current_text = []
        else:
            current_text.append(line.strip())

    if current_text:
        topic_blocks[current_topic] = "\n".join(current_text).strip()

    return topic_blocks


def generate_flashcards(
    text: str, 
    num_cards: int = 10, 
    card_type: str = "question_answer",
    focus_topics: Optional[List[str]] = None,
    language: str = "english",
    **kwargs
) -> List[Dict[str, str]]:
    """Generate flashcards with configurable parameters"""
    
    # Validate input
    if not text or len(text.strip()) < 50:
        logger.warning("Text too short for flashcard generation")
        return []
    
    # Get models
    qna_pipeline = get_qna_pipeline()
    summarizer = get_summarizer()
    
    topics = split_into_topics(text)
    flashcards = []

    # Filter topics if focus_topics specified
    if focus_topics:
        filtered_topics = {
            k: v for k, v in topics.items() 
            if any(focus in k.lower() for focus in [t.lower() for t in focus_topics])
        }
        if filtered_topics:
            topics = filtered_topics

    # Flashcard 1: Topic overview
    if card_type == "question_answer":
        topic_names = list(topics.keys())
        flashcards.append({
            "question": "📚 What are the main topics covered?",
            "answer": "\n".join(f"- {name}" for name in topic_names),
            "topic": "overview",
            "hint": None
        })

    # Generate cards for each topic
    for topic, topic_text in topics.items():
        if len(flashcards) >= num_cards:
            break
        
        # Generate summary
        try:
            summary = summarizer(
                topic_text,
                max_length=120,
                min_length=30,
                do_sample=False
            )[0]["summary_text"]
        except Exception as e:
            logger.warning(f"Summarization failed for topic '{topic}': {e}")
            summary = topic_text[:150] + "..."

        # Create cards based on type
        if card_type == "question_answer":
            flashcards.append({
                "question": f"📝 What are the key points of '{topic}'?",
                "answer": summary,
                "topic": topic,
                "hint": None
            })
        elif card_type == "definition":
            flashcards.append({
                "question": f"Define: {topic}",
                "answer": summary,
                "topic": topic,
                "hint": None
            })
        elif card_type == "fill_in_blank":
            words = summary.split()
            if len(words) > 5:
                blank_word = words[len(words)//2]
                blank_summary = summary.replace(blank_word, "______", 1)
                flashcards.append({
                    "question": f"Fill in the blank: {blank_summary}",
                    "answer": blank_word,
                    "topic": topic,
                    "hint": f"This word relates to {topic}"
                })

        # Generate additional Q&A
        if len(flashcards) < num_cards:
            sentences = re.split(r'(?<=[.!?]) +', topic_text)
            for sentence in sentences[:3]:
                if len(flashcards) >= num_cards:
                    break
                if len(sentence.strip()) < 30:
                    continue
                
                try:
                    prompt = f"generate question: <hl> {sentence.strip()} <hl> {topic_text}"
                    generated = qna_pipeline(prompt)[0]["generated_text"]
                    flashcards.append({
                        "question": generated.strip(),
                        "answer": sentence.strip(),
                        "topic": topic,
                        "hint": None
                    })
                except Exception as e:
                    logger.debug(f"Question generation failed: {e}")
                    continue

    return flashcards[:num_cards]