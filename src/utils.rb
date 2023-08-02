#!/usr/bin/ruby

# utilitary functions and constants

require './cfg.rb'

if COLORS
   BCK ="\e[01;30m"
   RED ="\e[01;31m"
   GRN ="\e[01;32m"
   YLW ="\e[01;33m"
   BLU ="\e[01;34m"
   MGN ="\e[01;35m"
   CYA ="\e[01;36m"
   WHT ="\e[01;37m"
else 
   BCK =''
   RED =''
   GRN =''
   YLW =''
   BLU =''
   MGN =''
   CYA =''
   WHT =''
end
RST ="\e[0m"

INVALID_IDX_ERR="invalid index"
INVALID_TASK_IDX_ERR="invalid task index"
INVALID_CMD_ERR="invalid command"

def error(err_msg)
   STDERR.print(RED,ERR,RST,err_msg,"\n")
   exit 1
end

