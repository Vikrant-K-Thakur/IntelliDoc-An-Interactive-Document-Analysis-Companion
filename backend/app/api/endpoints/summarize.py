<<<<<<< HEAD
from pydantic import BaseModel
from fastapi import APIRouter
from app.services import summarizer as summarizer_service 

router = APIRouter()

class SummarizeRequest(BaseModel):
    text: str
    num_sentences: int = 5

@router.post("/summarize/") 
def summarize(req: SummarizeRequest):
    return summarizer_service.summarize(req)
     
=======
from pydantic import BaseModel, Field
from fastapi import APIRouter, HTTPException
from app.services import summarizer2 as summarizer_service
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

class SummarizeRequest(BaseModel):
    text: str = Field(..., min_length=100, max_length=15000)
    num_sentences: int = Field(default=5, ge=1, le=10)
    profession: str = Field(default="general reader")  # ADDED
    purpose: str = Field(default="overview")  # ADDED
    document_type: str = Field(default="auto")  # ADDED

class SummarizeResponse(BaseModel):
    success: bool
    original_text_length: int
    summary: str
    summary_length: int
    num_sentences: int
    message: str

@router.post("/summarize/", response_model=SummarizeResponse)
def summarize(req: SummarizeRequest):
    """
    Summarize text with contextual awareness.
    """
    try:
        logger.info(f"Summarizing text of length {len(req.text)}")
        
        # Call the module-level function
        summary = summarizer_service.summarize(
            text=req.text,
            num_sentences=req.num_sentences,
            profession=req.profession,
            purpose=req.purpose,
            document_type=req.document_type
        )
        
        if not summary:
            raise HTTPException(status_code=500, detail="Failed to generate summary")
        
        return SummarizeResponse(
            success=True,
            original_text_length=len(req.text),
            summary=summary,
            summary_length=len(summary),
            num_sentences=req.num_sentences,
            message="Summary generated successfully"
        )
        
    except ValueError as e:
        logger.warning(f"Validation error: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to generate summary: {str(e)}")
>>>>>>> 17955a8 (Updated project)
