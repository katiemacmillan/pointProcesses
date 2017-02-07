--[[
  * * * * prog1.lua * * * *
Digital Image Process Program #1: This program does a multitude of point processes to a given image. Additionally, there are a handful of histogram operations that can be done. All operations can be accessed by the menus at the top of the screen. Most processes say which color model the calculations are done with.

Author: Katie MacMillan and Forrest Miller
Class: CSC442/542 Digital Image Processing
Date: 2/9/2017
--]]

-- LuaIP image processing routines
require "ip"
local viz = require "visual"
local histo = require "il.histo"
local il = require "il"

-- our lua routines
local myip = require "intensity"
local myHist = require "hist"
local myPseudo = require "pseudoColor"

-----------
-- menus --
-----------
-- point processes menu
imageMenu("Point Processes",
  {
    {"Negate (RGB)", myip.negate,
      {{name = "Color Mode", type = "string", default = "rgb"}}},
    {"Brighten/Darken", myip.brighten,
      {{name = "offset", type = "number", displaytype = "slider", default = 0, min = -255, max = 255},
        {name = "Color Mode", type = "string", default = "rgb"}}},
    {"Adjust Contrast", myip.contrast,
      {{name = "Min Intensity Offset", type = "number", displaytype = "spin", default = 0, min = -100, max = 100},
        {name = "Max Intensity Offset", type = "number", displaytype = "spin", default = 0, min = -100, max = 100},
        {name = "Color Mode", type = "string", default = "rgb"}}},
    {"Grayscale", myip.grayscale},
    {"Gamma (YIQ)", myip.gamma, {{name = "gamma", type = "number", displaytype = "textbox", default = "1.0"}}},
    {"Binary Threshold", myip.binary,
      {{name = "binThresh", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
    {"Bit Plane Slicing", myip.bitPlane,
      {{name = "bit", type = "number", displaytype = "slider", default = 0, min = 0, max = 7}}},
    })
  
  -- color processes
  imageMenu("Color LUTs", 
    {
      {"PseudoColor - Specify", myPseudo.pseudoColor,
        {{name = "Color Levels", type = "number", displaytype = "spin", default = 60, min = 1, max = 255}}},
      {"PseudoColor - 8", myPseudo.pseudoColor},
      {"PseudoColor - Continuous", myPseudo.continuousColor},
      {"Posterize", myip.posterize,
        {{name = "levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64}}},
  })

-- histogram processes
imageMenu("Histogram Processes",
  {
    {"Display Histogram", il.showHistogram,
      {{name = "Color Mode", type = "string", default = "rgb"}}},
    {"Equalize - Specify", myHist.equalize,
      {{name = "Max Times Avg", type = "number", displaytype = "slider", default = 3, min = 0, max = 10}}},
    {"Equalize - Auto", myHist.equalize},
    {"Contrast Stretch - Specify", myHist.contrastStretch,
      {{name = "Min Percent", type = "number", displaytype = "slider", default = 1, min = 0, max = 50},
      {name = "Max Percent", type = "number", displaytype = "slider", default = 1, min = 0, max = 50}}},
    {"Contrast Stretch - Auto", myHist.contrastStretch},
    {"Logarithmic Compression", myPseudo.logCompression},
  })

-- help menu
imageMenu("Help",
  {
    {"Help", viz.imageMessage("Help", "Under the File menu a user can open a new image, save the current image or exit the program.\n\nBy right clicking on the image tab, the user can duplicate or reload the image.\n\nThe Point Processes menu item hold all the different point processes you can use on your image. They also indicate what color model is used in the calculations.\n\nFinally, the Histogram Processes menu has the display histogram as well as the processes that are calculated using the histogram of the image.")},
    {"About", viz.imageMessage("Lua Image Point Processing" .. viz.VERSION, "Authors: Katie MacMillan and Forrest Miller\nClass: CSC442 Digital Image Processing\nDate: February 9th, 2017")},
  }
)

start()