# N8N Docker Setup and Management Script for Windows PowerShell
# Usage: .\setup.ps1 [setup|start|stop|status|logs|backup|env]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("setup", "start", "stop", "status", "logs", "backup", "env")]
    [string]$Action
)

# Function to generate secure password
function Generate-Password {
    param([int]$Length = 16)
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"
    return -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.length)] })
}

# Function to generate encryption key
function Generate-EncryptionKey {
    $bytes = New-Object byte[] 24
    [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
    return [System.Convert]::ToBase64String($bytes).Substring(0, 32)
}

# Function to get Docker Compose command
function Get-DockerComposeCommand {
    # Try docker-compose first (standalone version)
    try {
        docker-compose --version 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            return "docker-compose"
        }
    } catch {}
    
    # Try docker compose (integrated version)
    try {
        docker compose version 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            return "docker compose"
        }
    } catch {}
    
    return $null
}

# Function to check Docker Desktop
function Test-DockerDesktop {
    Write-Host "🔍 Checking Docker Desktop..." -ForegroundColor Cyan
    
    try {
        $dockerVersion = docker --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker not found"
        }
        
        $composeCmd = Get-DockerComposeCommand
        if (-not $composeCmd) {
            throw "Docker Compose not found"
        }
        
        Write-Host "✅ Docker Desktop is available (using '$composeCmd')" -ForegroundColor Green
        return @($true, $composeCmd)
    }
    catch {
        Write-Host "❌ Docker Desktop is not running or not installed." -ForegroundColor Red
        Write-Host "Please install Docker Desktop and make sure it's running." -ForegroundColor Yellow
        Write-Host "Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        return @($false, $null)
    }
}

# Function to create directories
function New-ProjectDirectories {
    Write-Host "📁 Creating required directories..." -ForegroundColor Cyan
    
    $directories = @(
        "custom-nodes",
        "backups", 
        "workflows",
        "workflows\production",
        "workflows\development", 
        "workflows\templates",
        "init-scripts"
    )
    
    foreach ($dir in $directories) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    Write-Host "✅ Directories created successfully" -ForegroundColor Green
}

# Function to load environment variables from .env file
function Get-EnvironmentVariables {
    $envVars = @{}
    
    if (Test-Path ".env") {
        $content = Get-Content ".env"
        foreach ($line in $content) {
            $line = $line.Trim()
            if ($line -and !$line.StartsWith("#") -and $line.Contains("=")) {
                $parts = $line.Split("=", 2)
                if ($parts.Length -eq 2) {
                    $envVars[$parts[0]] = $parts[1]
                }
            }
        }
    }
    
    return $envVars
}

# Function to generate init-user.sql from template
function New-InitSQL {
    Write-Host "🔧 Generating database initialization script..." -ForegroundColor Cyan
    
    $templatePath = "init-scripts\init-user.sql.template"
    $sqlPath = "init-scripts\init-user.sql"
    
    if (!(Test-Path $templatePath)) {
        Write-Host "❌ init-user.sql.template not found!" -ForegroundColor Red
        return $false
    }
    
    # Load environment variables
    $envVars = Get-EnvironmentVariables
    
    # Set default values
    $defaults = @{
        'POSTGRES_DB' = 'n8n'
        'POSTGRES_NON_ROOT_USER' = 'n8n'
        'POSTGRES_NON_ROOT_PASSWORD' = $envVars['POSTGRES_NON_ROOT_PASSWORD']
    }
    
    if (!$defaults['POSTGRES_NON_ROOT_PASSWORD']) {
        $defaults['POSTGRES_NON_ROOT_PASSWORD'] = 'n8n_password'
    }
    
    # Read template
    $content = Get-Content $templatePath -Raw
    
    # Replace placeholders
    foreach ($key in $defaults.Keys) {
        $value = if ($envVars[$key]) { $envVars[$key] } else { $defaults[$key] }
        $content = $content -replace "{$key}", $value
    }
    
    # Write SQL file
    $content | Out-File -FilePath $sqlPath -Encoding UTF8
    
    Write-Host "✅ Generated init-user.sql with current environment variables" -ForegroundColor Green
    return $true
}

