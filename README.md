Gabe
####

A framework for making LOVE games. If written correctly, a Gabe game
will be:

* fully reloadable: you can swap out a game's code and keep the data.
* fully serializable: you can swap out a game's data and keep the code
  and expensive to load assets.
* fully recoverable: you can break your code with impunity, and pick
  right back up where you left off when you fix it.

This is a lot to ask of a highly flexible language like Lua, so Gabe is
more than anything a set of conventions to make it possible to write
code with those properties.

The first is the notion of the gamestate. In Gabe, your entire game's
state should rest in a single global variable, ``S``. This includes your
game world state, your UI state, the state of the relevant key inputs,
everything and anything you might need to 100% reconstruct the same game
state somewhere else.
