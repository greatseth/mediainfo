class String
  # returns the string enclosed in double quotes.
  # all characters in the string that could be harmful will be escaped.
  # 
  # e.g. 
  # 'test'.shell_escape_double_quotes   # => "test"
  # '$\\'"`'.shell_escape_double_quotes # => "\$\\'\"\`"
  #
  # This should work in al POSIX compatible shells.
  #
  # see: http://www.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02_02_03
  def shell_escape_double_quotes
    ''+gsub(/\\|"|\$|`/, '\\\\\0')+''
  end unless method_defined?(:shell_escape_double_quotes)

  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

end
