# dotfiles

macOS 用の個人 dotfiles。Neovim (LazyVim) / fish / tmux / Ghostty / git / lazygit / mise の設定をまとめている。

> [!NOTE]
> このリポジトリは [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles)
> ([Takuya Matsuyama (@craftzdog)](https://github.com/craftzdog)) を履歴ごとフォークしたもの。
> 元の設定とそのクレジットは本人に帰属し、その上に加えた変更が自分のもの。
> 本家は `upstream` リモートとして残してあり、改善を取り込める ([upstream との同期](#upstream-との同期))。
> 本家からの差分は `git log upstream/master..main` で確認できる。

## 構成

| パス | 内容 |
| --- | --- |
| `.config/nvim` | LazyVim ベース。カラースキームは [solarized-osaka.nvim](https://github.com/craftzdog/solarized-osaka.nvim) (透過)。独自設定は `lua/config/` と `lua/plugins/` |
| `.config/fish` | `config.fish` → OS 別 (`config-osx.fish`) → `config-local.fish` の順に読み込む。fisher のプラグインは `fish_plugins` で管理 |
| `.config/tmux` | prefix は `Ctrl+t`。プラグインは tpm + tmux-pain-control |
| `.config/ghostty` | テーマ Solarized Dark - Patched、フォント PlemolJP Console NF |
| `.config/lazygit` | lazygit の設定 |
| `.config/mise` | mise で入れるランタイム (node / bun / python / ruby / rust / ghq) |
| `.config/git/delta.gitconfig` | delta (diff ページャ) の設定 |
| `.gitconfig` | エイリアス、nvimdiff、delta。最後に `~/.gitconfig.private` を include する |
| `.gitignore` | グローバルな除外設定 (`core.excludesfile`) |
| `.czrc` | commitizen (cz-git) の設定 |
| `.scripts/ide` | tmux のペインを IDE 風に分割するスクリプト |
| `.config/powershell` | upstream 由来。この Mac では未使用 |

## 新しい Mac でのセットアップ

### 1. ツールを入れる

```sh
brew install neovim fish tmux lazygit mise eza fzf fd ripgrep bat ghq peco git-delta gh gitleaks pre-commit
brew install --cask ghostty font-plemol-jp-nf font-blex-mono-nerd-font
```

### 2. リポジトリを取得してシンボリックリンクを張る

```sh
git clone git@github.com:e-sp9/dotfiles.git ~/ghq/github.com/e-sp9/dotfiles
cd ~/ghq/github.com/e-sp9/dotfiles
git remote add upstream ssh://git@github.com/craftzdog/dotfiles.git

D=~/ghq/github.com/e-sp9/dotfiles
mkdir -p ~/.config/git
for d in nvim fish tmux ghostty lazygit mise; do ln -sfn "$D/.config/$d" ~/.config/$d; done
ln -sfn "$D/.config/git/delta.gitconfig" ~/.config/git/delta.gitconfig
ln -sfn "$D/.gitconfig" ~/.gitconfig
ln -sfn "$D/.gitignore" ~/.gitignore
ln -sfn "$D/.czrc" ~/.czrc
ln -sfn "$D/.scripts" ~/.scripts
```

### 3. マシン専用の設定ファイルを作る

[マシン専用の設定](#マシン専用の設定-リポジトリ外) を参照。少なくとも `~/.gitconfig.private` に `user.name` / `user.email` を書く。

### 4. fish をログインシェルにしてプラグインを入れる

```sh
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

fish 上で:

```fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher update   # fish_plugins に書かれたプラグインを入れる
tide configure  # 任意
```

### 5. tmux のプラグインを入れる

```sh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

tmux を起動して `prefix + I` でプラグインをインストールする。

### 6. 残り

- Neovim を起動すると lazy.nvim がプラグインを入れる
- `mise install` でランタイムを入れる
- リポジトリ内で `pre-commit install` を実行する (gitleaks によるシークレット検出)

## マシン専用の設定 (リポジトリ外)

追跡していないファイル。ユーザー固有の値や環境依存の設定はここに置き、追跡ファイルには入れない。

- `~/.gitconfig.private` — `user.name` / `user.email` と `ghq.root = ~/ghq`。`.gitconfig` の最後に include されるので、リポジトリ側の `ghq.root` (`~/Developments/.ghq`) を上書きできる。XDG の `~/.config/git/config` は先に読まれて負けるので使わない。
- `~/Library/Application Support/com.mitchellh.ghostty/config` — `theme = Solarized Dark Patched` (Ghostty 1.3 でテーマ名が変わった) と、新しいウィンドウで herdr を起動する `command = shell:/opt/homebrew/bin/herdr || exec /opt/homebrew/bin/fish -l`。リポジトリ側の `.config/ghostty/config` の後に読まれる。
- `~/.config/fish/config-local.fish` (gitignore 済み) — `~/.docker/bin` を PATH に追加し、`Ctrl+]` に `fzf_change_directory` をバインド。
- `~/.config/herdr/config.toml` — `[terminal] default_shell = "/opt/homebrew/bin/fish"`。これがないと herdr サーバー起動時の `$SHELL` でペインが開く。

## upstream との同期

```sh
git fetch upstream
git merge upstream/master   # 本家のデフォルトブランチは master のまま
```

このリポジトリのデフォルトブランチは `main`。push 先は `origin` (e-sp9) だけで、`upstream` には push しない。

## 参考: 元の作者による解説

1. [My Neovim setup](https://www.youtube.com/watch?v=fFHlfbKVi30)
   - [記事版](https://www.devas.life/effective-neovim-setup-for-web-development-towards-2024/)
1. [My dev workflow using tmux and vim](https://www.youtube.com/watch?v=sSOfr2MtRU8&list=PLxQA0uNgQDCICMRwlOzWAZBPL05XBC_br&index=10)
1. [A productive command-line Git workflow for indie app developers](https://www.youtube.com/watch?v=qKpY7t5m35k&list=PLxQA0uNgQDCICMRwlOzWAZBPL05XBC_br&index=4)
   - [ブログ記事](https://dev.to/craftzdog/a-productive-command-line-git-workflow-for-indie-app-developers-k7d)
1. [My Fish shell workflow for coding](https://www.youtube.com/watch?v=KKxhf50FIPI)
1. [How to set up PowerShell prompt with Oh My Posh on Windows 11](https://www.youtube.com/watch?v=5-aK2_WwrmM)
