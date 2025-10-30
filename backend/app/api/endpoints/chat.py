import time
import logging
import uuid
from datetime import datetime
from app.services.llm_service import llm_service
from typing import Optional, List, Dict, Any
from fastapi import APIRouter, HTTPException, BackgroundTasks, UploadFile, File
from pydantic import BaseModel, Field, validator
from app.services.chatbot import document_chatbot
from app.services.document_parser import extract_text  # Your existing document parser
import tempfile
import os


# Configure logging
logger = logging.getLogger(__name__)
router = APIRouter()

# Request Models
class UploadDocumentRequest(BaseModel):
    """For uploading document via text"""
    document_text: str = Field(..., min_length=50, max_length=50000)
    document_name: Optional[str] = Field(default="untitled", description="Name of document")
    
    @validator('document_text')
    def validate_document(cls, v):
        if not v.strip():
            raise ValueError('Document text cannot be empty')
        return v.strip()    

class ChatQuestionRequest(BaseModel):
    session_id: str
    question: str = Field(..., min_length=5, max_length=500)
    language: Optional[str] = Field(default="english")  # NEW
    use_llm: Optional[bool] = Field(default=False)  # NEW
    
    @validator('question')
    def validate_question(cls, v):
        if not v.strip():
            raise ValueError('Question cannot be empty')
        return v.strip()
    
    
class ChatHistoryRequest(BaseModel):
    session_id: str = Field(..., description="Session ID to clear history")

# Response Models
class UploadDocumentResponse(BaseModel):
    success: bool
    session_id: str
    document_name: str
    document_length: int
    chunks_created: int
    message: str
    timestamp: str

class ChatResponse(BaseModel):
    success: bool
    session_id: str
    question: str
    answer: str
    confidence_score: Optional[float] = None
    relevant_context: Optional[str] = None
    processing_time: float
    timestamp: str

class ConversationHistoryResponse(BaseModel):
    success: bool
    session_id: str
    document_name: str
    total_messages: int
    conversation: List[Dict[str, str]]
    document_preview: str

class SessionInfoResponse(BaseModel):
    success: bool
    active_sessions: List[Dict[str, Any]]
    total_sessions: int

# Helper Functions
async def log_chat_analytics(
    session_id: str,
    question_length: int,
    processing_time: float,
    success: bool
):
    """Background task for logging analytics"""
    logger.info(
        f"Chat Analytics - Session: {session_id}, Q_Length: {question_length}, "
        f"Time: {processing_time:.2f}s, Success: {success}"
    )

# API Endpoints

@router.post("/chat/upload/", response_model=UploadDocumentResponse)
async def upload_document_for_chat(request: UploadDocumentRequest):
    """
    Upload a document to start a chat session.
    Returns a session_id that you'll use for all subsequent questions.
    """
    try:
        # Generate unique session ID
        session_id = str(uuid.uuid4())
        
        logger.info(f"Creating chat session for document: {request.document_name}")
        
        # Create session with document
        result = document_chatbot.create_session(
            session_id=session_id,
            document_text=request.document_text,
            metadata={"document_name": request.document_name}
        )
        
        if "error" in result:
            raise HTTPException(status_code=400, detail=result["error"])
        
        return UploadDocumentResponse(
            success=True,
            session_id=session_id,
            document_name=request.document_name,
            document_length=len(request.document_text),
            chunks_created=result.get("chunks_count", 0),
            message=f"Document uploaded successfully. Use session_id '{session_id}' to ask questions.",
            timestamp=datetime.now().isoformat()
        )
        
    except Exception as e:
        logger.error(f"Error uploading document: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to upload document: {str(e)}")

