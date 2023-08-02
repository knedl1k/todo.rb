#!/usr/bin/ruby

# (C) 2023 SKTM307 <sktm307@proton.me>

require 'json'
require './task.rb'
require './commands.rb'
require './default.rb'

class Main
  def initialize
    @commands=commands()
    command=getArg default: SETTINGS[:fallback_cmd]
    @tasks=Task.new(readTasks())
    if not @commands.key?command
      error :cmd
    end
    method=@commands[command][:method]
    if method.is_a? NilClass
      error :cmd
    end
    method.call
    if @commands[command][:w]
      writeTasks @tasks.getHash
    end
  end

  def getArg(prompt=nil,type: :normal,default: nil, required: false)
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
        rescue Exception
          error nil
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
    begin
      tasks=JSON.parse file.read
    rescue JSON::ParserError
      tasks={}
    end
    file.close
    rescue Errno::ENOENT
      tasks={}
    end
    return tasks
  end

  def writeTasks tasks
    file=open(SETTINGS[:todo_file],'w')
    file.print(JSON.generate(tasks))
    file.close
  end
end

def error(e)
  error={
    idx: {message: "invalid index",   exit: 1   },
    cmd: {message: "invalid command", exit: 2   },
    int: {message: "interrupted",     exit: 3   },
    eof: {message: "end of file",     exit: 4   },
  }[e]|| {message: "unknown error",   exit: -1  } 
  STDERR.print SETTINGS[:style][:text][:error]+error[:message]+"\n"
  if error[:exit].is_a?(Integer)then
    exit error[:exit]
  end
end


### MAIN ###

begin
  require ENV['HOME']+"/.config/todo/cfg.rb"
rescue LoadError
  # user config was not loaded
end

COLOR=Color.new unless defined? COLOR
SETTINGS=Settings.new unless defined? SETTINGS

main=Main.new
exit 0
