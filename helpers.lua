--[[
  * * * * helpers.lua * * * *
helpers.lua contains some helper functions that are seen in other
image processing functions.

Author: Katie MacMillan and Forrest Miller
Class: CSC442/542 Digital Image Processing
Date: 2/9/2017
--]]
local color = "il.color"
--[[
  Function Name: clip
  
  Author: Katie MacMillan
  
  Description: The clip function clips an intensity value to 255 if
  it is greater than 255, and clips it to 0 if it is less than 0. If
  the intensity value is between 0 and 255, it is simply returned unchaned
  Params: i    - the intensity value to bounds check
          
  Returns: the intensity with a value between 0 and 255
--]]

--[[
  Function Name: clip
  
  Author: Katie MacMillan
  
  Description: The clip function looks at an intensity value.
  If the value is greater than 255, the intensity is clipped to
  255. If the value is less than 0, the intensity is clipped to
  0. Otherwise the intensity is returned unchanged.
  Params: i - the intensity being evaluated
  
  Returns: the intensity with a value between 0 and 255
--]]
local function clip (i)
  if i > 255 then return 255
  elseif i < 0 then return 0
  else return i end
end

--[[
  Function Name: getIMin
  
  Author: Katie MacMillan
  
  Description: The getIMin function finds the smallest intensity within
  a histogram table after a specified percentage of pixels have been ignored.
  
  Params: hist    - the image that needs to be converted
          ignore  - the percentage of minimum pixels to ignore
  
  Returns: the index of the adjusted minimum intensity
--]]
local function getIMin( hist, ignore )
  -- index of minimum value
  local min = 1
  local sum = 0

  -- find true minimum intensity of image
  while hist[min] == 0 do
    min = min + 1
  end
  if ignore ~= nil then
    -- ignore specified number ofbottom pixels to get adjusted minimum
    while sum < ignore do
      sum = sum + hist[min]
      min = min + 1
    end
  end

  return min
end
--[[
  Function Name: getIMax
  
  Author: Katie MacMillan
  
  Description: The getIMax function finds the largest used intensity within
  a histogram table after a specified percentage of pixels have been ignored.
  
  Params: hist   - the image that needs to be converted
          ignore - the percentage of maximum pixels to ignore
  
  Returns: the index of the adjusted maximum intensity
--]]
local function getIMax( hist, ignore )
  local max = 256
  local sum = 0

  -- find true maximum intensity
  while hist[max] == 0 do
    max = max - 1
  end

  if ignore ~= nil then
    -- ignore specified number of top pixels to get adjusted maximum
    while sum < ignore do
      sum = sum + hist[max]
      max = max - 1
    end
  end

  return max
end

--[[
  Function Name: imgToRGB
  
  Author: Katie MacMillan
  
  Description: The imgToRGB function is a helper function that converts the
  incoming image from either yiq or ihs to rgb by utilizing Dr.Weiss' ip.lua file.
  
  Params: img  - the image that needs to be converted
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
  
  Params: img  - the image that needs to be converted
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
  Function Name: toBinary
  
  Author: Katie MacMillan
  
  Description: The toBinary function converts a pixel intensity value to a
  binary string
  
  Params: num - intensity value to be converted to binary
  
  Returns: binary - binary string representation of num
--]]
local function toBinary( num )
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

------------------------------------
-------- exported routines ---------
------------------------------------
return {
 clip = clip,
 getIMax = getIMax,
 getIMin = getIMin,
 imgToRGB = imgToRGB,
 imgFromRGB = imgFromRGB,
 toBinary = toBinary
}
