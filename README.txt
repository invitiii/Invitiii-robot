خطوات التشغيل الآمن للبوت باستخدام Render و Google Cloud:

1. أنشئ Google Service Account جديد من Google Cloud Console.
2. احفظ بيانات JSON، لكن لا ترفعها على GitHub.
3. حول محتوى JSON إلى متغيرات بيئة (Environment Variables).
4. ارفع الملفات في هذا المشروع إلى GitHub.
5. اربط GitHub بـ Render.com.
6. أنشئ Web Service جديدة وحدد start command: python main.py
7. تأكد من أن المتغيرات مضافة في إعدادات الخدمة بـ Render.
