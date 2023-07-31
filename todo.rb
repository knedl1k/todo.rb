#!/usr/bin/ruby

# 

require 'json'

TODO_FILE="#{ENV["HOME"]}/.local/share/todo.json"
CHCK_SYMBOL='X'
UCHCK_SYMBOL='O'
COLORS=true

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

class Task
  @name=''
  @desc=''
  @chck=false
  @tasks=[]

  def initialize(list={})
    @name=list['name']
    @desc=list['desc']
    @chck=list['chck']
    @tasks=[]
    if list['tasks'].is_a?Array
      for x in list['tasks']
        @tasks+=[Task.new(x)]
      end
    end
  end

  def [](x)
    if x.is_a?Numeric
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
      x_pop=x.pop
      if x_pop>=0 and x_pop<@tasks.count() 
        task=@tasks[x_pop]
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
      i=x.reverse.pop
      x.reverse
      task=@tasks[x.pop]
      if task==nil
        STDERR.print("invalid index\n")
        exit 1
      end
      task-=x
    end
    self
  end

  def getList
    {
      'name'=>@name,
      'desc'=>@desc,
      'chck'=>@chck,
      'tasks'=>@tasks.map{ |x| x.getList }
    }
  end

  def print(i=nil,depth=0)
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
    task=@tasks[idx.pop]
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

def getIdx(x)
  x.split('.').map!{ |x| x.to_i - 1 }.reverse
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

def popArg(args,prompt='')
  if not x=(args.pop) then
    print prompt
    x=STDIN.readline().chomp()
  end
  return x,args
end

# main

if ARGV!=[]
  args=ARGV.reverse
  ARGV.clear
else
  args=['list']
end

x,args=popArg args
tasks=Task.new(readTasks())
case x
when 'get'
  str_idx,args=popArg args,"index: "
  idx=getIdx str_idx
  task=tasks[idx]
  task.print
  print "subtasks #{task.subTasks}\n"
when 'getsub'
  str_idx,args=popArg args,"index: "
  idx=getIdx str_idx
  task=tasks[idx]
  task.listSubTasks
when 'getall'
  str_idx,args=popArg args,"index: "
  idx=getIdx str_idx
  task=tasks[idx]
  task.print
  task.listSubTasks 1
when 'list'
  tasks.listSubTasks
when 'add'
  name,args=popArg args,"name: "
  desc,args=popArg args,"description: "
  tasks+={"name"=>name,"desc"=>desc,"tasks"=>[],"chck"=>false}
  writeTasks tasks.getList
when 'addsub'
  str_idx,args=popArg args,"index: "
  idx=getIdx str_idx
  name,args=popArg args,"name: "
  desc,args=popArg args,"description: "
  tasks[idx]+={"name"=>name,"desc"=>desc,"tasks"=>[],"chck"=>false}
  writeTasks tasks.getList
when 'check'
  str_idx,args=popArg args,"index: "
  idx=getIdx str_idx
  tasks[idx].check
  writeTasks tasks.getList
when 'uncheck'
  str_idx,args=popArg args,"index: "
  idx=getIdx str_idx
  tasks[idx].uncheck
  writeTasks tasks.getList
when 'remove'
  str_idx,args=popArg args,"index: "
  idx=getIdx str_idx
  tasks-=idx
  writeTasks tasks.getList
else
  STDERR.print("invalid command\n")
end

