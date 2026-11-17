<p align="center">
  <img src="logo.jpg" alt="SupraOS logo" width="320">
</p>

# SupraOS

A minimal Alpine Linux desktop mod, inspired by [Omarchy](https://github.com/basecamp/omarchy)
but stripped down to the bone for weak hardware. Built on (and for) a Dell
Chromebook 12 with a 2-core Celeron and 4 GB of RAM.

One script, one tarball, one monochrome theme.

## Philosophy

- **Everything the setup needs lives in one POSIX sh script.** Packages, services,
  groups, and every dotfile are restored by running a single file.
- **Nothing you don't need.** No systemd (OpenRC), no display manager (sway from
  tty1 via `.profile`), no themes, no bling. If it isn't used daily, it isn't installed.
- **One look.** Black `#000000`, warm off-white `#e8e6df`, 2px square borders,
  zero gaps, DejaVu Sans Mono everywhere.

## The stack

| Role          | Tool      |
|---------------|-----------|
| Compositor    | Sway      |
| Bar           | Waybar    |
| Terminal      | foot      |
| Launcher      | fuzzel    |
| File manager  | pcmanfm   |
| Browser       | Firefox   |
| Screenshots   | grim + slurp + wl-copy |
| Brightness    | brightnessctl |
| Services      | OpenRC + seatd + elogind + dbus |

## Install

On a fresh Alpine Linux install (run `setup-alpine` first, create a normal user,
make sure you know the root password):

```sh
wget -O supra-bootstrap.sh https://raw.githubusercontent.com/drive85/SupraOS/main/supra-bootstrap.sh
chmod +x supra-bootstrap.sh
./supra-bootstrap.sh
```

Then reboot (or log out and back in) and sway starts on tty1.

What the script does:

1. Asks two questions: install Firefox? [Y/n] — install OpenCode? [y/N]
2. Enables the community repository, installs all packages (as root via `su`)
3. Enables the OpenRC services (udev, seatd, dbus, wpa_supplicant, ...)
4. Adds your user to the seat/video/input/audio groups
5. Extracts every config file into your home directory

Wi-Fi is configured via `wpa_supplicant` (edit `/etc/wpa_supplicant/wpa_supplicant.conf`
as root). Timezone/hostname/keymap come from your `setup-alpine` answers.

## Keybinds

| Keys              | Action                          |
|-------------------|---------------------------------|
| Super+Return      | terminal (foot)                 |
| Super+Space       | launcher (fuzzel)               |
| Super+B           | Firefox                         |
| Super+E           | pcmanfm                         |
| Super+W           | close window                    |
| Super+F           | fullscreen                      |
| Super+H/J/K/L     | focus (arrows also work)        |
| Super+Shift+HJKL  | move window                     |
| Super+1..9        | workspaces                      |
| Super+Shift+1..9  | send window to workspace        |
| Super+V           | split vertically                |
| Alt+Tab           | cycle focus                     |
| Super+S           | screenshot region (copies it)   |
| Super+Shift+S     | screenshot full screen          |
| XF86 brightness   | brightness up/down              |
| XF86 volume       | volume (see known quirks)       |

## The Supra menus

Fuzzel also lists these desktop entries (they are plain shell one-liners,
great templates to steal from):

- **Trigger** — screenshot region/fullscreen, keybinding cheat-sheet
- **Setup** — Wi-Fi, audio mixer, edit sway/waybar/fuzzel config
- **System** — reload sway, logout, reboot, shutdown
- **Update** — `apk upgrade` everything
- **About** — system info summary

## Repo layout

- `supra-bootstrap.sh` — the whole OS restore: package list + services + embedded
  base64 tarball of every config
- `NOTES.md` — working notes: audit results, decisions, pending ideas
- `AGENTS.md` — instructions for AI assistants working on this repo

## Known quirks / roadmap

Honest list (kept in `NOTES.md` with full detail):

- Volume keys are wired to `wpctl` but pipewire/wireplumber isn't installed yet,
  so they do nothing (and there's no sound). Planned.
- "Setup" menu's Wi-Fi (nmtui) and Audio Mixer (alsamixer) entries need packages
  that aren't installed yet, so they fail when clicked. Intentional for now.
- No screen locker yet (swaylock/swayidle would be nice).
- keyd runs with an empty config — placeholder for future remaps.
- The bootstrap restores configs and packages, but not personal data: Firefox
  profile, Wi-Fi passwords, and (optionally-installed) OpenCode binary are yours
  to bring back.

## License

Do whatever you want. It's dotfiles and a shell script.
