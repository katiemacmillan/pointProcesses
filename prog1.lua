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
local il = require "il"

-- our lua routines
local myip = require "intensity"
local myHist = require "hist"
local myPseudo = require "pseudoColor"

-- Weiss's Functions
local point = require "il.point"
local histo = require "il.histo"
local threshold = require "il.threshold"

-----------
-- menus --
-----------
-- point processes menu
imageMenu("Arithmetic Processes",
  {
    {"Negate", myip.negate,
      {{name = "Color Mode", type = "string", default = "rgb"}}},
    {"Brighten/Darken", myip.brightDark,
      {{name = "Offset", type = "number", displaytype = "slider", default = 0, min = -255, max = 255},
        {name = "Color Mode", type = "string", default = "rgb"}}},
    {"Adjust Contrast", myip.contrast,
        {{name = "min", type = "number", displaytype = "spin", default = 64, min = 0, max = 255},
        {name = "max", type = "number", displaytype = "spin", default = 191, min = 0, max = 255}}},
    {"Grayscale", myip.grayscale},
    {"Solarize", myip.solarize,
            {{name = "Threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
    {"Binary Threshold", myip.binary,
      {{name = "Threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
    {"Bit Plane Slicing", myip.bitPlane,
      {{name = "Bit (0 is LSB)", type = "number", displaytype = "spin", default = 0, min = 0, max = 7}}},
    {"Gamma", myip.gamma, {{name = "Gamma", type = "number", displaytype = "textbox", default = "1.0"}}},
    })
  
  -- color and lut processes
  imageMenu("LUT Processes", 
    {
      {"PseudoColor - 8", myPseudo.pseudoColor},
      {"PseudoColor - Specify", myPseudo.pseudoColor,
        {{name = "Color Levels", type = "number", displaytype = "spin", default = 60, min = 1, max = 255}}},
      {"PseudoColor - Continuous", myPseudo.continuousColor},
      {"Posterize", myPseudo.posterize,
        {{name = "Levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64}}},
      {"Logarithmic Compression", myPseudo.logCompression},
  })

-- histogram processes
imageMenu("Histogram Processes",
  {
    {"Display Histogram", il.showHistogram,
      {{name = "Color Mode", type = "string", default = "rgb"}}},
    {"Equalize - Specify", myHist.equalize,
      {{name = "Clip %", type = "number", displaytype = "textbox", default = "1.0"}}},
    {"Equalize - Auto", myHist.equalize},
    {"Contrast Stretch - Specify", myHist.contrastStretch,
      {{name = "Min Percent", type = "number", displaytype = "slider", default = 1, min = 0, max = 50},
      {name = "Max Percent", type = "number", displaytype = "slider", default = 1, min = 0, max = 50}}},
    {"Contrast Stretch - Auto", myHist.contrastStretch},
  })


-- help menu
imageMenu("Help",
  {
    {"Help", viz.imageMessage("Help", "Under the File menu a user can open a new image, save the current image or exit the program.\n\nBy right clicking on the image tab, the user can duplicate or reload the image. The user may also press Ctrl+D to duplicate an image or Crtl+R to reload it.\n\nThe Arithmetic Processes menu item hold all the arithmetic point processes you can use on your image. These are simple function maps, which do not require histograms or lookup tables.\n\nThe LUT Processes menu contains the point processs which do not require histograms, but do require lookup tables. Many, but not all, of these are pseudocolor processes.\n\nThe Histogram Processes menu contains the display histogram as well as the processes that are calculated using the histogram of the image.")},
    {"About", viz.imageMessage("Lua Image Point Processing" .. viz.VERSION, "Authors: Katie MacMillan and Forrest Miller\nClass: CSC442 Digital Image Processing\nDate: February 9th, 2017")},
  }
)

start()