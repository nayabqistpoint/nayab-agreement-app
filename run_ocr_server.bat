@echo off
title Nayab Agreement OCR Server
echo ===================================================
echo     Nayab Agreement App - Local OCR Server
echo ===================================================
echo.

cd /d "%~dp0backend_server"

if not exist "venv\Scripts\activate.bat" (
    echo [ERROR] Virtual Environment nahi mila!
    echo Folder check karein: backend_server\venv
    pause
    exit /b
)

echo Virtual Environment ko activate kiya ja raha hai...
call venv\Scripts\activate.bat

echo.
echo OCR Server shuru ho raha hai (Port: 8000)...
echo Band karne ke liye Ctrl + C dabayein.
echo.

uvicorn main:app --reload --host 0.0.0.0 --port 8000
pause