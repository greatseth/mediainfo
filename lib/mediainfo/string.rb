class String
  def shell_escape
    # The gsub is for ANSI-C style quoting.
    # 
    # The $'' is for bash, see http://www.faqs.org/docs/bashman/bashref_12.html,
    # but appears to be working for other shells: sh, zsh, ksh, dash
    "$'#{gsub(/\\|'/) { |c| "\\#{c}" }}'"
  end unless method_defined?(:shell_escape)
  
  # stolen from active_support/inflector
  # TODO require "active_support/core_ext/string/inflections" when 3.0 is released
  def underscore
    gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end unless method_defined?(:underscore)
end
