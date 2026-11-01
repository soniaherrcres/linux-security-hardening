#!/bin/bash
# ==============================================================================
# Script de Auditoría Básica y Endurecimiento de Seguridad (Linux)
# Autora: Sonia Herrera
# Descripción: Comprueba permisos críticos, usuarios y estado del cortafuegos.
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sin color

echo -e "${YELLOW}==========================================${NC}"
echo -e "${YELLOW}   INFORME DE AUDITORÍA Y SEGURIDAD LINUX ${NC}"
echo -e "${YELLOW}==========================================${NC}\n"

# 1. Verificación de privilegios de root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Advertencia: Se recomienda ejecutar como root para auditorías completas.${NC}"
else
  echo -e "${GREEN}[+] Ejecutando con privilegios de root.${NC}"
fi

# 2. Comprobación de usuarios con acceso de shell activo
echo -e "\n${YELLOW}[1/3] Analizando cuentas de usuario activas...${NC}"
awk -F: '($3 >= 1000 && $7 != "/sbin/nologin" && $7 != "/bin/false") {print " -> Usuario detectado: " $1 " (Shell: " $7 ")"}' /etc/passwd

# 3. Verificación del cortafuegos (UFW)
echo -e "\n${YELLOW}[2/3] Comprobando el estado del cortafuegos (UFW)...${NC}"
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status | grep "Status" | awk '{print $2}')
    if [ "$UFW_STATUS" == "active" ]; then
        echo -e "${GREEN} -> UFW está activo y operando correctamente.${NC}"
    else
        echo -e "${RED} -> Alerta: UFW está inactivo.${NC}"
    fi
else
    echo -e "${YELLOW} -> UFW no está instalado en este sistema.${NC}"
fi

# 4. Revisión de permisos en ficheros críticos
echo -e "\n${YELLOW}[3/3] Verificando permisos del archivo /etc/passwd...${NC}"
PERMS=$(stat -c "%a" /etc/passwd)
if [ "$PERMS" -eq 644 ]; then
    echo -e "${GREEN} -> Permisos correctos ($PERMS) para /etc/passwd.${NC}"
else
    echo -e "${RED} -> Alerta: Permisos inseguros ($PERMS) en /etc/passwd.${NC}"
fi

echo -e "\n${YELLOW}=== Auditoría finalizada con éxito ===${NC}"