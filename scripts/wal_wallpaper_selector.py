#!/usr/bin/env python3
import subprocess
from pathlib import Path
import json
import tkinter as tk
from PIL import Image, ImageTk

# Caminhos de configuração
WALLPAPER_DIR = Path("/home/lelouch/.config/wallpapers")
WAL_CACHE = Path.home() / ".cache" / "wal" / "colors.json"
HYPRLAND_CONF = Path.home() / ".config" / "hypr" / "hyprland.conf"
HYPRPAPER_CONF = Path.home() / ".config" / "hypr" / "hyprpaper.conf"
KITTY_CONF = Path.home() / ".config" / "kitty" / "kitty.conf"
ZSHRC = Path.home() / ".zshrc"
WAYBAR_CSS_PATH = Path.home() / ".config" / "waybar" / "style.css"

THUMBNAIL_SIZE = (180, 120)

def load_colors():
    with open(WAL_CACHE) as f:
        return json.load(f)

def hex_to_rgba(hex_color, alpha='ee'):
    hex_color = hex_color.lstrip('#')
    return f"rgba({hex_color[0:2]}{hex_color[2:4]}{hex_color[4:6]}{alpha})"

def update_hyprland_conf(active_hex, inactive_hex):
    lines = HYPRLAND_CONF.read_text().splitlines()
    new_lines = []
    for line in lines:
        if line.strip().startswith("col.active_border"):
            rgba = hex_to_rgba(active_hex)
            new_lines.append(f"col.active_border = {rgba} {rgba} 45deg")
        elif line.strip().startswith("col.inactive_border"):
            rgba = hex_to_rgba(inactive_hex, 'aa')
            new_lines.append(f"col.inactive_border = {rgba}")
        else:
            new_lines.append(line)
    HYPRLAND_CONF.write_text("\n".join(new_lines))
    subprocess.run(["hyprctl", "reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def update_hyprpaper_conf(wallpaper_path):
    wp_str = str(wallpaper_path)
    lines = HYPRPAPER_CONF.read_text().splitlines()
    new_lines = []
    for line in lines:
        if line.strip().startswith("preload ="):
            new_lines.append(f"preload = {wp_str}")
        elif line.strip().startswith("wallpaper ="):
            new_lines.append(f"wallpaper = , {wp_str}")
        else:
            new_lines.append(line)
    HYPRPAPER_CONF.write_text("\n".join(new_lines))
    subprocess.run(["hyprctl", "hyprpaper", "reload", f",{wp_str}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def ensure_zshrc_sources_pywal():
    line = '[[ -f ~/.cache/wal/colors.sh ]] && source ~/.cache/wal/colors.sh\n'
    if not ZSHRC.exists():
        ZSHRC.write_text(line)
        return
    content = ZSHRC.read_text()
    if 'source ~/.cache/wal/colors.sh' not in content:
        with ZSHRC.open("a") as f:
            f.write("\n# Autoload pywal colors\n" + line)

def ensure_kitty_conf_includes_pywal():
    include_line = "include ~/.cache/wal/colors-kitty.conf\n"
    if not KITTY_CONF.exists():
        KITTY_CONF.write_text(include_line)
        return
    content = KITTY_CONF.read_text()
    if "colors-kitty.conf" not in content:
        with KITTY_CONF.open("a") as f:
            f.write("\n# Pywal colors\n" + include_line)


def apply_theme_and_wallpaper(wallpaper_path):
    subprocess.run(["wal", "-n", "-i", str(wallpaper_path)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    colors = load_colors()
    update_hyprpaper_conf(wallpaper_path)
    update_hyprland_conf(colors["colors"]["color4"], colors["colors"]["color0"])
    update_waybar_colors(colors)
    ensure_zshrc_sources_pywal()
    ensure_kitty_conf_includes_pywal()
    subprocess.run(["zsh", "-c", "source ~/.cache/wal/colors.sh"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def create_thumbnail(path):
    try:
        img = Image.open(path)
        img.thumbnail(THUMBNAIL_SIZE)
        return ImageTk.PhotoImage(img)
    except:
        return None

def main():
    wallpapers = sorted([f for f in WALLPAPER_DIR.iterdir() if f.suffix.lower() in [".jpg", ".jpeg", ".png", ".bmp", ".webp"]])
    if not wallpapers:
        return

    root = tk.Tk()
    root.title("Wallpapers")
    root.geometry("720x480")
    root.configure(bg="#1e1e1e")
    frame = tk.Frame(root, bg="#1e1e1e")
    frame.pack(expand=True, fill="both")

    photos = []
    cols = 4
    row = col = 0

    def on_click(wp):
        apply_theme_and_wallpaper(wp)

    for wp in wallpapers:
        thumb = create_thumbnail(wp)
        if not thumb:
            continue
        photos.append(thumb)
        btn = tk.Button(
            frame,
            image=thumb,
            bg="#2e2e2e",
            relief="flat",
            command=lambda p=wp: on_click(p)
        )
        btn.grid(row=row, column=col, padx=6, pady=6)
        col += 1
        if col >= cols:
            col = 0
            row += 1

    root.mainloop()

if __name__ == "__main__":
    main()
