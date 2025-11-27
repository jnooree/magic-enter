if (( ! ${+MNML_ERR_COLOR} )) typeset -g MNML_ERR_COLOR=red
typeset -gi MNML_LAST_ERR

autoload -Uz colors && colors

_prompt_mnml_precmd() {
  MNML_LAST_ERR=$?
}

_prompt_mnml_sync_exit() {
  return "$MNML_LAST_ERR"
}

_prompt_mnml_buffer-empty() {
  builtin emulate -L zsh

  if [[ -z ${BUFFER} && ${CONTEXT} == start ]]; then
    if (( MNML_LAST_ERR )) print -Pn '%F{${MNML_ERR_COLOR}}${MNML_LAST_ERR} '
    print -Pn '%(1j.%F{8}%j%f& .)%F{8}%n%f@%F{8}%m%f:%F{8}%~%f'
    local v_files=(*(N^D)) h_files=(.*(N^D))
    print -Pn ' [%F{8}${#v_files}%f'
    if (( #h_files )) print -Pn ' (%F{8}${#h_files}%f)'
    print ]

    local -a zcommands
    zstyle -a ':zim:magic-enter' commands 'zcommands' || zcommands=( \
        'if (( ${#dirstack} )) print -P %F{244}${${(Dq+)dirstack}//\//%f\/%F{244}}%f' \
        'ls -AF' \
        'git --no-pager status -sb --untracked-files=no 2>/dev/null' \
    )
    local zcommand
    for zcommand (${zcommands}) eval ${zcommand}

    _prompt_mnml_sync_exit
    print -Pn "${PS1}"
    zle reset-prompt
  else
    zle accept-line
  fi
}

autoload -Uz add-zsh-hook && add-zsh-hook precmd _prompt_mnml_precmd
zle -N buffer-empty _prompt_mnml_buffer-empty
bindkey '^M' buffer-empty
