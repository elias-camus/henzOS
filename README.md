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

## Roadmap

**コンテンツ**
- デフォルト壁紙（emeraldテーマ向けダーク系）
- LightDMブランディング（ロゴ・背景色）
- 追加テーマ — catppuccin, nord, gruvbox

**機能**
- マルチモニター対応（arandr自動検出）
- GPU ドライバ自動検出インストール（NVIDIA / AMD）
- `henzos-doctor` — インストール後の自己診断コマンド
- Flatpak 対応

**配布**
- `henzos.dev` ランディングページ
- shellcheck CI（GitHub Actions）
- ISO 自動ビルド & リリース CI/CD

## License

MIT
