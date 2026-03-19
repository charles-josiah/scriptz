#!/bin/bash

# =========================================================================
# Description: Yet another Docker & Docker Compose installation script
# Target OS:  Ubuntu 22.04 (Jammy), 24.04 (Noble), and newer.
# Author:   Charles Josiah Rusch Alandt and Mano, my Gemini Assistant
# =========================================================================

set -e # Exit immediately if a command exits with a non-zero status

echo "--- Starting Docker Installation ---"

# 1. Clean up old versions
echo "Removing any conflicting Docker packages..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc > /dev/null 2>&1 || true

# 2. Setup dependencies
echo "Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# 3. Add Docker’s official GPG key
echo "Configuring GPG keys..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Add the repository to Apt sources
echo "Adding Docker repository to Apt..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker Engine and Compose Plugin
echo "Installing Docker Engine, CLI, and Compose Plugin..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Post-installation steps (Manage Docker as a non-root user)
echo "Adding user '$USER' to the docker group..."
sudo usermod -aG docker $USER

echo "--- Installation Complete! ---"
echo "IMPORTANT: To apply group changes, log out and log back in, or run: newgrp docker"
echo "Verify with: docker compose version"
