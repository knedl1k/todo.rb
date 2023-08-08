#!/usr/bin/ruby

# (C) 2023 SKTM307 <sktm307@proton.me>

require 'json'
require_relative './task.rb'
require_relative './commands.rb'
require_relative './default.rb'

class Main
  def initialize
    command=commands()[getArg default: SETTINGS[:fallback_cmd]]||error(:cmd)
    @tasks=Task.new(readTasks())
    if command[:method].is_a? Method
      command[:method].call
    else
      error :mtd
    end
    if command[:w]
      writeTasks @tasks.getHash
    end
  end

  def getArg(prompt=nil,type: :normal,default: nil,required: false)
    if not ARGV.empty?
      x=ARGV.shift
    elsif not default.is_a?NilClass
      return default
    else
      x=''
      begin
        if prompt.is_a?String
          print "#{prompt}: "
        end
        begin
          x=STDIN.readline.chomp
        rescue EOFError
          error :eof
        rescue Interrupt
          error :int
        end
      end while x.empty? and required
    end
    case type
    when :normal
      return x
    when :index
      return getIdx x
    end
  end

  def getIdx(x)
    x.split('.').map!{ |x| x.to_i - 1 }
  end

  def readTasks
    begin
      file=open(SETTINGS[:todo_file],'r')
    rescue Errno::ENOENT
      return {}
    end
    begin
      tasks=JSON.parse file.read
    rescue JSON::ParserError
      tasks={}
    ensure
      file.close
    end
    return tasks
  end

  def writeTasks(tasks)
    file=open(SETTINGS[:todo_file],'w')
    file.print(JSON.generate(tasks))
    file.close
  end
end
# if called, exits with an error value and error string
def error(e)
  error={
    idx: {message: "invalid index",               exit: 1   },
    cmd: {message: "invalid command",             exit: 2   },
    int: {message: "interrupted",                 exit: 3   },
    eof: {message: "end of file",                 exit: 4   },
    mtd: {message: "method has not been defined", exit: 5   },
  }[e]|| {message: "unknown error",               exit: -1  } 
  STDERR.print SETTINGS[:style][:text][:error]+error[:message]+"\n"
  if error[:exit].is_a?(Integer)then
    exit error[:exit]
  end
end


### MAIN ###

begin
  require ENV['HOME']+"/.config/todo/cfg.rb"
  require_relative "./cfg.rb"
rescue LoadError
  # user config was not loaded
end

COLOR=Color.new unless defined? COLOR
SETTINGS=Settings.new unless defined? SETTINGS

main=Main.new
exit 0
