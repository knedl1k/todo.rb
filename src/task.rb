
### Task class ###

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
    digits =3
    status =@chck ? :check : :uncheck
    check  =SETTINGS[:style][:color][status]+SETTINGS[:style][:text][status]+COLOR[:reset]
    box_l  =SETTINGS[:style][:color][:box]  +'['                            +COLOR[:reset]
    box_r  =SETTINGS[:style][:color][:box]  +']'                            +COLOR[:reset]
    name   =SETTINGS[:style][:color][:name] +@name                          +COLOR[:reset]
    comment=SETTINGS[:style][:color][:desc] +@desc                          +COLOR[:reset]
    colon  =SETTINGS[:style][:color][:line] +'|'                            +COLOR[:reset]
    number =(i.is_a?Integer)?
            SETTINGS[:style][:color][:index]+sprintf("%#{digits}d",i)       +COLOR[:reset]+
            SETTINGS[:style][:color][:colon]+':'                            +COLOR[:reset]:''
    comment_padding=' '*(digits+1+1+SETTINGS[:style][:text][status].length+1+1)
    padding=(' '*digits+colon)*depth

    text   = padding+number+box_l+check+box_r+' '+name+"\n"+
             ((@desc.is_a?String and not @desc.empty?)?
             padding+comment_padding+comment+"\n":'')
    STDOUT.print text
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

