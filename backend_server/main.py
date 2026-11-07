import os
import base64
import traceback
from fastapi import FastAPI, HTTPException
from fastapi.responses import Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
from playwright.async_api import async_playwright
import pymupdf

app = FastAPI(title="Nayab Agreement WYSIWYG Engine")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FONT_FILE = os.path.join(BASE_DIR, "Jameel.ttf")
if not os.path.exists(FONT_FILE):
    FONT_FILE = os.path.join(BASE_DIR, "jameel.ttf")

FONT_BASE64 = ""
if os.path.exists(FONT_FILE):
    with open(FONT_FILE, "rb") as f:
        FONT_BASE64 = base64.b64encode(f.read()).decode("utf-8")
    print(f"✅ Jameel Font loaded ({len(FONT_BASE64)} bytes)")

class SmartPrintRequest(BaseModel):
    body_html: str
    font_size: float = 13.5
    line_height: float = 2.0
    paper_size: str = "Legal"
    top_margin: float = 320.0
    subsequent_top_margin: float = 65.0
    bottom_margin: float = 270.0
    side_margin: float = 40.0
    stamp_pdf_base64: Optional[str] = None

@app.post("/generate-pdf")
async def generate_pdf(req: SmartPrintRequest):
    print("\n================== [WYSIWYG پروسیسنگ شروع] ==================")
    print(f"کاغذ: {req.paper_size} | فونٹ سائز: {req.font_size}pt | لائن ہائٹ: {req.line_height}")

    try:
        # پوائنٹس کو راؤنڈ کر کے پی ڈی ایف کے معیاری پوائنٹس (pt) میں لاک کرنا
        p1_top = f"{round(req.top_margin)}pt"
        sub_top = f"{round(req.subsequent_top_margin)}pt"
        bot_m = f"{round(req.bottom_margin)}pt"
        side_m = f"{round(req.side_margin)}pt"

        # فلٹر کے عین مطابق HTML پیج بنانا
        full_html = f"""<!DOCTYPE html>
<html dir="rtl" lang="ur">
<head>
<meta charset="utf-8">
<style>
@font-face {{
    font-family: 'JameelNoori';
    src: url('data:font/truetype;charset=utf-8;base64,{FONT_BASE64}') format('truetype');
}}

@page :first {{
    margin-top: {p1_top};
    margin-bottom: {bot_m};
    margin-left: {side_m};
    margin-right: {side_m};
}}

@page {{
    margin-top: {sub_top};
    margin-bottom: {bot_m};
    margin-left: {side_m};
    margin-right: {side_m};
}}

body {{
    font-family: 'JameelNoori', 'Urdu Typesetting', sans-serif;
    direction: rtl;
    text-align: justify;
    text-justify: inter-word;
    font-size: {req.font_size}pt;
    line-height: {req.line_height};
    color: #000000;
    margin: 0;
    padding: 0;
    background: transparent !important;
}}

p {{
    margin: 0 0 6px 0;
}}

b, strong {{
    font-weight: bold;
}}

u {{
    text-decoration: underline;
}}

.spacer {{
    height: 14px;
}}
</style>
</head>
<body>
{req.body_html}
</body>
</html>"""

        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=True)
            page = await browser.new_page()
            await page.set_content(full_html, wait_until="networkidle")

            # پی ڈی ایف کی درست پیمائش
            w_in = "8.5in"
            h_in = "14in" if req.paper_size.lower() == "legal" else "11.69in"

            text_pdf_bytes = await page.pdf(
                width=w_in,
                height=h_in,
                print_background=False
            )
            await browser.close()

        # اصل اسٹامپ کے ساتھ اوورلے
        if req.stamp_pdf_base64 and len(req.stamp_pdf_base64) > 100:
            stamp_bytes = base64.b64decode(req.stamp_pdf_base64)
            stamp_doc = pymupdf.open(stream=stamp_bytes, filetype="pdf")
            text_doc = pymupdf.open(stream=text_pdf_bytes, filetype="pdf")

            final_doc = pymupdf.open()
            for i in range(len(text_doc)):
                if i < len(stamp_doc):
                    page = final_doc.new_page(width=stamp_doc[i].rect.width, height=stamp_doc[i].rect.height)
                    page.show_pdf_page(page.rect, stamp_doc, i)
                else:
                    page = final_doc.new_page(width=text_doc[i].rect.width, height=text_doc[i].rect.height)

                page.show_pdf_page(page.rect, text_doc, i)

            final_bytes = final_doc.tobytes()
            stamp_doc.close()
            text_doc.close()
            final_doc.close()
            print("✅ فلٹر کی مکمل کسٹمائزیشن کے ساتھ اوورلے پی ڈی ایف تیار ہو گئی!")
            return Response(content=final_bytes, media_type="application/pdf")

        return Response(content=text_pdf_bytes, media_type="application/pdf")

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)