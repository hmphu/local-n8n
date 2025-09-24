@echo off
REM N8N Docker Setup and Management Script for Windows
REM Usage: setup.bat [setup|start|stop|status|logs|backup|env]

setlocal enabledelayedexpansion

if "%1"=="" (
    echo Usage: setup.bat [setup^|start^|stop^|status^|logs^|backup^|env]
    echo.
    echo Commands:
    echo   setup  - Initial setup with environment file creation
    echo   start  - Start all services
    echo   stop   - Stop all services
    echo   status - Show service status
    echo   logs   - Show service logs
    echo   backup - Create database backup
    echo   env    - Create/recreate environment file
    exit /b 1
)

REM Function to detect Docker Compose command
set COMPOSE_CMD=
echo Checking Docker Desktop...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running or not installed.
    echo Please install Docker Desktop and make sure it's running.
    echo Download from: https://www.docker.com/products/docker-desktop
    exit /b 1
)

REM Try docker-compose first (standalone version)
docker-compose --version >nul 2>&1
if not errorlevel 1 (
    set COMPOSE_CMD=docker-compose
    echo [OK] Docker Desktop is available (using 'docker-compose')
) else (
    REM Try docker compose (integrated version)
    docker compose version >nul 2>&1
    if not errorlevel 1 (
        set COMPOSE_CMD=docker compose
        echo [OK] Docker Desktop is available (using 'docker compose')
    ) else (
        echo [ERROR] Docker Compose is not available.
        echo Please make sure Docker Desktop is properly installed.
        exit /b 1
    )
)

if "%1"=="setup" (
    echo.
    echo [SETUP] Setting up N8N Docker environment for Windows...
    
    REM Create directories
    echo [SETUP] Creating required directories...
    if not exist "custom-nodes" mkdir custom-nodes
    if not exist "backups" mkdir backups
    if not exist "workflows" mkdir workflows
    if not exist "workflows\production" mkdir workflows\production
    if not exist "workflows\development" mkdir workflows\development
    if not exist "workflows\templates" mkdir workflows\templates
    if not exist "init-scripts" mkdir init-scripts
    
    REM Check if .env exists
    if exist ".env" (
        set /p "overwrite=.env file already exists. Overwrite? (y/N): "
        if /i not "!overwrite!"=="y" (
            echo Skipping .env file creation.
            goto :setup_complete
        )
    )
    
    REM Use Python to generate secure passwords if available
    python --version >nul 2>&1
    if not errorlevel 1 (
        echo [SETUP] Using Python to generate secure passwords and database script...
        python setup.py env
    ) else (
        echo [SETUP] Python not found. Creating .env file with placeholder passwords...
        echo Please edit .env file manually and replace placeholder passwords.
        copy env.template .env >nul
        echo [WARNING] Database initialization script will not be generated automatically.
    )
    
    :setup_complete
    echo.
    echo [OK] Setup complete! Next steps:
    echo 1. Review the .env file and adjust settings if needed
    echo 2. Run: setup.bat start
    
) else if "%1"=="start" (
    echo.
    echo [START] Starting N8N services...
    
    if not exist ".env" (
        echo [ERROR] .env file not found. Run 'setup.bat setup' first.
        exit /b 1
    )
    
    REM Generate SQL file before starting services
    python --version >nul 2>&1
    if not errorlevel 1 (
        echo [SETUP] Generating database initialization script...
        python -c "import sys; sys.path.append('.'); from setup import generate_init_sql; generate_init_sql()"
    ) else (
        echo [WARNING] Python not found. Database initialization script will not be generated.
        echo [WARNING] Please ensure init-scripts\init-user.sql exists with correct credentials.
    )
    
    %COMPOSE_CMD% up -d
    if not errorlevel 1 (
        echo.
        echo [OK] Services started successfully!
        echo [INFO] N8N is available at: http://localhost:5678
        echo [INFO] Use 'setup.bat logs' to view service logs
    )
    
) else if "%1"=="stop" (
    echo.
    echo [STOP] Stopping N8N services...
    %COMPOSE_CMD% down
    if not errorlevel 1 (
        echo [OK] Services stopped successfully
    )
    
) else if "%1"=="status" (
    echo.
    echo [STATUS] Service Status:
    %COMPOSE_CMD% ps
    
) else if "%1"=="logs" (
    echo.
    echo [LOGS] Service Logs (Press Ctrl+C to exit):
    %COMPOSE_CMD% logs -f
    
) else if "%1"=="backup" (
    echo.
    echo [BACKUP] Creating database backup...
    
    REM Get current timestamp
    for /f "tokens=1-4 delims=/ " %%i in ('date /t') do (
        set dt=%%i%%j%%k
    )
    for /f "tokens=1-2 delims=: " %%i in ('time /t') do (
        set tm=%%i%%j
    )
    set timestamp=!dt!_!tm!
    set backup_file=backups\n8n_backup_!timestamp!.sql
    
    %COMPOSE_CMD% exec -T postgres pg_dump -U n8n n8n > "!backup_file!"
    if not errorlevel 1 (
        echo [OK] Database backup created: !backup_file!
    ) else (
        echo [ERROR] Failed to create backup
    )
    
) else if "%1"=="env" (
    REM Use Python to generate environment file if available
    python --version >nul 2>&1
    if not errorlevel 1 (
        echo [SETUP] Generating environment file and database script...
        python setup.py env
    ) else (
        echo [INFO] Python not found. Copying template manually...
        copy env.template .env
        echo [WARNING] Please edit .env file and replace placeholder passwords manually.
        echo [WARNING] Database initialization script will not be generated automatically.
    )
    
) else (
    echo [ERROR] Unknown command: %1
    echo Usage: setup.bat [setup^|start^|stop^|status^|logs^|backup^|env]
    exit /b 1
)

endlocal
