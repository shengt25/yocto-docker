#!/bin/bash

cat << EOF
WARNING: This will remove all user configurations!
However, the following data will be PRESERVED since
they are mounted as volumes:
- Yocto labs data
- NFS data
- User folder data

EOF

read -p "Do you want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo "Resetting environment..."
docker compose down
docker compose up -d --build

echo "Environment reset complete!"
echo "You can now run './run.sh' to start"
