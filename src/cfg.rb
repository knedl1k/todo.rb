#!/usr/bin/ruby

# config file

### SETTINGS ###

require './utils.rb'

$settings={
  todo_file:     "#{ENV["HOME"]}/.local/share/todo.json",
  fallback_cmd:  'list',
  colors:        true,
  style: {
    text: {
      check:     'X',
      uncheck:   ' ',
      error:     $color[:bright][:red]+'ERROR: '+$color[:reset],
    },
    color: {
      index:     $color[:bright][:cyan],
      name:      $color[:bright][:green],
      desc:      $color[:normal][:white],
      check:     $color[:bright][:red],
      uncheck:   $color[:none],
      box:       $color[:bright][:white],
      colon:     $color[:bright][:white],
      line:      $color[:bright][:white],
    },
  },
}

