#!/bin/bash

# =============================================================================
# Script para obtener SHA-256 fingerprints de certificados SSL
# =============================================================================
#
# Este script obtiene los fingerprints SHA-256 de los certificados SSL
# de los servidores configurados. Los fingerprints deben copiarse a
# lib/core/config/app_config.dart
#
# Uso:
#   ./scripts/get_cert_fingerprints.sh
#
# Requisitos:
#   - openssl instalado
#   - Acceso a los servidores (puerto 443 o puerto custom)
# =============================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}    SSL Certificate Fingerprint Utility${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# Función para obtener fingerprint
get_fingerprint() {
    local host=$1
    local port=$2
    local name=$3
    
    echo -e "${YELLOW}=== $name ($host:$port) ===${NC}"
    
    # Intentar obtener el certificado
    fingerprint=$(echo | openssl s_client -connect "$host:$port" -servername "$host" 2>/dev/null | openssl x509 -fingerprint -sha256 -noout 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$fingerprint" ]; then
        # Extraer solo el fingerprint (remover "SHA256 Fingerprint=")
        fingerprint_clean=$(echo "$fingerprint" | sed 's/SHA256 Fingerprint=//')
        echo -e "${GREEN}✓ Fingerprint obtenido:${NC}"
        echo -e "  $fingerprint_clean"
        echo ""
        echo -e "${BLUE}Copiar a app_config.dart:${NC}"
        echo -e "  '$fingerprint_clean',"
        echo ""
    else
        echo -e "${RED}✗ No se pudo conectar a $host:$port${NC}"
        echo -e "  Posibles causas:"
        echo -e "  - El servidor no está ejecutándose"
        echo -e "  - El puerto es incorrecto"
        echo -e "  - El servidor no tiene HTTPS habilitado"
        echo ""
    fi
}

# Función para obtener fingerprint de un servidor sin SNI
get_fingerprint_no_sni() {
    local host=$1
    local port=$2
    local name=$3
    
    echo -e "${YELLOW}=== $name ($host:$port) ===${NC}"
    
    fingerprint=$(echo | openssl s_client -connect "$host:$port" 2>/dev/null | openssl x509 -fingerprint -sha256 -noout 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$fingerprint" ]; then
        fingerprint_clean=$(echo "$fingerprint" | sed 's/SHA256 Fingerprint=//')
        echo -e "${GREEN}✓ Fingerprint obtenido:${NC}"
        echo -e "  $fingerprint_clean"
        echo ""
        echo -e "${BLUE}Copiar a app_config.dart:${NC}"
        echo -e "  '$fingerprint_clean',"
        echo ""
    else
        echo -e "${RED}✗ No se pudo conectar a $host:$port${NC}"
        echo ""
    fi
}

# =============================================================================
# SERVIDORES LOCALES (DESARROLLO)
# =============================================================================

echo -e "${BLUE}Servidores Locales:${NC}"
echo ""

# Backend NestJS (normalmente HTTP en desarrollo, pero si tienes HTTPS:)
# get_fingerprint_no_sni "localhost" 3000 "Backend NestJS"

# FastAPI Music Service
# get_fingerprint_no_sni "localhost" 8000 "Music Service (FastAPI)"

# Docker services (si usas docker-compose)
# get_fingerprint_no_sni "backend" 3000 "Backend (Docker)"
# get_fingerprint_no_sni "music_service" 8000 "Music Service (Docker)"

# =============================================================================
# SERVIDORES DE PRODUCCIÓN
# =============================================================================

echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}    Servidores de Producción${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# DESCOMENTAR Y CONFIGURAR PARA PRODUCCIÓN:
# Reemplaza 'api.tudominio.com' con tu dominio real

# Backend API
# get_fingerprint "api.tudominio.com" 443 "Backend API (Producción)"

# Music Service
# get_fingerprint "music-api.tudominio.com" 443 "Music Service (Producción)"

# =============================================================================
# INSTRUCCIONES
# =============================================================================

echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}    Instrucciones${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo -e "1. Copia los fingerprints obtenidos a ${YELLOW}lib/core/config/app_config.dart${NC}"
echo ""
echo -e "2. Agrega los fingerprints a la lista ${GREEN}sslFingerprints${NC}:"
echo ""
echo -e "   static const List<String> sslFingerprints = ["
echo -e "     'A1:B2:C3:D4:E5:F6:...',  // Producción"
echo -e "     '11:22:33:44:55:66:...',  // Backup/CA"
echo -e "   ];"
echo ""
echo -e "3. Habilita SSL Pinning en ${YELLOW}env.json${NC} o con dart-define:"
echo ""
echo -e "   flutter run --dart-define=SSL_PINNING_ENABLED=true"
echo ""
echo -e "4. Para producción, asegúrate de:"
echo -e "   - ${RED}NUNCA${NC} usar bypassSslPinningInDebug = true"
echo -e "   - Incluir fingerprints de certificados de backup"
echo -e "   - Actualizar fingerprints cuando rotes certificados"
echo ""
echo -e "${YELLOW}Nota:${NC} Los certificados Let's Encrypt rotan cada 90 días."
echo -e "Considera usar certificados de CA raíz o fingerprints de CA intermedia."
echo ""
