# henzOS

```text
  ██╗  ██╗███████╗███╗   ██╗███████╗ ██████╗ ███████╗
  ██║  ██║██╔════╝████╗  ██║╚══███╔╝██╔═══██╗██╔════╝
  ███████║█████╗  ██╔██╗ ██║  ███╔╝ ██║   ██║███████╗
  ██╔══██║██╔══╝  ██║╚██╗██║ ███╔╝  ██║   ██║╚════██║
  ██║  ██║███████╗██║ ╚████║███████╗╚██████╔╝███████║
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚══════╝
```

Ubuntu 24.04 LTS ベースの、i3wm 中心で統一感ある開発環境を一括構築する opinionated デスクトップ構成。

![screenshot](docs/screenshot.png)

## Install

```bash
curl -sL henzos.dev/install | bash
```

## Stack

| レイヤー | ソフトウェア |
|---|---|
| WM | i3wm (X11, gaps) |
| バー | Polybar |
| ランチャー | Rofi |
| コンポジター | Picom |
| ターミナル | Alacritty |
| 通知 | dunst |
| エディタ | Neovim (LazyVim) |
| シェル | Bash + Starship |
| ファイルマネージャ | Thunar |
| ブラウザ | Firefox |
| 壁紙 | feh |
| ロック | i3lock |
| DM | LightDM |
| 日本語入力 | ibus-mozc |
| コンテナ | Docker + docker-compose |
| Git TUI | lazygit |
| フォント | UDEV Gothic 35NF, JetBrains Mono NF, Noto CJK |

## License

MIT
