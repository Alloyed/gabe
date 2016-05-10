package = "gabe"
version = "scm-1"
source = {
   url = "git://github.com/Alloyed/gabe"
}
description = {
   homepage = "https://github.com/Alloyed/gabe",
   license = "MIT"
}
dependencies = {
   "love >= 0.9" 
}
build = {
   type = "builtin",
   modules = {
      ["gabe"] = "gabe/init.lua",
      ["gabe.class"] = "gabe/class.lua",
      ["gabe.error_handlers"] = "gabe/error_handlers.lua",
      ["gabe.runners"] = "gabe/runners.lua",
      ["gabe.love"] = "gabe/love.lua",
      ["gabe.pickle"] = "gabe/pickle.lua",
      ["gabe.reload"] = "gabe/reload.lua",
      ["gabe.state"] = "gabe/state.lua",
   }
}
