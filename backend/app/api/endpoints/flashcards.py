
import time
import logging
import uuid
from typing import Optional, List
from enum import Enum
from fastapi import APIRouter, HTTPException, BackgroundTasks, Request, Depends
from pydantic import BaseModel, Field
from app.services.qna_generator import generate_flashcards 
from app.services.llm_service import llm_service

# Configure logging
logger = logging.getLogger(__name__)
router = APIRouter()

# Enums for better type safety
# Removed DifficultyLevel enum - simplified version

class FlashcardType(str, Enum):
    QA = "question_answer"
    FILL_BLANK = "fill_in_blank"
    TRUE_FALSE = "true_false"
    DEFINITION = "definition"

# Request Models
class FlashcardRequest(BaseModel):
    text: str = Field(..., min_length=50, max_length=100000)
    num_cards: Optional[int] = Field(default=10, ge=1, le=50)
    card_type: Optional[FlashcardType] = Field(default=FlashcardType.QA)
    focus_topics: Optional[List[str]] = Field(default=None)
    language: Optional[str] = Field(default="english")
    use_llm: Optional[bool] = Field(default=False, description="Use LLM for generation")  # NEW
    difficulty: Optional[str] = Field(default=None)  # NEW

class PreviewRequest(BaseModel):
    text: str = Field(..., min_length=20, max_length=1000, description="Text for preview")
    num_cards: Optional[int] = Field(default=3, ge=1, le=5, description="Number of preview cards")

# Response Models
class Flashcard(BaseModel):
    id: str
    question: str
    answer: str
    topic: Optional[str] = None
    card_type: str
    hint: Optional[str] = None

class FlashcardResponse(BaseModel):
    flashcards: List[Flashcard]
    total_cards: int
    card_type: str
    source_text_length: int
    generation_time: Optional[float] = None
    message: str

class PreviewResponse(BaseModel):
    preview_cards: List[Flashcard]
    total_preview: int
    message: str

class BatchRequest(BaseModel):
    requests: List[FlashcardRequest] = Field(..., max_items=10, description="List of flashcard requests")

class BatchResponse(BaseModel):
    results: List[dict]
    total_processed: int
    successful: int
    failed: int

# Helper Functions
def validate_text_content(text: str) -> str:
    """Validate and clean text content"""
    if not text or not text.strip():
        raise ValueError("Text cannot be empty")
    
    cleaned_text = text.strip()
    
    if len(cleaned_text) < 50:
        raise ValueError("Text too short. Please provide at least 50 characters.")
    
    if len(cleaned_text) > 100000:
        raise ValueError("Text too long. Maximum 100,000 characters allowed.")
    
    return cleaned_text

async def generate_flashcard_data(
    text: str,
    num_cards: int = 10,
    card_type: str = "question_answer",
    focus_topics: Optional[List[str]] = None,
    language: str = "english"
) -> List[Flashcard]:
    """Enhanced wrapper for flashcard generation"""
    try:
        # Call your existing service
        raw_flashcards = generate_flashcards(
            text=text,
            num_cards=num_cards,
            card_type=card_type,
            focus_topics=focus_topics,
            language=language
        )
        
        # Convert to structured format
        structured_flashcards = []
        for i, card in enumerate(raw_flashcards):
            if isinstance(card, dict):
                flashcard = Flashcard(
                    id=str(uuid.uuid4()),
                    question=card.get("question", ""),
                    answer=card.get("answer", ""),
                    topic=card.get("topic"),
                    card_type=card_type,
                    hint=card.get("hint")
                )
            else:
                # Handle if service returns simple format
                flashcard = Flashcard(
                    id=str(uuid.uuid4()),
                    question=card.get("question") if hasattr(card, 'get') else str(card),
                    answer=card.get("answer") if hasattr(card, 'get') else "",
                    topic=None,
                    card_type=card_type,
                    hint=None
                )
            structured_flashcards.append(flashcard)
        
        return structured_flashcards
    
    except Exception as e:
        logger.error(f"Error in flashcard generation: {str(e)}")
        raise

async def log_flashcard_analytics(
    text_length: int, 
    num_cards: int, 
    generation_time: float,
    card_type: str
):
    """Background task for logging analytics"""
    logger.info(
        f"Flashcard Analytics - Cards: {num_cards}, Text Length: {text_length}, "
        f"Time: {generation_time:.2f}s, Type: {card_type}"
    )



@router.post("/flashcards/preview/", response_model=PreviewResponse)
async def preview_flashcards(data: PreviewRequest):
    """Generate a preview of flashcards from text"""
    try:
        # Limit text for preview
        preview_text = data.text[:1000] if len(data.text) > 1000 else data.text
        
        flashcards =await  generate_flashcard_data(
            text=preview_text,
            num_cards=min(data.num_cards, 5),
            card_type="question_answer"
        )
        
        return PreviewResponse(
            preview_cards=flashcards,
            total_preview=len(flashcards),
            message="Preview flashcards generated successfully"
        )
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error generating preview: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to generate preview")

