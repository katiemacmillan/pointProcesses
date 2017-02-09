--[[
  * * * * lut.lua * * * *
This file contains image process functions that require lookup tables,
but do not involve histograms. Most of these involve color-maps.

Author: Katie MacMillan and Forrest Miller
Class: CSC442/542 Digital Image Processing
Date: 2/9/2017
--]]

local color = require "il.color"
--[[
  Name: colorMap
  
  Description: The colorMap is a pre-defined variable which is
  used as a lookup table for the continuous pseudocolor color
  mapping, and is used to create discrete pseudocolor lookup tables.
  
--]]
local colorMap = {
  {0, 0, 0},
  {0, 0, 7},
  {0, 0, 14},
  {0, 0, 21},
  {0, 0, 28},
  {0, 0, 35},
  {0, 0, 42},
  {0, 0, 49},
  {0, 0, 56},
  {0, 0, 63},
  {0, 0, 70},
  {0, 0, 77},
  {0, 0, 84},
  {0, 0, 91},
  {0, 0, 98},
  {0, 0, 105},
  {0, 0, 112},
  {0, 0, 119},
  {0, 0, 126},
  {0, 0, 133},
  {0, 0, 140},
  {0, 0, 147},
  {0, 0, 154},
  {0, 0, 161},
  {0, 0, 168},
  {0, 0, 175},
  {0, 0, 182},
  {0, 0, 189},
  {0, 0, 196},
  {0, 0, 203},
  {0, 0, 210},
  {0, 0, 217},
  {0, 0, 224},
  {0, 0, 231},
  {0, 0, 238},
  {0, 0, 245},
  {0, 0, 252},
  {0, 0, 255},
  {0, 7, 255},
  {0, 14, 255},
  {0, 21, 255},
  {0, 28, 255},
  {0, 35, 255},
  {0, 42, 255},
  {0, 49, 255},
  {0, 56, 255},
  {0, 63, 255},
  {0, 70, 255},
  {0, 77, 255},
  {0, 84, 255},
  {0, 91, 255},
  {0, 98, 255},
  {0, 105, 255},
  {0, 112, 255},
  {0, 119, 255},
  {0, 126, 255},
  {0, 133, 255},
  {0, 140, 255},
  {0, 147, 255},
  {0, 154, 255},
  {0, 161, 255},
  {0, 168, 255},
  {0, 175, 255},
  {0, 182, 255},
  {0, 189, 255},
  {0, 196, 255},
  {0, 203, 255},
  {0, 210, 255},
  {0, 217, 255},
  {0, 224, 255},
  {0, 231, 255},
  {0, 238, 255},
  {0, 245, 255},
  {0, 252, 255},
  {0, 255, 248},
  {0, 255, 241},
  {0, 255, 234},
  {0, 255, 227},
  {0, 255, 220},
  {0, 255, 213},
  {0, 255, 206},
  {0, 255, 199},
  {0, 255, 192},
  {0, 255, 185},
  {0, 255, 178},
  {0, 255, 171},
  {0, 255, 164},
  {0, 255, 157},
  {0, 255, 150},
  {0, 255, 143},
  {0, 255, 136},
  {0, 255, 129},
  {0, 255, 122},
  {0, 255, 115},
  {0, 255, 108},
  {0, 255, 101},
  {0, 255, 94},
  {0, 255, 87},
  {0, 255, 80},
  {0, 255, 73},
  {0, 255, 66},
  {0, 255, 59},
  {0, 255, 52},
  {0, 255, 45},
  {0, 255, 38},
  {0, 255, 31},
  {0, 255, 24},
  {0, 255, 17},
  {0, 255, 10},
  {0, 255, 3},
  {0, 255, 0},
  {7, 255, 0},
  {14, 255, 0},
  {21, 255, 0},
  {28, 255, 0},
  {35, 255, 0},
  {42, 255, 0},
  {49, 255, 0},
  {56, 255, 0},
  {63, 255, 0},
  {70, 255, 0},
  {77, 255, 0},
  {84, 255, 0},
  {91, 255, 0},
  {98, 255, 0},
  {105, 255, 0},
  {112, 255, 0},
  {119, 255, 0},
  {126, 255, 0},
  {133, 255, 0},
  {140, 255, 0},
  {147, 255, 0},
  {154, 255, 0},
  {161, 255, 0},
  {168, 255, 0},
  {175, 255, 0},
  {182, 255, 0},
  {189, 255, 0},
  {196, 255, 0},
  {203, 255, 0},
  {210, 255, 0},
  {217, 255, 0},
  {224, 255, 0},
  {231, 255, 0},
  {238, 255, 0},
  {245, 255, 0},
  {252, 255, 0},
  {255, 248, 0},
  {255, 241, 0},
  {255, 234, 0},
  {255, 227, 0},
  {255, 220, 0},
  {255, 213, 0},
  {255, 206, 0},
  {255, 199, 0},
  {255, 192, 0},
  {255, 185, 0},
  {255, 178, 0},
  {255, 171, 0},
  {255, 164, 0},
  {255, 157, 0},
  {255, 150, 0},
  {255, 143, 0},
  {255, 136, 0},
  {255, 129, 0},
  {255, 122, 0},
  {255, 115, 0},
  {255, 108, 0},
  {255, 101, 0},
  {255, 94, 0},
  {255, 87, 0},
  {255, 80, 0},
  {255, 73, 0},
  {255, 66, 0},
  {255, 59, 0},
  {255, 52, 0},
  {255, 45, 0},
  {255, 38, 0},
  {255, 31, 0},
  {255, 24, 0},
  {255, 17, 0},
  {255, 10, 0},
  {255, 3, 0},
  {255, 0, 0},
  {255, 0, 7},
  {255, 0, 14},
  {255, 0, 21},
  {255, 0, 28},
  {255, 0, 35},
  {255, 0, 42},
  {255, 0, 49},
  {255, 0, 56},
  {255, 0, 63},
  {255, 0, 70},
  {255, 0, 77},
  {255, 0, 84},
  {255, 0, 91},
  {255, 0, 98},
  {255, 0, 105},
  {255, 0, 112},
  {255, 0, 119},
  {255, 0, 126},
  {255, 0, 133},
  {255, 0, 140},
  {255, 0, 147},
  {255, 0, 154},
  {255, 0, 161},
  {255, 0, 168},
  {255, 0, 175},
  {255, 0, 182},
  {255, 0, 189},
  {255, 0, 196},
  {255, 0, 203},
  {255, 0, 210},
  {255, 0, 217},
  {255, 0, 224},
  {255, 0, 231},
  {255, 0, 238},
  {255, 0, 245},
  {255, 0, 252},
  {255, 0, 255},
  {255, 7, 255},
  {255, 14, 255},
  {255, 21, 255},
  {255, 28, 255},
  {255, 35, 255},
  {255, 42, 255},
  {255, 49, 255},
  {255, 56, 255},
  {255, 63, 255},
  {255, 70, 255},
  {255, 77, 255},
  {255, 84, 255},
  {255, 91, 255},
  {255, 98, 255},
  {255, 105, 255},
  {255, 112, 255},
  {255, 119, 255},
  {255, 126, 255},
  {255, 133, 255},
  {255, 140, 255},
  {255, 147, 255},
  {255, 154, 255},
  {255, 161, 255},
  {255, 168, 255},
  {255, 175, 255},
  {255, 182, 255},
  {255, 189, 255},
  {255, 196, 255},
  {255, 203, 255},
  {255, 210, 255},
  {255, 217, 255},
  {255, 224, 255},
  {255, 231, 255},
  {255, 238, 255},
  {255, 245, 255},
}
--[[
  Function Name: pseudoColorLUT
  
  Author: Katie MacMillan

  Description: The pseudoColorLUT function 
  
  Params:  levels - the number of discrete pseudocolor levels to be generated
          specify - a boolean indicating whether the levels are user specified
  
  Returns: a discrete pseudocolor lookup table
--]]
local function pseudoColorLUT(levels, specify)
  local lut = {}
  -- determine the size of each color zone
  local zones = math.floor((256/levels) + 0.5)
  -- start the color map base at position 1 (0)
  local cm = 1
  -- if the levels are user specified, start in a random position in the color map
 if specify then
    math.randomseed(os.time())
    local rand = math.random()*1000
    cm = (math.floor(rand+0.5))%256
  end
  
  i = 1
  while i < 257 do
    local j = 0 -- tracks the number of positions in a color zone
    while j < zones do
    -- fill each zone with the same color
      lut[i] = colorMap[cm]
      j = j + 1
      i = i+1
    end
    -- move color map position to next zone intensity
    cm = (cm + zones)%256
  end
  
  return lut
