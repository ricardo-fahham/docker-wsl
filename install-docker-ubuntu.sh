#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Docker Installer for Ubuntu
# ==============================

DOCKER_GPG_KEYRING="/etc/apt/keyrings/docker.gpg"
DOCKER_REPO_FILE="/etc/apt/sources.list.d/docker.list"

MIN_UBUNTU_VERSION="22.04"

log() {
  echo -e "\n[INFO] $1"
}

error() {
  echo -e "\n[ERROR] $1" >&2
  exit 1
}

# ------------------------------
# Check root
# ------------------------------
if [[ "$EUID" -ne 0 ]]; then
  error "Execute este script como root (use sudo)."
fi

# ------------------------------
# Check OS
# ------------------------------
if [[ -r /etc/os-release ]]; then
  source /etc/os-release
else
  error "Não foi possível detectar o sistema operacional."
fi

if [[ "${ID:-}" != "ubuntu" ]]; then
  error "Este script suporta apenas Ubuntu. Detectado: ${ID:-unknown}"
fi

log "Sistema detectado: Ubuntu ${VERSION_ID:-unknown}"

# ------------------------------
# Check Ubuntu version
# ------------------------------
if [[ -n "${VERSION_ID:-}" ]]; then
  REQUIRED_MAJOR=$(echo "$MIN_UBUNTU_VERSION" | cut -d. -f1)
  CURRENT_MAJOR=$(echo "$VERSION_ID" | cut -d. -f1)

  if (( CURRENT_MAJOR < REQUIRED_MAJOR )); then
    error "Ubuntu ${MIN_UBUNTU_VERSION}+ é necessário. Atual: ${VERSION_ID}"
  fi
fi

# ------------------------------
# Update base packages
# ------------------------------
log "Atualizando pacotes base..."
apt update -y
apt install -y ca-certificates curl gnupg lsb-release

# ------------------------------
# Create keyrings directory
# ------------------------------
log "Configurando chave GPG do Docker..."
install -m 0755 -d /etc/apt/keyrings

if [[ ! -f "$DOCKER_GPG_KEYRING" ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o "$DOCKER_GPG_KEYRING"
  chmod a+r "$DOCKER_GPG_KEYRING"
else
  log "Chave GPG já existe, ignorando..."
fi

# ------------------------------
# Add repository
# ------------------------------
ARCH=$(dpkg --print-architecture)
CODENAME=$(lsb_release -cs)

log "Adicionando repositório Docker (${CODENAME}, ${ARCH})..."

cat > "$DOCKER_REPO_FILE" <<EOF
deb [arch=${ARCH} signed-by=${DOCKER_GPG_KEYRING}] https://download.docker.com/linux/ubuntu ${CODENAME} stable
EOF

# ------------------------------
# Install Docker
# ------------------------------
log "Instalando Docker Engine..."
apt update -y

apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# ------------------------------
# Enable service (systemd if available)
# ------------------------------
log "Configurando serviço Docker..."

if command -v systemctl >/dev/null 2>&1; then
  systemctl enable docker || true

  if systemctl list-unit-files | grep -q docker; then
    systemctl start docker || true
  fi
else
  log "systemctl não disponível (possível WSL sem systemd)."
  log "Você pode iniciar manualmente: sudo dockerd"
fi

# ------------------------------
# Post-install validation
# ------------------------------
log "Validando instalação..."

if ! command -v docker >/dev/null 2>&1; then
  error "Docker não foi instalado corretamente."
fi

docker --version

log "Testando execução do Docker..."

if docker run --rm hello-world >/dev/null 2>&1; then
  log "Docker instalado e funcionando corretamente!"
else
  log "Docker instalado, mas o teste hello-world falhou."
  log "Verifique se o daemon está rodando: sudo systemctl status docker"
fi

# ------------------------------
# Optional: add user to docker group
# ------------------------------
if [[ -n "${SUDO_USER:-}" ]]; then
  log "Adicionando usuário '${SUDO_USER}' ao grupo docker..."
  usermod -aG docker "$SUDO_USER"

  log "OBS: você precisa reiniciar a sessão para aplicar permissões."
fi

log "Instalação concluída com sucesso!"