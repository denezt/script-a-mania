
### **fzf** (Command Line Fuzzy Finder)
*   **Installation:** `brew install fzf`
*   **Configuration:** 
    *   `open ~/.zshrc` (or `code ~/.zshrc` / `nvim ~/.zshrc`)
    *   `source ~/.zshrc`
*   **Keybind Examples:**
    *   `CTRL-t`: Look for files and directories
    *   `CTRL-r`: Look through command history
    *   `Enter`: Select the item
    *   `Ctrl-j` or `Ctrl-n` (or Down arrow): Go down one result
    *   `Ctrl-k` or `Ctrl-p` (or Up arrow): Go up one result
    *   `Tab`: Mark a result
    *   `Shift-Tab`: Unmark a result
    *   `cd **Tab`: Open up fzf to find directory
    *   `export **Tab`: Look for env variable to export
    *   `unset **Tab`: Look for env variable to unset
    *   `unalias **Tab`: Look for alias to unalias
    *   `ssh **Tab`: Look for recently visited host names
    *   `kill -9 **Tab`: Look for process name to kill to get pid
    *   `any command (like nvim or code) + **Tab`: Look for files & directories to complete command

### **fzf with fd**
*   **Installation:** `brew install fd`
*   **Environment Variables:** 
    *   `export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"`
    *   `export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"`
    *   `export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"`
*   **Shell Functions:** Definitions for `_fzf_compgen_path()` and `_fzf_compgen_dir()`.

### **fzf-git**
*   **Setup:** 
    *   `git clone https://github.com/junegunn/fzf-git.sh.git`
    *   `source ~/fzf-git.sh/fzf-git.sh`
*   **Keybind Examples:**
    *   `CTRL-GFL`: Look for git files
    *   `CTRL-GBL`: Look for git branches
    *   `CTRL-GT`: Look for git tags
    *   `CTRL-GRL`: Look for git remotes
    *   `CTRL-GH`: Look for git commit hashes
    *   `CTRL-GSL`: Look for git stashes
    *   `CTRL-GLL`: Look for git reflogs
    *   `CTRL-GW`: Look for git worktrees
    *   `CTRL-GEL`: Look for git for-each-ref

### **fzf Themes**
*   **Custom Theme Export:** `export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"`

### **bat** (Better cat)
*   **Installation:** `brew install bat`
*   **Usage:** `bat filename.txt`
*   **Theme Selection:** `bat --list-themes | fzf --preview="bat --theme={} --color=always /path/to/file"`
*   **Custom Theme Setup:**
    *   `mkdir -p "$(bat --config-dir)/themes"`
    *   `curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme`
    *   `bat cache --build`
*   **Export:** `export BAT_THEME=tokyonit_night`

### **delta** (Better git diff)
*   **Installation:** `brew install git-delta`
*   (Note: The text also provides a `.gitconfig` block for delta configuration).

### **fzf Previews**
*   **Preview Exports:** 
    *   `export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"`
    *   `export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"`
*   **Advanced Customization:** A script for `_fzf_comprun()` that handles specific previews for `cd`, `export/unset`, and `ssh`.

### **eza** (Better ls)
*   **Installation:** `brew install eza`
*   **Alias:** `alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"`

### **tldr** (User-friendly man pages)
*   **Installation:** `brew install tlrc`
*   **Usage:** `tldr eza`

### **thefuck** (Auto correct mistyped commands)
*   **Installation:** `brew install thefuck`
*   **Activation:** 
    *   `eval $(thefuck --alias)`
    *   `eval $(thefuck --alias fk)`

### **zoxide** (Better cd)
*   **Installation:** `brew install zoxide`
*   **Setup:** `eval "$(zoxide init zsh)"`
*   **Alias:** `alias cd="z"`
