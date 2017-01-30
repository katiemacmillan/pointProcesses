
local color = require "il.color"

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
local function equalizeLUT(alpha, hist)
  local lut = {}
  lut[1] = alpha*hist[1]
  for i=2, 256 do
    lut[i] = lut[i-1] + (alpha * hist[i])
  end
  return lut
end

-- Total equalization
local function contrastLUT(hist, fudgeMin, fudgeMax)
  local lut = {}
  local iMax = 256
  local iMin = 1
  local sum = 0
  
  -- find true iMin (smalles intensity value)
  while hist[iMin] == 0 do
    lut[iMin] = 0     -- clip to 0
    iMin = iMin + 1
  end
  -- ignore bottom fudge factor pixels to get adjusted iMin
  while sum < fudgeMin do
    sum = sum + hist[iMin]
    lut[iMin] = 0     --clip to 0
    iMin = iMin + 1
  end
  
  sum = 0   -- reset sum
    -- find true iMax (largest intensity value)
  while hist[iMax] == 0 do
    lut[iMax] = 255     -- clip to 255
    iMax = iMax - 1
  end
  -- ignore top fudge factor pixels to get adjusted iMax
  while sum < fudgeMax do
    sum = sum + hist[iMax]
    lut[iMax] = 255     -- clip to 255
    iMax = iMax - 1
  end  
  
  local deltaX = iMax-iMin  -- find deltaX
  -- set all remaining intensities to fit between contrasts
  for i =  iMin, iMax do
    lut[i] = math.floor(((255/deltaX)*(i-iMin))+0.5)
  end
  
  return lut
end

-- Total equalization
local function equalize (img)
  -- convert image to YIQ color mode
  img = color.RGB2YIQ( img )
  
  local nrows, ncols = img.height, img.width
  local alpha = 255/ (nrows * ncols)
  
  local hist = getHistogram (img)
  -- create look up table for each gray value
  local lut = equalizeLUT(alpha, hist)
  
  for r = 0, nrows - 1 do
    for c = 0, ncols - 1 do
      -- replace each pixel intensity with intensity from LUT
      i = img:at(r,c).y + 1
      img:at(r,c).y = lut[i]
    end
  end
  return color.YIQ2RGB( img )
end


-- Contrast Stretching
local function contrastStretch (img, pMin, pMax)
  -- convert image to YIQ color mode
  img = color.RGB2YIQ( img )
  local nrows, ncols = img.height, img.width
  local pixels = nrows*ncols
    
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
  
  for r = 0, nrows - 1 do
    for c = 0, ncols - 1 do
      -- replace each pixel intensity with intensity from LUT
      local i = img:at(r,c).y + 1
      img:at(r,c).y = lut[i]
    end
  end
  
  return color.YIQ2RGB( img )
end

    
------------------------------------
-------- exported routines ---------
------------------------------------

return {
  equalize = equalize,
  contrastStretch = contrastStretch
}