@router.post("/chat/upload/file/", response_model=UploadDocumentResponse)
async def upload_document_file_for_chat(
    file: UploadFile = File(...),
    document_name: Optional[str] = None
):
    """
    Upload a document file (PDF, DOCX, TXT) to start a chat session.
    Returns a session_id for asking questions.
    """
    try:
        # Validate file type
        filename = file.filename or "document"
        file_ext = filename.split(".")[-1].lower() if "." in filename else ""
        
        if file_ext not in ["pdf", "docx", "txt"]:
            raise HTTPException(
                status_code=400,
                detail="Unsupported file type. Allowed: .pdf, .docx, .txt"
            )
        
        # Read file
        file_content = await file.read()
        
        # Extract text
        if file_ext == "txt":
            extracted_text = file_content.decode('utf-8')
        else:
            # Save temporarily and extract
            with tempfile.NamedTemporaryFile(suffix=f".{file_ext}", delete=False) as temp_file:
                temp_file.write(file_content)
                temp_path = temp_file.name
            
            try:
                extracted_text = extract_text(temp_path, file_ext)
            finally:
                os.unlink(temp_path)
        
        # Validate extracted text
        if len(extracted_text.split()) < 20:
            raise HTTPException(
                status_code=400,
                detail="Document too short. Please provide a document with at least 20 words."
            )
        
        # Generate session ID
        session_id = str(uuid.uuid4())
        doc_name = document_name or filename
        
        # Create session
        result = document_chatbot.create_session(
            session_id=session_id,
            document_text=extracted_text,
            metadata={"document_name": doc_name, "filename": filename}
        )
        
        if "error" in result:
            raise HTTPException(status_code=400, detail=result["error"])
        
        return UploadDocumentResponse(
            success=True,
            session_id=session_id,
            document_name=doc_name,
            document_length=len(extracted_text),
            chunks_created=result.get("chunks_count", 0),
            message=f"File '{filename}' uploaded successfully. Use session_id '{session_id}' to ask questions.",
            timestamp=datetime.now().isoformat()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error uploading file: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to upload file: {str(e)}")

@router.post("/chat/ask/", response_model=ChatResponse)
async def ask_question(
    request: ChatQuestionRequest,
    background_tasks: BackgroundTasks
):
    """
    Ask a question about your uploaded document.
    Use the session_id you received when uploading the document.
    """
    start_time = time.time()
    
    try:
        logger.info(f"Processing question for session: {request.session_id}")
        
        # Get answer from stored session
        result = document_chatbot.answer_from_session(
            session_id=request.session_id,
            question=request.question
        )
        
        if "error" in result:
            if "not found" in result["error"].lower():
                raise HTTPException(
                    status_code=404,
                    detail="Session not found. Please upload a document first."
                )
            raise HTTPException(status_code=400, detail=result["error"])
        
        processing_time = time.time() - start_time
        
        # Log analytics
        background_tasks.add_task(
            log_chat_analytics,
            request.session_id,
            len(request.question),
            processing_time,
            True
        )
        
        return ChatResponse(
            success=True,
            session_id=request.session_id,
            question=request.question,
            answer=result.get("answer", ""),
            confidence_score=result.get("confidence_score"),
            relevant_context=result.get("relevant_context"),
            processing_time=processing_time,
            timestamp=datetime.now().isoformat()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error answering question: {str(e)}")
        processing_time = time.time() - start_time
        
        background_tasks.add_task(
            log_chat_analytics,
            request.session_id,
            len(request.question),
            processing_time,
            False
        )
        
        raise HTTPException(
            status_code=500,
            detail=f"Failed to answer question: {str(e)}"
        )

@router.get("/chat/history/{session_id}/", response_model=ConversationHistoryResponse)
async def get_chat_history(session_id: str):
    """
    Get the full conversation history for a session.
    Shows all questions and answers exchanged.
    """
    try:
        result = document_chatbot.get_session_history(session_id)
        
        if "error" in result:
            raise HTTPException(status_code=404, detail="Session not found")
        
        # Format conversation
        conversation = []
        for item in result.get("history", []):
            conversation.append({
                "type": "question",
                "content": item.get("question", ""),
                "timestamp": item.get("timestamp", "")
            })
            conversation.append({
                "type": "answer",
                "content": item.get("answer", ""),
                "timestamp": item.get("timestamp", "")
            })
        
        return ConversationHistoryResponse(
            success=True,
            session_id=session_id,
            document_name=result.get("metadata", {}).get("document_name", "Unknown"),
            total_messages=len(conversation),
            conversation=conversation,
            document_preview=result.get("document_summary", "")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting history: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get history: {str(e)}")

@router.delete("/chat/session/{session_id}/")
async def delete_chat_session(session_id: str):
    """
    Delete a chat session and all its history.
    This frees up memory.
    """
    try:
        result = document_chatbot.delete_session(session_id)
        
        if result.get("success"):
            return {
                "success": True,
                "message": f"Session '{session_id}' deleted successfully",
                "timestamp": datetime.now().isoformat()
            }
        else:
            raise HTTPException(status_code=404, detail="Session not found")
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting session: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to delete session: {str(e)}")

@router.post("/chat/history/{session_id}/clear/")
async def clear_chat_history(session_id: str):
    """
    Clear conversation history but keep the document.
    Useful for starting fresh with the same document.
    """
    try:
        result = document_chatbot.clear_history(session_id)
        
        if "error" in result:
            raise HTTPException(status_code=404, detail="Session not found")
        
        return {
            "success": True,
            "session_id": session_id,
            "message": "Conversation history cleared. Document retained.",
            "timestamp": datetime.now().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error clearing history: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to clear history: {str(e)}")

@router.get("/chat/sessions/", response_model=SessionInfoResponse)
async def get_active_sessions():
    """
    Get list of all active chat sessions.
    Useful for managing multiple document chats.
    """
    try:
        sessions_info = document_chatbot.get_all_sessions()
        
        return SessionInfoResponse(
            success=True,
            active_sessions=sessions_info.get("sessions", []),
            total_sessions=sessions_info.get("total", 0)
        )
        
    except Exception as e:
        logger.error(f"Error getting sessions: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get sessions: {str(e)}")

@router.get("/chat/health/")
async def chat_health():
    """Health check for chat service"""
    try:
        test_result = document_chatbot.test_connection()
        return {
            "status": "healthy",
            "service": "document_chat",
            "chatbot_available": test_result.get("available", False),
            "active_sessions": len(document_chatbot.sessions),
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "service": "document_chat",
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }

@router.get("/chat/stats/")
async def get_chat_stats():
    """Get statistics about the chat system"""
    return {
        "system_info": {
            "max_document_length": 50000,
            "max_question_length": 500,
            "session_storage": "In-memory",
            "models_used": [
                "Sentence Transformers (all-MiniLM-L6-v2)"
            ]
        },
        "features": {
            "file_upload": True,
            "text_upload": True,
            "conversation_history": True,
            "session_management": True,
            "confidence_scoring": True,
            "context_retrieval": True
        },
        "supported_formats": ["PDF", "DOCX", "TXT"]
    }
    


@router.post("/chat/ask/", response_model=ChatResponse)
async def ask_question(
    request: ChatQuestionRequest,
    background_tasks: BackgroundTasks
):
    start_time = time.time()
    
    try:
        if request.use_llm and llm_service.is_available():
            # Get document from session
            session = document_chatbot.sessions.get(request.session_id)
            if not session:
                raise HTTPException(status_code=404, detail="Session not found")
            
            # Use LLM for answer
            answer = llm_service.chat_with_llm(
                document_context=session["document_text"],
                question=request.question,
                language=request.language,
                conversation_history=session.get("conversation_history")
            )
            
            result = {
                "answer": answer,
                "confidence_score": 0.95,  # LLM answers are generally high confidence
                "relevant_context": session["document_text"][:500]
            }
        else:
            # Use existing semantic search method
            result = document_chatbot.answer_from_session(
                session_id=request.session_id,
                question=request.question
            )
        
        if "error" in result:
            raise HTTPException(status_code=400, detail=result["error"])
        
        processing_time = time.time() - start_time
        
        return ChatResponse(
            success=True,
            session_id=request.session_id,
            question=request.question,
            answer=result.get("answer", ""),
            confidence_score=result.get("confidence_score"),
            relevant_context=result.get("relevant_context"),
            processing_time=processing_time,
            timestamp=datetime.now().isoformat()
        )
        
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))