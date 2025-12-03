from fastapi import FastAPI
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

from app.api.endpoints import documents, flashcards, summarize

app.include_router(documents.router, prefix="/api", tags=["Documents"])
app.include_router(flashcards.router, prefix="/api", tags=["Flashcards"])
app.include_router(summarize.router, prefix="/api", tags=["Summarize"])

@app.get("/")
def root():
    return {"message": "IntelliDoc API", "status": "running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
