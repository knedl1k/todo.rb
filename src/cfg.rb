#!/usr/bin/ruby

# config file

### SETTINGS ###

COLOR=Color.new

class Settings
  def initialize
    @settings={
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
end

SETTINGS=Settings.new

