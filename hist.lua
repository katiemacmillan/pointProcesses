--[[
  * * * * hist.lua * * * *
hist.lua contains image processing functions which
rely on the use of an image histogram.

Author: Katie MacMillan and Forrest Miller
Class: CSC442/542 Digital Image Processing
Date: 2/9/2017
--]]

local color = require "il.color"
local help = require "helpers"
--[[
  Function Name: getHistogram
  
  Author: Katie MacMillan
  
  Description: The getHistogram function creates a histogram table
  of the given image by accumulating at the index of each intensity 
  the total number of pixels that have that intensity
  
  Params: img - the image to be evaluated
  
  Returns: histogram of the passed in image
--]]
local function getHistogram( img )
  -- create new array for histogram
  local h = {}
  local sum = 0
  -- initialize each intensity to 0
  for i=1, 256 do
    h[i] = 0
  end

  -- sum pixels per intensity into array h
  img = img:mapPixels(
    function( y, i, q )
      -- lua is indexed at 1, not 0
      h[y+1] = h[y+1] + 1
      return y, i, q
    end
  )

  return h, sum
end

--[[
  Function Name: clipHistogram
  
  Author: Katie MacMillan
  
  Description: The clipHistogram function evaluates the count
  of pixels at each intensity index within a histogram. If any intensity
  pixel count is above the limit specified in clip, that intensity index
  count is changed to the value in clip.
  
  Params: hist - the histogram containing intensity pixel counts
          clip - the maximum pixel count for any given intensity
  
  Returns: the adjusted histogram and a count of the total number of pixels
  represented within the adjusted histogram
--]]
local function clipHistogram( hist, clip )
  -- track total pixels in the histogram
  local sum = 0

  for i = 1, 256 do
    -- check if intensity has more than the specified number of pixels
    if hist[i] > ( clip ) then
      -- if so clip it
      hist[i] = clip
    end
    -- track the new histogram pixel count
    sum = sum + hist[i]
  end

  return hist, sum
end

--[[
  Function Name: equalizeLUT
  
  Author: Katie MacMillan
  
  Description: The equalizeLUT function utilizes the number of pixels
  within a histogram to create a lookup-table which will automatically
  equalize an input image. 
  
  Params:  img -  the image that needs to be evaluated
          clip -  the maximum percentage of total pixels allowed to be in
                  any given intensity value
  
  Returns: an equalization lookup table
--]]
local function equalizeLUT( img, clip )
  local lut = {}
  -- grab initial sum of pixels in the image
  local sum = img.height * img.width

  -- get the initial histogram
  local hist = getHistogram ( img )
  -- check if a clip value has been passed in
  if clip ~= nil then
    -- compute the maximum number of pixels to be assigned to any intensity
    local pixels = sum * clip / 100
    -- adjust the histogram and retrieve the new pixel sum
    hist, sum = clipHistogram( hist, pixels )
  end

  -- compute an alpha muliplier
  local alpha = 256 / sum

  -- set first used intensity position in the array
  lut[1] = alpha * hist[1]

  -- set remaining array values
  for i=2, 256 do
    lut[i] = lut[i - 1] + (alpha * hist[i])
    lut[i] = clip( lut[i] )
  end

  return lut
end

--[[
  Function Name: contrastLUT
  
  Author: Katie MacMillan
  
  Description: The contrastLUT function stretches the contrast between
  pixel intensities by decreasing the pixel range and remapping this from
  0 to 255 while multiplying each intensity by an offset modifier.
  
  Params: hist - the histogram to be evaluated
          pMin - the number of pixels at low intensities to ignore
          pMax - the number of pixels at high intensities to ignore
  
  Returns: the lookup table remapped for stretched contrast
--]]
local function contrastLUT( hist, pMin, pMax )
  local lut = {}
  -- get min and max intensities after ignoring pixels
  local max = help.getIMax( hist, pMax )
  local min = help.getIMin( hist, pMin )

  -- initialize bottom of lut to 0
  for i = 1, min - 1 do
    lut[i] = 0
  end

  -- initialize top of lut to 255
  for i = max + 1, 256 do
    lut[i] = 255     -- clip to 255
  end

  local deltaX = max - min  -- find deltaX
  -- set all remaining intensities to fit between contrasts
  for i =  min, max do
    local contrast = ( 255 / deltaX ) * ( i - min ) -- calculate contrast
    lut[i] = math.floor( contrast + 0.5 ) -- round contrast
  end

  return lut
end

--[[
  Function Name: equalize
  
  Author: Katie MacMillan
  
  Description: The equalize function utilized an equalize lookup table
  to map all of the pixels in an image to a new set of histogram equalized
  pixels.
  
  Params:  img - the image that needs to be converted
          clip - the maximum percentage of the overal image pixels which can be
                 assigned to any given intensity
          
  Returns: img after its pixels have been remapped
--]]
local function equalize ( img, clip )
  -- convert image to YIQ color mode
  local cpy = img:clone()
  cpy = color.RGB2YIQ( cpy )
  -- create look up table for each gray value
  local lut = equalizeLUT( cpy, clip )

  -- map image pixels to pixels in lut
  cpy = cpy:mapPixels(
    function( y, i, q )
      y = lut[y + 1]      
      return y, i, q
    end
  )

  return color.YIQ2RGB( cpy )
end


--[[
  Function Name: contrast
  
  Author: Katie MacMillan
  
  Description: The contrast function utilizes a contrast stretched lookup table
  to map all of the pixels in an image to a new set of contrast stretched
  pixels.
  
  Params: img  - the image that needs to be converted
          pMin - the percentage of low intensity pixels to ignore
          pMax - the percentage of high intensity pixels to ignore
          
  Returns: img after its pixels have been remapped
--]]
local function contrastStretch (img, pMin, pMax)

  local topPercent = 0
  local bottomPercent = 0
  local pixelCount = 0

  -- convert image to YIQ color mode
  local cpy = img:clone()
  cpy = color.RGB2YIQ( cpy )
  local pixels = cpy.height * cpy.width -- total pixels in image

  -- check for user input ignore percentages
  if pMin ~= nil then
    pixelCount = pixels * pMin / 100 -- calculate bottom % of pixels
    bottomPercent = math.floor( pixelCount + 0.5 ) -- round bottom % of pixels
  end
  if pMax ~= nil then
    pixelCount = pixels * pMax / 100 -- count top % of pixels
    topPercent = math.floor( pixelCount + 0.5 ) -- round top % of pixel count
  end

  -- get histogram of image
  local hist = getHistogram ( cpy )

  -- create look up table for each intensity
  local lut = contrastLUT(hist, bottomPercent, topPercent)

  -- map each pixel to the contrast stretched intensity
  cpy = cpy:mapPixels(
    function( y, i, q )
      y = lut[y + 1]      
      return y, i, q
    end
  )

  return color.YIQ2RGB( cpy )
end


------------------------------------
-------- exported routines ---------
------------------------------------

return {
  equalize = equalize,
  contrastStretch = contrastStretch
}
