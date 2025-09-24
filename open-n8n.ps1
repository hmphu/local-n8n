# Open N8N Web Interface
# This PowerShell script opens N8N at http://localhost:5678 in the default browser

param(
    [string]$Url = "http://localhost:5678/",
    [switch]$Force
)

Write-Host "🚀 Opening N8N Workflow Automation Tool..." -ForegroundColor Magenta
Write-Host "🌐 URL: $Url" -ForegroundColor Cyan

# Function to check if N8N is running
function Test-N8NRunning {
    param([string]$TestUrl)
    
    try {
        Write-Host "🔍 Checking if N8N is running..." -ForegroundColor Yellow
        $response = Invoke-WebRequest -Uri $TestUrl -Method HEAD -TimeoutSec 5 -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Function to check if Docker containers are running
function Test-DockerContainers {
    try {
        # Try to get Docker Compose command
        $composeCmd = $null
        try {
            docker-compose ps >$null 2>&1
            if ($LASTEXITCODE -eq 0) { $composeCmd = "docker-compose" }
        } catch {}
        
        if (-not $composeCmd) {
            try {
                docker compose ps >$null 2>&1
                if ($LASTEXITCODE -eq 0) { $composeCmd = "docker compose" }
            } catch {}
        }
        
        if ($composeCmd) {
            $containers = Invoke-Expression "$composeCmd ps --services --filter status=running" 2>$null
            return @($containers).Count -gt 0
        }
        return $false
    }
    catch {
        return $false
    }
}

# Check if N8N is running unless Force is specified
if (-not $Force) {
    $isRunning = Test-N8NRunning -TestUrl $Url
    
    if (-not $isRunning) {
        Write-Host "⚠️  N8N does not appear to be running!" -ForegroundColor Red
        
        # Check if Docker containers are running
        $dockerRunning = Test-DockerContainers
        if ($dockerRunning) {
            Write-Host "✅ Docker containers are running, N8N might be starting up..." -ForegroundColor Yellow
            Write-Host "⏳ Waiting for N8N to become available..." -ForegroundColor Yellow
            
            # Wait up to 30 seconds for N8N to start
            $timeout = 30
            $elapsed = 0
            while ($elapsed -lt $timeout -and -not (Test-N8NRunning -TestUrl $Url)) {
                Start-Sleep -Seconds 2
                $elapsed += 2
                Write-Host "." -NoNewline
            }
            Write-Host ""
            
            if (Test-N8NRunning -TestUrl $Url) {
                Write-Host "✅ N8N is now available!" -ForegroundColor Green
            } else {
                Write-Host "❌ N8N is still not responding after $timeout seconds" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ Docker containers are not running." -ForegroundColor Red
            Write-Host "💡 Please start N8N first:" -ForegroundColor Yellow
            Write-Host "   - .\setup.ps1 start" -ForegroundColor White
            Write-Host "   - setup.bat start" -ForegroundColor White
            Write-Host "   - python setup.py start" -ForegroundColor White
            Write-Host ""
            
            $proceed = Read-Host "Open browser anyway? (y/N)"
            if ($proceed -ne "y" -and $proceed -ne "Y") {
                Write-Host "❌ Cancelled." -ForegroundColor Red
                exit 1
            }
        }
    } else {
        Write-Host "✅ N8N is running and accessible!" -ForegroundColor Green
    }
}

# Open the URL in the default browser
try {
    Write-Host "🌐 Opening N8N in your default browser..." -ForegroundColor Cyan
    Start-Process $Url
    
    Write-Host "✅ N8N should now be open in your browser!" -ForegroundColor Green
    Write-Host "📋 If it doesn't open automatically, navigate to: $Url" -ForegroundColor Yellow
    
    # Show useful information
    Write-Host ""
    Write-Host "💡 Quick Tips:" -ForegroundColor Magenta
    Write-Host "   - Default credentials are in your .env file" -ForegroundColor White
    Write-Host "   - Check logs with: .\setup.ps1 logs" -ForegroundColor White
    Write-Host "   - Stop N8N with: .\setup.ps1 stop" -ForegroundColor White
    Write-Host "   - Install community nodes: Settings > Community Nodes" -ForegroundColor White
}
catch {
    Write-Host "❌ Failed to open browser: $_" -ForegroundColor Red
    Write-Host "💡 Please manually navigate to: $Url" -ForegroundColor Yellow
}
