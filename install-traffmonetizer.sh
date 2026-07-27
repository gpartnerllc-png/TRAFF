#!/bin/bash

# ============================================================
# Traffmonetizer - Instalador Universal + Múltiplos Containers
# Suporta: AWS, GCP, Azure, Oracle, Vultr, Hetzner, etc.
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════╗"
echo "║     Traffmonetizer - Instalador Completo           ║"
echo "║     Múltiplos containers | Todas as Clouds         ║"
echo "╚════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ====================== VERIFICAÇÕES ======================
if [ -z "$TOKEN" ]; then
  echo -e "\( {RED}Erro: Token não informado! \){NC}"
  echo ""
  echo "Como usar (1 container):"
  echo -e "\( {YELLOW}TOKEN=seu_token bash install-traffmonetizer.sh \){NC}"
  echo ""
  echo "Como usar (vários containers):"
  echo -e "\( {YELLOW}TOKEN=seu_token QUANTIDADE=3 bash install-traffmonetizer.sh \){NC}"
  echo ""
  echo "Exemplo completo:"
  echo "TOKEN=seu_token QUANTIDADE=3 DEVICE_NAME=Cloud bash install-traffmonetizer.sh"
  exit 1
fi

QUANTIDADE=${QUANTIDADE:-1}
DEVICE_NAME=${DEVICE_NAME:-Cloud}
PREFIXO=${PREFIXO:-tm}

# ====================== DETECTAR ARQUITETURA ======================
ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64)
    IMAGE="traffmonetizer/cli_v2:arm64v8"
    ARCH_NAME="ARM64"
    ;;
  armv7l)
    IMAGE="traffmonetizer/cli_v2:arm32v7"
    ARCH_NAME="ARM32"
    ;;
  *)
    IMAGE="traffmonetizer/cli_v2"
    ARCH_NAME="x86_64"
    ;;
esac

echo -e "${YELLOW}→ Arquitetura     : \( ARCH_NAME \){NC}"
echo -e "${YELLOW}→ Quantidade      : \( QUANTIDADE container(s) \){NC}"
echo -e "${YELLOW}→ Prefixo         : \( PREFIXO \){NC}"
echo -e "${YELLOW}→ Nome base       : \( DEVICE_NAME \){NC}"
echo ""

# ====================== INSTALAR DOCKER ======================
echo -e "\( {GREEN}[1/3] Verificando / Instalando Docker... \){NC}"

if command -v docker &> /dev/null; then
  echo -e "\( {GREEN}Docker já está instalado. \){NC}"
else
  echo "Instalando Docker..."
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker > /dev/null 2>&1
  systemctl start docker > /dev/null 2>&1
fi

# ====================== CRIAR CONTAINERS ======================
echo -e "${GREEN}[2/3] Criando \( QUANTIDADE container(s)... \){NC}"
echo ""

for i in $(seq 1 $QUANTIDADE); do
  CONTAINER_NAME="\( {PREFIXO}- \){i}"
  DEVICE_FULL="\( {DEVICE_NAME}- \){i}"

  # Remover se já existir
  docker rm -f $CONTAINER_NAME > /dev/null 2>&1

  # Criar novo container
  docker run -d \
    --name $CONTAINER_NAME \
    --restart always \
    $IMAGE start accept \
    --token "$TOKEN" \
    --device-name "$DEVICE_FULL" > /dev/null

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ $CONTAINER_NAME criado com sucesso → \( DEVICE_FULL \){NC}"
  else
    echo -e "${RED}✗ Falha ao criar \( CONTAINER_NAME \){NC}"
  fi
done

# ====================== RESULTADO FINAL ======================
echo ""
echo -e "\( {GREEN}[3/3] Verificando containers... \){NC}"
sleep 2

echo ""
echo -e "\( {CYAN}Containers em execução: \){NC}"
docker ps --filter "name=$PREFIXO" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

echo ""
echo -e "\( {GREEN}╔════════════════════════════════════════════════════╗ \){NC}"
echo -e "\( {GREEN}║              INSTALAÇÃO CONCLUÍDA!                 ║ \){NC}"
echo -e "\( {GREEN}╚════════════════════════════════════════════════════╝ \){NC}"
echo ""
echo -e "Arquitetura     : ${YELLOW}\( ARCH_NAME \){NC}"
echo -e "Imagem          : ${YELLOW}\( IMAGE \){NC}"
echo -e "Quantidade      : ${YELLOW}\( QUANTIDADE \){NC}"
echo ""
echo "Comandos úteis:"
echo "  docker ps"
echo "  docker logs ${PREFIXO}-1"
echo "  docker restart ${PREFIXO}-1"
echo "  docker stop \$(docker ps -q --filter name=$PREFIXO)"
echo "  docker rm -f \$(docker ps -aq --filter name=$PREFIXO)"
