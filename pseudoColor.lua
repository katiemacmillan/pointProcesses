
local color = require "il.color"

local function psudoColor8LUT()
  local lut = {}
  colorMap = {
    {255, 0, 0},
    {255, 128, 0},
    {255, 0, 128},
    {0, 255, 0},
    {0, 255, 128},
    {128, 255, 0},
    {0, 0, 255},
    {0, 128, 255}
  }
  
  for i = 1, 32 do
    lut[i] = colorMap[1]
  end
  for i = 33, 64 do
    lut[i] = colorMap[2]
  end
  for i = 65, 96 do
    lut[i] = colorMap[3]
  end
  for i = 97, 128 do
    lut[i] = colorMap[4]
  end
  for i = 129, 160 do
    lut[i] = colorMap[5]
  end
  for i = 161, 192 do
    lut[i] = colorMap[6]
  end
  for i = 193, 224 do
    lut[i] = colorMap[7]
  end
  for i = 225, 256 do
    lut[i] = colorMap[8]
  end
  
  return lut
end

local function psudoColorLUT(count)
  local step = math.floor((255/count)+0.5)
  local lut = {}
  for i = 0, 255 do
    lut[i] = {}
  end
  
end

-- create & return a histogram of an image
local function pseudoColor8( img )
  -- get number of rows and columns in image
  local nrows, ncols = img.height, img.width
  local LUT = psudoColor8LUT()
  local temp = img:clone()
  temp = color.RGB2YIQ(temp)
  -- for each pixel in the image
  for r = 0, nrows-1 do
    for c = 0, ncols-1 do
      local i = img:at(r,c).y
      for ch = 0, 2 do
        img:at(r,c).rgb[ch] = LUT[i+1][ch + 1]
        end      
    end
  end  
  -- return the histogram array
  return img
end


------------------------------------
-------- exported routines ---------
------------------------------------

return {
  pseudoColor8 = pseudoColor8
}
