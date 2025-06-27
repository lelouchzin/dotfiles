#!/bin/bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
FILE="$DIR/screenshot_$TIMESTAMP.png"

# Seleciona área, se cancelou, sai sem erro
AREA=$(slurp)
if [ -z "$AREA" ]; then
  exit 0
fi

# Tira print da área selecionada
grim -g "$AREA" "$FILE"

# Copia imagem para o clipboard
wl-copy < "$FILE"

# Notificação com swaync
notify-send "Screenshot" "Screenshot saved and copied to clipboard: $FILE"
