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
    img = color.YIQ2RGB( img )
  elseif mode == "ihs" then
    img = color.IHS2RGB( img )
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
    img = color.RGB2YIQ( img )
  elseif mode == "ihs" then
    img = color.RGB2IHS( img )
  end
  return img
end

--[[
  Function Name: toBin
  
  Author: Katie MacMillan
  
  Description: The toBin function converts a pixel intensity value to a
  binary string
  
  Params: num - intensity value to be converted to binary
  
  Returns: binary - binary string representation of num
--]]
local function toBin( num )
  local binary = {}

  -- convert the number to a bit string
  while num > 0 do
    local remainder = num % 2 -- get a big
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
  Function Name: grayscale
  
  Author: Katie MacMillan
  
  Description: The grayscale function multiplies each channel value
  of a each pixel by different percentages to get the pixel's intensity,
  which is then set as the new value of each color channel.
  
  Params: img    - the image that needs to be converted
  
  Returns: img after its pixels have been re-mapped
--]]
local function grayscale( img )
  img = img:mapPixels(
    function( r, g, b )
      -- calculate pixel's intensity
      local i = ( r * 0.3 ) + ( g * 0.59 ) + ( b * 0.11 )
      return i, i, i
    end
  )
  return img
end

--[[
  Function Name: gamma
  
  Author: Forrest Miller
  
  Description: The gamma function 
  
  Params: img    - the image that needs to be converted
          offset - how mush we are supposed to brighten or darken
          mode   - which color model we are converting from
  
  Returns: img after it has been converted back to RGB
--]]
local function gamma( img, gamma )
  local nrows, ncols = img.height, img.width

  -- convert from RGB to YIQ
  img = color.RGB2YIQ( img )

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

  return color.YIQ2RGB( res )
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
  Function Name: posterize
  
  Author: Forrest Miller
  
  Description: The brighten function 
  
  Params: img    - the image that needs to be converted
          levels   - which color model we are converting from
  
  Returns: img after it has been converted back to RGB
--]]
local function posterize( img, levels )
  local nrows, ncols = img.height, img.width
  -- convert from RGB to YIQ
  img = color.RGB2YIQ( img )
  
  local res = img:clone()

  -- create lut for intensities
  local lut = posterizeLUT( levels )

  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      -- look up intensity in lut
      local i = img:at( r, c ).y
      res:at( r, c ).y = lut[i]
    end
  end
  
  return color.YIQ2RGB( res )
end

--[[
  Function Name: binary
  
  Author: Forrest Miller and Katie MacMillan
  
  Description: The binary function takes in an intensity value
  threshold. If the pixel value is greater than the threshold
  then the pixel's intensity will be set to 255, otherwise it
  will be set to 0.
  
  Params: img    - the image that needs to be converted
          binThresh   - the intensity value threshold which determines
                      if a pixel is set to 255 or 0
  
  Returns: img after it has been converted back to RGB
--]]
local function binary( img, binThresh )
  img = img:mapPixels(
    function( r, g, b )
      -- get intensity value of the pixel
      local i = ( r * 0.3 ) + ( g * 0.59 ) + ( b * 0.11 )
      if i < binThresh then i = 0
      else i = 255 end

      return i, i, i
    end
  )

  return img
end

--[[
  Function Name: bitPlane
  
  Author: Katie MacMillan
  
  Description: The function which maps an image based on whether or not a
  specified bit in the intensity value is 1 or 0. If the bit in the pixel's
  intensity value is 1, the pixel's intensity will be set to 255, otherwise
  it will be set to 0.
  
  Params: img    - the image that needs to be converted
          bit   - the bit which will determine if a pixel intensity is 0 or 255
  
  Returns: img after it has been converted back to RGB
--]]
local function bitPlane( img, plane )
  img = img:mapPixels(
    function( r, g, b )
      -- get intensity value
      local i = ( r * 0.3 ) + ( g * 0.59 ) + ( b * 0.11 )
      -- convert intensity to a binary string
      local bin = toBin( i )
      -- set all channel intensities to 0 or 255 if the specified bit is high or low
      if bin[plane+1] == 1 then i = 255
      else i = 0 end
      return i, i, i
    end
  )
  return img

end

--[[
  Function Name: contrast
  
  Author: Katie MacMillan
  
  Description: The constrast stretch function which allows users to
  specify minimum and maximum intensity values
  
  Params: img    - the image that needs to be converted
          min - the minimum intensity of any pixel
          max   - the maximum intensity of any pixel
  
  Returns: img after it has been converted back to RGB
--]]
local function contrast( img, min, max )
  img = color.RGB2YIQ( img )
  local lut = {}

  for i = 1, min - 1 do
    lut[i] = 0
  end

  for i = max + 1, 256 do
    lut[i] = 255     -- clip to 255
  end

  local deltaX = max - min  -- find deltaX
  -- set all remaining intensities to fit between contrasts
  for i =  min, max do
    local contrast = ( 255 / deltaX ) * ( i - min ) -- calculate contrast
    lut[i] = math.floor( contrast + 0.5 ) -- round contrast
  end

  img = img:mapPixels(
    function( r, g, b )
      r = lut[r + 1]      
      return r, g, b
    end
  )

  return color.YIQ2RGB(img)

end

--[[
  Function Name: solarize
  
  Author: Katie MacMillan
  
  Description: The solarize function takes in a threshold value
  and any color channel intensity that is below the threshold
  is negated
  
  Params: img    - the image that needs to be converted
          threshold - the value which determines if a color intensity is inverted
  
  Returns: img after its pixels have been remapped
--]]
local function solarize (img, threshold)
  img = img:mapPixels(
    function( r, g, b )
      if r < threshold then r = 255 - r end
      if g < threshold then g = 255 - g end
      if b < threshold then b = 255 - b end
      return r, g, b
    end
  )

  return img
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
  solarize = solarize
}