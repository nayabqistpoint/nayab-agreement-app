import fitz  # PyMuPDF
from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import HTMLResponse, Response
from fastapi.middleware.cors import CORSMiddleware
import io
import os
import textwrap
import arabic_reshaper
from bidi.algorithm import get_display

app = FastAPI(title="Nayab Agreement PDF Overlay Engine")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def fix_urdu_line(text: str) -> str:
    """Urdu text ko reshape aur RTL theek karne ka function"""
    if not text.strip():
        return ""
    reshaper = arabic_reshaper.ArabicReshaper({
        'delete_harakat': False,
        'support_ligatures': True
    })
    reshaped = reshaper.reshape(text)
    return get_display(reshaped)

SAMPLE_TWO_PAGE_TEXT = """اقرار نامہ و معاہدہ بیع بالاقساط (نایاب قسط پوائنٹ حاصل پور)

منکہ ابوبکر روشن ولد محمد ایوب قوم کھاوڑ شناختی کارڈ نمبر 31203-1188884-3 ساکن قائم پور تحصیل حاصل پور ضلع بہاولپور کا مستقل رہائشی ہوں۔

1. یہ کہ میں نے نایاب قسط پوائنٹ حاصل پور سے ایک عدد اسمارٹ فون برانڈ ویوو ماڈل V2029 بمعہ اصلی چارجر، ڈبہ اور جملہ لوازمات کل طے شدہ رقم مبلغ 45,000 روپے میں باقاعدہ قسطوں پر خریدا ہے۔
2. یہ کہ میں نے پیشگی رقم (ایڈوانس) مبلغ 10,000 روپے موقع پر نقد ادا کر دی ہے جبکہ بقایا رقم مبلغ 35,000 روپے میں ہر ماہ کی 5 تاریخ کو ماہانہ قسط مبلغ 5,000 روپے نایاب قسط پوائنٹ کے کاؤنٹر پر جمع کروانے کا پابند رہوں گا۔
3. یہ کہ اقساط کی کل مدت 7 ماہ مقرر پائی ہے۔ اگر میں کسی بھی ماہ کی قسط مقررہ تاریخ تک ادا کرنے میں ناکام رہا تو دکاندار یا ادارہ کو مکمل قانونی حق حاصل ہوگا کہ وہ بقیہ تمام واجب الادا رقم یکمشت وصول کرے یا موبائل واپس تحویل میں لے۔
4. یہ کہ موبائل سیٹ میں دوران استعمال اگر کوئی تکنیکی خرابی پیش آئے تو اس کی ذمہ داری وارنٹی کارڈ کے مطابق متعلقہ کمپنی پر ہوگی اور دکان یا قسط کے معاملات پر اس کا کوئی اثر نہیں پڑے گا۔

شرائط و ضوابط برائے ضامن و قانونی چارہ جوئی:
5. یہ کہ ضامن مسمی محمد ایوب ولد غلام قادر شناختی کارڈ نمبر 31203-0000000-0 خریدار کے ہر قسم کے مالی معاملات اور بروقت اقساط کی ادائیگی کا مکمل ضامن و ذمہ دار ہے۔
6. خریدار یا ضامن کسی بھی قانونی تنازع کی صورت میں عدالت دیوانی یا فوجداری مجاز حاصل پور کے دائرہ اختیار کو تسلیم کریں گے۔
7. یہ تحریر بقائمی ہوش و حواس خمسہ، بلاتکلف و جبر اور روبرو گواہان درج کر کے دستخط و نشان انگوٹھا ثبت کر دیے ہیں تاکہ سند رہے اور بوقت ضرورت کام آئے۔

دستخط خریدار: ___________________        دستخط دکاندار: ___________________
نشان انگوٹھا خریدار: ___________________    دستخط ضامن: ___________________
گواہ نمبر 1: ___________________        گواہ نمبر 2: ___________________"""

@app.get("/", response_class=HTMLResponse)
async def upload_ui():
    return f"""
    <!DOCTYPE html>
    <html dir="rtl" lang="ur">
    <head>
        <meta charset="UTF-8">
        <title>نایاب ای-اسٹامپ پی ڈی ایف اوورلے</title>
        <style>
            body {{ font-family: 'Segoe UI', Tahoma, Arial, sans-serif; background: #f0f2f5; padding: 25px; display: flex; justify-content: center; }}
            .card {{ background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); width: 100%; max-width: 650px; }}
            h2 {{ color: #00796b; margin-top: 0; text-align: center; }}
            .field {{ margin-bottom: 18px; }}
            label {{ display: block; font-weight: bold; margin-bottom: 6px; color: #333; }}
            input[type="file"], textarea {{ width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 6px; box-sizing: border-box; }}
            textarea {{ height: 220px; font-size: 14px; line-height: 1.8; text-align: right; }}
            button {{ background: #00796b; color: white; border: none; padding: 12px 20px; font-size: 16px; font-weight: bold; border-radius: 6px; cursor: pointer; width: 100%; }}
            button:hover {{ background: #004d40; }}
            .note {{ font-size: 13px; color: #333; background: #e0f2f1; padding: 10px; border-radius: 6px; margin-top: 15px; line-height: 1.6; }}
        </style>
    </head>
    <body>
        <div class="card">
            <h2>ای-اسٹامپ اوورلے لائیو ٹیسٹر</h2>
            <form action="/merge-stamp" method="post" enctype="multipart/form-data" target="_blank">
                <div class="field">
                    <label>1. ای-اسٹامپ پی ڈی ایف فائل منتخب کریں:</label>
                    <input type="file" name="pdf_file" accept=".pdf" required />
                </div>
                <div class="field">
                    <label>2. معاہدے کی تحریر:</label>
                    <textarea name="agreement_text">{SAMPLE_TWO_PAGE_TEXT}</textarea>
                </div>
                <button type="submit">پی ڈی ایف اوورلے بنائیں 🚀</button>
            </form>
            <div class="note">
                • اوپر کالی لکیر سے فاصلہ بالکل درست ہے۔<br>
                • نیچے QR کوڈ تک صفحہ 1 مکمل طور پر بھرے گا۔
            </div>
        </div>
    </body>
    </html>
    """

