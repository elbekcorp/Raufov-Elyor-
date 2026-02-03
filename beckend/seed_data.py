
import json
from sqlalchemy.orm import Session
from database import SessionLocal, engine
import models

def seed():
    # Jadvallarni yaratish
    models.Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    # Eskilarini o'chirish (to'liq yangilash uchun)
    print("Eski ma'lumotlar o'chirilmoqda...")
    db.query(models.Word).delete()
    db.commit()

    try:
        # Yangi words.json faylidan yuklash
        words_file = '../mobil/assets/data/words.json'
        with open(words_file, 'r', encoding='utf-8') as f:
            words_data = json.load(f)
        
        print(f"{len(words_data)} ta so'z bazaga qo'shilmoqda...")
        for item in words_data:
            # Word modelidagi fieldlar: uz, en, ru
            db_word = models.Word(uz=item['uz'], en=item['en'], ru=item['ru'])
            db.add(db_word)
        
        db.commit()
        print(f"Muvaffaqiyatli {len(words_data)} ta so'z bazaga yuklandi.")
    except Exception as e:
        print(f"Xato yuz berdi: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed()
