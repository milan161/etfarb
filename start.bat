@echo off
title ETFarb Dashboard Launcher

set "PROJ_DIR=%~dp0"
set "PROJ_DIR=%PROJ_DIR:~0,-1%"
set "BACKEND=%PROJ_DIR%\src\backend"

:: [AI-2026-10-06] 单一真库 = _shared/arb_master.db（与 LOFarb 一致）。显式指定，与 ETFarb core/db.py 回退一致。
:: %PROJ_DIR%=.../ETFarb，上一层到 ARB 根。
set "ARB_MASTER_DB=%PROJ_DIR%\..\_shared\arb_master.db"
set "DATA_DIR=%PROJ_DIR%\data"
set "LOG_DIR=%PROJ_DIR%\log"
set "PYTHON=C:\Users\milan\AppData\Local\Programs\Python\Python311\python.exe"
set "NO_PROXY=127.0.0.1,localhost,*.local"
if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo ========================================
echo  Starting ETFarb Dashboard (port 8102)...
echo ========================================

powershell -NoProfile -Command "foreach($p in @(8101,8102)){ Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue } }"
powershell -NoProfile -Command "for($i=0;$i -lt 10;$i++){ if(-not (Get-NetTCPConnection -LocalPort 8102 -State Listen -ErrorAction SilentlyContinue)){ break }; Start-Sleep -Seconds 1 }"

echo [1/1] Starting Backend (port 8102)...
start "ETFarb Backend" cmd /k "cd /d %BACKEND% && set NO_PROXY=127.0.0.1,localhost,*.local && %PYTHON% app.py"

echo Waiting 4 seconds for backend to be ready...
timeout /t 4 /nobreak > nul

echo [2/2] Opening browser...
start http://127.0.0.1:8102

echo.
echo ========================================
echo  ETFarb Dashboard: http://127.0.0.1:8102
echo  Log: %LOG_DIR%\server.log
echo ========================================
pause
