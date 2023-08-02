#!/usr/bin/ruby

# (C) 2023 SKTM307 <sktm307@proton.me>

require 'json'
require './commands.rb'
require './default.rb'


### CLASSES ###

class Task
  def initialize(list={})
    name=list['name']
    @name=(name.is_a? String and not name.empty?) ? name : 'Unnamed task'
    @desc=list['desc']
    @chck=list['chck']
    @tasks=[]
    tasks=list['tasks']
    if tasks.is_a? Array
      for task in tasks
        @tasks+=[Task.new(task)]
      end
    end
  end

  def [](x) # TODO: prettify
    if x.is_a? Numeric
      if x>=0 and x<@tasks.count()
        return @tasks[x] 
      else
        error :idx
      end
    end
    if x.is_a?Array
      if x==[]
        return self
      end
      i=x.shift
      if i>=0 and i<@tasks.count()
        task=@tasks[i]
      else
        error :idx
      end

      if task==nil
        error :idx
      end
      return task[x]
    end
  end

  def []=(x,y)
    if x.is_a?Numeric
      @tasks[x]=y
    end
    if x.is_a?Array
      task=self[x]
      task=y
    end
  end

  def +(x)
    @tasks+=[Task.new(x)]
    return self
  end

  def -(x)
    if x.is_a?Numeric
      @tasks.delete_at x
      return self
    end
    if x.is_a?Array
      if x.count()==1
        @tasks.delete_at x[0]
        return self
      end
      task=@tasks[x.shift]
      if task==nil
        error :idx
      end
      task-=x
    end
    return self
  end

  def getHash
    {
      'name'  => @name,
      'desc'  => @desc,
      'chck'  => @chck,
      'tasks' => @tasks.map{ |x| x.getHash },
    }
  end

  def print(i=nil,depth=0) # TODO: prettify
      n=@name
      d=@desc
      c=@chck?
        SETTINGS[:style][:color][:check]+SETTINGS[:style][:text][:check]+COLOR[:reset]:
        SETTINGS[:style][:color][:uncheck]+SETTINGS[:style][:text][:uncheck]+COLOR[:reset]
      padding = "   #{SETTINGS[:style][:color][:line]}|#{COLOR[:reset]}" * depth
      STDOUT.print padding
      if i.is_a?Integer
        STDOUT.printf SETTINGS[:style][:color][:index]+'%3d'+
                      SETTINGS[:style][:color][:colon]+':'+COLOR[:reset],i
      end
      STDOUT.print SETTINGS[:style][:color][:box]+'['+COLOR[:reset]+
                    c+
                    SETTINGS[:style][:color][:box]+']'+COLOR[:reset]+
                    SETTINGS[:style][:color][:name]+n+COLOR[:reset]+"\n"
      if d.is_a?String and not d.empty?
        STDOUT.print padding
        STDOUT.printf "        #{SETTINGS[:style][:color][:desc]}\"%s\"#{COLOR[:reset]}\n",d
      end
  end

  def listSubTasks(depth=0)
    @tasks.each.with_index(1) {
      |task,i|
      task.print i,depth
      task.listSubTasks depth+1
    }
  end

  def getTask(idx)
    task=@tasks[idx.shift]
    if task==nil
      error :idx
    end
  end

  def check
    @chck=true
  end

  def uncheck
    @chck=false
  end

  def subTasks
    @tasks.count()
  end
end

class Main
  def initialize
    @commands={
      'get'    => {method: method(:get)     ,w: false ,help: 'shows item at [index]'},
      'getsub' => {method: method(:getsub)  ,w: false ,help: 'shows subitems of [index]'},
      'getall' => {method: method(:getall)  ,w: false ,help: 'shows item and it\'s subitems at [index]'},
      'list'   => {method: method(:list)    ,w: false ,help: 'lists all items'},
      'add'    => {method: method(:add)     ,w: true  ,help: 'adds item with [name] and [description]'},
      'addsub' => {method: method(:addsub)  ,w: true  ,help: 'adds item under [index] with [name] and [description]'},
      'check'  => {method: method(:check)   ,w: true  ,help: 'checks item at [index]'},
      'uncheck'=> {method: method(:uncheck) ,w: true  ,help: 'unchecks item at [index]'},
      'remove' => {method: method(:remove)  ,w: true  ,help: 'removes item at [index]'},
      'help'   => {method: method(:help)    ,w: false ,help: 'shows this help menu'},
    }
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
        x=STDIN.readline.chomp
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
    idx: {message: "invalid index",   exit: 1 },
    cmd: {message: "invalid command", exit: 2 },
  }[e]|| {message: "unknown error",   exit: -1} 
  STDERR.print SETTINGS[:style][:text][:error]+error[:message]+"\n"
  if error[:exit].is_a?(Integer)then
    exit error[:exit]
  end
end



### MAIN ###

begin
  require './cfg.rb'
rescue LoadError
  # user config was not loaded
end

COLOR=Color.new unless defined? COLOR
SETTINGS=Settings.new unless defined? SETTINGS

main=Main.new
exit 0
