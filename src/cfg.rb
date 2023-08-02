#!/usr/bin/ruby

# config file

### SETTINGS ###

DEFAULT=true

if DEFAULT
   TODO_FILE="#{ENV["HOME"]}/.local/share/todo.json"
   CHCK_SYMBOL='X'
   UCHCK_SYMBOL='O'
   COLORS=true
   FALLBACK_CMD='list'
   ERR="ERROR:"
else # user's custom config here

end

require './utils.rb'

if COLORS # probably redundant 
  COL_NUM  =CYA
  COL_NAME =GRN
  COL_DESC =WHT
  COL_CHCK =RED
  COL_UCHCK=BLU
  COL_BOX  =WHT
  COL_COL  =WHT
  COL_LINE =WHT
  COL_RESET=RST
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
