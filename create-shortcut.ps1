# Create Windows Shortcut for N8N Web Interface
# This script creates a desktop shortcut to open N8N at http://localhost:5678

param(
    [string]$ShortcutPath = "$env:USERPROFILE\Desktop\N8N Workflow.lnk"
)

Write-Host "🔗 Creating N8N shortcut..." -ForegroundColor Cyan

try {
    # Create WScript.Shell object
    $WScriptShell = New-Object -ComObject WScript.Shell

    # Create the shortcut
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
    
    # Set shortcut properties
    $Shortcut.TargetPath = "http://localhost:5678/"
    $Shortcut.Description = "Open N8N Workflow Automation Tool"
    $Shortcut.WorkingDirectory = $PWD.Path
    $Shortcut.IconLocation = "shell32.dll,14"  # Globe icon from shell32.dll
    
    # Save the shortcut
    $Shortcut.Save()
    
    Write-Host "✅ Shortcut created successfully!" -ForegroundColor Green
    Write-Host "📍 Location: $ShortcutPath" -ForegroundColor Yellow
    Write-Host "🌐 Target: http://localhost:5678/" -ForegroundColor Yellow
    
    # Ask if user wants to create additional shortcuts
    $createMore = Read-Host "`nCreate additional shortcuts? (y/N)"
    if ($createMore -eq "y" -or $createMore -eq "Y") {
        # Create Start Menu shortcut
        $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\N8N Workflow.lnk"
        $StartMenuShortcut = $WScriptShell.CreateShortcut($startMenuPath)
        $StartMenuShortcut.TargetPath = "http://localhost:5678/"
        $StartMenuShortcut.Description = "Open N8N Workflow Automation Tool"
        $StartMenuShortcut.WorkingDirectory = $PWD.Path
        $StartMenuShortcut.IconLocation = "shell32.dll,14"
        $StartMenuShortcut.Save()
        
        Write-Host "✅ Start Menu shortcut created: $startMenuPath" -ForegroundColor Green
        
        # Create project folder shortcut
        $projectShortcutPath = "$PWD\N8N Workflow.lnk"
        $ProjectShortcut = $WScriptShell.CreateShortcut($projectShortcutPath)
        $ProjectShortcut.TargetPath = "http://localhost:5678/"
        $ProjectShortcut.Description = "Open N8N Workflow Automation Tool"
        $ProjectShortcut.WorkingDirectory = $PWD.Path
        $ProjectShortcut.IconLocation = "shell32.dll,14"
        $ProjectShortcut.Save()
        
        Write-Host "✅ Project folder shortcut created: $projectShortcutPath" -ForegroundColor Green
    }
    
    Write-Host "`n💡 Tips:" -ForegroundColor Magenta
    Write-Host "- Double-click the shortcut to open N8N in your default browser" -ForegroundColor White
    Write-Host "- Make sure N8N is running before using the shortcut" -ForegroundColor White
    Write-Host "- Start N8N with: .\setup.ps1 start" -ForegroundColor White
    
} catch {
    Write-Host "❌ Failed to create shortcut: $_" -ForegroundColor Red
    Write-Host "💡 Try running PowerShell as Administrator" -ForegroundColor Yellow
}
