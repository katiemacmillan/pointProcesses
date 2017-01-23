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
    {"Negate", myip.negate},
    {"Brighten", myip.brighten},
    {"Darken", myip.darken},
    {"Grayscale", myip.grayscale},
    {"Binary Threshold", myip.binary,
      {{name = "binThresh", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
    {"Equalize", myHist.equalize},
  }
)
start()
