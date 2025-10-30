from typing import Dict, List, Optional, Any
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
import re
from datetime import datetime

class DocumentChatbot:
    """Chatbot for answering questions about documents"""
    
    def __init__(self):
        # Load sentence transformer for semantic search
        print("Loading chatbot models...")
        self.sentence_model = SentenceTransformer('all-MiniLM-L6-v2')
        
        # Store active sessions
        self.sessions = {}
        
        print("✓ Chatbot ready!")
    
    def chunk_document(self, text: str, chunk_size: int = 200) -> List[str]:
        """Split document into chunks for better context retrieval"""
        # Split by sentences
        sentences = re.split(r'(?<=[.!?])\s+', text)
        
        chunks = []
        current_chunk = []
        current_length = 0
        
        for sentence in sentences:
            sentence_words = sentence.split()
            sentence_length = len(sentence_words)
            
            if current_length + sentence_length > chunk_size and current_chunk:
                chunks.append(' '.join(current_chunk))
                current_chunk = [sentence]
                current_length = sentence_length
            else:
                current_chunk.append(sentence)
                current_length += sentence_length
        
        if current_chunk:
            chunks.append(' '.join(current_chunk))
        
        return chunks
    
    def find_relevant_context(
        self, 
        question: str, 
        document_chunks: List[str], 
        top_k: int = 3
    ) -> tuple:
        """Find most relevant chunks for the question"""
        
        # Encode question and chunks
        question_embedding = self.sentence_model.encode([question])
        chunk_embeddings = self.sentence_model.encode(document_chunks)
        
        # Calculate similarities
        similarities = cosine_similarity(question_embedding, chunk_embeddings)[0]
        
        # Get top-k most similar chunks
        top_indices = np.argsort(similarities)[-top_k:][::-1]
        
        relevant_chunks = [document_chunks[i] for i in top_indices]
        confidence_scores = [float(similarities[i]) for i in top_indices]
        
        # Combine relevant chunks
        context = ' '.join(relevant_chunks)
        avg_confidence = float(np.mean(confidence_scores))
        
        return context, avg_confidence, relevant_chunks
    
    def generate_answer(
        self, 
        question: str, 
        context: str,
        conversation_history: Optional[List[Dict[str, str]]] = None
    ) -> str:
        """Generate answer based on context (simple extractive approach)"""
        
        # Simple extractive approach: find sentences related to question
        question_words = set(question.lower().split())
        context_sentences = re.split(r'(?<=[.!?])\s+', context)
        
        # Score sentences
        scored_sentences = []
        for sentence in context_sentences:
            sentence_words = set(sentence.lower().split())
            overlap = len(question_words.intersection(sentence_words))
            if overlap > 0:
                scored_sentences.append((overlap, sentence))
        
        if not scored_sentences:
            return "I couldn't find a specific answer to your question in the document. Could you rephrase or ask something else?"
        
        # Get top sentences
        scored_sentences.sort(reverse=True, key=lambda x: x[0])
        answer_sentences = [s[1] for s in scored_sentences[:2]]
        
        answer = ' '.join(answer_sentences)
        
        # Add conversational context if available
        if conversation_history and len(conversation_history) > 0:
            last_exchange = conversation_history[-1]
            if 'answer' in last_exchange:
                # Reference previous context if relevant
                pass
        
        return answer.strip()
    
    def answer_question(
        self,
        document_text: str,
        question: str,
        conversation_history: Optional[List[Dict[str, str]]] = None
    ) -> Dict[str, Any]:
        """Main method to answer questions about a document"""
        
        try:
            # Chunk the document
            chunks = self.chunk_document(document_text)
            
            if not chunks:
                return {"error": "Could not process document"}
            
            # Find relevant context
            context, confidence, relevant_chunks = self.find_relevant_context(
                question, 
                chunks
            )
            
            # Generate answer
            answer = self.generate_answer(question, context, conversation_history)
            
            return {
                "answer": answer,
                "confidence_score": round(confidence, 3),
                "relevant_context": context[:500] + "..." if len(context) > 500 else context,
                "sources": relevant_chunks,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {"error": f"Failed to generate answer: {str(e)}"}
    
    def create_session(
        self,
        session_id: str,
        document_text: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Create a chat session with stored document"""
        
        try:
            # Chunk and store document
            chunks = self.chunk_document(document_text)
            chunk_embeddings = self.sentence_model.encode(chunks)
            
            self.sessions[session_id] = {
                "document_text": document_text,
                "chunks": chunks,
                "chunk_embeddings": chunk_embeddings,
                "metadata": metadata or {},
                "conversation_history": [],
                "created_at": datetime.now().isoformat()
            }
            
            return {
                "success": True,
                "session_id": session_id,
                "chunks_count": len(chunks)
            }
            
        except Exception as e:
            return {"error": f"Failed to create session: {str(e)}"}
    
    def answer_from_session(
        self,
        session_id: str,
        question: str
    ) -> Dict[str, Any]:
        """Answer question using stored session"""
        
        if session_id not in self.sessions:
            return {"error": "Session not found. Please create a session first."}
        
        session = self.sessions[session_id]
        
        try:
            # Use pre-computed embeddings
            question_embedding = self.sentence_model.encode([question])
            similarities = cosine_similarity(
                question_embedding, 
                session["chunk_embeddings"]
            )[0]
            
            # Get top chunks
            top_indices = np.argsort(similarities)[-3:][::-1]
            relevant_chunks = [session["chunks"][i] for i in top_indices]
            context = ' '.join(relevant_chunks)
            avg_confidence = float(np.mean([similarities[i] for i in top_indices]))
            
            # Generate answer
            answer = self.generate_answer(
                question, 
                context, 
                session["conversation_history"]
            )
            
            # Store in history
            session["conversation_history"].append({
                "question": question,
                "answer": answer,
                "timestamp": datetime.now().isoformat()
            })
            
            return {
                "answer": answer,
                "confidence_score": round(avg_confidence, 3),
                "relevant_context": context[:500] + "..." if len(context) > 500 else context,
                "sources": relevant_chunks
            }
            
        except Exception as e:
            return {"error": f"Failed to answer from session: {str(e)}"}
    
    def delete_session(self, session_id: str) -> Dict[str, bool]:
        """Delete a chat session"""
        if session_id in self.sessions:
            del self.sessions[session_id]
            return {"success": True}
        return {"success": False}
    
    def get_session_history(self, session_id: str) -> Dict[str, Any]:
        """Get conversation history for a session"""
        if session_id not in self.sessions:
            return {"error": "Session not found"}
        
        session = self.sessions[session_id]
        
        # Generate quick summary of document
        doc_preview = session["document_text"][:200] + "..."
        
        return {
            "history": session["conversation_history"],
            "document_summary": doc_preview,
            "created_at": session["created_at"],
            "total_questions": len(session["conversation_history"])
        }
    
    def clear_history(self, session_id: str) -> Dict[str, Any]:
        """Clear conversation history but keep document"""
        if session_id not in self.sessions:
            return {"error": "Session not found"}
        
        self.sessions[session_id]["conversation_history"] = []
        return {"success": True}
    
    def get_all_sessions(self) -> Dict[str, Any]:
        """Get info about all active sessions"""
        sessions_list = []
        for session_id, session_data in self.sessions.items():
            sessions_list.append({
                "session_id": session_id,
                "document_name": session_data["metadata"].get("document_name", "Unknown"),
                "created_at": session_data["created_at"],
                "total_questions": len(session_data["conversation_history"]),
                "document_length": len(session_data["document_text"])
            })
        
        return {
            "sessions": sessions_list,
            "total": len(sessions_list)
        }
    
    def test_connection(self) -> Dict[str, bool]:
        """Test if chatbot is working"""
        try:
            # Test encoding
            test_text = "This is a test"
            self.sentence_model.encode([test_text])
            return {"available": True}
        except:
            return {"available": False}


# Initialize global chatbot instance
document_chatbot = DocumentChatbot()