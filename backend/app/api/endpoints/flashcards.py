from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.qna_generator import generate_flashcards

router = APIRouter()

class FlashcardRequest(BaseModel):
    text: str

@router.post("/flashcards/")
def get_flashcards(data: FlashcardRequest):
    try:
        flashcards = generate_flashcards(data.text)
        return {"flashcards": flashcards}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
