
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

    
------------------------------------
-------- exported routines ---------
------------------------------------

return {
  equalize = equalize
}
