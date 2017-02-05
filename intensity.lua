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
local function negateRGB( img )
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
local function negateYIQ( img )
  local nrows, ncols = img.height, img.width
  
  -- convert from RGB to YIQ
  img = il.RGB2YIQ( img )
  
  local res = img:clone()
  
  -- for each pixel
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      res:at(r,c).y = 255 - img:at(r,c).y
    end
  end
  
  return il.YIQ2RGB( res )
end
-- negate the intensities of an image
local function negateIHS( img )
  local nrows, ncols = img.height, img.width
  
  -- convert from RGB to YIQ
  img = il.RGB2IHS( img )
  
  local res = img:clone()
  
  -- for each pixel
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      res:at(r,c).r = 255 - img:at(r,c).r
    end
  end
  
  return il.IHS2RGB( res )
end
-----------------
-- brighten image by 10(default)
local function brightenRGB( img, offset )
  local nrows, ncols = img.height, img.width

  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      -- increase each RGB channel by 10
      for ch = 0, 2 do
        local i = img:at(r,c).rgb[ch] + offset
        -- clip max at 255
        if i > 255 then img:at(r,c).rgb[ch] = 255
        elseif i < 0 then img:at(r,c).rgb[ch] = 0
        else img:at(r,c).rgb[ch] = i
        end
      end
    end
  end

  return img
end

local function brightenYIQ( img, offset )
  local nrows, ncols = img.height, img.width
  img = il.RGB2YIQ( img )
  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      -- increase each RGB channel by 10
      local i = img:at(r,c).y + offset
      -- clip max at 255
      if i > 255 then img:at(r,c).y = 255
      elseif i < 0 then img:at(r,c).y = 0
      else img:at(r,c).y = i
      end
    end
  end

  return   il.YIQ2RGB( img )
end

local function brightenIHS( img, offset )
  local nrows, ncols = img.height, img.width
  img = il.RGB2IHS( img )
  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      -- increase each RGB channel by 10
      local i = img:at(r,c).r + offset
      -- clip max at 255
      if i > 255 then 
        img:at(r,c).r = 255
      elseif i < 0 then 
        img:at(r,c).r = 0
      else 
        img:at(r,c).r = i
      end
    end
  end

  return   il.IHS2RGB( img )
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

-- gamma transformation
local function gamma( img, gamma )
  local nrows, ncols = img.height, img.width
  
  -- convert from RGB to YIQ
  img = il.RGB2YIQ(img)
  
  local res = img:clone()
  local gam = gamma
  
  if gam <= 0 then
    gam = 1.0
  end
  
  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      local orig = img:at(r,c).y/255
      local i = 255 * math.pow( orig, gam )
      
      if i < 0 then i = 0 end
      if i > 255 then i = 255 end
      
      res:at(r,c).y = i
    end
  end
  
  return il.YIQ2RGB( res )
end

local function posterizeLUT( levels )
  local lut = {}
  
  -- initialize to 0
  for i = 0, 256 do
    lut[i] = 0
  end
  
  -- stair step
  for i = 0, 256 do
    lut[i] = 255 / (levels - 1) * math.floor(i * levels / 256)
  end
    
  return lut
end

-- posterize image
local function posterize( img, levels )
  local nrows, ncols = img.height, img.width
  -- convert from RGB to YIQ
  img = il.RGB2YIQ(img)
  
  local res = img:clone()
  
  -- create lut for intensities
  local lut = posterizeLUT(levels)
  
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      -- look up intensity in lut
      i = img:at(r,c).y
      res:at(r,c).y = lut[i]
    end
  end
  
  return il.YIQ2RGB( res )
end

-- convert to binary image
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
  negateRGB = negateRGB,
  negateYIQ = negateYIQ,
  negateIHS = negateIHS,
  brightenRGB = brightenRGB,
  brightenYIQ = brightenYIQ,
  brightenIHS = brightenIHS,
  grayscale = grayscale,
  binary = binary,
  gamma = gamma,
  posterize = posterize
}