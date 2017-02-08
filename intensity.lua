--[[
  * * * * intensity.lua * * * *
This file contains most on the point processes an useful helper methods. The
histogram and pseudocolor functions are located in other files.

Author: Katie MacMillan and Forrest Miller
Class: CSC442/542 Digital Image Processing
Date: 2/9/2017
--]]

local color = require "il.color"

--[[
  Function Name: imgToRGB
  
  Author: Katie MacMillan
  
  Description: The imgToRGB function is a helper function that converts the
  incoming image from either yiq or ihs to rgb by utilizing Dr.Weiss' ip.lua file.
  
  Params: img - the image that needs to be converted
          mode - which color model we are converting from
  
  Returns: img after it has been converted back to RGB
--]]
local function imgToRGB( img, mode )
  if mode == "yiq" then
    img = il.YIQ2RGB( img )
  elseif mode == "ihs" then
    img = il.IHS2RGB( img )
  end
  return img
end

--[[
  Function Name: imgFromRGB
  
  Author: Katie MacMillan
  
  Description: The imgFromRGB function is a helper function that converts the
  incoming image from rgb to either yiq or ihs using Dr.Weiss' ip.lua file.
  
  Params: img - the image that needs to be converted
          mode - which color model we are converting to
  
  Returns: img after it has been converted to the requested color model
--]]
local function imgFromRGB( img, mode )
  if mode == "yiq" then
    img = il.RGB2YIQ( img )
  elseif mode == "ihs" then
    img = il.RGB2IHS( img )
  end
  return img
end

--[[
  Function Name: toBin
  
  Author: Katie MacMillan
  
  Description: The toBin function...
  
  Params: num - ???
  
  Returns: binary - ???
--]]
local function toBin( num )
  local binary = {}
  
  -- convert the number to a bit string
  while num > 0 do
    remainder = num % 2 -- get a big
    table.insert( binary, 1 , remainder ) -- add bit to the front of the bit string
    num = ( num - remainder ) / 2 -- subtract the bit from the number and divide by 2
  end 
  
  -- insert 0s at the front of the array until we have 8 bits
  while table.getn( binary ) < 8 do
    table.insert( binary, 1, 0 )
  end
  
  return binary
end

--[[
  Function Name: negate
  
  Author: Katie MacMillan
  
  Description: The negate function subtracts the r (intensity) value from 255 in
  order to negate the image. If the user specified rbg mode then the g and b
  values are also subtracted from 255. Each color model gives a slightly different
  looking negate.
  
  Params: img - the image that the process will be done to
          mode - which color model the user wishes to use
  
  Returns: img after it has been converted back to RGB
--]]
local function negate( img, mode )
  img = imgFromRGB( img, mode ) -- convert from rgb to mode for calculations
  
  -- set image by mapping the pixels through a function
  img = img:mapPixels(
    function( r, g, b )
      r = 255 - r -- negate the r/y/i value
      if mode == "rgb" then
        -- if we are in rgb mode, negate the g and b values
        g = 255 - g
        b = 255 - b
      end
      
      return r, g, b
    end
  )
  
  return imgToRGB( img, mode ) -- return the image after converting back to rgb
end

--[[
  Function Name: brightDark
  
  Author: Katie MacMillan
  
  Description: The brightDark function uses an offset to either brighten(positive
  offset) or darken(negative offset) an image. First we convert to whichever color
  model the user has specified. Then we add the offset to the r of the image,
  clipping at 0 and 255. If the process is being done in rgb mode then the offset
  is added to the g and b values, again clipping at 0 and 255. Finally, the image
  is returned after being converted back to rgb.
  
  Params: img    - the image that needs to be converted
          offset - how much we are supposed to brighten or darken
          mode   - which color model we are converting from
  
  Returns: img after it has been converted back to RGB
--]]
local function brightDark( img, offset, mode )
  img = imgFromRGB( img, mode )
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
   return   imgToRGB( img, mode )
end

--[[
  Function Name: brighten
  
  Author: Katie MacMillan
  
  Description: The brighten function 
  
  Params: img    - the image that needs to be converted
          offset - how mush we are supposed to brighten or darken
          mode   - which color model we are converting from
  
  Returns: img after it has been converted back to RGB
--]]
local function grayscale( img )
  img = img:mapPixels(
    function( r, g, b )
      local i = ( r * 0.3 ) + ( g * 0.59 ) + ( b * 0.11 )
      return i, i, i
    end
  )
  return img
end

