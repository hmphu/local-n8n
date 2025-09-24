# Windows 10 Setup Guide for N8N Docker

This guide provides detailed instructions for setting up N8N with Docker on Windows 10 using Docker Desktop.

## Prerequisites

### 1. Install Docker Desktop for Windows

1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop
2. Run the installer and follow the setup wizard
3. Enable WSL 2 backend when prompted (recommended)
4. Restart your computer after installation
5. Start Docker Desktop and wait for it to finish starting

### 2. Verify Installation

Open Command Prompt or PowerShell and run:
```cmd
docker --version
docker-compose --version
```

You should see version information for both commands.

## Setup Options

You have three options for setting up and managing N8N on Windows:

### Option 1: PowerShell Script (Recommended)
Modern PowerShell script with colored output and advanced features.

### Option 2: Batch File
Traditional Windows batch file for compatibility.

### Option 3: Python Script
Cross-platform Python script that works on Windows.

## Quick Start

### Using PowerShell (Recommended)

1. **Open PowerShell as Administrator** (right-click PowerShell and select "Run as administrator")

2. **Enable execution of PowerShell scripts** (first time only):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Navigate to the project directory**:
   ```powershell
   cd C:\path\to\local-n8n
   ```

4. **Run the setup**:
   ```powershell
   .\setup.ps1 setup
   ```

5. **Start the services**:
   ```powershell
   .\setup.ps1 start
   ```

6. **Access N8N**: Open your browser and go to `http://localhost:5678`

7. **Install Community Nodes** (Optional): Go to Settings > Community Nodes to install additional nodes from npm

### Using Batch File

1. **Open Command Prompt** (cmd)

2. **Navigate to the project directory**:
   ```cmd
   cd C:\path\to\local-n8n
   ```

3. **Run the setup**:
   ```cmd
   setup.bat setup
   ```

4. **Start the services**:
   ```cmd
   setup.bat start
   ```

5. **Access N8N**: Open your browser and go to `http://localhost:5678`

6. **Install Community Nodes** (Optional): Go to Settings > Community Nodes to install additional nodes from npm

### Using Python

1. **Install Python** (if not already installed):
   - Download from: https://www.python.org/downloads/
   - Make sure to check "Add Python to PATH" during installation

2. **Open Command Prompt or PowerShell**

3. **Navigate to the project directory**:
   ```cmd
   cd C:\path\to\local-n8n
   ```

4. **Run the setup**:
   ```cmd
   python setup.py setup
   ```

5. **Start the services**:
   ```cmd
   python setup.py start
   ```

6. **Access N8N**: Open your browser and go to `http://localhost:5678`

7. **Install Community Nodes** (Optional): Go to Settings > Community Nodes to install additional nodes from npm

## Management Commands

### PowerShell Commands
```powershell
# Setup environment
.\setup.ps1 setup

# Start services
.\setup.ps1 start

# Stop services
.\setup.ps1 stop

# View service status
.\setup.ps1 status

# View logs
.\setup.ps1 logs

# Create database backup
.\setup.ps1 backup

# Recreate environment file
.\setup.ps1 env
```

### Batch File Commands
```cmd
# Setup environment
setup.bat setup

# Start services
setup.bat start

# Stop services
setup.bat stop

# View service status
setup.bat status

# View logs
setup.bat logs

# Create database backup
setup.bat backup

# Recreate environment file
setup.bat env
```

### Python Commands
```cmd
# Setup environment
python setup.py setup

# Start services
python setup.py start

# Stop services
python setup.py stop

# View service status
python setup.py status

# View logs
python setup.py logs

# Create database backup
python setup.py backup

# Recreate environment file
python setup.py env
```

## Windows-Specific Considerations

