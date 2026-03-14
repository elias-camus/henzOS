# henzOS

Ubuntu 24.04 LTS ベースの opinionated デスクトップ環境。i3wm を中心に、見た目・操作感・開発ツールを統一したフルスタック構成をシェルスクリプトで配布する。

## インストール

```bash
curl -sL henzos.dev/install | bash
```

ローカル開発:

```bash
git clone <repo> ~/.local/share/henzos
cd ~/.local/share/henzos && source install.sh
```

## スタック

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

## プロジェクト構造

```
boot.sh                     curl | bash エントリポイント
install.sh                  メインオーケストレーター

install/
  helpers/                  ログ、表示ヘルパー
  preflight/                OS検証、apt設定、初回/更新判定、マイグレーション
  packaging/                apt パッケージ + バイナリ (lazygit, gh, starship)
  config/                   dotfile配置、テーマ、ibus、docker、git
  login/                    LightDM + i3 セッション
  post-install/             クリーンアップ、完了メッセージ

config/                     ~/.config/ にコピーされる dotfiles (Tier 2)
default/                    読み取り専用デフォルト (Tier 1)
themes/emerald/             デフォルトテーマ
bin/                        ユーザーコマンド (henzos-update, henzos-theme-set 等)
migrations/                 バージョン間マイグレーション
iso/                        live-build による ISO 構築
```

## 設定の3層アーキテクチャ

i3 config を例にした読み込み順:

1. **Tier 1 — テーマカラー** `themes/emerald/i3.conf`
   - `$bg`, `$accent` 等の変数を定義
2. **Tier 2 — henzOS デフォルト** `default/i3/*.conf`
   - 変数を参照して appearance, bindings, autostart, workspaces を構成
3. **Tier 3 — ユーザーオーバーライド** `config/i3/local.conf`
   - ユーザーが自由に追加。後勝ちで上書き

デフォルトは `~/.local/share/henzos/default/` に据え置き（git管理下、ユーザーは編集しない）。`~/.config/` にコピーされたファイルはユーザーが自由に編集できる。

## テーマシステム

`~/.config/henzos/current/theme/` が symlink でアクティブテーマを指す。

各アプリの設定ファイルはこのパスを参照する:

- **i3**: `include ~/.config/henzos/current/theme/i3.conf`
- **Polybar**: `include-file = ~/.config/henzos/current/theme/polybar.ini`
- **Rofi**: `@theme "~/.config/henzos/current/theme/rofi.rasi"`
- **Alacritty**: `import = ["~/.config/henzos/current/theme/alacritty.toml"]`

テーマ追加は `themes/` に新ディレクトリを作成し、同じファイル群を配置するだけ。`henzos-theme-set <name>` で symlink を切り替えて即反映。

### emerald カラーパレット

| 用途 | カラー |
|---|---|
| bg | `#0b0f10` |
| bg-alt | `#11181a` |
| fg | `#cfd7d6` |
| muted | `#8c9797` |
| accent | `#2bd9a5` |
| urgent | `#d96b5f` |

## ユーザーコマンド

| コマンド | 機能 |
|---|---|
| `henzos-update` | git pull + install.sh 再実行 |
| `henzos-theme-set <name>` | テーマ切替 + i3/polybar/dunst リロード |
| `henzos-wallpaper-set <path>` | 壁紙設定 |

## ISO ビルド

Ubuntu 24.04 LTS ベースの ISO を live-build で生成する。ビルドは GitHub Actions (x86_64) で自動化されている。

### GitHub Actions（推奨）

**手動ビルド（テスト用）:**
```bash
gh workflow run "Build henzOS ISO"
```
完成した ISO は GitHub Actions の Artifacts から 7 日間ダウンロード可能。

**リリースビルド:**
```bash
git tag v1.x.x && git push --tags
```
自動で ISO をビルドし GitHub Release に添付される。

### ローカルビルド（x86_64 Linux のみ）

```bash
sudo apt-get install live-build rsync
cd iso/ && sudo bash build.sh
```

出力: `iso/henzos-amd64-YYYYMMDD.iso`

### ISO の構成

- Ubuntu 24.04 LTS ライブ環境に henzOS の dotfile・テーマ・設定を `/etc/skel` に同梱
- 起動直後から i3wm + LightDM が設定済みの状態で動作
- 約 2.3 GB、ビルド時間は約 11 分

---

## TODO

### フェーズ 1 — 動作検証

- [x] VM (Ubuntu 24.04 LTS) で `source install.sh` を通しで実行
- [x] 各 dotfile が正しいパスに配置されているか確認
- [x] テーマ・i3wm・Polybar・Alacritty・LightDM の動作確認
- [ ] `henzos-update` で再実行しても冪等に動くか確認（2回目で壊れないか）

### フェーズ 2 — ISO 検証

- [x] GitHub Actions で x86_64 ISO の自動ビルド CI/CD を構築
- [x] ISO ビルド成功（2.3 GB、約 11 分）
- [ ] **ISO からブートして LightDM・i3wm が正常に起動するか確認** ← 次のステップ
- [ ] ライブ環境で各アプリが動作するか確認

### フェーズ 3 — コンテンツ

- [ ] デフォルト壁紙を `themes/emerald/backgrounds/` に追加
- [ ] LightDM greeter のブランディング（ロゴ、背景色）
- [ ] テーマ追加: catppuccin, nord, gruvbox 等

### フェーズ 4 — 配布・ブランディング

- [ ] GitHub リポジトリを公開
- [ ] `henzos.dev` にランディングページを作成（curl | bash の配布元）
- [ ] boot.sh 内の `HENZOS_REPO` URL を実際のリポジトリに更新
- [ ] LICENSE を選定して追加 (MIT 等)
- [ ] スクリーンショット / デモ動画を用意

### フェーズ 5 — 発展

- [ ] NVIDIA / AMD GPU ドライバの自動検出・インストール
- [ ] マルチモニター対応の改善 (arandr 連携 or 自動検出)
- [ ] `henzos-doctor` コマンド — インストール後の自己診断ツール
- [ ] Flatpak 対応
- [ ] shellcheck CI — GitHub Actions で ShellScript の静的解析
