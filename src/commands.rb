# control commands of the program #

class Main
  def commands
    {
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
  end
# prints task with its description and number of connected subtasks
  def get
    idx=getArg "index",type: :index
    task=@tasks[idx]
    task.print
    print "subtasks #{task.subTasks}\n"
  end
# prints all connected subtasks to the [index]item with their descriptions 
  def getsub
    idx=getArg "index",type: :index
    task=@tasks[idx]
    task.listSubTasks
  end
# prints task, its descritpion and all connected subtasks with their descriptions 
  def getall
    idx=getArg "index",type: :index
    task=@tasks[idx]
    task.print
    task.listSubTasks 1
  end
# prints all tasks with subtasks
  def list
    @tasks.listSubTasks
  end
# creates an item, prompts for name and optional description
  def add
    name=getArg "name",required: true
    desc=getArg "description"
    @tasks+={"name"=>name,"desc"=>desc,"tasks"=>[],"chck"=>false}
    writeTasks @tasks.getHash
  end
# creates a subitem for an item at [index]
  def addsub
    idx=getArg "index",type: :index
    name=getArg "name",required: true
    desc=getArg "description"
    @tasks[idx]+={"name"=>name,"desc"=>desc,"tasks"=>[],"chck"=>false}
  end
# checks an item at [index]; if the item is already checked, nothing happens
  def check
    idx=getArg "index",type: :index
    @tasks[idx].check
  end
# unchecks an item at [index]; if the item is not checked, nothing happens
  def uncheck
    idx=getArg "index",type: :index
    @tasks[idx].uncheck
  end
# removes an item at [index] and shifts all other items respectively 
  def remove
    idx=getArg "index",type: :index
    @tasks-=idx
  end
# prints help menu
  def help
    commands=commands()
    message="Usage: "+COLOR[:normal][:cyan]+"#{$0} "+COLOR[:reset]+"[command] [arguments]\n"+
            "a simple commandline todo app written in "+COLOR[:normal][:red]+"Ruby\n\n"+COLOR[:reset]
    max=commands.keys.map(&:length).max
    for command in commands.keys
      message+=sprintf "  %#{max}s - %s\n",command,commands[command][:help]||'missing description'
    end
    if not SETTINGS[:fallback_cmd].is_a? NilClass
      message+="\nif no command is supplied '#{SETTINGS[:fallback_cmd]}' command will be used\n"
    end
    STDOUT.print message
  end
end

