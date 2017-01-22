--[[

  * * * * negate_smooth.lua * * * *

Lua image processing program: performs image negation and smoothing.
Menu routines are in example2.lua, IP routines are negate_smooth.lua.

Author: John Weiss, Ph.D.
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

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
local function binary( img )
  local nrows, ncols = img.height, img.width
  -- convert to YIQ mode
  img = color.RGB2YIQ( img )

  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
--      for ch = 0, 2 do
        -- get intensity for each pixel
        local i = img:at(r,c).rgb[0]
        -- default threshold is 128
        if i < 128 then 
          img:at(r,c).rgb[0] = 0
        else 
          img:at(r,c).rgb[0] = 255
        end
  --    end
    end
  end
  
  -- return image as RGB color mode image
  return color.YIQ2RGB( img )
end


------------------------------------
-------- exported routines ---------
------------------------------------

return {
  negate = negate,
  brighten = brighten,
  darken = darken,
  grayscale = grayscale,
  binary = binary
}
