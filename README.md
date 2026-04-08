# dotfiles — lelouch

> Arch Linux personalizado com Hyprland, temas dinâmicos via pywal e ambiente completo para desenvolvimento.

---

## Visão geral

```
OS        Arch Linux
WM        Hyprland (Wayland)
Bar       Waybar
Launcher  Wofi
Terminal  Kitty
Shell     Zsh + Oh My Zsh (tema lelouch)
Notif.    SwayNC
Lock      Hyprlock
Idle      Hypridle
Files     Thunar
Display   Ly
Audio     PipeWire + WirePlumber
GPU       Intel (mesa / vulkan-intel)
AUR       Yay
```

---

## Funcionalidades

### Temas dinâmicos com Pywal

O coração visual do setup é o **Pywal**. Ao selecionar um wallpaper, o script `wal_wallpaper_selector.py` automaticamente:

- Extrai a paleta de cores da imagem
- Aplica as cores nas bordas das janelas do Hyprland
- Atualiza o estilo do Waybar
- Recolore o terminal Kitty
- Atualiza o tema do Zsh

Tudo isso em tempo real, sem precisar reiniciar nada.

### Seletor de wallpaper

Acessível com `Super + W`, abre uma janela gráfica (Tkinter) com miniaturas de todos os wallpapers em `~/.config/wallpapers/`. Ao clicar em um, o tema inteiro é regenerado instantaneamente.

### Tela de bloqueio

O Hyprlock exibe um relógio grande no centro da tela com horas e minutos destacados, data no canto superior direito e saudação com o nome do usuário. Todas as cores seguem a paleta atual do Pywal.

O Hypridle gerencia a inatividade:
- **4:30 min** — trava a sessão
- **5:00 min** — desliga a tela

---

## Atalhos de teclado

> `Super` = tecla Windows

### Aplicativos

| Atalho | Ação |
|--------|------|
| `Super + T` | Abre o terminal (Kitty) |
| `Super + E` | Abre o gerenciador de arquivos (Thunar) |
| `Super + Space` | Abre o launcher (Wofi) |
| `Super + W` | Abre o seletor de wallpaper |
| `Super + L` | Trava a tela (Hyprlock) |

### Janelas

| Atalho | Ação |
|--------|------|
| `Super + Q` | Fecha a janela ativa |
| `Super + V` | Alterna janela flutuante |
| `Super + F` | Maximiza a janela |
| `Super + Shift + F` | Fullscreen real |
| `Super + Tab` | Cicla entre janelas |
| `Super + Setas` | Move o foco entre janelas |

### Workspaces

| Atalho | Ação |
|--------|------|
| `Super + 1..9` | Muda para o workspace |
| `Super + Shift + 1..9` | Move a janela para o workspace |

### Capturas de tela

| Atalho | Ação |
|--------|------|
| `Super + P` | Captura de área selecionada |
| `Super + Shift + P` | Captura a tela inteira |

### Sistema

| Atalho | Ação |
|--------|------|
| `Super + Escape` | Reinicia o Waybar |
| `XF86AudioRaiseVolume` | Volume +5% |
| `XF86AudioLowerVolume` | Volume -5% |
| `XF86AudioMute` | Muta/desmuta |
| `XF86AudioMicMute` | Muta/desmuta microfone |
| `XF86MonBrightnessUp` | Brilho +5% |
| `XF86MonBrightnessDown` | Brilho -5% |
| `XF86AudioNext/Prev/Play` | Controle de mídia (playerctl) |

---

## Waybar

A barra está posicionada no topo com três zonas:

- **Esquerda:** notificações (SwayNC), relógio, atualizações pendentes (pacman), tray
- **Centro:** indicador de workspaces com ícones
- **Direita:** grupo expansível com CPU, memória e temperatura · Bluetooth · Rede · Bateria

---

## Estrutura dos dotfiles

```
dotfiles/
├── config/
│   ├── hypr/          # Hyprland, Hyprlock, Hypridle, Hyprpaper
│   ├── waybar/        # Config e CSS da barra
│   ├── kitty/         # Terminal (cores via pywal)
│   ├── wofi/          # Launcher
│   ├── swaync/        # Central de notificações
│   ├── fastfetch/     # Fetch com logo personalizado
│   ├── scripts/       # wal_wallpaper_selector.py, printscreen, etc.
│   ├── wallpapers/    # Wallpapers
│   ├── gtk-3.0/       # Tema GTK3 (Materia)
│   ├── gtk-4.0/       # Tema GTK4
│   ├── wal/           # Templates do pywal
│   └── cava/          # Visualizador de áudio
├── home/
│   ├── .zshrc
│   └── .oh-my-zsh/custom/themes/lelouch.zsh-theme
├── lelouch.zsh-theme
└── install.sh
```

---

## Instalação

> Requer Arch Linux com `git` instalado.

```bash
git clone https://github.com/lelouch/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

O script realiza automaticamente:

1. Atualiza o sistema (`pacman -Syu`)
2. Instala o **yay** (AUR helper)
3. Instala todos os pacotes oficiais e AUR
4. Configura Oh My Zsh com o tema personalizado
5. Instala NVM + Node.js v22 + Angular CLI
6. Copia todas as configs para `~/.config`
7. Define Zsh como shell padrão
8. Habilita os serviços do sistema (NetworkManager, Bluetooth, Ly, Docker, MariaDB, PipeWire...)
9. Configura ZRAM (metade da RAM, compressão zstd)
10. Executa o Pywal com o primeiro wallpaper disponível

### Após a instalação

```bash
sudo reboot
```

No login do **Ly**, selecione **Hyprland**.

> Se seus monitores tiverem nomes diferentes de `eDP-1` e `HDMI-A-1`, edite `~/.config/hypr/hyprland.conf` e ajuste a seção `MONITORS`. Use `hyprctl monitors` para listar os seus.

---

## Configuração de monitores

O setup padrão é para um notebook com monitor externo via HDMI:

```
monitor=eDP-1,1366x768@60,0x0,1          # tela interna
monitor=HDMI-A-1,1920x1080@60,1366x0,1   # monitor externo
```

Edite `~/.config/hypr/hyprland.conf` conforme sua configuração.

---

## Fonte

Todo o sistema usa **CodeNewRoman Nerd Font** — incluindo terminal, tela de bloqueio e tema do Zsh.

---

## Tecnologias

| Categoria | Ferramenta |
|-----------|-----------|
| Compositor | Hyprland |
| Shell | Zsh + Oh My Zsh |
| Theming | Pywal |
| Áudio | PipeWire + WirePlumber |
| Rede | NetworkManager + iwd |
| Bluetooth | BlueZ + Blueman |
| Desenvolvimento | Node.js (nvm), Java 17, Maven, Rust, Docker, MariaDB, MongoDB |
| AUR Helper | Yay |
