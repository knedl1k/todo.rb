class Main
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
    "a simple commandline todo app written in Ruby\n"\
    "   \n"
    for command in @commands.keys
      message+=sprintf "  %7s - %s\n",command,@commands[command][:help] # TODO: change to dynamic length
    end
    if not SETTINGS[:fallback_cmd].is_a? NilClass
      message+="\nif no command is supplied \"#{SETTINGS[:fallback_cmd]}\" command will be used\n"
    end
    print message
  end
end

