# Initialize glyphs to be used in the prompt.
set -q chain_prompt_glyph
  or set -g chain_prompt_glyph ">"
set -q chain_git_branch_glyph
  or set -g chain_git_branch_glyph "⎇"
set -q chain_git_detached_glyph
  or set -g chain_git_detached_glyph "➤"
set -q chain_git_dirty_glyph
  or set -g chain_git_dirty_glyph "±"
set -q chain_git_staged_glyph
  or set -g chain_git_staged_glyph "~"
set -q chain_git_stashed_glyph
  or set -g chain_git_stashed_glyph '$'
set -q chain_git_new_glyph
  or set -g chain_git_new_glyph "…"
set -q chain_su_glyph
  or set -g chain_su_glyph "⚡"

function __chain_prompt_segment
  set_color $argv[1]
  echo -n -s "[" $argv[2..-1] "]-"
  set_color normal
end

function __chain_prompt_root
  set -l uid (id -u $USER)
  if test $uid -eq 0
    __chain_prompt_segment yellow $chain_su_glyph
  end
end

function __chain_prompt_dir
  __chain_prompt_segment cyan (prompt_pwd)
end

function __chain_prompt_git
  test (git_branch_name); or return

  set -l git_branch (git_branch_name)
  if git_is_detached_head
    __chain_prompt_segment bryellow "$chain_git_detached_glyph $git_branch"
  else
    __chain_prompt_segment blue "$chain_git_branch_glyph $git_branch"
  end

  set -l glyphs ''
  git_is_dirty; and set -l is_git_dirty 1; and set glyphs "$glyphs$chain_git_dirty_glyph"
  git_is_staged; and set -l is_git_staged 1; and set glyphs "$glyphs$chain_git_staged_glyph"
  git_is_stashed; and set -l is_git_stashed 1; and set glyphs "$glyphs$chain_git_stashed_glyph"
  git_untracked_files >/dev/null; and set -l is_git_new 1; and set glyphs "$glyphs$chain_git_new_glyph"

  set -l color green
  if test "$is_git_dirty" -o "$is_git_staged"
    set color red
  else if test "$is_git_stashed"
    set color yellow
  end

  if test -n "$glyphs"
    __chain_prompt_segment $color $glyphs
  end
end

function __chain_prompt_virtualenv
  if test "$VIRTUAL_ENV"
    __chain_prompt_segment blue (basename $VIRTUAL_ENV)
  end
end

function __chain_prompt_time
  __chain_prompt_segment normal (date +%H:%M:%S)
end

function __chain_prompt_arrow
  if test $last_status = 0
    set_color green
  else
    set_color red
    echo -n "($last_status)-"
  end

  if test (jobs -l | wc -l) -gt 0
    echo -n "%"
  end

  echo -n "$chain_prompt_glyph "
end

function fish_prompt
  set -g last_status $status

  __chain_prompt_time
  __chain_prompt_root
  __chain_prompt_dir
  __chain_prompt_virtualenv
  type -q git; and __chain_prompt_git
  __chain_prompt_arrow

  set_color normal
end
