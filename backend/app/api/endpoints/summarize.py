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
     