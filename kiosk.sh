#!/bin/bash
# /opt/kiosk.sh


URL="[COLOQUE A SUA URL AQUI]"
LOG="[CAMINHO da LOG AQUI]/kiosk.log"
PROFILE_DIR="/home/[USUARIOAQUI]/.config/chromium"

export DISPLAY=:0

# Desativa screensaver e economia de energia
xset s off
xset -dpms
xset s noblank

echo "[$(date)] Iniciando kiosk..." >> "$LOG"

# ── 1. Aguarda conexão com a internet ──────────
echo "[$(date)] Aguardando rede..." >> "$LOG"
MAX_WAIT=60
ELAPSED=0

until ping -c1 -W2 8.8.8.8 &>/dev/null; do
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    if [ "$ELAPSED" -ge "$MAX_WAIT" ]; then
        echo "[$(date)] AVISO: rede indisponível, abrindo mesmo assim." >> "$LOG"
        break
    fi
done

echo "[$(date)] Rede OK após ${ELAPSED}s." >> "$LOG"

# ── 2. Limpa sessão anterior do Chromium ───────
rm -rf "$PROFILE_DIR/Default/Cache"/* 2>/dev/null
rm -rf "$PROFILE_DIR/Default/Code Cache"/* 2>/dev/null
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/g' \
    "$PROFILE_DIR/Default/Preferences" 2>/dev/null

# ── 3. Loop – reabre o Chromium se fechar ──────
while true; do
    echo "[$(date)] Abrindo $URL" >> "$LOG"

    /usr/bin/chromium-browser \
        --kiosk \
        --incognito \
        --no-sandbox \
        --noerrdialogs \
        --disable-infobars \
        --no-first-run \
        --disable-application-cache \
        --disk-cache-size=0 \
        --disable-session-crashed-bubble \
        --disable-restore-session-state \
        --disable-sync \
        "$URL" >> "$LOG" 2>&1

    echo "[$(date)] Chromium fechou, reiniciando em 5s..." >> "$LOG"
    sleep 5
done
