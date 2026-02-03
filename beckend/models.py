from sqlalchemy import Column, Integer, String
from database import Base

class Word(Base):
    __tablename__ = "words"

    id = Column(Integer, primary_key=True, index=True)
    uz = Column(String, index=True)
    en = Column(String, index=True)
    ru = Column(String, index=True)