# Function to create environment file
function New-EnvironmentFile {
    Write-Host "🔐 Creating environment file..." -ForegroundColor Cyan
    
    if (Test-Path ".env") {
        $overwrite = Read-Host ".env file already exists. Overwrite? (y/N)"
        if ($overwrite -ne "y" -and $overwrite -ne "Y") {
            Write-Host "Skipping .env file creation." -ForegroundColor Yellow
            return
        }
    }
    
    if (!(Test-Path "env.template")) {
        Write-Host "❌ env.template not found!" -ForegroundColor Red
        return
    }
    
    # Generate secure passwords
    $postgresPassword = Generate-Password -Length 20
    $postgresNonRootPassword = Generate-Password -Length 20
    $n8nPassword = Generate-Password -Length 16
    $encryptionKey = Generate-EncryptionKey
    
    # Read template and replace placeholders
    $content = Get-Content "env.template" -Raw
    
    $replacements = @{
        'your_secure_postgres_password_here' = $postgresPassword
        'your_secure_n8n_db_password_here' = $postgresNonRootPassword
        'your_secure_n8n_password_here' = $n8nPassword
        'your_32_character_encryption_key_here' = $encryptionKey
    }
    
    foreach ($placeholder in $replacements.Keys) {
        $content = $content -replace $placeholder, $replacements[$placeholder]
    }
    
    # Write .env file
    $content | Out-File -FilePath ".env" -Encoding UTF8
    
    Write-Host "✅ .env file created with generated passwords:" -ForegroundColor Green
    Write-Host "   - N8N Admin Password: $n8nPassword" -ForegroundColor Yellow
    Write-Host "   - Database passwords: [generated]" -ForegroundColor Yellow
    Write-Host "   - Encryption key: [generated]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⚠️  Save these credentials securely!" -ForegroundColor Red
    
    # Generate the SQL file after creating .env
    New-InitSQL
}

# Function to run Docker Compose commands
function Invoke-DockerCompose {
    param([string]$ComposeCmd, [string]$Command, [string]$Description = "")
    
    if ($Description) {
        Write-Host "🔄 $Description" -ForegroundColor Cyan
    }
    
    try {
        Invoke-Expression "$ComposeCmd $Command"
        return $LASTEXITCODE -eq 0
    }
    catch {
        Write-Host "❌ Command failed: $_" -ForegroundColor Red
        return $false
    }
}

# Get Docker Compose command for actions that need it
$composeCmd = $null
if ($Action -in @("setup", "start", "stop", "status", "logs", "backup")) {
    $dockerResult = Test-DockerDesktop
    if (-not $dockerResult[0]) {
        exit 1
    }
    $composeCmd = $dockerResult[1]
}

# Main script logic
switch ($Action) {
    "setup" {
        Write-Host "🚀 Setting up N8N Docker environment for Windows..." -ForegroundColor Magenta
        Write-Host ""
        
        New-ProjectDirectories
        New-EnvironmentFile
        
        Write-Host ""
        Write-Host "✅ Setup complete! Next steps:" -ForegroundColor Green
        Write-Host "1. Review the .env file and adjust settings if needed" -ForegroundColor White
        Write-Host "2. Run: .\setup.ps1 start" -ForegroundColor White
    }
    
    "env" {
        New-EnvironmentFile
    }
    
    "start" {
        Write-Host "🚀 Starting N8N services..." -ForegroundColor Magenta
        
        if (!(Test-Path ".env")) {
            Write-Host "❌ .env file not found. Run '.\setup.ps1 setup' first." -ForegroundColor Red
            exit 1
        }
        
        # Generate SQL file before starting services
        New-InitSQL
        
        $success = Invoke-DockerCompose $composeCmd "up -d" "Starting services"
        if ($success) {
            Write-Host ""
            Write-Host "✅ Services started successfully!" -ForegroundColor Green
            Write-Host "🌐 N8N is available at: http://localhost:5678" -ForegroundColor Yellow
            Write-Host "📋 Use '.\setup.ps1 logs' to view service logs" -ForegroundColor White
        }
    }
    
    "stop" {
        Write-Host "🛑 Stopping N8N services..." -ForegroundColor Magenta
        $success = Invoke-DockerCompose $composeCmd "down" "Stopping services"
        if ($success) {
            Write-Host "✅ Services stopped successfully" -ForegroundColor Green
        }
    }
    
    "status" {
        Write-Host "📊 Service Status:" -ForegroundColor Magenta
        Invoke-Expression "$composeCmd ps"
    }
    
    "logs" {
        Write-Host "📋 Service Logs (Press Ctrl+C to exit):" -ForegroundColor Magenta
        Invoke-Expression "$composeCmd logs -f"
    }
    
    "backup" {
        Write-Host "💾 Creating database backup..." -ForegroundColor Magenta
        
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = "backups\n8n_backup_$timestamp.sql"
        
        try {
            Invoke-Expression "$composeCmd exec -T postgres pg_dump -U n8n n8n" | Out-File -FilePath $backupFile -Encoding UTF8
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Database backup created: $backupFile" -ForegroundColor Green
            } else {
                Write-Host "❌ Failed to create backup" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "❌ Failed to create backup: $_" -ForegroundColor Red
        }
    }
}
