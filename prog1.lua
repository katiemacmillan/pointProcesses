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
local viz = require "visual"

--local color = require "il.color"

-- my routines
local myip = require "intensity"
local myHist = require "hist"
local myPseudo = require "pseudoColor"
local histo = require "il.histo"
-----------
-- menus --
-----------

imageMenu("Point processes",
  {
    {"Negate (RGB)", myip.negate},
    {"Histogram Equalize YIQ", histo.equalizeYIQ},
    {"Negate (intensity)", myip.negateInt},
    {"Brighten", myip.brighten},
    {"Darken", myip.darken},
    {"Grayscale", myip.grayscale},
    {"Binary Threshold", myip.binary,
      {{name = "binThresh", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
    {"Equalize", myHist.equalize},
    {"Contrast", myHist.contrastStretch,
      {{name = "Min Percent", type = "number", displaytype = "slider", default = 1, min = 0, max = 50},
      {name = "Max Percent", type = "number", displaytype = "slider", default = 1, min = 0, max = 50}}},
    {"AutoContrast", myHist.contrastStretch},
    {"PseudoColor - 8", myPseudo.pseudoColor8},
  }
)

imageMenu("Help",
  {
    { "Help", viz.imageMessage( "Help", "Abandon all hope, ye who enter here..." ) },
    { "About", viz.imageMessage( "Lua Image Point Processing" .. viz.VERSION, "Authors: Katie MacMillan and Forrest Miller\nClass: CSC442 Digital Image Processing\nDate: February 9th, 2017" ) },
  }
)
start()
