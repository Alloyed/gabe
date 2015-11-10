package = "gabe"
version = "scm-1"
source = {
   url = "/home/kyle/src/love-libs/gabe"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
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
      ["gabe.love"] = "gabe/love.lua",
      ["gabe.pickle"] = "gabe/pickle.lua",
      ["gabe.reload"] = "gabe/reload.lua",
      ["gabe.state"] = "gabe/state.lua",
   }
}
