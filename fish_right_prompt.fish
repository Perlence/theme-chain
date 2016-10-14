function fish_right_prompt
  if test "$CMD_DURATION" -gt 250
    set -l duration (echo $CMD_DURATION | humanize_duration)
    set_color brgrey
    echo -sn "$duration "
  end

  set_color normal
end
