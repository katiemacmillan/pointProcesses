--[[

  * * * * example2.lua * * * *

Lua image processing program: performs image negation and smoothing.
Menu routines are in example2.lua, IP routines are negate_smooth.lua.

Author: John Weiss, Ph.D.
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

-- LuaIP image processing routines

require "ip"
require "visual"

--local color = require "il.color"

-- my routines
local myip = require "intensity"
local myHist = require "hist"
-----------
-- menus --
-----------

imageMenu("Point processes",
  {
    {"My Negate", myip.negate},
    {"My Brighten", myip.brighten},
    {"My Darken", myip.darken},
    {"My Grayscale", myip.grayscale},
    {"Binary", myip.binary},
    {"Equalize", myHist.equalize},
  }
)
start()
