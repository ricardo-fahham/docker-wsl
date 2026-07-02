# Docker no WSL2 sem Docker Desktop

Guia para instalar e utilizar o **Docker Engine** diretamente no **WSL2**, sem instalar ou depender do **Docker Desktop** no Windows.

## 📋 Visão Geral

É possível executar o Docker inteiramente dentro da distribuição Linux do WSL (Ubuntu, Debian, etc.), proporcionando um ambiente muito próximo de um servidor Linux.

### Benefícios

- Menor consumo de memória.
- Não depende do Docker Desktop.
- Não exige licença do Docker Desktop.
- Ambiente semelhante ao de servidores Linux.
- Ideal para desenvolvimento via terminal.

---

## ✅ Requisitos

Antes de começar, verifique se você possui:

- Windows 10 (versão 2004 ou superior) ou Windows 11;
- WSL2 habilitado;
- Virtualização habilitada na BIOS;
- Uma distribuição Linux instalada (Ubuntu, Debian, etc.).

---

# Opções de instalação

## Opção 1 — Docker Engine no WSL (Recomendado)

Instale o Docker Engine diretamente na distribuição Linux.

Vantagens:

- Não depende do Docker Desktop;
- Não requer licença do Docker Desktop;
- Ambiente mais próximo de um servidor Linux.

---

## Opção 2 — Utilizando systemd

As versões recentes do WSL suportam **systemd**, permitindo que o serviço do Docker seja iniciado automaticamente.

Verifique se o `systemd` está habilitado:

```bash
ps -p 1 -o comm=
```

Saída esperada:

```text
systemd
```

---

# Instalação do Docker Engine (Ubuntu)

## 1. Atualize os pacotes

```bash
sudo apt update
sudo apt install ca-certificates curl gnupg
```

---

## 2. Adicione o repositório oficial do Docker

Crie o diretório das chaves:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

Baixe a chave GPG:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

Adicione o repositório:

```bash
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

---

## 3. Instale o Docker

```bash
sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io \
docker-buildx-plugin docker-compose-plugin
```

---

## 4. Inicie o serviço

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

Verifique se o serviço está em execução:

```bash
systemctl status docker
```

Se a saída mostrar:

```text
active (running)
```

o Docker está funcionando corretamente.

---

# Testando a instalação

Execute:

```bash
docker run hello-world
```

Saída esperada:

```text
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
...

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

Se essa mensagem aparecer, a instalação foi concluída com sucesso.

---

# Vantagens de não usar o Docker Desktop

- Menor consumo de memória.
- Sem interface gráfica adicional.
- Ambiente semelhante ao de servidores Linux.
- Independência do Docker Desktop.
- Sem necessidade de licença do Docker Desktop.

---

# Limitações

Ao utilizar apenas o Docker Engine no WSL, você não terá:

- Interface gráfica para gerenciamento de containers;
- Extensões do Docker Desktop;
- Kubernetes integrado (pode ser instalado separadamente);
- Atualizações automáticas do Docker Engine.

Para desenvolvimento via terminal, essas limitações normalmente não representam um problema.

---

# Solução de problemas

### Verificar se o Docker está ativo

```bash
systemctl status docker
```

### Reiniciar o serviço

```bash
sudo systemctl restart docker
```

### Verificar a versão instalada

```bash
docker --version
```

### Verificar informações do daemon

```bash
docker info
```

---

# Ambiente suportado

Este guia é indicado para:

- Windows 10 (2004+)
- Windows 11
- Ubuntu 22.04+
- Ubuntu 24.04+
- Debian
- Outras distribuições Linux compatíveis com o Docker Engine

---

## Referências

- https://docs.docker.com/engine/install/ubuntu/
- https://learn.microsoft.com/windows/wsl/