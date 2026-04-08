#!/bin/bash
# ==============================================================================
# install.sh — Setup do sistema Arch Linux (Hyprland + ferramentas)
# Autor: lelouch
# Uso: bash install.sh
# ==============================================================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[AVISO]${NC} $1"; }
error()   { echo -e "${RED}[ERRO]${NC} $1"; exit 1; }
step()    { echo -e "\n${CYAN}========== $1 ==========${NC}"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

# ==============================================================================
# 0. VERIFICAÇÕES INICIAIS
# ==============================================================================
step "Verificando ambiente"

[[ "$(uname -s)" != "Linux" ]] && error "Este script requer Linux."
[[ ! -f /etc/arch-release ]] && error "Este script requer Arch Linux."
[[ "$(id -u)" == "0" ]] && error "Não execute como root. O script usará sudo quando necessário."

command -v git &>/dev/null || error "git não encontrado. Instale com: sudo pacman -S git"

success "Ambiente OK — usuário: $USER, home: $HOME_DIR"

# ==============================================================================
# 1. ATUALIZAR SISTEMA
# ==============================================================================
step "Atualizando pacotes do sistema"
sudo pacman -Syu --noconfirm
success "Sistema atualizado"

# ==============================================================================
# 2. INSTALAR YAY (AUR Helper)
# ==============================================================================
step "Instalando yay (AUR helper)"
if ! command -v yay &>/dev/null; then
    sudo pacman -S --noconfirm --needed base-devel git
    TMPDIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TMPDIR/yay"
    (cd "$TMPDIR/yay" && makepkg -si --noconfirm)
    rm -rf "$TMPDIR"
    success "yay instalado"
else
    success "yay já instalado"
fi

# ==============================================================================
# 3. PACOTES OFICIAIS (pacman)
# ==============================================================================
step "Instalando pacotes oficiais"

PACMAN_PACKAGES=(
    # Base
    base base-devel git nano wget unzip zip curl cmake cpio

    # Shell
    zsh

    # Hyprland e Wayland
    hyprland hyprpaper hyprlock hypridle hyprpicker
    xdg-desktop-portal-hyprland
    xorg-server xorg-xinit xorg-xkill
    wl-clipboard grim slurp

    # Status bar, launcher, notificações
    waybar wofi swaync swayidle

    # Terminal e ferramentas de terminal
    kitty htop neovim lsof nmap sl cmatrix

    # Gerenciador de arquivos
    thunar gvfs

    # Áudio
    pipewire pipewire-alsa pipewire-jack pipewire-pulse
    wireplumber libpulse gst-plugin-pipewire
    pavucontrol alsa-utils

    # Rede
    networkmanager network-manager-applet iwd

    # Bluetooth
    bluez blueman

    # Display manager
    ly

    # Intel GPU
    intel-media-driver intel-ucode libva-intel-driver vulkan-intel

    # Fontes
    noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-nerd-fonts-symbols-mono otf-codenewroman-nerd

    # Temas e aparência
    materia-gtk-theme nwg-look

    # Python e ferramentas
    python-pywal python-pillow python-pip python-pipx tk

    # Java / Maven
    jdk17-openjdk maven

    # Docker
    docker

    # Banco de dados
    mariadb

    # Rust
    rust

    # Disco e boot
    dosfstools efibootmgr mtools

    # Outros utilitários
    flatpak sshpass spotify-launcher
    firefox code sof-firmware
    fastfetch zram-generator

    # Captura de tela e brightness
    # (brightnessctl instalado via AUR abaixo)
)

FAILED_PKGS=()
for pkg in "${PACMAN_PACKAGES[@]}"; do
    sudo pacman -S --noconfirm --needed "$pkg" 2>/dev/null || {
        warn "Pacote não encontrado (pulando): $pkg"
        FAILED_PKGS+=("$pkg")
    }
done
[ ${#FAILED_PKGS[@]} -gt 0 ] && warn "Pacotes não instalados: ${FAILED_PKGS[*]}" || true
success "Pacotes oficiais instalados"

# ==============================================================================
# 4. PACOTES AUR
# ==============================================================================
step "Instalando pacotes AUR"

AUR_PACKAGES=(
    yay
    beekeeper-studio-bin
    postman-bin
    mongodb-bin
    mongosh-bin
    illogical-impulse-bibata-modern-classic-bin
    qogir-icon-theme
    woeusb-ng
    iwgtk
    pipes.sh
    2048.zig-bin
    brightnessctl
    playerctl
)

yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"
success "Pacotes AUR instalados"

# ==============================================================================
# 5. OH MY ZSH
# ==============================================================================
step "Instalando Oh My Zsh"

if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    success "Oh My Zsh instalado"
else
    success "Oh My Zsh já instalado"
fi

# Instalar tema personalizado "lelouch"
mkdir -p "$HOME_DIR/.oh-my-zsh/themes"
if [ -f "$DOTFILES_DIR/home/.oh-my-zsh/custom/themes/lelouch.zsh-theme" ]; then
    cp "$DOTFILES_DIR/home/.oh-my-zsh/custom/themes/lelouch.zsh-theme" \
       "$HOME_DIR/.oh-my-zsh/themes/lelouch.zsh-theme"
    success "Tema lelouch instalado"
fi

# ==============================================================================
# 6. NVM + NODE
# ==============================================================================
step "Instalando NVM e Node.js"

if [ ! -d "$HOME_DIR/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    success "NVM instalado"
fi

# Carregar nvm no contexto atual
export NVM_DIR="$HOME_DIR/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Instalar Node LTS v22
if command -v nvm &>/dev/null; then
    nvm install 22
    nvm use 22
    nvm alias default 22
    success "Node.js v22 instalado"
fi

# ==============================================================================
# 7. ANGULAR CLI
# ==============================================================================
step "Instalando Angular CLI"
if command -v npm &>/dev/null; then
    npm install -g @angular/cli 2>/dev/null && success "Angular CLI instalado" || warn "Falha ao instalar Angular CLI"
fi

# ==============================================================================
# 8. COPIAR DOTFILES / CONFIGURAÇÕES
# ==============================================================================
step "Copiando configurações (.config)"

# Backup das configs existentes
BACKUP_DIR="$HOME_DIR/.config_backup_$(date +%Y%m%d_%H%M%S)"
if [ -d "$HOME_DIR/.config" ]; then
    warn "Fazendo backup de ~/.config em $BACKUP_DIR"
    cp -r "$HOME_DIR/.config" "$BACKUP_DIR"
fi

# Copiar configs do dotfiles
CONFIG_DIRS=(
    hypr waybar wofi kitty swaync cava fastfetch
    scripts wallpapers gtk-3.0 gtk-4.0 htop autostart
    xsettingsd nwg-look wal
)

mkdir -p "$HOME_DIR/.config"
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$DOTFILES_DIR/config/$dir" ]; then
        cp -r "$DOTFILES_DIR/config/$dir" "$HOME_DIR/.config/"
        success "Config copiada: $dir"
    fi
done

# Arquivos soltos de config
for file in mimeapps.list pavucontrol.ini; do
    if [ -f "$DOTFILES_DIR/config/$file" ]; then
        cp "$DOTFILES_DIR/config/$file" "$HOME_DIR/.config/"
    fi
done

# Copiar .zshrc
if [ -f "$DOTFILES_DIR/home/.zshrc" ]; then
    cp "$DOTFILES_DIR/home/.zshrc" "$HOME_DIR/.zshrc"
    success ".zshrc copiado"
fi

# ==============================================================================
# 9. AJUSTAR PATHS NO FASTFETCH (usuário pode ter nome diferente)
# ==============================================================================
step "Ajustando paths do fastfetch para usuário atual"

FASTFETCH_CFG="$HOME_DIR/.config/fastfetch/config.jsonc"
if [ -f "$FASTFETCH_CFG" ]; then
    sed -i "s|/home/lelouch|$HOME_DIR|g" "$FASTFETCH_CFG"
    success "Paths fastfetch ajustados"
fi

# ==============================================================================
# 10. AJUSTAR PATHS DO HYPRPAPER (wallpaper)
# ==============================================================================
HYPRPAPER_CFG="$HOME_DIR/.config/hypr/hyprpaper.conf"
if [ -f "$HYPRPAPER_CFG" ]; then
    sed -i "s|/home/lelouch|$HOME_DIR|g" "$HYPRPAPER_CFG"
    success "Paths hyprpaper ajustados"
fi

# Scripts
for script in "$HOME_DIR/.config/scripts/"*.py "$HOME_DIR/.config/scripts/"*.sh; do
    [ -f "$script" ] && sed -i "s|/home/lelouch|$HOME_DIR|g" "$script" && chmod +x "$script"
done

# ==============================================================================
# 11. CONFIGURAR ZSH COMO SHELL PADRÃO
# ==============================================================================
step "Configurando zsh como shell padrão"

ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    chsh -s "$ZSH_PATH" "$USER"
    success "zsh definido como shell padrão (reinicie a sessão)"
else
    success "zsh já é o shell padrão"
fi

# ==============================================================================
# 12. HABILITAR SERVIÇOS DO SISTEMA
# ==============================================================================
step "Habilitando serviços do sistema"

SYSTEM_SERVICES=(
    NetworkManager
    bluetooth
    iwd
    mariadb
    mongodb
    fstrim.timer
)

for service in "${SYSTEM_SERVICES[@]}"; do
    if systemctl list-unit-files "${service}.service" 2>/dev/null | grep -q "${service}"; then
        sudo systemctl enable "$service" && success "Serviço habilitado: $service" || warn "Falha ao habilitar: $service"
    else
        warn "Serviço não encontrado, pulando: $service"
    fi
done

# Configurar Ly como display manager
step "Configurando Ly (display manager)"

# Desabilitar DMs conflitantes
for dm in gdm sddm lightdm lxdm xdm; do
    if systemctl list-unit-files "${dm}.service" 2>/dev/null | grep -q "$dm"; then
        if systemctl is-enabled "$dm" &>/dev/null; then
            sudo systemctl disable "$dm" && warn "DM conflitante desabilitado: $dm"
        fi
    fi
done

if systemctl list-unit-files "ly@.service" 2>/dev/null | grep -q "ly"; then
    # Ly 1.3+ usa serviço template — habilitar no tty2
    sudo systemctl enable ly@tty2.service && success "Ly habilitado em tty2" || error "Falha ao habilitar ly@tty2.service"
else
    warn "ly@.service não encontrado — verifique se o pacote 'ly' foi instalado"
fi

# Habilitar serviços de usuário
USER_SERVICES=(
    pipewire
    pipewire-pulse
    wireplumber
)

for service in "${USER_SERVICES[@]}"; do
    systemctl --user enable "$service" 2>/dev/null && success "Serviço de usuário habilitado: $service" || warn "Falha: $service"
done

# ==============================================================================
# 13. CONFIGURAR MARIADB
# ==============================================================================
step "Inicializando MariaDB"

if command -v mariadb-install-db &>/dev/null; then
    if [ ! -d /var/lib/mysql/mysql ]; then
        sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
        success "MariaDB inicializado"
    else
        success "MariaDB já inicializado"
    fi
fi

# ==============================================================================
# 14. CONFIGURAR DOCKER
# ==============================================================================
step "Configurando Docker"

if command -v docker &>/dev/null; then
    sudo systemctl enable docker 2>/dev/null
    sudo usermod -aG docker "$USER" 2>/dev/null
    success "Docker configurado — reinicie a sessão para aplicar grupo"
fi

# ==============================================================================
# 15. ZRAM
# ==============================================================================
step "Configurando ZRAM"

ZRAM_CFG="/etc/systemd/zram-generator.conf"
if [ ! -f "$ZRAM_CFG" ]; then
    sudo bash -c "cat > $ZRAM_CFG << 'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF"
    success "ZRAM configurado"
else
    success "ZRAM já configurado"
fi

# ==============================================================================
# 16. ATIVAR PYWAL (gerar cores do wallpaper)
# ==============================================================================
step "Ativando pywal"

if command -v wal &>/dev/null; then
    WALLPAPER=$(ls "$HOME_DIR/.config/wallpapers/"*.{png,jpg,jpeg} 2>/dev/null | head -1)
    if [ -n "$WALLPAPER" ]; then
        wal -i "$WALLPAPER" -n 2>/dev/null && success "Pywal configurado com: $WALLPAPER" || warn "Pywal falhou"
    else
        warn "Nenhum wallpaper encontrado em ~/.config/wallpapers/"
    fi
fi

# ==============================================================================
# AVISO SOBRE MONITORES
# ==============================================================================
echo ""
warn "IMPORTANTE — Configuração de monitores:"
echo "  O hyprland.conf está configurado para:"
echo "    monitor=eDP-1,1366x768@60,0x0,1       (tela interna do notebook)"
echo "    monitor=HDMI-A-1,1920x1080@60,1366x0,1 (monitor externo HDMI)"
echo ""
echo "  Se os nomes dos seus monitores forem diferentes, edite:"
echo "  ~/.config/hypr/hyprland.conf"
echo "  Use 'hyprctl monitors' para ver os nomes dos monitores."
echo ""

# ==============================================================================
# CONCLUÍDO
# ==============================================================================
echo ""
echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}  Instalação concluída! Próximos passos:${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo ""
echo "  1. Reinicie o sistema: sudo reboot"
echo "  2. No login (ly), selecione Hyprland"
echo "  3. Configure monitores se necessário:"
echo "     hyprctl monitors"
echo "     nano ~/.config/hypr/hyprland.conf"
echo "  4. Para selecionar wallpaper: Super + W"
echo "  5. Para abrir terminal: Super + T"
echo "  6. Para lançar apps: Super + Space"
echo ""
