#!/bin/bash
# /opt/refresh.sh
# Configurar no cron para rodar a cada 10 minutos:
# */10 * * * * DISPLAY=:0 /opt/refresh.sh

LOG="/home/operador/kiosk.log"
export DISPLAY=:0

echo "[$(date)] Recarregando página..." >> "$LOG"

WID=$(xdotool search --onlyvisible --class chromium | head -1)
if [ -n "$WID" ]; then
    xdotool key --window "$WID" F5
    echo "[$(date)] F5 enviado." >> "$LOG"
else
    echo "[$(date)] Janela não encontrada." >> "$LOG"
fi
