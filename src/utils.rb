#!/usr/bin/ruby

# utilitary functions and constants

$color={
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

def error(e)
  error={
    idx: {message: "invalid index",   exit: 1 },
    cmd: {message: "invalid command", exit: 2 },
  }[e]|| {message: "unknown error",   exit: -1} 
  STDERR.print $settings[:text][:error]+error[:message]+"\n"
  if error[:exit].is_a?(Integer)then
    exit error[:exit]
  end
end

