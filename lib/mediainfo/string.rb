class String
  def shell_escape
    # The gsub is for ANSI-C style quoting.
    # 
    # The $'' is for bash, see http://www.faqs.org/docs/bashman/bashref_12.html,
    # but appears to be working for other shells: sh, zsh, ksh, dash
    "$'#{gsub(/\\|'/) { |c| "\\#{c}" }}'"
  end
end
