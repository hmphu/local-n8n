@echo off
REM Open N8N Web Interface
REM This batch file opens N8N at http://localhost:5678 in the default browser

echo Opening N8N Workflow Automation Tool...
echo URL: http://localhost:5678/

REM Check if N8N is running by attempting to connect
echo Checking if N8N is running...
curl -s --connect-timeout 5 http://localhost:5678/ >nul 2>&1
if errorlevel 1 (
    echo.
    echo [WARNING] N8N does not appear to be running!
    echo Please start N8N first:
    echo   - Run: setup.bat start
    echo   - Or:  setup.ps1 start
    echo   - Or:  python setup.py start
    echo.
    set /p "proceed=Open browser anyway? (y/N): "
    if /i not "!proceed!"=="y" (
        echo Cancelled.
        pause
        exit /b 1
    )
)

REM Open the URL in the default browser
start "" "http://localhost:5678/"

echo.
echo N8N should now open in your default browser.
echo If it doesn't open automatically, navigate to: http://localhost:5678/
echo.
echo Press any key to exit...
pause >nul
