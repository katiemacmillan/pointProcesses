--[[
  * * * * intensity.lua * * * *
This file contains basic arithmetic (additive, subtractive, scaled), and binary 
point process operation fuctions.

Author: Katie MacMillan and Forrest Miller
Class: CSC442/542 Digital Image Processing
Date: 2/9/2017
--]]

local color = require "il.color"
local help = require "helpers"

--[[
  Function Name: negate
  
  Author: Katie MacMillan
  
  Description: The negate function subtracts the r (intensity) value from 255 in
  order to negate the image. If the user specified rbg mode then the g and b
  values are also subtracted from 255. Each color model gives a slightly different
  looking negate.
  
  Params: img  - the image that the process will be done to
          mode - which color model the user wishes to use
  
  Returns: img after it has been converted back to RGB
--]]
local function negate( img, mode )
  local cpy = img:clone()
  cpy = help.imgFromRGB( cpy, mode ) -- convert from rgb to mode for calculations

  -- set image by mapping the pixels through a function
  cpy = cpy:mapPixels(
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

  return help.imgToRGB( cpy, mode ) -- return the image after converting back to rgb
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
  local cpy = img:clone()
  
  cpy = help.imgFromRGB( cpy, mode )
  
  cpy = cpy:mapPixels(
    function( r, g, b )
      r = help.clip(r + offset)
      
      -- if we are in rgb mode add the offset to g and b
      if mode == "rgb" then
        g = help.clip(g + offset)
        b = help.clip(b + offset)
      end

      return r, g, b
    end
  )
  
  return   help.imgToRGB( cpy, mode )
end

--[[
  Function Name: grayscale
  
  Author: Katie MacMillan
  
  Description: The grayscale function multiplies each channel value
  of a each pixel by different percentages to get the pixel's intensity,
  which is then set as the new value of each color channel.
  
  Params: img - the image that needs to be converted
  
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
  
  Description: The gamma function starts by converting the image to yiq. Next we
  ensure that gamma is within the proper range. Then for each pixel we perform a
  gamma transformation to calculate a new intensity. This value is first clipped
  between 0 and 255 then set as the new intensity for the pixel. Finally, the
  image is converted back to rgb and returned.
  
  Params: img   - the image that needs to be converted
          gamma - the value chosen by the user for gamma
  
  Returns: img after it has been converted back to RGB
--]]
local function gamma( img, gamma )
  local nrows, ncols = img.height, img.width
  -- convert from RGB to YIQ
  local res = img:clone()
  res = color.RGB2YIQ( res )

  local gam = gamma

  if gam <= 0 then
    gam = 1.0 -- set gamma to the default if it is <= 0
  end

  -- for each pixel in the image
--<<<<<<< HEAD
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      local orig = img:at( r, c ).y / 255 -- intensity / 255
      -- raise orig intensity to gamma and multiply by 255
      local i = 255 * math.pow( orig, gam )

      -- clip to 0 and 255
      if i < 0 then i = 0 end
      if i > 255 then i = 255 end

      res:at( r, c ).y = i -- set new intensity
    end
  end

  return color.YIQ2RGB( res ) -- convert back and return
  
--======= Made it pink...?
--  res = img:mapPixels(
--    function (y, i, q)
--      local orig = y / 255
--      y = help.clip( 255 * math.pow( orig, gam ) )
--      return y, i, q
--    end)

--  return color.YIQ2RGB( res )
-->>>>>>> 0dc7e611dc82ddc3fcef9d853300904901fbda1b
end

--[[
  Function Name: binary
  
  Author: Forrest Miller and Katie MacMillan
  
  Description: The binary function takes in an intensity value
  threshold. If the pixel value is greater than the threshold
  then the pixel's intensity will be set to 255, otherwise it
  will be set to 0.
  
  Params:       img - the image that needs to be converted
          binThresh - the intensity value threshold which determines
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
  
  Params: img - the image that needs to be converted
          bit - the bit which will determine if a pixel intensity is 0 or 255
  
  Returns: img after it has been converted back to RGB
--]]
local function bitPlane( img, plane )
  img = img:mapPixels(
    function( r, g, b )
      -- get intensity value
      local i = ( r * 0.3 ) + ( g * 0.59 ) + ( b * 0.11 )
      
      -- convert intensity to a binary string
      local bin = help.toBinary( i )
      
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
  local cpy = img:clone()
  cpy = color.RGB2YIQ( img )
  local deltaX = max - min  -- find deltaX

  cpy = cpy:mapPixels(
    function( y, i, q )
      if y < min then y = 0
      elseif y > max then y = 255
      else 
        local contrast = ( 255 / deltaX ) * ( y - min ) -- calculate contrast
        y = math.floor( contrast + 0.5 ) -- round contrast
      end

      return y, i, q
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
  
  Params:       img - the image that needs to be converted
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
  bitPlane = bitPlane,
  solarize = solarize
}