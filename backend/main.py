from fastapi import FastAPI
from app.api.endpoints import documents
from app.api.endpoints import summarize
from app.api.endpoints import flashcards

app = FastAPI(title="DocuVerse API")

# Add your routes
app.include_router(documents.router, prefix="/api", tags=["Documents"]) # Document upload and parsing
app.include_router(summarize.router, prefix="/api", tags=["Summarize"]) # Text summarization
app.include_router(flashcards.router, prefix="/api") # Flashcard generation
