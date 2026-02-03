# Lug'at Backend (FastAPI)

Ushbu backend Python tilida FastAPI freymvorki yordamida yaratilgan. Unda 1000 dan ortiq so'zlar SQLite bazasida saqlanadi.

## O'rnatish va ishga tushirish

1. **Pythonni o'rnating** (agar yo'q bo'lsa).
2. **Kutubxonalarni o'rnating**:
   ```bash
   pip install -r requirements.txt
   ```
3. **Bazani yaratish va ma'lumotlarni yuklash**:
   ```bash
   python seed_data.py
   ```
4. **Serverni ishga tushirish**:
   ```bash
   uvicorn main:app --reload
   ```

## Funktsiyalar

- `GET /words`: So'zlar ro'yxati.
- `GET /search?q=...`: Qidiruv.
- `POST /words`: Yangi so'z qo'shish.
- `GET /test`: Tasodifiy test savoli.

## Maslahat
Server ishga tushgach, barcha endpointlarni `http://localhost:8000/docs` manzilida test qilishingiz mumkin.
