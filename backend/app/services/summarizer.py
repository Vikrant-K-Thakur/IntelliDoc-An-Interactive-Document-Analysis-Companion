from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from transformers import pipeline

router = APIRouter()

# summarizer = pipeline("summarization", model="sshleifer/distilbart-cnn-12-6")
summarizer = pipeline("summarization", model="facebook/bart-large-cnn")

class SummarizeRequest(BaseModel):
    text: str
    num_sentences: int = 5

@router.post("/api/summarize/")
def summarize(req: SummarizeRequest):
    try:
        if len(req.text) > 2000:
            req.text = req.text[:2000]

        result = summarizer(req.text, max_length=req.num_sentences * 20, min_length=req.num_sentences * 10, do_sample=False)
        return {"summary": result[0]['summary_text']}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
