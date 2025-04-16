# add git package name in the terminal info about ZSH shell

- change **'➜  .oh-my-zsh git:(master) ✗'** to **'➜  .oh-my-zsh git:(oh-my-zsh-master) ✗'**
- refine function 'git_prompt_info' in file '.oh-my-zsh/lib/git.zsh'

```shell
function git_prompt_info() {
  local ref
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    git_name=$(command git config --get remote.origin.url 2> /dev/null) || return 0
    git_name="${${git_name##*/}%%.*}" || return 0
    ref="${git_name} ${ref#refs/heads/}" || return 0
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}
```

- Attention: beside those code above, if you have other change, you should attention this bug. When you use "TAB" key to smarted list usable params in zsh shell, it may be display disorderedly.