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
imageMenu("Point Processes",
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
    {"Gamma (YIQ)", myip.gamma, {{name = "Gamma", type = "number", displaytype = "textbox", default = "1.0"}}},
    })
  
  -- color processes
  imageMenu("Color LUTs", 
    {
      {"PseudoColor - Specify", myPseudo.pseudoColor,
        {{name = "Color Levels", type = "number", displaytype = "spin", default = 60, min = 1, max = 255}}},
      {"PseudoColor - 8", myPseudo.pseudoColor},
      {"PseudoColor - Continuous", myPseudo.continuousColor},
      {"Posterize (YIQ)", myPseudo.posterize,
        {{name = "Levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64}}},
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
    {"Logarithmic Compression", myPseudo.logCompression},
  })

imageMenu("Weiss processes",
  {
    {"Grayscale YIQ\tCtrl-M", il.grayscaleYIQ, hotkey = "C-M"},
    {"Grayscale IHS", il.grayscaleIHS},
    {"Negate\tCtrl-N", il.negate, hotkey = "C-N",
      {{name = "color model", type = "string", default = "rgb"}}},
    {"Brighten", il.brighten,
      {{name = "amount", type = "number", displaytype = "slider", default = 0, min = -255, max = 255},
       {name = "color model", type = "string", default = "rgb"}}},
    {"Contrast Stretch", il.contrastStretch,
      {{name = "min", type = "number", displaytype = "spin", default = 64, min = 0, max = 255},
       {name = "max", type = "number", displaytype = "spin", default = 191, min = 0, max = 255}}},
    {"Scale Intensities", il.scaleIntensities,
      {{name = "min", type = "number", displaytype = "spin", default = 64, min = 0, max = 255},
       {name = "max", type = "number", displaytype = "spin", default = 191, min = 0, max = 255}}},
    {"Posterize", il.posterize,
      {{name = "levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64},
       {name = "color model", type = "string", default = "rgb"}}},
    {"Gamma", il.gamma,
      {{name = "gamma", type = "number", displaytype = "textbox", default = "1.0"},
       {name = "color model", type = "string", default = "rgb"}}},
    {"Log", il.logscale,
      {{name = "color model", type = "string", default = "rgb"}}},
    {"Solarize", il.solarize},
    {"Sawtooth", il.sawtooth,
      {{name = "levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64}}},
    {"Bitplane Slice", il.slice,
      {{name = "plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}},
    {"Cont Pseudocolor", il.pseudocolor1},
    {"Disc Pseudocolor", il.pseudocolor2},
    {"Color Cube", il.pseudocolor3},
    {"Random Pseudocolor", il.pseudocolor4},
    {"Color Sawtooth RGB", il.sawtoothRGB},
    {"Color Sawtooth BGR", il.sawtoothBGR},
    {"Contrast Stretch", il.stretch,
       {{name = "color model", type = "string", default = "yiq"}}},
    {"Contrast Specify\tCtrl-H", il.stretchSpecify, hotkey = "C-H",
      {{name = "lp", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
       {name = "rp", type = "number", displaytype = "spin", default = 99, min = 0, max = 100},
       {name = "color model", type = "string", default = "yiq"}}},
    {"Histogram Equalize", il.equalize,
      {{name = "color model", type = "string", default = "yiq"}}},
    {"Histogram Equalize Clip", il.equalizeClip,
      {{name = "clip %", type = "number", displaytype = "textbox", default = "1.0"},
       {name = "color model", type = "string", default = "yiq"}}},
    {"Display Histogram", il.showHistogram,
       {{name = "color model", type = "string", default = "yiq"}}},
    {"Adaptive Equalize", il.adaptiveEqualize,
      {{name = "width", type = "number", displaytype = "spin", default = 15, min = 3, max = 65}}},
    {"Adaptive Contrast Stretch", il.adaptiveContrastStretch,
      {{name = "width", type = "number", displaytype = "spin", default = 15, min = 3, max = 65}}},
  }
)

-- help menu
imageMenu("Help",
  {
    {"Help", viz.imageMessage("Help", "Under the File menu a user can open a new image, save the current image or exit the program.\n\nBy right clicking on the image tab, the user can duplicate or reload the image.\n\nThe Point Processes menu item hold all the different point processes you can use on your image. They also indicate what color model is used in the calculations.\n\nFinally, the Histogram Processes menu has the display histogram as well as the processes that are calculated using the histogram of the image.")},
    {"About", viz.imageMessage("Lua Image Point Processing" .. viz.VERSION, "Authors: Katie MacMillan and Forrest Miller\nClass: CSC442 Digital Image Processing\nDate: February 9th, 2017")},
  }
)

start()