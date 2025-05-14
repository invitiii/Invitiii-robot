import pandas as pd
import gspread
from oauth2client.service_account import ServiceAccountCredentials
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, MessageHandler, filters
import asyncio
from datetime import datetime
import pytz
import os
import json
from keep_alive import keep_alive
from googleapiclient.discovery import build
from google.oauth2.service_account import Credentials
from math import radians, sin, cos, sqrt, atan2

# إعداد بيانات اعتماد Google من متغيرات البيئة
service_account_info = {
    "type": "service_account",
    "project_id": os.getenv("GOOGLE_PROJECT_ID"),
    "private_key_id": os.getenv("GOOGLE_PRIVATE_KEY_ID"),
    "private_key": os.getenv("GOOGLE_PRIVATE_KEY").replace('\\n', '\n'),
    "client_email": os.getenv("GOOGLE_CLIENT_EMAIL"),
    "client_id": os.getenv("GOOGLE_CLIENT_ID"),
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": os.getenv("GOOGLE_CLIENT_X509_CERT_URL")
}

scopes = ["https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/calendar"]
TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
GOOGLE_SHEET_NAME = "بيانات الحفل"
TIMEZONE = "Asia/Kuwait"

creds = Credentials.from_service_account_info(service_account_info, scopes=scopes)
gc = gspread.authorize(creds)
sheet = gc.open(GOOGLE_SHEET_NAME).sheet1
calendar_service = build("calendar", "v3", credentials=creds)

employee_df = pd.read_excel("attached_assets/قالب_الموظفين.xlsx")
employee_df["chat_id"] = employee_df["chat_id"].astype(str)

sent_employees = []
selected_employee = None

area_coords = {
    "مدينة الكويت": (29.3759, 47.9774), "السالمية": (29.3339, 48.0760), "حولي": (29.3322, 48.0280),
    "الجابرية": (29.3147, 48.0404), "الرميثية": (29.3113, 48.0747), "بيان": (29.3074, 48.0471),
    "مشرف": (29.2952, 48.0545), "سلوى": (29.2898, 48.0825), "الزهراء": (29.2881, 48.0512),
    "السلام": (29.2818, 48.0421), "حطين": (29.2825, 48.0332), "الشهداء": (29.2810, 48.0250),
    "الصديق": (29.2800, 48.0150), "العديلية": (29.3350, 47.9777), "الخالدية": (29.3086, 47.9583),
    "كيفان": (29.3461, 47.9569), "قرطبة": (29.3278, 47.9572), "اليرموك": (29.3400, 47.9700),
    "السرة": (29.3300, 47.9800), "الفيحاء": (29.3505, 47.9642), "الشامية": (29.3532, 47.9578),
    "الروضة": (29.3444, 47.9797), "العقيلة": (29.1457, 48.1304), "أبو حليفة": (29.1389, 48.1300),
    "الصباحية": (29.1459, 48.1166), "المنقف": (29.1326, 48.1286), "الفنطاس": (29.1705, 48.1219),
    "الرقة": (29.1200, 48.1500), "هدية": (29.1100, 48.1600), "العدان": (29.2810, 48.0250),
    "القصور": (29.2700, 48.0150), "القرين": (29.2600, 48.0050), "صباح السالم": (29.2500, 47.9950),
    "المسيلة": (29.2400, 47.9850), "المسايل": (29.2300, 47.9750)
}

def calculate_distance_km(coord1, coord2):
    R = 6371
    lat1, lon1 = map(radians, coord1)
    lat2, lon2 = map(radians, coord2)
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    global selected_employee, sent_employees

    msg = update.message.text.strip().lower()
    chat_id = str(update.effective_chat.id)
    user_name = update.effective_user.full_name
    if msg == "موافقة" and chat_id in sent_employees and selected_employee is None:
        selected_employee = chat_id
        await context.bot.send_message(chat_id=chat_id, text="✅ تم تأكيد مشاركتك في الحفل. شكراً على تعاونك.")
        for cid in sent_employees:
            if cid != chat_id:
                await context.bot.send_message(chat_id=cid, text="تم اختيار موظفة أخرى لهذا الحفل.")
        await add_event_to_calendar(user_name)
    elif selected_employee:
        await context.bot.send_message(chat_id=chat_id, text="تم بالفعل اختيار موظفة لهذا الحفل.")

async def add_event_to_calendar(employee_name):
    rows = sheet.get_all_records()
    latest_event = rows[-1]
    summary = latest_event['اسم الحفل']
    location = latest_event['اللوكيشن (اختياري)']
    description = f"نوع الحجز: {latest_event['نوع الحجز']} - موظفة: {employee_name}"
    date = latest_event['التاريخ']
    start_time = latest_event['الوقت من']
    end_time = latest_event['الوقت إلى']
    start_dt = pytz.timezone(TIMEZONE).localize(datetime.strptime(f"{date} {start_time}", "%Y-%m-%d %H:%M"))
    end_dt = pytz.timezone(TIMEZONE).localize(datetime.strptime(f"{date} {end_time}", "%Y-%m-%d %H:%M"))

    event = {
        "summary": summary,
        "location": location,
        "description": description,
        "start": {"dateTime": start_dt.isoformat(), "timeZone": TIMEZONE},
        "end": {"dateTime": end_dt.isoformat(), "timeZone": TIMEZONE},
    }
    calendar_service.events().insert(calendarId='primary', body=event).execute()

async def main():
    app = ApplicationBuilder().token(TELEGRAM_BOT_TOKEN).build()
    app.add_handler(MessageHandler(filters.TEXT, handle_message))
    rows = sheet.get_all_records()
    latest_event = rows[-1]
    target_area = latest_event['منطقة الحفل']

    global sent_employees
    sent_employees = []
    if target_area in area_coords:
        target_coord = area_coords[target_area]
        for _, row in employee_df.iterrows():
            emp_area = row["المنطقة"]
            if emp_area in area_coords:
                emp_coord = area_coords[emp_area]
                if calculate_distance_km(emp_coord, target_coord) <= 15:
                    sent_employees.append(str(row["chat_id"]))

    for cid in sent_employees:
       await app.bot.send_message(
    chat_id=cid,
    text=f"""يوجد حفل جديد في {target_area}.
هل أنتِ متاحة؟
الرجاء الرد بـ 'موافقة'."""
)


    await app.run_polling()

if __name__ == "__main__":
    import nest_asyncio
    nest_asyncio.apply()
    keep_alive()
    asyncio.get_event_loop().run_until_complete(main())
