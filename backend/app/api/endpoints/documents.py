import os
import shutil
import uuid
from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from app.services.document_parser import extract_text


router = APIRouter()

UPLOAD_DIR = "temp_uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)










@router.post("/upload_file/")
async def upload_file(file: UploadFile = File(...)):
    # 1. Validate file type
    filename = file.filename
    file_ext = filename.split(".")[-1].lower()
    if file_ext not in ["pdf", "docx", "txt"]:
        raise HTTPException(status_code=400, detail="Unsupported file type. Allowed: .pdf, .docx, .txt")

    # 2. Save file temporarily
    unique_id = str(uuid.uuid4())
    temp_path = os.path.join(UPLOAD_DIR, f"{unique_id}.{file_ext}")
    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # 3. Extract text
    try:
        extracted_text = extract_text(temp_path, file_ext)
    except Exception as e:
        os.remove(temp_path)
        raise HTTPException(status_code=500, detail=f"Failed to parse document: {str(e)}")

    # 4. Optionally delete file after processing
    os.remove(temp_path)

    # 5. Return result
    return JSONResponse({
        "filename": filename,
        "extracted_text": extracted_text,  
        "message": "File uploaded and parsed successfully."
    })
