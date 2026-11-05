from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, JSONResponse
from google import genai
from google.genai import types
import fitz  # PyMuPDF
import json
import time

app = FastAPI(title="Nayab Automated Agreement Engine")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

GEMINI_API_KEY = "AQ.Ab8RN6I5BuUyUvljLuQxtsKCusKuWInRuz7NgOscUtvx7MyKlA"
client = genai.Client(api_key=GEMINI_API_KEY)

def get_live_working_models():
    """گوگل کے سرور سے براہ راست فعال ماڈلز کی تصدیق شدہ لسٹ لینا"""
    valid_models = []
    try:
        for model in client.models.list():
            name = model.name
            if name.startswith("models/"):
                name = name.replace("models/", "")
            
            # صرف وہی ماڈل چنیں جو ٹیکسٹ اور وژن کے ساتھ مواد بنا سکتے ہوں
            actions = getattr(model, "supported_actions", []) or getattr(model, "supported_generation_methods", [])
            if any("generateContent" in str(act) for act in actions):
                valid_models.append(name)
    except Exception as e:
        print(f"ماڈل لسٹ حاصل کرنے میں انتباہ: {e}")
    
    # ترجیحی ترتیب (نیا فلیش ماڈل سب سے اوپر)
    sorted_models = []
    for m in valid_models:
        if "3.8" in m:
            sorted_models.insert(0, m)
        elif "flash" in m.lower():
            sorted_models.append(m)
        else:
            sorted_models.append(m)
            
    # اگر لسٹ نہ ملے تو ڈیفالٹ 3.8 رکھیں
    return sorted_models if sorted_models else ["gemini-3.8-flash"]

AVAILABLE_MODELS = get_live_working_models()
print(f"آپ کی کی پر فعال ماڈلز کی تصدیق شدہ لسٹ: {AVAILABLE_MODELS}")

def auto_process_document(file_bytes, filename):
    image_parts = []
    
    if filename.endswith(".pdf"):
        doc = fitz.open(stream=file_bytes, filetype="pdf")
        for page in doc:
            pix = page.get_pixmap(dpi=130)
            img_bytes = pix.tobytes("jpeg")
            image_parts.append(
                types.Part.from_bytes(data=img_bytes, mime_type="image/jpeg")
            )
    else:
        image_parts.append(
            types.Part.from_bytes(data=file_bytes, mime_type="image/jpeg")
        )

    prompt = (
        "آپ ایک مکمل طور پر خودکار قانونی دستاویز کے تجزیہ کار اور ٹرانسکرائبر ہیں۔\n"
        "اس دستاویز کی تصاویر کو دیکھ کر درج ذیل دو چیزیں JSON فارمیٹ میں فراہم کریں:\n"
        "1. original_text: اصل دستاویز کا 100 فیصد ہو بہو، مکمل متن، لائن بائی لائن ترتیب کے ساتھ۔\n"
        "2. template_with_tags: وہی متن لیکن تمام متغیرات (جیسے نام، والد کا نام، قوم، پتہ، شناختی کارڈ، فون، رقم، تاریخ وغیرہ) کی جگہ واضح ڈائنامک ٹیگز (مثلاً {{applicant_name}}, {{applicant_cnic}} وغیرہ) لگا کر تیار کی گئی حتمی ٹیمپلیٹ۔\n\n"
        "جواب صرف اور صرف درست JSON فارمیٹ میں دیں:\n"
        "{\n"
        '  "original_text": "...",\n'
        '  "template_with_tags": "..."\n'
        "}"
    )

    last_error = None
    
    # صرف انہی ماڈلز کو کال جائے گی جو گوگل کے مطابق 100% فعال ہیں
    for model_name in AVAILABLE_MODELS:
        for attempt in range(2):
            try:
                response = client.models.generate_content(
                    model=model_name,
                    contents=[prompt, *image_parts],
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json"
                    )
                )
                if response.text:
                    return json.loads(response.text)
            except Exception as e:
                last_error = e
                time.sleep(2)
                continue

    raise Exception(f"پروسیسنگ فیل ہوئی: {last_error}")

