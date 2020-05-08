-- Copyright 2020, Sjors van Gelderen

function loadPattern(path)
   local file = io.open(path .. "/" .. path .. ".chr", "rb")
   local bytes_in_file = {}

   if file == nil then
      print("The file " .. path .. "/" .. path .. ".chr does not exist!")
      return
   end

   while true do
      local char = file:read(1)

      if char == nil then
	 break
      end
      
      local byte = string.byte(char)
      bytes_in_file[#bytes_in_file + 1] = byte
   end
   
   file:close()
   
   local amount_of_tiles = 512 -- 256 per page, 2 pages
   local amount_of_bits_in_tile = 128 -- 8 * 8 * 2, 2 bits per pixel
   local amount_of_bytes_in_tile = 16
   local amount_of_pixels_in_tile = 64 -- 8 * 8 color bytes to store
   local pixels = {} -- Buffer to hold the read tone values
   
   for tile_index = 0, amount_of_tiles - 1 do
      local tile_index_in_page = tile_index % (amount_of_tiles / 2)
      local tile_x = tile_index_in_page % 16
      local tile_y = math.floor(tile_index_in_page / 16)
      local page_offset = nil

      if tile_index >= amount_of_tiles / 2 then
   	 page_offset = 16384
      else
   	 page_offset = 0
      end

      for byte_index = 0, amount_of_bytes_in_tile / 2 - 1 do
      	 local byte_offset = tile_index * amount_of_bytes_in_tile
      	 local byte_one = bytes_in_file[byte_offset + byte_index + 1]
      	 local byte_two = bytes_in_file[byte_offset + amount_of_bytes_in_tile / 2 + byte_index + 1]
	 
      	 for x = 0, 7 do	    
      	    local value_one = bit.band(byte_one, bit.rshift(0x80, x)) > 0
      	    local value_two = bit.band(byte_two, bit.rshift(0x80, x)) > 0
      	    local value = 0
	    
      	    if value_one and value_two then
      	       value = 3
      	    elseif not value_one and value_two then
      	       value = 2
      	    elseif value_one and not value_two then
      	       value = 1
      	    end

      	    local pixel_x = tile_x * 8 + x
	    local pixel_y = tile_y * 128 * 8 + byte_index * 128
	    local pixel_index = pixel_y + pixel_x + page_offset + 1

      	    pixels[pixel_index] = value / 3
      	 end
      end
   end

   if pixels ~= nil then
      pattern.replacePixels(pixels)
      pattern.updateColors()
      metatiler.generateImage()
   end

   pattern.dirty = false
   print("Loaded the pattern!")
end

function loadSamples(path)
   local file = io.open(path .. "/" .. path .. ".s", "rb")
   local bytes_in_file = {}

   if file == nil then
      print("The file " .. path .. "/" .. path .. ".s does not exist!")
      return
   end

   while true do
      local char = file:read(1)

      if char == nil then
	 break
      end
      
      local byte = string.byte(char) + 1
      bytes_in_file[#bytes_in_file + 1] = byte
   end
   
   file:close()

   sampler.background_color = bytes_in_file[1]
   
   for i = 1, #sampler.samples do
      for o = 1, 3 do
	 sampler.samples[i][o] = bytes_in_file[(i - 1) * 4 + (o - 1) + 2]
      end
   end

   print("Loaded the samples!")
end

function loadMetatiles(path)
   local file = io.open(path .. "/" .. path .. ".mt", "rb")
   local bytes_in_file = {}

   if file == nil then
      print("The file " .. path .. "/" .. path .. ".mt does not exist!")
      return
   end

   while true do
      local char = file:read(1)

      if char == nil then
	 break
      end
      
      local byte = string.byte(char)
      bytes_in_file[#bytes_in_file + 1] = byte + 1
   end
   
   file:close()
   local tiles = {}
   
   for i = 1, 256 do
      local x = (i - 1) % 16 * 2
      local y = math.floor((i - 1) / 16) * 2

      local o = (i - 1) * 4

      -- Metatile segments
      tiles[y * 32 + x + 1] = bytes_in_file[o + 1] -- Top left
      tiles[y * 32 + x + 1 + 1] = bytes_in_file[o + 2] -- Top right
      tiles[y * 32 + x + 32 + 1] = bytes_in_file[o + 3] -- Bottom left
      tiles[y * 32 + x + 32 + 1 + 1] = bytes_in_file[o + 4] -- Bottom right
   end
   
   metatiler.tiles = tiles
   metatiler.dirty = false
   print("Loaded the metatiles!")
end

function loadMetatilesSamples(path)
   local file = io.open(path .. "/" .. path .. ".mts", "rb")
   local bytes_in_file = {}

   if file == nil then
      print("The file " .. path .. "/" .. path .. ".mts does not exist!")
      return
   end

   while true do
      local char = file:read(1)

      if char == nil then
	 break
      end
      
      local byte = string.byte(char)
      bytes_in_file[#bytes_in_file + 1] = byte
   end
   
   file:close()
   metatiler.samples = bytes_in_file

   print("Loaded the metatiles' samples!")
end

function loadNametable(path)
   local file = io.open(path .. "/" .. path .. ".nt", "rb")
   local bytes_in_file = {}

   if file == nil then
      print("The file " .. path .. ".nt does not exist!")
      return
   end

   while true do
      local char = file:read(1)

      if char == nil then
	 break
      end
      
      local byte = string.byte(char)
      bytes_in_file[#bytes_in_file + 1] = byte + 1
   end
   
   file:close()
   nametable.metatiles = bytes_in_file

   nametable.dirty = false
   print("Loaded the nametable!")
end

function loadProject()
   print("Please enter the name of the project to load:")
   local path = io.read()

   if path == nil then
      print("Canceled!")
      return
   end

   loadSamples(path)
   loadPattern(path)
   loadMetatiles(path)
   loadMetatilesSamples(path)
   loadNametable(path)
   sampler.updateSamples()
   pattern.updateColors()
   metatiler.generateImage()
   nametable.refresh()
end

function savePattern(path)
   local image_data = pattern.tone_image_data

   local file = io.open(path .. "/" .. path .. ".chr", "r")
   if file ~= nil then
      file:close()
      
      print(path .. "/" .. path .. ".chr exists already. Overwrite? y/n")
      response = io.read()

      if response == nil or response == "n" or response == "no" or
	 (response ~= "y" and response ~= "yes")
      then
	 print("Canceled!")
	 return
      end
   end
   
   local file = io.open(path .. "/" .. path .. ".chr", "wb+")
   
   for tile_y = 1, 32 do
      for tile_x = 1, 16 do
	 for pass = 1, 2 do
	    for pixel_y = 1, 8 do
	       local byte = 0x00
	       
	       for pixel_x = 1, 8 do
	       	  local x = (tile_x - 1) * 8 + pixel_x - 1
	       	  local y = (tile_y - 1) * 8 + pixel_y - 1
	       	  local tone = image_data:getPixel(x, y)
		  
	       	  if tone > 0 then
	       	     if tone > 0.7 or
	       	  	pass == 1 and (tone < 0.4 or tone > 0.7) or
	       	  	pass == 2 and tone > 0.4
	       	     then
	       	  	local mask = bit.rshift(0x80, pixel_x - 1)
	       	  	byte = bit.bor(byte, mask)
	       	     end
	       	  end
	       end

	       file:write(string.char(byte))
	    end
	 end
      end
   end
   
   file:close()

   pattern.dirty = false
   print("Saved the pattern!")
end

function saveSamples(path)
   local file = io.open(path .. "/" .. path .. ".s", "r")
   if file ~= nil then
      file:close()
      
      print(path .. "/" .. path .. ".s exists already. Overwrite? y/n")
      response = io.read()

      if response == nil or response == "n" or response == "no" or
	 (response ~= "y" and response ~= "yes")
      then
	 print("Canceled!")
	 return
      end
   end
   
   local file = io.open(path .. "/" .. path .. ".s", "wb+")
   
   for i = 1, #sampler.samples do
      file:write(string.char(sampler.background_color - 1))
      
      for o = 1, 3 do
	 local byte = sampler.samples[i][o] - 1
	 file:write(string.char(byte))
      end
   end
   
   file:close()

   print("Saved the samples!")
end

function saveMetatiles(path)   
   local file = io.open(path .. "/" .. path .. ".mt", "r")
   if file ~= nil then
      file:close()
      
      print(path .. "/" .. path .. ".mt exists already. Overwrite? y/n")
      response = io.read()

      if response == nil or response == "n" or response == "no" or
	 (response ~= "y" and response ~= "yes")
      then
	 print("Canceled!")
	 return
      end
   end

   local file = io.open(path .. "/" .. path .. ".mt", "wb+")
   local indices = {}
   
   for i = 1, 256 do
      local x = (i - 1) % 16 * 2
      local y = math.floor((i - 1) / 16) * 2
      
      -- Metatile segments
      table.insert(indices, y * 32 + x) -- Top left
      table.insert(indices, y * 32 + x + 1) -- Top right
      table.insert(indices, y * 32 + x + 32) -- Bottom left
      table.insert(indices, y * 32 + x + 32 + 1) -- Bottom right
   end

   for o = 1, #indices do
      local index = indices[o] + 1
      file:write(string.char(metatiler.tiles[index] - 1))
   end
   
   file:close()

   metatiler.dirty = false
   print("Saved the metatiles!")
end

function saveMetatilesSamples(path)
   local file = io.open(path .. "/" .. path .. ".mts", "r")
   if file ~= nil then
      file:close()
      
      print(path .. "/" .. path .. ".mts exists already. Overwrite? y/n")
      response = io.read()

      if response == nil or response == "n" or response == "no" or
	 (response ~= "y" and response ~= "yes")
      then
	 print("Canceled!")
	 return
      end
   end
   
   local file = io.open(path .. "/" .. path .. ".mts", "wb+")

   for i = 1, #metatiler.samples do
      local byte = metatiler.samples[i]
      file:write(string.char(byte))
   end
   
   file:close()

   print("Saved the metatiles' samples!")
end

function saveNametable(path)
   local file = io.open(path .. "/" .. path .. ".nt", "r")
   if file ~= nil then
      file:close()
      
      print(path .. "/" .. path .. ".nt exists already. Overwrite? y/n")
      response = io.read()

      if response == nil or response == "n" or response == "no" or
	 (response ~= "y" and response ~= "yes")
      then
	 print("Canceled!")
	 return
      end
   end
   
   local file = io.open(path .. "/" .. path .. ".nt", "wb+")

   for i = 1, #nametable.metatiles do      
      local byte = nametable.metatiles[i] - 1
      file:write(string.char(byte))
   end
   
   file:close()

   nametable.dirty = false
   print("Saved the nametable!")
end

function saveAttributeTable(path)
   local file = io.open(path .. "/" .. path .. ".at", "r")
   if file ~= nil then
      file:close()
      
      print(path .. "/" .. path .. ".at exists already. Overwrite? y/n")
      response = io.read()

      if response == nil or response == "n" or response == "no" or
         (response ~= "y" and response ~= "yes")
      then
         print("Canceled!")
         return
      end
   end
   
   local file = io.open(path .. "/" .. path .. ".at", "wb+")
   local samples = {}
   
   for y = 1, 8 do
      for x = 1, 8 do
         local byte = 0x00
         local offset = (y - 1) * 16 * 2 + (x - 1) * 2 + 1
         
         local metatileIndices = {
            offset, -- Top left
            offset + 1, -- Top right
            offset + 16, -- Bottom left
            offset + 17 -- Bottom right
         }
         
         for i = 1, #metatileIndices do
            local sample = metatiler.samples[nametable.metatiles[metatileIndices[i]]]

            if sample == nil then
               sample = 1 -- The last row needs dummy values
            end

            sample = sample - 1

            local o = (i - 1) * 2

            if sample == 1 then
               byte = bit.bor(byte, bit.lshift(0x01, 0 + o))
            elseif sample == 2 then
               byte = bit.bor(byte, bit.lshift(0x01, 1 + o))
            elseif sample == 3 then
               byte = bit.bor(byte, bit.lshift(0x01, 1 + o))
               byte = bit.bor(byte, bit.lshift(0x01, 0 + o))
            end
         end

         file:write(string.char(byte))
      end
   end
   
   file:close()

   print("Saved the attribute table!")
end

function saveProject()
   print("Please enter the name of the project to save:")
   local path = io.read()

   if path == nil then
      print("Canceled!")
      return
   end

   saveSamples(path)
   savePattern(path)
   saveMetatiles(path)
   saveMetatilesSamples(path)
   saveNametable(path)
   saveAttributeTable(path)
end
