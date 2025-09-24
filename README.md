# N8N Docker Compose Setup

A complete Docker Compose setup for running n8n with PostgreSQL database and persistent data storage.

## Features

- **N8N**: Latest version with web interface
- **PostgreSQL**: Reliable database backend
- **Data Persistence**: All data stored in Docker volumes and mounted directories
- **Health Checks**: Automatic service health monitoring
- **Environment Configuration**: Twelve-Factor App compliant configuration
- **Custom Nodes Support**: Directory for custom n8n nodes
- **Backup Support**: Mounted directories for easy backups
- **Cross-Platform**: Works on Linux, macOS, and Windows 10 with Docker Desktop

## Platform Support

- **Linux**: Native Docker support
- **macOS**: Docker Desktop
- **Windows 10**: Docker Desktop with WSL 2 backend

For Windows-specific instructions, see [WINDOWS_SETUP.md](WINDOWS_SETUP.md)

## Docker Compose Compatibility

This project automatically detects and works with both Docker Compose versions:

- **Standalone Docker Compose**: `docker-compose` (older installations)
- **Integrated Docker Compose**: `docker compose` (newer Docker Desktop versions)

The setup scripts automatically detect which version you have and use the appropriate commands. No manual configuration needed!

## Quick Start

Choose your platform for setup instructions:

### Linux/macOS (Manual Setup)

```bash
# Copy environment template
cp env.template .env

# Edit the .env file with your configuration
nano .env
```

### Automated Setup (All Platforms)

Use the provided setup scripts for automatic configuration:

**Linux/macOS:**
```bash
# Using Python script
python3 setup.py setup
python3 setup.py start
```

**Windows PowerShell:**
```powershell
# Using PowerShell script (recommended)
.\setup.ps1 setup
.\setup.ps1 start
```

**Windows Command Prompt:**
```cmd
# Using batch file
setup.bat setup
setup.bat start

# Or using Python
python setup.py setup
python setup.py start
```

### 2. Configure Environment Variables

Edit the `.env` file and set the following required values:

```bash
# Database passwords (REQUIRED)
POSTGRES_PASSWORD=your_secure_postgres_password_here
POSTGRES_NON_ROOT_PASSWORD=your_secure_n8n_db_password_here

# N8N authentication (REQUIRED)
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_n8n_password_here

# N8N encryption key (REQUIRED - 32 characters)
N8N_ENCRYPTION_KEY=your_32_character_encryption_key_here
```

### 3. Start Services

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Check service status
docker-compose ps
```

### 4. Access N8N

Open your browser and navigate to: `http://localhost:5678`

Default credentials (if configured):
- Username: `admin` (or as set in N8N_BASIC_AUTH_USER)
- Password: As set in N8N_BASIC_AUTH_PASSWORD

#### Quick Access Options (Windows)

**Create Desktop Shortcut:**
```powershell
# Run PowerShell as Administrator
.\create-shortcut.ps1
```

**Open N8N in Browser:**
```powershell
# PowerShell - with health check
.\open-n8n.ps1

# Batch file - simple version
open-n8n.bat
```

## Directory Structure

```
local-n8n/
├── docker-compose.yml          # Main Docker Compose configuration
├── env.template               # Environment variables template
├── .env                      # Your environment configuration (create from template)
├── .gitignore               # Git ignore file
├── README.md                # This file
├── WINDOWS_SETUP.md         # Windows-specific setup guide
├── setup.py                 # Python setup script (cross-platform)
├── setup.ps1               # PowerShell setup script (Windows)
├── setup.bat               # Batch setup script (Windows)
├── create-shortcut.ps1      # Create Windows desktop shortcut
├── open-n8n.ps1            # Open N8N in browser (PowerShell)
├── open-n8n.bat            # Open N8N in browser (Batch)
├── init-scripts/            # Database initialization scripts
│   ├── init-user.sql.template  # PostgreSQL user setup template
│   └── init-user.sql       # Generated PostgreSQL user setup (auto-generated)
├── custom-nodes/           # Custom n8n nodes directory
│   └── README.md
├── backups/               # Backup storage directory
│   └── README.md
└── workflows/            # Workflow files directory
    ├── production/       # Production workflows
    ├── development/      # Development workflows
    ├── templates/        # Workflow templates
    └── README.md
```

## Data Persistence

All data is persisted using Docker volumes and mounted directories:

- **PostgreSQL Data**: Stored in `postgres_data` Docker volume
- **N8N Data**: Stored in `n8n_data` Docker volume
- **Custom Nodes**: Mounted from `./custom-nodes` directory
- **Backups**: Mounted from `./backups` directory
- **Workflows**: Mounted from `./workflows` directory

## Management Commands

### Using Setup Scripts (Recommended)

**Linux/macOS:**
```bash
# Start services
python3 setup.py start

# Stop services
python3 setup.py stop

# View status
python3 setup.py status

# View logs
python3 setup.py logs

# Create backup
python3 setup.py backup
```

**Windows PowerShell:**
```powershell
# Start services
.\setup.ps1 start

# Stop services
.\setup.ps1 stop

# View status
.\setup.ps1 status

# View logs
.\setup.ps1 logs

# Create backup
.\setup.ps1 backup
```

