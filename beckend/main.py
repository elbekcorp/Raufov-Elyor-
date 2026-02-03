from fastapi import FastAPI, Depends, HTTPException, Query, Request
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import ORJSONResponse
from fastapi.openapi.utils import get_openapi
from sqlalchemy.orm import Session
from typing import List
import models, schemas, database
from database import SessionLocal, engine
import random
import time

# Ma'lumotlar bazasini yaratish
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Lug'at API (Optimallashgan)",
    description="Ushbu API lug'at ilovasi uchun ma'lumotlarni tezkor va xavfsiz taqdim etadi.",
    version="2.1.0",
    default_response_class=ORJSONResponse
)

# CORS (Xavfsizlik va kirish uchun)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Gzip siqish (trafikni 80% gacha kamaytiradi)
app.add_middleware(GZipMiddleware, minimum_size=500)

# OpenAPI sxemasini optimallashtirish (ilova qotmasligi uchun)
def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    
    openapi_schema = get_openapi(
        title=app.title,
        version=app.version,
        description=app.description,
        routes=app.routes,
    )
    
    # Ortiqcha "HTTPValidationError" va "ValidationError" sxemalarini olib tashlash
    # Bu openapi.json hajmini keskin kamaytiradi
    if "components" in openapi_schema:
        components = openapi_schema["components"]
        if "schemas" in components:
            schemas_to_remove = ["HTTPValidationError", "ValidationError"]
            for schema_name in schemas_to_remove:
                if schema_name in components["schemas"]:
                    del components["schemas"][schema_name]
    
    # Marshrutlardan 422 xatolarini olib tashlash (sxema hajmini kichraytirish uchun)
    for path in openapi_schema["paths"].values():
        for method in path.values():
            if "responses" in method and "422" in method["responses"]:
                del method["responses"]["422"]
                
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi

# Middleware: So'rov vaqtini o'lchash
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/", summary="API holati")
def home():
    return {"status": "ok", "message": "Lug'at API optimallashtirildi va mukammal ishlamoqda."}

@app.get("/words", 
         response_model=List[schemas.WordResponse], 
         summary="Barcha so'zlar",
         description="Paginatsiya bilan so'zlar ro'yxati.")
def read_words(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    # Offset va limit orqali bazadan tezkor olish
    return db.query(models.Word).offset(skip).limit(limit).all()

@app.get("/search", 
         response_model=List[schemas.WordResponse], 
         summary="Qidiruv",
         description="O'zbek, ingliz yoki rus tillari bo'yicha tez qidiruv.")
def search_words(q: str = Query(..., min_length=1), db: Session = Depends(get_db)):
    return db.query(models.Word).filter(
        (models.Word.uz.contains(q)) | 
        (models.Word.en.contains(q)) | 
        (models.Word.ru.contains(q))
    ).limit(30).all() # Natijalarni 30 tagacha cheklash tezlikni oshiradi

@app.post("/words", 
          response_model=schemas.WordResponse, 
          summary="Yangisoz")
def create_word(word: schemas.WordCreate, db: Session = Depends(get_db)):
    db_word = models.Word(uz=word.uz, en=word.en, ru=word.ru)
    db.add(db_word)
    db.commit()
    db.refresh(db_word)
    return db_word

@app.get("/test", 
         response_model=schemas.WordResponse, 
         summary="Tasodifiy test")
def get_quiz_word(db: Session = Depends(get_db)):
    count = db.query(models.Word).count()
    if count == 0:
        raise HTTPException(status_code=404, detail="So'zlar topilmadi")
    random_index = random.randint(0, count - 1)
    return db.query(models.Word).offset(random_index).first()
