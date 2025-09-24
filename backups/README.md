# Backups Directory

This directory is mounted to `/home/node/backups` inside the n8n container for storing workflow backups and exports.

## Usage

- Export workflows from n8n UI and they can be saved here
- Use this directory for automated backup scripts
- Database backups can also be stored here

## Backup Scripts

You can create automated backup scripts that:
1. Export n8n workflows
2. Backup PostgreSQL database
3. Store backups with timestamps