**Windows Command Prompt:**
```cmd
# Start services
setup.bat start

# Stop services
setup.bat stop

# View status
setup.bat status

# View logs
setup.bat logs

# Create backup
setup.bat backup
```

### Manual Docker Commands

**Note**: Use either `docker-compose` (standalone) or `docker compose` (integrated) depending on your Docker installation. The setup scripts automatically detect which one to use.

### Start Services
```bash
# Standalone Docker Compose
docker-compose up -d

# OR Integrated Docker Compose
docker compose up -d
```

### Stop Services
```bash
# Standalone Docker Compose
docker-compose down

# OR Integrated Docker Compose
docker compose down
```

### View Logs
```bash
# All services (standalone)
docker-compose logs -f

# All services (integrated)
docker compose logs -f

# Specific service
docker-compose logs -f n8n
docker-compose logs -f postgres
```

### Restart Services
```bash
# All services (standalone)
docker-compose restart

# All services (integrated)
docker compose restart

# Specific service
docker-compose restart n8n
```

### Update N8N
```bash
# Pull latest images (standalone)
docker-compose pull

# Pull latest images (integrated)
docker compose pull

# Restart with new images
docker-compose up -d
# OR
docker compose up -d
```

## Backup and Restore

### Database Backup
```bash
# Create database backup (standalone)
docker-compose exec postgres pg_dump -U n8n n8n > backups/n8n_backup_$(date +%Y%m%d_%H%M%S).sql

# Create database backup (integrated)
docker compose exec postgres pg_dump -U n8n n8n > backups/n8n_backup_$(date +%Y%m%d_%H%M%S).sql
```

### Database Restore
```bash
# Restore database backup (standalone)
docker-compose exec -T postgres psql -U n8n n8n < backups/n8n_backup_YYYYMMDD_HHMMSS.sql

# Restore database backup (integrated)
docker compose exec -T postgres psql -U n8n n8n < backups/n8n_backup_YYYYMMDD_HHMMSS.sql
```

### Workflow Export/Import
Workflows can be exported from the n8n web interface and saved to the `workflows/` directory for version control.

## Custom and Community Nodes

### Community Nodes (npm packages)
N8N supports installing community nodes directly from npm. This feature is enabled by default in this setup.

1. **Access the Community Nodes tab** in the N8N interface (Settings > Community Nodes)
2. **Install nodes** by entering the npm package name (e.g., `n8n-nodes-telegram`)
3. **Restart N8N** after installation: `docker-compose restart n8n`

### Custom Nodes (local files)
1. Place custom node files in the `custom-nodes/` directory
2. Restart the n8n container: `docker-compose restart n8n`
3. Custom nodes will be available in the n8n interface

### Managing Community Nodes
- **View installed nodes**: Settings > Community Nodes
- **Uninstall nodes**: Use the uninstall button in the Community Nodes interface
- **Update nodes**: Uninstall and reinstall with the latest version

## Configuration

### Environment Variables

**Automated Configuration:**
Database initialization scripts are automatically generated from templates using environment variables, ensuring credentials are never hardcoded and always match your `.env` configuration. This works seamlessly across all platforms (Python, PowerShell, and Batch scripts).

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `POSTGRES_PASSWORD` | PostgreSQL root password | - | Yes |
| `POSTGRES_NON_ROOT_PASSWORD` | N8N database user password | - | Yes |
| `N8N_BASIC_AUTH_USER` | N8N web interface username | - | Yes |
| `N8N_BASIC_AUTH_PASSWORD` | N8N web interface password | - | Yes |
| `N8N_ENCRYPTION_KEY` | N8N encryption key (32 chars) | - | Yes |
| `N8N_HOST` | N8N host | localhost | No |
| `N8N_PORT` | N8N port | 5678 | No |
| `WEBHOOK_URL` | Webhook base URL | http://localhost:5678/ | No |
| `N8N_COMMUNITY_PACKAGES_ENABLED` | Enable community node installation | true | No |
| `N8N_NODES_EXCLUDE` | Comma-separated list of nodes to exclude | - | No |
| `N8N_NODES_INCLUDE` | Comma-separated list of nodes to include | - | No |
| `N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS` | Enforce secure file permissions | true | No |

### Ports

- **N8N Web Interface**: 5678
- **PostgreSQL**: 5432

## Troubleshooting

### Check Service Health
```bash
docker-compose ps
docker-compose logs -f
```

### Reset Everything
```bash
# Stop and remove containers, networks (standalone)
docker-compose down
# OR (integrated)
docker compose down

# Remove volumes (WARNING: This deletes all data)
docker-compose down -v
# OR (integrated)
docker compose down -v

# Remove all local data directories
rm -rf custom-nodes backups workflows

# Recreate directories
mkdir -p custom-nodes backups workflows/production workflows/development workflows/templates
```

### Common Issues

1. **Port conflicts**: Change ports in `.env` file if 5678 or 5432 are already in use
2. **Permission issues**: Ensure Docker has permission to mount directories
3. **Database connection issues**: Check PostgreSQL logs and ensure passwords match
4. **Windows-specific issues**: See [WINDOWS_SETUP.md](WINDOWS_SETUP.md) for Windows troubleshooting

## Security Notes

- Change all default passwords in the `.env` file
- Use strong passwords for all services
- Keep the `.env` file secure and never commit it to version control
- Regularly backup your data
- Consider using HTTPS in production environments

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.