def get_all_wrapped_lines(text: str, chars_per_line: int = 86):
    """Lines ko page width ke mutabiq wrap karne ka function"""
    all_lines = []
    paragraphs = text.strip().split("\n")
    for p in paragraphs:
        p_clean = p.strip()
        if not p_clean:
            all_lines.append("")
            continue
        wrapped = textwrap.wrap(p_clean, width=chars_per_line)
        for line in wrapped:
            all_lines.append(line)
        all_lines.append("")
    return all_lines

@app.post("/merge-stamp")
async def merge_stamp_overlay(
    pdf_file: UploadFile = File(...),
    agreement_text: str = Form(...)
):
    try:
        pdf_bytes = await pdf_file.read()
        doc = fitz.open(stream=pdf_bytes, filetype="pdf")

        font_path = "C:/Windows/Fonts/arial.ttf"
        if not os.path.exists(font_path):
            font_path = "C:/Windows/Fonts/segoeui.ttf"
        font_name = "UrduFont"
        font_obj = fitz.Font(fontfile=font_path)

        page1 = doc[0]
        p1_w = page1.rect.width
        p1_h = page1.rect.height

        right_margin = p1_w - 45.0

        # Exact Boundaries:
        # start_y_p1 = 360.0 (Kaali line se bilkul saaf neeche)
        # max_y_p1 = 705.0 (QR code ke theek upar tak poora space use karega)
        start_y_p1 = 360.0
        max_y_p1 = 705.0
        line_height = 16.5
        font_size = 10.5

        all_lines = get_all_wrapped_lines(agreement_text, chars_per_line=86)

        current_y = start_y_p1
        line_index = 0

        # Page 1 par likhai
        while line_index < len(all_lines) and current_y + line_height <= max_y_p1:
            line_str = all_lines[line_index]
            if line_str.strip():
                shaped = fix_urdu_line(line_str)
                text_width = font_obj.text_length(shaped, fontsize=font_size)
                start_x = right_margin - text_width
                page1.insert_text(
                    fitz.Point(start_x, current_y),
                    shaped,
                    fontname=font_name,
                    fontfile=font_path,
                    fontsize=font_size,
                    color=(0, 0, 0)
                )
                current_y += line_height
            else:
                current_y += 5.0
            line_index += 1

        # Page 2 par bachi hui lines likhna
        if line_index < len(all_lines):
            if len(doc) > 1:
                page2 = doc[1]
            else:
                page2 = doc.new_page(width=p1_w, height=p1_h)

            start_y_p2 = 65.0
            max_y_p2 = 910.0
            current_y_p2 = start_y_p2

            while line_index < len(all_lines) and current_y_p2 + line_height <= max_y_p2:
                line_str = all_lines[line_index]
                if line_str.strip():
                    shaped = fix_urdu_line(line_str)
                    text_width = font_obj.text_length(shaped, fontsize=font_size)
                    start_x = right_margin - text_width
                    page2.insert_text(
                        fitz.Point(start_x, current_y_p2),
                        shaped,
                        fontname=font_name,
                        fontfile=font_path,
                        fontsize=font_size,
                        color=(0, 0, 0)
                    )
                    current_y_p2 += line_height
                else:
                    current_y_p2 += 5.0
                line_index += 1

        out_buffer = io.BytesIO()
        doc.save(out_buffer)
        doc.close()
        out_buffer.seek(0)

        return Response(
            content=out_buffer.getvalue(),
            media_type="application/pdf",
            headers={"Content-Disposition": "inline; filename=stamp_agreement.pdf"}
        )

    except Exception as e:
        return HTMLResponse(
            content=f"<div dir='rtl' style='color:red; font-size:18px; padding:20px; font-family:sans-serif;'>"
                    f"<h3>پی ڈی ایف بنانے میں خرابی:</h3>"
                    f"<p>{str(e)}</p></div>",
            status_code=500
        )