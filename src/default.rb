# default values of constants and settings #

class Color
  def initialize
    @color={
      normal:{
        black:   "\e[00;30m",
        red:     "\e[00;31m",
        green:   "\e[00;32m",
        yellow:  "\e[00;33m",
        blue:    "\e[00;34m",
        magenta: "\e[00;35m",
        cyan:    "\e[00;36m",
        white:   "\e[00;37m",
      },
      bright:{
        black:   "\e[01;30m",
        red:     "\e[01;31m",
        green:   "\e[01;32m",
        yellow:  "\e[01;33m",
        blue:    "\e[01;34m",
        magenta: "\e[01;35m",
        cyan:    "\e[01;36m",
        white:   "\e[01;37m",
      },
      none:  '',
      reset: "\e[0m",
      }
  end
  def [](x)
    @color[x]
  end
end

class Settings

  def initialize
    @settings=settings()
    setColors()
  end

  def settings
    {
      todo_file:     "#{ENV["HOME"]}/.local/share/todo.json",
      fallback_cmd:  'list',
      colors:        true,
      style: {
        text: {
          check:     'X',
          uncheck:   ' ',
          error:     COLOR[:bright][:red]+'ERROR: '+COLOR[:reset],
        },
        color: {
          index:     COLOR[:bright][:cyan],
          name:      COLOR[:bright][:green],
          desc:      COLOR[:normal][:white],
          check:     COLOR[:bright][:red],
          uncheck:   COLOR[:none],
          box:       COLOR[:bright][:white],
          colon:     COLOR[:bright][:white],
          line:      COLOR[:bright][:white],
        },
      },
    }
  end

  def setColors
    if not @settings[:colors]
      for key in @settings[:style][:color].keys
        @settings[:style][:color][key]=COLOR[:none]
      end
    end
  end

  def [](x)
    @settings[x]
  end
end