HTML_PAGE = """<!DOCTYPE html>
<html lang="ur" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>نایاب ایگریمنٹ - خودکار انجن</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/earlyaccess/notonastaliqurdukasheeda.css">
    <style>
        @font-face {
            font-family: 'Jameel Noori Nastaleeq';
            src: local('Jameel Noori Nastaleeq');
        }
        body {
            background-color: #0f172a;
            margin: 0;
            padding: 25px;
            font-family: 'Jameel Noori Nastaleeq', 'Noto Nastaliq Urdu Kasheeda', serif;
            color: #f8fafc;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: #1e293b;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.5);
        }
        h1 { text-align: center; color: #38bdf8; font-size: 32px; margin-bottom: 20px; }
        .upload-box {
            border: 2px dashed #0284c7;
            background: #0f172a;
            padding: 25px;
            text-align: center;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        input[type="file"] { font-size: 16px; color: #cbd5e1; margin-bottom: 15px; }
        button {
            background-color: #0284c7;
            color: white;
            border: none;
            padding: 10px 30px;
            font-size: 20px;
            font-family: inherit;
            border-radius: 6px;
            cursor: pointer;
        }
        button:hover { background-color: #0369a1; }
        #loading { display: none; text-align: center; font-size: 20px; color: #f59e0b; margin: 15px 0; }
        .result-container { display: none; margin-top: 25px; }
        .box-title { font-size: 22px; color: #38bdf8; margin-bottom: 10px; }
        textarea {
            width: 100%;
            min-height: 350px;
            background: #ffffff;
            color: #000000;
            padding: 20px;
            border-radius: 8px;
            font-size: 20px;
            line-height: 2.2;
            box-sizing: border-box;
            direction: rtl;
            font-family: 'Jameel Noori Nastaleeq', serif;
            margin-bottom: 25px;
            white-space: pre-wrap;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>نایاب ایگریمنٹ - 100% خودکار ٹیمپلیٹ سسٹم</h1>
        <div class="upload-box">
            <input type="file" id="fileInput" accept="application/pdf,image/*"><br>
            <button onclick="autoProcess()">دستاویز خودکار طریقے سے تیار کریں</button>
        </div>
        <div id="loading">⚡ دستاویز پروسیس ہو رہی ہے، براہ کرم چند سیکنڈ انتظار کریں...</div>

        <div class="result-container" id="resultContainer">
            <div class="box-title">1. اصل مکمل متن (100% لائن بائی لائن):</div>
            <textarea id="originalText"></textarea>

            <div class="box-title">2. تیار شدہ ٹیمپلیٹ بمعہ ٹیگز (فلٹر ایپ کے لیے):</div>
            <textarea id="templateText"></textarea>
        </div>
    </div>

    <script>
        async function autoProcess() {
            const fileInput = document.getElementById('fileInput');
            const loading = document.getElementById('loading');
            const resultContainer = document.getElementById('resultContainer');
            const originalText = document.getElementById('originalText');
            const templateText = document.getElementById('templateText');

            if (!fileInput.files[0]) {
                alert("پہلے فائل منتخب کریں!");
                return;
            }

            const formData = new FormData();
            formData.append('file', fileInput.files[0]);

            loading.style.display = 'block';
            resultContainer.style.display = 'none';

            try {
                const res = await fetch('/auto-process-doc', {
                    method: 'POST',
                    body: formData
                });
                const data = await res.json();
                loading.style.display = 'none';

                if (data.status === 'success') {
                    resultContainer.style.display = 'block';
                    originalText.value = data.original_text;
                    templateText.value = data.template_with_tags;
                } else {
                    alert("خرابی: " + data.message);
                }
            } catch(e) {
                loading.style.display = 'none';
                alert("سرور سے رابطہ نہ ہو سکا: " + e);
            }
        }
    </script>
</body>
</html>"""

@app.get("/", response_class=HTMLResponse)
def home():
    return HTML_PAGE

@app.post("/auto-process-doc")
async def auto_process_doc(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        result = auto_process_document(contents, file.filename.lower())

        return {
            "status": "success",
            "filename": file.filename,
            "original_text": result.get("original_text", ""),
            "template_with_tags": result.get("template_with_tags", "")
        }
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": str(e)}
        )