@router.post("/flashcards/batch/", response_model=BatchResponse)
async def generate_flashcards_batch(data: BatchRequest):
    """Generate flashcards for multiple texts in batch"""
    if len(data.requests) > 10:
        raise HTTPException(status_code=400, detail="Maximum 10 requests per batch")
    
    results = []
    successful = 0
    failed = 0
    
    for i, request in enumerate(data.requests):
        try:
            # Validate each request
            cleaned_text = validate_text_content(request.text)
            
            flashcards = await generate_flashcard_data(
                text=cleaned_text,
                num_cards=request.num_cards,
                card_type=request.card_type.value,
                focus_topics=request.focus_topics,
                language=request.language
            )
            
            results.append({
                "index": i,
                "success": True,
                "flashcards": [card.dict() for card in flashcards],
                "total_cards": len(flashcards)
            })
            successful += 1
            
        except Exception as e:
            results.append({
                "index": i,
                "success": False,
                "error": str(e),
                "flashcards": []
            })
            failed += 1
            logger.error(f"Batch request {i} failed: {str(e)}")
    
    return BatchResponse(
        results=results,
        total_processed=len(data.requests),
        successful=successful,
        failed=failed
    )

@router.get("/flashcards/types/")
async def get_flashcard_types():
    """Get available flashcard types and difficulties"""
    return {
        "card_types": [
            {"value": "question_answer", "label": "Question & Answer"},
            {"value": "fill_in_blank", "label": "Fill in the Blank"},
            {"value": "true_false", "label": "True/False"},
            {"value": "definition", "label": "Definition"}
        ],
        "supported_languages": ["english", "spanish", "french", "german", "italian"]
    }

@router.get("/flashcards/stats/")
async def get_flashcard_stats():
    """Get statistics about flashcard generation"""
    # This would typically come from your database
    return {
        "total_flashcards_generated": 0,  # Implement actual counting
        "most_popular_type": "question_answer",
        "average_generation_time": 2.5,
        "supported_file_types": ["pdf", "docx", "txt"],
        "max_text_length": 100000,
        "max_flashcards_per_request": 50
    }

# Health check endpoint
@router.get("/flashcards/health/")
async def health_check():
    """Health check for flashcards service"""
    return {
        "status": "healthy",
        "service": "flashcards",
        "timestamp": time.time(),
        "version": "1.0.0"
    }
@router.post("/flashcards/test/")
async def test_flashcards(data: FlashcardRequest):
    try:
        # Mock response for testing
        mock_flashcards = [
            {
                "id": str(uuid.uuid4()),
                "question": "Test question?",
                "answer": "Test answer",
                "topic": "test",
                "card_type": "question_answer",
                "hint": None
            }
        ]
        
        return {
            "flashcards": mock_flashcards,
            "total_cards": 1,
            "message": "Test successful"
        }
    except Exception as e:
        return {"error": str(e)}
    
    
    


@router.post("/flashcards/", response_model=FlashcardResponse)
async def generate_flashcards_endpoint(
    data: FlashcardRequest,
    background_tasks: BackgroundTasks
):
    start_time = time.time()
    
    try:
        cleaned_text = validate_text_content(data.text)
        
        # Check if user wants LLM-powered generation
        if data.use_llm and llm_service.is_available():
            logger.info(f"Using LLM for flashcard generation in {data.language}")
            
            # Use LLM service
            raw_flashcards = llm_service.generate_flashcards_with_llm(
                text=cleaned_text,
                num_cards=data.num_cards,
                card_type=data.card_type.value,
                language=data.language,
                difficulty=data.difficulty
            )
            
            # Convert to Flashcard models
            flashcards = []
            for card in raw_flashcards:
                flashcards.append(Flashcard(
                    id=str(uuid.uuid4()),
                    question=card.get("question", ""),
                    answer=card.get("answer", ""),
                    topic=card.get("topic"),
                    card_type=data.card_type.value,
                    hint=card.get("hint")
                ))
        else:
            # Use existing transformer-based generation
            logger.info(f"Using transformers for flashcard generation")
            flashcards = await generate_flashcard_data(
                text=cleaned_text,
                num_cards=data.num_cards,
                card_type=data.card_type.value,
                focus_topics=data.focus_topics,
                language=data.language
            )
        
        processing_time = time.time() - start_time
        
        return FlashcardResponse(
            flashcards=flashcards,
            total_cards=len(flashcards),
            card_type=data.card_type.value,
            source_text_length=len(cleaned_text),
            generation_time=round(processing_time, 2),
            message="Flashcards generated successfully" + (" using LLM" if data.use_llm else "")
        )
        
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

