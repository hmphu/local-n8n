# Custom and Community Nodes

This directory contains information about both custom local nodes and community nodes from npm.

## Community Nodes (Recommended)

N8N supports installing community nodes directly from npm packages through the web interface.

### How to Install Community Nodes:

1. **Access N8N Web Interface**: Go to http://localhost:5678
2. **Navigate to Settings**: Click on Settings in the main menu
3. **Open Community Nodes**: Click on "Community Nodes" tab
4. **Install Package**: Enter the npm package name (e.g., `n8n-nodes-telegram`)
5. **Restart N8N**: Run `docker-compose restart n8n` after installation

### Popular Community Nodes:

- `n8n-nodes-telegram` - Telegram integration
- `n8n-nodes-text-manipulation` - Text processing utilities
- `n8n-nodes-chatwork` - Chatwork integration
- `n8n-nodes-pushover` - Pushover notifications
- `n8n-nodes-xml` - XML processing

### Managing Community Nodes:

- **View installed**: Settings > Community Nodes
- **Uninstall**: Use the uninstall button in the interface
- **Update**: Uninstall and reinstall the latest version

## Custom Local Nodes

Place your custom n8n node files in this directory. The directory is mounted to `/home/node/.n8n/custom` inside the n8n container.

### Structure

```
custom-nodes/
├── your-custom-node/   # Your custom node directory
│   ├── package.json   # Node package definition
│   └── YourNode.node.ts  # Node implementation
└── README.md          # This file
```

### Installation

1. Copy your custom node files into this directory
2. Restart the n8n container: `docker-compose restart n8n`
3. Custom nodes will appear in the n8n interface

### Resources

- **Creating custom nodes**: https://docs.n8n.io/integrations/creating-nodes/
- **Community nodes**: https://docs.n8n.io/integrations/community-nodes/
- **Node development**: https://docs.n8n.io/integrations/creating-nodes/build/