--[[
  Function Name: brighten
  
  Author: Forrest Miller
  
  Description: The brighten function 
  
  Params: img    - the image that needs to be converted
          offset - how mush we are supposed to brighten or darken
          mode   - which color model we are converting from
  
  Returns: img after it has been converted back to RGB
--]]
local function gamma( img, gamma )
  local nrows, ncols = img.height, img.width
  
  -- convert from RGB to YIQ
  img = il.RGB2YIQ( img )
  
  local res = img:clone()
  local gam = gamma
  
  if gam <= 0 then
    gam = 1.0
  end
  
  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      local orig = img:at( r, c ).y / 255
      local i = 255 * math.pow( orig, gam )
      
      if i < 0 then i = 0 end
      if i > 255 then i = 255 end
      
      res:at( r, c ).y = i
    end
  end
  
  return il.YIQ2RGB( res )
end

--[[
  Function Name: brighten
  
  Author: Forrest Miller
  
  Description: The brighten function 
  
  Params: img    - the image that needs to be converted
          offset - how mush we are supposed to brighten or darken
          mode   - which color model we are converting from
  
  Returns: img after it has been converted back to RGB
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
  Function Name: brighten
  
  Author: Forrest Miller
  
  Description: The brighten function 
  
  Params: img    - the image that needs to be converted
          offset - how mush we are supposed to brighten or darken
          mode   - which color model we are converting from
  
  Returns: img after it has been converted back to RGB
--]]
local function posterize( img, levels )
  local nrows, ncols = img.height, img.width
  -- convert from RGB to YIQ
  img = il.RGB2YIQ( img )
  
  local res = img:clone()
  
  -- create lut for intensities
  local lut = posterizeLUT( levels )
  
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      -- look up intensity in lut
      i = img:at( r, c ).y
      res:at( r, c ).y = lut[i]
    end
  end
  
  return il.YIQ2RGB( res )
end

--[[
  Function Name: brighten
  
  Author: Forrest Miller and Katie MacMillan
  
  Description: The brighten function 
  
  Params: img    - the image that needs to be converted
          offset - how mush we are supposed to brighten or darken
          mode   - which color model we are converting from
  
  Returns: img after it has been converted back to RGB
--]]
local function binary( img, binThresh )
   img = img:mapPixels(
    function( r, g, b )
      local i = ( r * 0.3 ) + ( g * 0.59 ) + ( b * 0.11 )
      if i < binThresh then i = 0
      else i = 255 end
      
      return i, i, i
    end
  )
  
  return img
end

--[[
  Function Name: brighten
  
  Author: Katie MacMillan
  
  Description: The brighten function 
  
  Params: img    - the image that needs to be converted
          offset - how mush we are supposed to brighten or darken
          mode   - which color model we are converting from
  
  Returns: img after it has been converted back to RGB
--]]
local function bitPlane( img, plane )
  local nrows, ncols = img.height, img.width
   img = img:mapPixels(
    function( r, g, b )
      local bin = toBin( r )
      if bin[plane+1] == 1 then r = 255
      else r = 0 end
      bin = toBin( g )
      if bin[plane+1] == 1 then g = 255
    else g = 0 end
      bin = toBin( b )
      if bin[plane+1] == 1 then b = 255
      else b = 0 end
      
      return r, g, b
    end
  )
  
  return img
end

--[[
  Function Name: brighten
  
  Author: Katie MacMillan
  
  Description: The brighten function 
  
  Params: img    - the image that needs to be converted
          offset - how mush we are supposed to brighten or darken
          mode   - which color model we are converting from
  
  Returns: img after it has been converted back to RGB
--]]
local function contrast( img, contrast, mode )
  local scale = ( 256 * ( contrast + 256 ) ) / ( 256 * ( 256 - contrast ) )
  img = imgFromRGB( img, mode )
  img = img:mapPixels(
    function( r, g, b )
      r = scale * ( r   - 128 ) + 128 
      if r < 0 then r = 0
      elseif r > 255 then r = 255 end
      
      if mode == "rgb" then
        g = scale * ( g   - 128 ) + 128
        if g < 0 then g = 0
        elseif g > 255 then g = 255 end
      
        b = scale * ( b   - 128 ) + 128
        if b < 0 then b = 0
        elseif b > 255 then b = 255 end
      end
      
      return r, g, b
    end
  )
  return imgToRGB( img, mode )
  
end

------------------------------------
-------- exported routines ---------
------------------------------------
return {
  negate = negate,
  brightDark = brightDark,
  contrast = contrast,
  grayscale = grayscale,
  binary = binary,
  gamma = gamma,
  posterize = posterize,
  bitPlane = bitPlane,
}