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
local function imgToRGB( img, mode )
  if mode == "yiq" then
    img = il.YIQ2RGB( img )
  elseif mode == "ihs" then
    img = il.IHS2RGB( img )
  end
  return img
end

local function imgFromRGB( img, mode )
  if mode == "yiq" then
    img = il.RGB2YIQ( img )
  elseif mode == "ihs" then
    img = il.RGB2IHS( img )
  end
  return img
end
-- negate/invert image
local function negate( img, mode )
  img = imgFromRGB(img, mode)
  img = img:mapPixels(
    function( r, g, b )
      r = 255 - r
      if mode == "rgb" then
        g = 255 - g
        b = 255 - b
      end
      
      return r, g, b
    end
  )
  
  return imgToRGB(img, mode)
end

local function brighten( img, offset, mode )
  img = imgFromRGB(img, mode)
  img = img:mapPixels(
    function( r, g, b )
      r = r + offset
      if r > 255 then r = 255
      elseif r < 0 then r = 0 end
      if mode == "rgb" then
        g = g + offset
        if g > 255 then g = 255
        elseif g < 0 then g = 0 end
        b = b + offset
        if b > 255 then b = 255
        elseif b < 0 then b = 0 end
      end
      
      return r, g, b
    end
  )
   return   imgToRGB(img, mode)
end

-- convert image to graysale
local function grayscale( img )
  img = img:mapPixels(
    function( r, g, b )
      local i = (r*0.3) + (g*0.59) + (b*0.11)
      return i, i, i
    end
  )
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
  for r = 0, nrows-1 do
    for c = 0, ncols-1 do        
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

local function toBin(num)
  local binary={}
  while num>0 do
    remainder = num%2
    table.insert(binary,1,remainder)
    num=(num-remainder)/2
  end 
  while table.getn(binary) < 8 do
    table.insert(binary, 1, 0)
  end
  
  return binary
end
local function bitPlane(img, plane)
  local nrows, ncols = img.height, img.width
  local temp = color.RGB2YIQ(img)
  -- for each pixel in the image
  for r = 0, nrows-1 do
    for c = 0, ncols-1 do        
      local bin = toBin(temp:at(r,c).y)
      if bin[plane+1] == 1 then 
        for ch = 0, 2 do
          temp:at(r,c).rgb[ch] = 255
        end
      else
        for ch = 0, 2 do
          temp:at(r,c).rgb[ch] = 0
        end
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
  grayscale = grayscale,
  binary = binary,
  gamma = gamma,
  posterize = posterize,
  bitPlane = bitPlane,
}