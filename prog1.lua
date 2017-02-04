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
local il = require "il"
-----------
-- menus --
-----------

imageMenu("Point processes",
  {
    {"Negate (RGB)", myip.negateRGB},
    {"Negate (YIQ)", myip.negateYIQ},
    {"Negate (IHS)", myip.negateIHS},
    {"Brighten (RGB)", myip.brightenRGB,
      {{name = "binThresh", type = "number", displaytype = "slider", default = 0, min = -255, max = 255}}},
    {"Brighten (YIQ)", myip.brightenYIQ,
      {{name = "binThresh", type = "number", displaytype = "slider", default = 0, min = -255, max = 255}}},
    {"Brighten (IHS)", myip.brightenIHS,
      {{name = "binThresh", type = "number", displaytype = "slider", default = 0, min = -255, max = 255}}},
    {"Grayscale", myip.grayscale},
    {"Gamma (YIQ)", myip.gamma, {{name = "gamma", type = "number", displaytype = "textbox", default = "1.0"}}},
    {"Binary Threshold", myip.binary,
      {{name = "binThresh", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
    {"PseudoColor - Specify", myPseudo.pseudoColor,
      {{name = "Color Levels", type = "number", displaytype = "spin", default = 60, min = 1, max = 255}}},
    {"PseudoColor - 8", myPseudo.pseudoColor},
    {"PseudoColor - Continuous", myPseudo.continuousColor},
    {"Posterize", myip.posterize,
      {{name = "levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64}}},
  })
imageMenu("Histogram Processes",
  {
    {"Equalize - Specify", myHist.equalize,
      {{name = "Min Percent", type = "number", displaytype = "slider", default = 1, min = 0, max = 50},
      {name = "Max Percent", type = "number", displaytype = "slider", default = 1, min = 0, max = 50}}},
    {"Equalize - Auto", myHist.equalize},
    {"Contrast Stretch - Specify", myHist.contrastStretch,
      {{name = "Min Percent", type = "number", displaytype = "slider", default = 1, min = 0, max = 50},
      {name = "Max Percent", type = "number", displaytype = "slider", default = 1, min = 0, max = 50}}},
    {"Contrast Stretch - Auto", myHist.contrastStretch},
    {"Display Histogram", il.showHistogram,
      {{name = "Color Mode", type = "string", default = "rgb"}}},
  })
imageMenu("Weiss Processes",
  {
    {"IHStogram Equalize YIQ", histo.equalizeYIQ},
    {"Contrast Stretch", histo.stretch},
    {"Contrast Specify", histo.stretchSpecify, hotkey = "C-H",
      {{name = "lp", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
       {name = "rp", type = "number", displaytype = "spin", default = 99, min = 0, max = 100}}},
    {"Weiss Gamma (RGB)", il.gamma, {{name = "gamma", type = "number", displaytype = "textbox", default = "1.0"}}},
    {"Weiss Posterize", il.posterize,
      {{name = "levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64}}},
  })

imageMenu("Help",
  {
    { "Help", viz.imageMessage( "Help", "Abandon all hope, ye who enter here..." ) },
    { "About", viz.imageMessage( "Lua Image Point Processing" .. viz.VERSION, "Authors: Katie MacMillan and Forrest Miller\nClass: CSC442 Digital Image Processing\nDate: February 9th, 2017" ) },
  }
)
start()
