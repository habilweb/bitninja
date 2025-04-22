#!/bin/bash

# Script de escaneo y limpieza con BitNinja
# Autor: Hans + ChatGPT

CUARENTENA="/root/malware_cuarentena"
SOSPECHOSOS="/root/archivos_sospechosos.txt"
FECHA=$(date +"%Y-%m-%d_%H-%M")

echo "=== 🚧 CREANDO CARPETA DE CUARENTENA: $CUARENTENA"
mkdir -p "$CUARENTENA"
chmod 700 "$CUARENTENA"

echo "=== 🧹 BORRANDO CACHÉ DE DETECCIÓN DE MALWARE"
rm -f /var/lib/bitninja/MalwareDetection/filesystem.db*
sleep 2

echo "=== 🔁 REINICIANDO BITNINJA"
service bitninja restart
sleep 5

echo "=== 🔍 ESCANEANDO /home COMPLETAMENTE CON BITNINJA"
bitninjacli --module=MalwareDetection --scan --path=/home

echo "=== 🧪 BUSCANDO ARCHIVOS CON FUNCIONES MALICIOSAS EN PHP"
grep -rl --include="*.php" -E "eval\(|base64_decode\(|gzinflate\(|shell_exec\(|exec\(|system\(|assert\(|passthru\(" /home/ > "$SOSPECHOSOS"

echo "=== 🚛 MOVIENDO ARCHIVOS SOSPECHOSOS A $CUARENTENA (si hay)"
if [ -s "$SOSPECHOSOS" ]; then
    mkdir -p "$CUARENTENA/$FECHA"
    xargs -a "$SOSPECHOSOS" -I{} mv -v {} "$CUARENTENA/$FECHA/" 2>/dev/null
else
    echo "✅ No se encontraron archivos sospechosos por grep."
fi

echo "=== 📌 FIN DEL ESCANEO ==="
echo "Puedes revisar: $SOSPECHOSOS y $CUARENTENA/$FECHA"