### File Paths
- Use backslashes (`\`) in Windows paths
- The scripts handle path conversion automatically
- Volume mounts use Windows-style paths in Docker Desktop

### WSL 2 Backend
- WSL 2 is recommended for better performance
- Docker Desktop will prompt you to install WSL 2 if needed
- All containers run in WSL 2 but are accessible from Windows

### Firewall and Antivirus
- Windows Defender may prompt to allow Docker Desktop
- Allow Docker Desktop through the firewall
- Some antivirus software may interfere with Docker

### Performance
- Make sure Docker Desktop has enough resources allocated:
  - Go to Docker Desktop Settings > Resources
  - Allocate at least 4GB RAM and 2 CPU cores
  - Adjust based on your system specifications

## Troubleshooting

### Docker Desktop Not Starting
1. Restart Docker Desktop
2. Check if Hyper-V is enabled (Windows features)
3. Ensure WSL 2 is installed and updated
4. Run Docker Desktop as Administrator

### Permission Issues
1. Run PowerShell/Command Prompt as Administrator
2. Check Docker Desktop is running with proper permissions
3. Ensure your user is in the "docker-users" group

### Port Conflicts
If ports 5678 or 5432 are already in use:
1. Edit the `.env` file
2. Change `N8N_PORT` to a different port (e.g., 8080)
3. Change `POSTGRES_PORT` to a different port (e.g., 15432)
4. Restart services: `.\setup.ps1 stop` then `.\setup.ps1 start`

### Container Startup Issues
1. Check Docker Desktop is running
2. Verify enough disk space is available
3. Check logs: `.\setup.ps1 logs`
4. Restart services: `.\setup.ps1 stop` then `.\setup.ps1 start`

### Network Issues
1. Disable VPN if experiencing connectivity issues
2. Check Windows Firewall settings
3. Ensure Docker Desktop network settings are correct

## Directory Structure on Windows

```
C:\your\project\path\local-n8n\
├── docker-compose.yml
├── env.template
├── .env                    (created after setup)
├── setup.ps1              (PowerShell script)
├── setup.bat              (Batch script)
├── setup.py               (Python script)
├── custom-nodes\
├── backups\
├── workflows\
│   ├── production\
│   ├── development\
│   └── templates\
└── init-scripts\
```

## Security Notes for Windows

1. **Keep Docker Desktop Updated**: Regular updates include security patches
2. **Use Strong Passwords**: The setup scripts generate secure passwords automatically
3. **Firewall Configuration**: Only allow necessary ports through Windows Firewall
4. **File Permissions**: Ensure `.env` file is not accessible to other users
5. **Regular Backups**: Use the built-in backup commands regularly

## Integration with Windows Tools

### Windows Terminal
For the best experience, use Windows Terminal with PowerShell:
1. Install Windows Terminal from Microsoft Store
2. Set PowerShell as default profile
3. Use the PowerShell setup script for best results

### VS Code
If using Visual Studio Code:
1. Install Docker extension
2. Install PowerShell extension
3. Open the project folder in VS Code
4. Use integrated terminal for running commands

## Updates and Maintenance

### Updating N8N
```powershell
# Pull latest images
docker-compose pull

# Restart with new images
.\setup.ps1 stop
.\setup.ps1 start
```

### Cleaning Up
```powershell
# Stop all services
.\setup.ps1 stop

# Remove containers and networks (keeps data)
docker-compose down

# Remove everything including volumes (WARNING: deletes all data)
docker-compose down -v
```

## Desktop Shortcuts and Quick Access

### Create Desktop Shortcut

To create a convenient desktop shortcut for opening N8N:

```powershell
# Run PowerShell as Administrator
.\create-shortcut.ps1
```

This will create:
- Desktop shortcut to `http://localhost:5678/`
- Optional Start Menu shortcut
- Optional project folder shortcut

### Quick Open Scripts

**PowerShell (Recommended):**
```powershell
# Opens N8N with health check
.\open-n8n.ps1
```
Features:
- Checks if N8N is running
- Waits for startup if containers are running
- Provides helpful tips and error messages

**Batch File:**
```cmd
# Simple browser opener
open-n8n.bat
```
Features:
- Basic connection check
- Opens default browser to N8N
- Simple error handling

### Manual Browser Access

If shortcuts don't work, manually navigate to:
- **N8N Interface**: `http://localhost:5678/`
- **Default credentials**: Check your `.env` file

## Support

For Windows-specific issues:
1. Check Docker Desktop documentation
2. Verify WSL 2 is properly configured
3. Ensure all prerequisites are installed
4. Check Windows Event Viewer for system errors
5. Consult the main README.md for general troubleshooting
