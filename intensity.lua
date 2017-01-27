--[[

  * * * * negate_smooth.lua * * * *

Lua image processing program: performs image negation and smoothing.
Menu routines are in example2.lua, IP routines are negate_smooth.lua.

Author: John Weiss, Ph.D.
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

require "ip"
local il = require "il"
local color = require "il.color"
-----------------
-- IP routines --
-----------------

-- negate/invert image
local function negate( img )
  local nrows, ncols = img.height, img.width

  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      -- negate each RGB channel
      for ch = 0, 2 do
        img:at(r,c).rgb[ch] = 255 - img:at(r,c).rgb[ch]
      end
    end
  end

  return img
end

-- negate the intensities of an image
local function negateInt( img )
  local nrows, ncols = img.height, img.width
  
  -- convert from RGB to YIQ
  img = il.RGB2YIQ( img )
  
  local res = img:clone()
  
  -- for each pixel
  for r = 0, nrows-1 do
    for c = 0, ncols-1 do
      res:at(r,c).y = 255 - img:at(r,c).y
    end
  end
  
  return il.YIQ2RGB( res )
end

-----------------
-- brighten image by 10(default)
local function brighten( img )
  local nrows, ncols = img.height, img.width

  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      -- increase each RGB channel by 10
      for ch = 0, 2 do
        local i = img:at(r,c).rgb[ch] + 10
        -- clip max at 255
        if i > 255 
        then img:at(r,c).rgb[ch] = 255
        else img:at(r,c).rgb[ch] = i
        end
      end
    end
  end

  return img
end

-- darken image by 10 (default)
local function darken( img )
  local nrows, ncols = img.height, img.width

  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      -- darken each RGB channel by 10
      for ch = 0, 2 do
        local i = img:at(r,c).rgb[ch] - 10
        -- clip min at 0
        if i < 0 
        then img:at(r,c).rgb[ch] = 0
        else img:at(r,c).rgb[ch] = i
        end
      end
    end
  end

  return img
end


-- convert image to graysale
local function grayscale( img )
  local nrows, ncols = img.height, img.width

  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      -- negate each RGB channel
      local i = 0
      -- use red intensity as 30%, green as %59 and blue as %11
      i = (img:at(r,c).rgb[0]*0.3)
      i = i + (img:at(r,c).rgb[1]*0.59)
      i = i + (img:at(r,c).rgb[2]*0.11)
      -- clip min at 0
      if i < 0 
      then img:at(r,c).rgb[0] = 0
        img:at(r,c).rgb[1] = 0
        img:at(r,c).rgb[2] = 0
        -- clip max at 255
      elseif i > 255
      then img:at(r,c).rgb[0] = 255
        img:at(r,c).rgb[1] = 255
        img:at(r,c).rgb[2] = 255
        -- set intensity for each to i
      else img:at(r,c).rgb[0] = i
        img:at(r,c).rgb[1] = i
        img:at(r,c).rgb[2] = i
      end
    end
  end

  return img
end

-- convert to binary image (doesn't work right)
local function binary( img, binThresh )
  local nrows, ncols = img.height, img.width

  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do        
      -- use red intensity as 30%, green as %59 and blue as %11 to get grayscale intensity
      i = (img:at(r,c).rgb[0]*0.3)
      i = i + (img:at(r,c).rgb[1]*0.59)
      i = i + (img:at(r,c).rgb[2]*0.11)

      if i < binThresh then 
        img:at(r,c).rgb[0] = 0
        img:at(r,c).rgb[1] = 0
        img:at(r,c).rgb[2] = 0
      else 
        img:at(r,c).rgb[0] = 255
        img:at(r,c).rgb[1] = 255
        img:at(r,c).rgb[2] = 255
      end
    end
  end
  
  return img
end


------------------------------------
-------- exported routines ---------
------------------------------------

return {
  negate = negate,
  brighten = brighten,
  darken = darken,
  grayscale = grayscale,
  binary = binary,
  negateInt = negateInt
}
