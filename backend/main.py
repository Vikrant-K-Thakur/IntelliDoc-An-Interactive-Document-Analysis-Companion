from fastapi import FastAPI
<<<<<<< HEAD
from app.api.endpoints import documents
from app.api.endpoints import summarize
from app.api.endpoints import flashcards

app = FastAPI(title="DocuVerse API")

# Add your routes
app.include_router(documents.router, prefix="/api", tags=["Documents"]) # Document upload and parsing
app.include_router(summarize.router, prefix="/api", tags=["Summarize"]) # Text summarization
app.include_router(flashcards.router, prefix="/api") # Flashcard generation
=======
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
load_dotenv()
app = FastAPI(title="IntelliDoc API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Import only what we know works
from app.api.endpoints import documents, flashcards

app.include_router(documents.router, prefix="/api", tags=["Documents"])
app.include_router(flashcards.router, prefix="/api", tags=["Flashcards"])

@app.get("/")
def root():
    return {"message": "IntelliDoc API", "status": "running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
>>>>>>> 17955a8 (Updated project)
