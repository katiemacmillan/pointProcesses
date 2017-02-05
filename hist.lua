
local color = require "il.color"
-------------------------------------------------
-- Find the index to the minimum intensity
-- after ignoring a percentage threshold
-------------------------------------------------
local function getIndexMin(hist, pMin)
  local iMin = 1
  local sum = 0
  
  -- find true iMin (smalles intensity value)
  while hist[iMin] == 0 do
    iMin = iMin + 1
  end
  -- ignore bottom fudge factor pixels to get adjusted iMin
  while sum < pMin do
    sum = sum + hist[iMin]
    iMin = iMin + 1
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
  -- ignore bottom fudge factor pixels to get adjusted iMin
  while sum < pMax do
    sum = sum + hist[iMax]
    iMax = iMax - 1
  end
    return iMax
end


-- create & return a histogram of an image
local function getHistogram( img )
  -- create new array for histogram
  h = {}
  
  -- initialize each intensity to 0
  for i=1, 256 do
    h[i] = 0
  end
  
  -- get number of rows and columns in image
  local nrows, ncols = img.height, img.width
  -- for each pixel in the image
  for r = 0, nrows-1 do
    for c = 0, ncols-1 do
      i = img:at(r,c).y + 1
      -- increment intensity count in histogram
      h[i] = h[i] + 1
    end
  end  
  -- return the histogram array
  return h
end

-- Total equalization
local function equalizeLUT(alpha, hist, pMin, pMax)
  local lut = {}
  local iMax = getIndexMax(hist, pMax)
  local iMin = getIndexMin(hist, pMin)
  
  for i = 1, iMin-1 do
    lut[i] = 0
  end
  
  for i = iMax+1, 256 do
    lut[i] = 255     -- clip to 255
  end
  
  lut[iMin] = alpha*hist[iMin]
  for i=(iMin+1), iMax do
    lut[i] = lut[i-1] + (alpha * hist[i])
  end
  
  return lut
end

-- Total equalization
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
local function equalize (img, pMin, pMax)
  -- convert image to YIQ color mode
  img = color.RGB2YIQ( img )
  
  local nrows, ncols = img.height, img.width
  local pixels = nrows * ncols
  local alpha = 255/ (nrows * ncols)
  
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
  local lut = equalizeLUT(alpha, hist, bottomPercent, topPercent)
  
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
