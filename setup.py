#!/usr/bin/env python3
"""
N8N Docker Setup and Management Script
"""

import os
import sys
import secrets
import string
import subprocess
import argparse
import platform
from pathlib import Path
from datetime import datetime


def generate_password(length=16):
    """Generate a secure random password."""
    alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(secrets.choice(alphabet) for _ in range(length))


def generate_encryption_key():
    """Generate a 32-character encryption key."""
    return secrets.token_urlsafe(24)[:32]


def load_env_variables():
    """Load environment variables from .env file."""
    env_path = Path(".env")
    env_vars = {}
    
    if env_path.exists():
        with open(env_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    env_vars[key] = value
    
    return env_vars


def generate_init_sql():
    """Generate init-user.sql from template using environment variables."""
    template_path = Path("init-scripts/init-user.sql.template")
    sql_path = Path("init-scripts/init-user.sql")
    
    if not template_path.exists():
        print("Error: init-user.sql.template not found!")
        return False
    
    # Load environment variables
    env_vars = load_env_variables()
    
    # Set default values
    defaults = {
        'POSTGRES_DB': 'n8n',
        'POSTGRES_NON_ROOT_USER': 'n8n',
        'POSTGRES_NON_ROOT_PASSWORD': env_vars.get('POSTGRES_NON_ROOT_PASSWORD', 'n8n_password')
    }
    
    # Read template
    with open(template_path, 'r') as f:
        content = f.read()
    
    # Replace placeholders
    for key, default_value in defaults.items():
        value = env_vars.get(key, default_value)
        content = content.replace(f'{{{key}}}', value)
    
    # Write SQL file
    with open(sql_path, 'w') as f:
        f.write(content)
    
    print("✅ Generated init-user.sql with current environment variables")
    return True


def create_env_file():
    """Create .env file from template with generated passwords."""
    env_template_path = Path("env.template")
    env_path = Path(".env")
    
    if env_path.exists():
        response = input(".env file already exists. Overwrite? (y/N): ")
        if response.lower() != 'y':
            print("Skipping .env file creation.")
            return
    
    if not env_template_path.exists():
        print("Error: env.template not found!")
        return
    
    # Generate secure passwords
    postgres_password = generate_password(20)
    postgres_non_root_password = generate_password(20)
    n8n_password = generate_password(16)
    encryption_key = generate_encryption_key()
    
    # Read template and replace placeholders
    with open(env_template_path, 'r') as f:
        content = f.read()
    
    replacements = {
        'your_secure_postgres_password_here': postgres_password,
        'your_secure_n8n_db_password_here': postgres_non_root_password,
        'your_secure_n8n_password_here': n8n_password,
        'your_32_character_encryption_key_here': encryption_key,
    }
    
    for placeholder, value in replacements.items():
        content = content.replace(placeholder, value)
    
    # Write .env file
    with open(env_path, 'w') as f:
        f.write(content)
    
    print("✅ .env file created with generated passwords:")
    print(f"   - N8N Admin Password: {n8n_password}")
    print(f"   - Database passwords: [generated]")
    print(f"   - Encryption key: [generated]")
    print("\n⚠️  Save these credentials securely!")
    
    # Generate the SQL file after creating .env
    generate_init_sql()


def run_command(command, description=""):
    """Run a shell command and return the result."""
    if description:
        print(f"🔄 {description}")
    
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.CalledProcessError as e:
        return False, e.stdout, e.stderr


def setup_directories():
    """Create required directories."""
    directories = [
        "custom-nodes",
        "backups",
        "workflows",
        "workflows/production",
        "workflows/development",
        "workflows/templates",
        "init-scripts"
    ]
    
    # Use proper path separators for Windows
    if platform.system() == "Windows":
        directories = [d.replace("/", "\\") for d in directories]
    
    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
    
    print("✅ Created required directories")


def get_docker_compose_command():
    """Detect and return the correct Docker Compose command."""
    # Try docker compose (integrated version)
    success, stdout, stderr = run_command("docker compose version")
    if success:
        return "docker compose"

    # Try docker-compose (standalone version)
    success, stdout, stderr = run_command("docker-compose --version")
    if success:
        return "docker-compose"
    
    return None


def check_docker():
    """Check if Docker and Docker Compose are available."""
    success, stdout, stderr = run_command("docker --version")
    if not success:
        print("❌ Docker is not installed or not accessible")
        if platform.system() == "Windows":
            print("Please install Docker Desktop for Windows and make sure it's running.")
            print("Download from: https://www.docker.com/products/docker-desktop")
        return False, None
    
    compose_cmd = get_docker_compose_command()
    if not compose_cmd:
        print("❌ Docker Compose is not installed or not accessible")
        if platform.system() == "Windows":
            print("Docker Compose should be included with Docker Desktop for Windows.")
        return False, None
    
    print(f"✅ Docker and Docker Compose are available (using '{compose_cmd}')")
    return True, compose_cmd


def start_services(compose_cmd="docker-compose"):
    """Start the Docker Compose services."""
    success, stdout, stderr = run_command(f"{compose_cmd} up -d", "Starting services")
    if success:
        print("✅ Services started successfully")
        print("🌐 N8N is available at: http://localhost:5678")
    else:
        print(f"❌ Failed to start services: {stderr}")
    return success


def stop_services(compose_cmd="docker-compose"):
    """Stop the Docker Compose services."""
    success, stdout, stderr = run_command(f"{compose_cmd} down", "Stopping services")
    if success:
        print("✅ Services stopped successfully")
    else:
        print(f"❌ Failed to stop services: {stderr}")
    return success


def show_status(compose_cmd="docker-compose"):
    """Show status of services."""
    success, stdout, stderr = run_command(f"{compose_cmd} ps")
    if success:
        print("📊 Service Status:")
        print(stdout)
    else:
        print(f"❌ Failed to get status: {stderr}")


def show_logs(compose_cmd="docker-compose"):
    """Show logs from services."""
    print("📋 Service Logs (Press Ctrl+C to exit):")
    os.system(f"{compose_cmd} logs -f")


def backup_database(compose_cmd="docker-compose"):
    """Create a database backup."""
    # Use datetime for cross-platform timestamp generation
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Use proper path separator for the platform
    if platform.system() == "Windows":
        backup_file = f"backups\\n8n_backup_{timestamp}.sql"
    else:
        backup_file = f"backups/n8n_backup_{timestamp}.sql"
    
    command = f"{compose_cmd} exec -T postgres pg_dump -U n8n n8n > {backup_file}"
    success, stdout, stderr = run_command(command, f"Creating database backup: {backup_file}")
    
    if success:
        print(f"✅ Database backup created: {backup_file}")
    else:
        print(f"❌ Failed to create backup: {stderr}")


def main():
    """Main function."""
    parser = argparse.ArgumentParser(description="N8N Docker Setup and Management")
    parser.add_argument("action", choices=[
        "setup", "start", "stop", "status", "logs", "backup", "env"
    ], help="Action to perform")
    
    args = parser.parse_args()
    
    # Get Docker Compose command for actions that need it
    compose_cmd = None
    if args.action in ["setup", "start", "stop", "status", "logs", "backup"]:
        docker_ok, compose_cmd = check_docker()
        if not docker_ok:
            sys.exit(1)
    
    if args.action == "setup":
        print("🚀 Setting up N8N Docker environment...")
        
        setup_directories()
        create_env_file()
        
        print("\n✅ Setup complete! Next steps:")
        print("1. Review the .env file and adjust settings if needed")
        if platform.system() == "Windows":
            print("2. Run: python setup.py start")
            print("   Or use: setup.bat start")
            print("   Or use: .\\setup.ps1 start")
        else:
            print("2. Run: python3 setup.py start")
        
    elif args.action == "env":
        create_env_file()
        
    elif args.action == "start":
        if not Path(".env").exists():
            if platform.system() == "Windows":
                print("❌ .env file not found. Run 'python setup.py setup' first.")
            else:
                print("❌ .env file not found. Run 'python3 setup.py setup' first.")
            sys.exit(1)
        
        # Generate SQL file before starting services
        generate_init_sql()
        start_services(compose_cmd)
        
    elif args.action == "stop":
        stop_services(compose_cmd)
        
    elif args.action == "status":
        show_status(compose_cmd)
        
    elif args.action == "logs":
        show_logs(compose_cmd)
        
    elif args.action == "backup":
        backup_database(compose_cmd)


if __name__ == "__main__":
    main()