end

--[[
  Function Name: pseudoColor
  
  Author: Katie MacMillan

  Description: The pseudoColor function utilizes a colormap lookup
  table of discrete color values to map each pixel intensity to
  an arbitrary color
  
  Params:    img - the image that needs to be converted
          levels - the number of discrete color levels to be used
  
  Returns: img after it has been converted to a pseudocolor image
--]]
local function pseudoColor( img, levels )
  -- assume the user passed in number of discrete levels
  local specify = true
  -- if no levels indicated, default is 8 and specify is false
  if levels == nil then 
    levels = 8
    specify = false
  end
  -- get number of rows and columns in image
  local lut = pseudoColorLUT(levels, specify)
  -- for each pixel in the image
  img = img:mapPixels(
    function( r, g, b )
      -- get the intensity of the pixel, plus 1 because lua is 1 indexed
      local i = math.floor((r*0.3) + (g*0.59) + (b*0.11)+0.5) + 1
      -- map each channel to the corresponding lookup table channel
      return lut[i][1], lut[i][2], lut[i][3]
    end
  )
  return img
end


--[[
  Function Name: continuousColor
  
  Author: Katie MacMillan

  Description: The continuousColor function utilizes the colorMap lookup table
  to assign each pixel intensity in an image to an arbitrary, pre-defined color.
  These color values are incremented in small steps, giving a continuous effect.
  
  Params: img - the image that needs to be converted
  
  Returns: img after it has been converted to continuous pseudocolor
--]]
local function continuousColor(img)  
  -- for each pixel in the image
  img = img:mapPixels(
    function( r, g, b )
      -- get pixel intensity, plus 1 because lua is 1 indexed
      local i = math.floor((r*0.3) + (g*0.59) + (b*0.11)+0.5) + 1
      -- map each channel to the corresponding channel at the intensity index of the color map
      return colorMap[i][1], colorMap[i][2], colorMap[i][3]
    end
  )
  return img
