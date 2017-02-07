
local color = require "il.color"
-------------------------------------------------
-- Find the index to the minimum intensity
-- after ignoring a percentage threshold
-------------------------------------------------
local function getIndexMin( hist, pMin )
  -- index of minimum value
  local iMin = 1
  local sum = 0
  
  -- find true iMin (smalles intensity value)
  while hist[iMin] == 0 do
    iMin = iMin + 1
  end
  if pMin ~= nil then
    -- ignore bottom fudge factor pixels to get adjusted iMin
    while sum < pMin do
      sum = sum + hist[iMin]
      iMin = iMin + 1
    end
  end
  
    return iMin
end
-------------------------------------------------
-- Find the index to the maximum intensity
-- after ignoring a percentage threshold
-------------------------------------------------
local function getIndexMax( hist, pMax )
  local iMax = 256
  local sum = 0
  
  -- find true iMin (smalles intensity value)
  while hist[iMax] == 0 do
    iMax = iMax - 1
  end
  
  if pMax ~= nil then
    -- ignore bottom fudge factor pixels to get adjusted iMin
    while sum < pMax do
      sum = sum + hist[iMax]
      iMax = iMax - 1
    end
  end
  
    return iMax
end


-- create & return a histogram of an image
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
    function( r, g, b )
      local i = r + 1
         h[i] = h[i] + 1
      return r, g, b
    end
  )
  
  return h, sum
end

local function getHistogramAverage( hist )
  local sum = 0
  for i = 1, 256 do
    sum = sum + hist[i]
  end
  
  -- return average of intensity counts
  return sum / 256  
end
-- Total equalization
local function clipHistogram( hist, clip )
  -- track total pixels in the histogram
  local sum = 0
  
  for i = 1, 256 do
    -- check if intensity has more than % of pixels, if so clip it
    if hist[i] > ( clip ) then
      hist[i] = clip
    end
    sum = sum + hist[i]
  end
  
  return hist, sum
end

local function equalizeLUT( img, clip )
  local lut = {}
  local sum = img.height * img.width
  -- set clip value to percentage of pixels
  
  local hist = getHistogram ( img )
  if clip ~= nil then
    local pixels = sum * clip / 100
    hist, sum = clipHistogram( hist, pixels )
  end
 
  local alpha = 256 / sum
  
  -- set first used intensity position in the array
  lut[1] = alpha * hist[1]
  
  -- set remaining array values
  for i=2, 256 do
    lut[i] = lut[i - 1] + (alpha * hist[i])
    if lut[i] > 255 then
      lut[i] = 255
    elseif lut[i] < 0 then
      lut[i] = 0
    end

  end
  
  return lut
end

local function contrastLUT( hist, pMin, pMax )
  local lut = {}
  local iMax = getIndexMax( hist, pMax )
  local iMin = getIndexMin( hist, pMin )
  
  for i = 1, iMin - 1 do
    lut[i] = 0
  end
  
  for i = iMax + 1, 256 do
    lut[i] = 255     -- clip to 255
  end
  
  local deltaX = iMax - iMin  -- find deltaX
  -- set all remaining intensities to fit between contrasts
  for i =  iMin, iMax do
    local contrast = ( 255 / deltaX ) * ( i - iMin ) -- calculate contrast
    lut[i] = math.floor( contrast + 0.5 ) -- round contrast
  end
  
  return lut
end

-- Total equalization
local function equalize ( img, clip )
  -- convert image to YIQ color mode
  img = color.RGB2YIQ( img )
  -- create look up table for each gray value
  local lut = equalizeLUT( img, clip )
  
  img = img:mapPixels(
    function( r, g, b )
      r = lut[r + 1]      
      return r, g, b
    end
  )
  
  return color.YIQ2RGB( img )
end


-- Contrast Stretching
local function contrastStretch (img, pMin, pMax)
  
  local topPercent = 0
  local bottomPercent = 0
  local pixelCount = 0
  
  -- convert image to YIQ color mode
  img = color.RGB2YIQ( img )
  local pixels = img.height * img.width -- total pixels in image
  
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
  local hist = getHistogram (img)
  
  -- create look up table for each intensity
  local lut = contrastLUT(hist, bottomPercent, topPercent)
  
  -- map each pixel to the contrast stretched intensity
  img = img:mapPixels(
    function( r, g, b )
      r = lut[r + 1]      
      return r, g, b
    end
  )
  
  return color.YIQ2RGB( img )
end

    
------------------------------------
-------- exported routines ---------
------------------------------------

return {
  equalize = equalize,
  contrastStretch = contrastStretch
}
