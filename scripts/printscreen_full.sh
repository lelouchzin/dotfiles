#!/bin/bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
FILE="$DIR/screenshot_full_$TIMESTAMP.png"

# Tira screenshot da tela inteira
grim "$FILE"

# Copia para clipboard
wl-copy < "$FILE"

# Notificação
notify-send "Screenshot" "Screenshot da tela inteira salva e copiada para clipboard: $FILE"