end



--[[
  Function Name: logarithmicLUT
  
  Author: Katie MacMillan

  Description: The logarithmicLUT function creates a lookup table
  which compresses intensity values by mapping several to the same
  intensity through the use of logarithms.
    
  Returns: the logarithm based lookup table
--]]
local function logarithmicLUT()
  local lut = {}
  -- set a constant multiplier
  local c = (255/(math.log(255)))
  -- get the logarithm times the multiplier of each intensity
  for i = 1, 256 do
    lut[i] = math.floor((c*(math.log(i)))+0.5)
    lut[i] = help.clip(lut[i])
  end
    
  return lut
end
--[[
  Function Name: logCompression
  
  Author: Katie MacMillan

  Description: The logCompression function utilizes a lookup table which maps
  intensity values to their log values times a multiplier. The effect is that
  many intensities will map to the same intensity.
  
  Params: img - the image that needs to be converted
  
  Returns: img after it has been log compressed
--]]
local function logCompression(img)
  local lut = logarithmicLUT()
  cpy = img:clone()
  cpy = color.RGB2YIQ(img)
  
  cpy = cpy:mapPixels(
    function( y, i, q )
      -- map pixels to the log lookuptable
      return lut[y+1], i, q
    end
  )
  -- return the histogram array
  return color.YIQ2RGB(cpy)
end

--[[
  Function Name: posterizeLUT
  
  Author: Forrest Miller
  
  Description: The posterizeLUT function creates a look up table for the posterize
  intensities so that from 0 to 255 there are as many levels as requested. This is
  returned to the posterize function for use.
  
  Params: levels - the number of levels of posterization requested by the user
  
  Returns: lut - intensity look up table
--]]
local function posterizeLUT( levels )
  local lut = {}

  -- initialize to 0
  for i = 0, 256 do
    lut[i] = 0
  end

  -- stair step
  for i = 0, 256 do
    lut[i] = 255 / ( levels - 1 ) * math.floor( i * levels / 256 )
  end

  return lut
end

--[[
  Function Name: posterize
  
  Author: Forrest Miller
  
  Description: The posterize function converts the image to yiq first. Then a call
  is made to create the posterize look up table. Then we just look up the
  intensities in the look up table and return the image after it is converted back
  to rgb.
  
  Params:    img - the image that needs to be converted
          levels - how many levels of posterization the user wants
  
  Returns: img after it has been converted back to RGB
--]]
local function posterize( img, levels )
  local res = img:clone()
 -- convert from RGB to YIQ
  res = color.RGB2YIQ( res )
 
  -- create lut for intensities
  local lut = posterizeLUT( levels )

  res = res:mapPixels(
    function(y, i, q) 
      y = lut[y]      
      return y, i, q
    end)
  
  return color.YIQ2RGB( res )
end

------------------------------------
-------- exported routines ---------
------------------------------------

return {
  pseudoColor = pseudoColor,
  continuousColor = continuousColor,
  logCompression = logCompression,
  posterize = posterize,
}
