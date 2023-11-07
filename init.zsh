if (( ! ${+MNML_ERR_COLOR} )) typeset -g MNML_ERR_COLOR=red
typeset -gi MNML_LAST_ERR

_prompt_mnml_precmd() {
  MNML_LAST_ERR=$?
}

_prompt_mnml_buffer-empty() {
  local dentries i

  if [[ -z ${BUFFER} && ${CONTEXT} == start ]]; then
    if (( MNML_LAST_ERR )) print -Pn '%F{${MNML_ERR_COLOR}}${MNML_LAST_ERR} '
    print -Pn '%(1j.%F{8}%j%f& .)%F{8}%n%f@%F{8}%m%f:%F{8}%~%f'
    local v_files=(*(N^D)) h_files=(.*(N^D))
    print -Pn ' [%F{8}${#v_files}%f'
    if (( #h_files )) print -Pn ' (%F{8}${#h_files}%f)'
    print ]

    dentries=${#dirstack}
    for (( i = 1; i < $dentries; i++ )); do
      print -n "($i) \e[90m${(D)dirstack[$i]}$reset_color "
    done
    if [[ $i -eq $dentries ]] print "($i) \e[90m${(D)dirstack[$i]}$reset_color"

    ls --group-directories-first --color=always -vF
    command git status -sb 2>/dev/null
    print -Pn "${PS1}"
    zle redisplay
  else
    zle accept-line
  fi
}

autoload -Uz add-zsh-hook && add-zsh-hook precmd _prompt_mnml_precmd
zle -N buffer-empty _prompt_mnml_buffer-empty
bindkey '^M' buffer-empty
