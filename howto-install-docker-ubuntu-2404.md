# Howto - Instalacao do Docker no Ubuntu 24.04 LTS

Este guia ensina como instalar o Docker no Ubuntu 24.04 de forma segura e atualizada, utilizando o repositório oficial da Docker Inc.

## 1. Atualizar o sistema

```bash
sudo apt update && sudo apt upgrade -y
```

## 2. Instalar dependencias necessarias

```bash
sudo apt install -y ca-certificates curl gnupg lsb-release
```

## 3. Adicionar a chave GPG oficial do Docker

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

## 4. Adicionar o repositorio do Docker

```bash
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg]   https://download.docker.com/linux/ubuntu   $(lsb_release -cs) stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

## 5. Atualizar os pacotes e instalar o Docker Engine

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 6. Verificar a instalacao

```bash
sudo docker version
sudo docker run hello-world
```

## 7. (Opcional) Executar Docker como usuario normal

```bash
sudo usermod -aG docker $USER
newgrp docker
```

## 8. (Opcional) Habilitar Docker para iniciar com o sistema

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

## Referencia oficial

https://docs.docker.com/engine/install/ubuntu/
