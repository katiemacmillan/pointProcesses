
local color = require "il.color"
-------------------------------------------------
-- Find the index to the minimum intensity
-- after ignoring a percentage threshold
-------------------------------------------------
local function getIndexMin(hist, pMin)
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
local function getIndexMax(hist, pMax)
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

local function getHistogramAverage(hist)
  local sum = 0
  for i = 1, 256 do
    sum = sum + hist[i]
  end
  
  -- return average of intensity counts
  return sum/256  
end
-- Total equalization
local function clipHistogram( hist, clip)
  -- get average pixels per intensity
  local avg = getHistogramAverage(hist)
  -- track total pixels in the histogram
  local sum = 0
  
  for i = 1, 256 do
    -- check if intensity has more than clip*avg pixels, if so clip it
    if hist[i] > (clip * avg) then
      hist[i] = clip * avg
    end
    sum = sum + hist[i]
  end
  
  return hist, sum
end

local function equalizeLUT( img, clip )
  local lut = {}
  local sum = 0
  
  local hist = getHistogram ( img )
  local avg = getHistogramAverage(hist)
  hist, sum = clipHistogram(hist, clip)
  -- get max and min intensities
  local alpha = 255/ sum
  
  -- set first used intensity position in the array
  lut[1] = alpha*hist[1]
  
  -- set remaining array values
  for i=2, 256 do
    lut[i] = lut[i-1] + (alpha * hist[i])
  end
  
  return lut
end

local function contrastLUT(hist, pMin, pMax)
  local lut = {}
  local iMax = getIndexMax(hist, pMax)
  local iMin = getIndexMin(hist, pMin)
  
  for i = 1, iMin-1 do
    lut[i] = 0
  end
  
  for i = iMax+1, 256 do
    lut[i] = 255     -- clip to 255
  end
  
  local deltaX = iMax-iMin  -- find deltaX
  -- set all remaining intensities to fit between contrasts
  for i =  iMin, iMax do
    lut[i] = math.floor(((255/deltaX)*(i-iMin))+0.5)
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
      r = lut[r+1]      
      return r, g, b
    end
  )
  
  return color.YIQ2RGB( img )
end


-- Contrast Stretching
local function contrastStretch (img, pMin, pMax)
  -- convert image to YIQ color mode
  img = color.RGB2YIQ( img )
  local pixels = img.height * img.width
    
  -- calculate number of pixels to skip on each side
  local topPercent = 0
  local bottomPercent = 0
  
  -- check for user input ignore percentages
  if pMin ~= nil then
    bottomPercent = math.floor((pixels*pMax/100)+0.5)
  end
  if pMax ~= nil then
    topPercent = math.floor((pixels*pMin/100)+0.5)
  end

  
  local hist = getHistogram (img)
  -- create look up table for each gray value
  local lut = contrastLUT(hist, bottomPercent, topPercent)
  
  img = img:mapPixels(
    function( r, g, b )
      r = lut[r+1]      
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
