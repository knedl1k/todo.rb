#!/usr/bin/ruby

# (C) 2023 SKTM307 <sktm307@proton.me>

require 'json'

### SETTINGS ###

TODO_FILE="#{ENV["HOME"]}/.local/share/todo.json"
CHCK_SYMBOL='X'
UCHCK_SYMBOL='O'
COLORS=true
DEFAULT='list'

if COLORS
  COL_NUM  ="\e[01;36m"
  COL_NAME ="\e[01;32m"
  COL_DESC ="\e[00;37m"
  COL_CHCK ="\e[01;31m"
  COL_UCHCK="\e[01;34m"
  COL_BOX  ="\e[01;37m"
  COL_COL  ="\e[01;37m"
  COL_LINE ="\e[01;37m"
  COL_RESET="\e[0m"
else
  COL_NUM  =''
  COL_NAME =''
  COL_DESC =''
  COL_CHCK =''
  COL_UCHCK=''
  COL_BOX  =''
  COL_COL  =''
  COL_LINE =''
  COL_RESET=''
end

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
        STDERR.print("invalid index\n")
        exit 1
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
        STDERR.print("invalid index\n")
        exit 1
      end
      if task==nil
        STDERR.print("invalid index\n")
        exit 1
      end
      task[x]
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
    self
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
        STDERR.print("invalid index\n")
        exit 1
      end
      task-=x
    end
    self
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
      if @chck
        c=COL_CHCK+CHCK_SYMBOL+COL_RESET
      else
        c=COL_UCHCK+UCHCK_SYMBOL+COL_RESET
      end
      padding = "   #{COL_LINE}|#{COL_RESET}" * depth
      printf padding
      if i.is_a?Integer
        printf "#{COL_NUM}%3d#{COL_RESET}#{COL_COL}:#{COL_RESET} ",i
      end
      printf "#{COL_BOX}[#{COL_RESET}%s#{COL_BOX}]#{COL_RESET} #{COL_NAME}%s#{COL_RESET}\n",c,n
      if d.is_a?String and not d.empty?
        printf padding
        printf "        #{COL_DESC}\"%s\"#{COL_RESET}\n",d
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
      STDERR.print("invalid task index\n")
      exit 1
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
    command=getArg default: DEFAULT
    @tasks=Task.new(readTasks())
    method=@commands[command][:method]
    if method.is_a? NilClass
      STDERR.print("invalid command\n")
      exit 1
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
    file=open(TODO_FILE,'r')
    begin
      tasks=JSON.parse file.read
    rescue JSON::ParserError
      tasks={}
    end
    file.close
    rescue Errno::ENOENT
      tasks={}
    end
    tasks
  end

  def writeTasks tasks
    file=open(TODO_FILE,'w')
    file.print(JSON.generate(tasks))
    file.close
  end
  
  ### COMMANDS ###

  def get
    idx=getArg "index",type: :index
    task=@tasks[idx]
    task.print
    print "subtasks #{task.subTasks}\n"
  end

  def getsub
    idx=getArg "index",type: :index
    task=@tasks[idx]
    task.listSubTasks
  end

  def getall
    idx=getArg "index",type: :index
    task=@tasks[idx]
    task.print
    task.listSubTasks 1
  end

  def list
    @tasks.listSubTasks
  end

  def add
    name=getArg "name",required: true
    desc=getArg "description"
    @tasks+={"name"=>name,"desc"=>desc,"tasks"=>[],"chck"=>false}
    writeTasks @tasks.getHash
  end

  def addsub
    idx=getArg "index",type: :index
    name=getArg "name",required: true
    desc=getArg "description"
    @tasks[idx]+={"name"=>name,"desc"=>desc,"tasks"=>[],"chck"=>false}
  end

  def check
    idx=getArg "index",type: :index
    @tasks[idx].check
  end

  def uncheck
    idx=getArg "index",type: :index
    @tasks[idx].uncheck
  end

  def remove
    idx=getArg "index",type: :index
    @tasks-=idx
  end

  def help
    message=\
    "Usage: #{$0} [command] [arguments]\n"\
    "a simple commandline todo app written in ruby\n"\
    "   \n"
    for command in @commands.keys
      message+=sprintf "  %7s - %s\n",command,@commands[command][:help] # TODO: change to dynamic length
    end
    if not DEFAULT.is_a? NilClass
      message+="\nif no command is supplied \"#{DEFAULT}\" command will be used\n"
    end
    print message
  end
end

### MAIN ###

main=Main.new
exit 0
