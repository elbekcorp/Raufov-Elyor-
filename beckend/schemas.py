from pydantic import BaseModel, Field

class WordBase(BaseModel):
    uz: str = Field(..., alias="u")
    en: str = Field(..., alias="e")
    ru: str = Field(..., alias="r")

class WordCreate(BaseModel):
    uz: str
    en: str
    ru: str

class WordResponse(BaseModel):
    id: int = Field(..., alias="i")
    uz: str = Field(..., alias="u")
    en: str = Field(..., alias="e")
    ru: str = Field(..., alias="r")

    class Config:
        from_attributes = True
        populate_by_name = True
