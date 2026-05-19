#!/usr/bin/env bash

# =========================================================
# Escáner TCP rápido hasta el puerto 50000
# =========================================================
#Autor: Carlos Martín
#
# Uso:
#   chmod +x fastscan.sh
#   ./fastscan.sh <IP OBJETIVO> (en caso de no introducir IP se usa la 127.0.0.1)
#
# Ejemplo:
#   ./fastscan.sh 127.0.0.1
#
# =========================================================

TARGET="${1:-127.0.0.1}"
MAX_PORT=50000
MAX_JOBS=300

echo "[+] Escaneando $TARGET hasta el puerto $MAX_PORT..."
echo

scan_port() {
    local port=$1

    timeout 0.2 bash -c "echo >/dev/tcp/$TARGET/$port" 2>/dev/null && \
        echo "[ABIERTO] Puerto $port"
}

for ((port=1; port<=MAX_PORT; port++)); do
    scan_port "$port" &

    # Limitar procesos simultáneos
    while (( $(jobs -r | wc -l) >= MAX_JOBS )); do
        sleep 0.05
    done
done

wait

echo
echo "[+] Escaneo finalizado"
