# مرجع کامل APIهای اپلیکیشن قرآن (Quran API Reference)

این سند شامل تمام اندپوینت‌های کاربردی و در دسترس برای توسعه بخش‌های مختلف اپلیکیشن قرآن کریم می‌باشد.

---

## ۱. AlQuran Cloud API
- **Base URL:** `https://api.alquran.cloud/v1`

| کاربرد | اندپوینت | مثال |
| :--- | :--- | :--- |
| **لیست همه ترجمه‌ها و قاریان** | `/edition` | `https://api.alquran.cloud/v1/edition` |
| **لیست ترجمه‌های یک زبان** | `/edition/language/{lang}` | `https://api.alquran.cloud/v1/edition/language/en` |
| **لیست سوره‌ها** | `/surah` | `https://api.alquran.cloud/v1/surah` |
| **گرفتن یک سوره کامل** | `/surah/{number}/{edition}` | `https://api.alquran.cloud/v1/surah/36/quran-uthmani` |
| **گرفتن یک آیه مشخص** | `/ayah/{surah}:{ayah}/{edition}` | `https://api.alquran.cloud/v1/ayah/2:255/en.sahih` |
| **جستجو در قرآن** | `/search/{keyword}/{surah یا all}/{edition}` | `https://api.alquran.cloud/v1/search/mercy/all/en.sahih` |
| **گرفتن یک جزء** | `/juz/{number}/{edition}` | `https://api.alquran.cloud/v1/juz/30/quran-uthmani` |
| **متادیتا (اطلاعات سجده‌ها و...)** | `/meta` | `https://api.alquran.cloud/v1/meta` |

---

## ۲. Fawaz Ahmed Quran API (CDN)
- **Base URL:** `https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1`

| کاربرد | اندپوینت | مثال |
| :--- | :--- | :--- |
| **لیست همه ترجمه‌ها** | `/editions.json` | `https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions.json` |
| **گرفتن یک ترجمه کامل** | `/editions/{editionName}.json` | `https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions/fas-ansarian.json` |
| **گرفتن یک سوره از ترجمه** | `/editions/{editionName}/{surahNumber}.json` | `https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions/fas-ansarian/36.json` |
| **لیست تفاسیر** | `/editions.json` | - |
| **تفسیر یک سوره** | `/editions/{editionSlug}/{surahNumber}.json` | - |
| **تفسیر یک آیه** | `/editions/{editionSlug}/{surahNumber}/{ayahNumber}.json` | - |

---

## ۳. Ummah API
- **Base URL:** `https://ummahapi.com/api`

| کاربرد | اندپوینت | مثال |
| :--- | :--- | :--- |
| **لیست سوره‌ها** | `/quran/surahs` | `https://ummahapi.com/api/quran/surahs` |
| **گرفتن یک سوره** | `/quran/surah/{number}` | `https://ummahapi.com/api/quran/surah/36` |
| **گرفتن یک آیه** | `/quran/surah/{number}/ayah/{ayah}` | `https://ummahapi.com/api/quran/surah/2/ayah/255` |
| **ترجمه کلمه به کلمه** | `/quran/words/{surah}/{ayah}` | `https://ummahapi.com/api/quran/words/1/1` |
| **تفسیر (مانند ابن کثیر)** | `/tafsir/{tafsir}/surah/{surah}/ayah/{ayah}` | `https://ummahapi.com/api/quran/tafsir/ibn_kathir/surah/2/ayah/255` |
| **جستجوی کلمات** | `/quran/search?q={query}` | `https://ummahapi.com/api/quran/search?q=رحمت` |
| **لیست قاریان** | `/quran/reciters` | `https://ummahapi.com/api/quran/reciters` |
| **صوت یک آیه** | `/quran/audio/{surah}/{ayah}` | `https://ummahapi.com/api/quran/audio/36/1` |
| **آیه تصادفی (آیه روز)** | `/quran/random` | `https://ummahapi.com/api/quran/random` |

---

## 🎯 پیشنهادهای فوق‌العاده کاربردی برای فیچرهای بعدی اپلیکیشن:

1. **کلمه به کلمه (Word-by-Word Translation) 💡:**
   - اندپوینت: `/quran/words/{surah}/{ayah}` از Ummah API
   - **کاربرد:** امکان کلیک روی هر کلمه آیه برای مشاهده معنی دقیقا همان کلمه به فارسی/انگلیسی.

2. **تفسیر آیه (Tafsir View) 📚:**
   - اندپوینت: `/tafsir/{tafsir}/surah/{surah}/ayah/{ayah}` از Ummah API یا Fawaz Ahmed API
   - **کاربرد:** افزوده شدن یک تب «تفسیر» ذیل هر آیه برای مطالعه تفسیر انصاریان یا نمونه.

3. **آیه تصادفی مستقیم (Random Ayah Endpoint) 🎲:**
   - اندپوینت: `https://ummahapi.com/api/quran/random`
   - **کاربرد:** دریافت آیه روز مستقیم از این اندپوینت بدون نیاز به محاسبات دستی شماره آیه در کلاینت.

4. **تغییر قاری (Reciter Selection) 🎧:**
   - اندپوینت: `/quran/reciters` از Ummah API یا `/edition` از AlQuran Cloud
   - **کاربرد:** امکان انتخاب قاری محبوب (المنشاوی، پرهیزگار، العفاسی، الحصری) در تنظیمات برنامه.
