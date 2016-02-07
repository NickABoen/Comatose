HC = require 'HC'

Loader = {}
Loader.__index = Loader

Tile = {}
Tile.__index = Tile

function Tile:draw(...)
  love.graphics.draw(self.image, self.quad, ...)
end

local function convertNum(num, width, height, spacing, px, py)
  num = num - 1
  local y = math.floor(num / width)
  local x = num % width
  local ix = spacing * x + px * x
  local iy = spacing * y + py * y
  return ix, iy
end

local function loadTilesets(dir, out)
  for i=1,#out.map.tilesets do
    local tset = out.map.tilesets[i]
    local image = {}
    image.image = love.graphics.newImage(dir .. "/" .. tset.image)
    image.width = tset.imagewidth
    image.height = tset.imageheight
    image.tilewidth = tset.tilewidth
    image.tileheight = tset.tileheight
    image.spacing = tset.spacing
    image.count = tset.tilecount
    image.tileswidth = math.ceil(tset.imagewidth / (tset.spacing + tset.tilewidth))
    image.tilesheight = math.ceil(tset.imageheight / (tset.spacing + tset.tileheight))
    table.insert(out.tilesets, image)
    out.tilecollide = {}
    --print(#out.map.tilesets[i].tiles)
    for j, tile in ipairs(out.map.tilesets[i].tiles) do
      --print(j, tile)
      local obj = tile.objectGroup.objects[1]
      --print("added", tile.id)
      out.tileboxs[tile.id + 1] = HC.rectangle(obj.x,obj.y,obj.width,obj.height)
      --print(tile.id, out.tileboxs[tile.id])
    end
    for j=1, tset.tilecount do
      local x, y = convertNum(j, image.tileswidth, image.tilesheight, image.spacing, image.tilewidth, image.tileheight)
      local q = love.graphics.newQuad(x, y, image.tilewidth, image.tileheight, image.width, image.height)
      table.insert(out.tiles, {quad = q, image = image.image}) --insert a new tile
    end
  end
end

local function copyRect(hbox)
  local x, y, x2, y2 = hbox:bbox()
  return HC.rectangle(x, y, x2 - x, y2 - y)
end

local function makeBatch(out, batch, data, mw, mh, tx, ty, sx, sy, spacing, tsw, tsh)
  local loc = 1
  local hboxs = {}
  for x=0, mw-1 do
    for y=0, mh-1 do
      if data[loc] ~= 0 then
        local ix, iy = convertNum(data[loc], tsw, tsw, spacing, tx, ty)
        --print(tsw, tsw, ix, iy, tx, ty, sx, sy)
        local q = love.graphics.newQuad(ix, iy, tx, ty, sx, sy)
        ix, iy = convertNum(loc, mw, mh, 0, tx, ty)
        if out.tileboxs[data[loc]] then
          --print("adding to hboxs", data[loc], ix, iy)
          local hbox = copyRect(out.tileboxs[data[loc]])
          local bx, by, bx2, by2 = hbox:bbox()
          hbox:move(ix, iy)
          table.insert(hboxs, hbox)
        end
        batch:add(q, ix, iy)
      end
      loc = loc + 1
    end
  end
  --print("hbox", #hboxs)
  return hboxs
end

local function createBatches(out)
  for i=1,#out.map.layers do
    local mlayer = out.map.layers[i]
    local layer = {}
    local maxSprites = out.mapwidth * out.mapheight + 100
    local tset = out.tilesets[1]
    local img = tset.image
    layer.batch = love.graphics.newSpriteBatch(img, maxSprites, "static")
    layer.name = mlayer.name
    local loc = 1
    local data = mlayer.data
    local tx = tset.tilewidth
    local ty = tset.tileheight
    local sx = tset.width
    local sy = tset.height
    local spacing = tset.spacing
    local hboxs = makeBatch(
      out,
      layer.batch,
      data,
      out.mapwidth, out.mapheight,
      tx, ty,
      sx, sy,
      spacing,
      tset.tileswidth, tset.tilesheight)
    for k, box in pairs(hboxs) do table.insert(out.boxes, box) end
    table.insert(out.layers, layer)
  end
end

Layer = {}
Layer.__index = Layer

function Layer:draw(...)
  love.graphics.draw(self.batch, ...)
end

function Loader.load(dir, path)
  local out = {map = require(dir .. "." .. path)}
  out.tilesets = {}
  out.layers = {}
  out.boxes = {}
  out.tiles = {}
  out.tileboxs = {}
  out.mapwidth = out.map.width
  out.mapheight = out.map.height
  loadTilesets(dir, out)
  createBatches(out)
  for i,layer in ipairs(out.layers) do
    setmetatable(layer, Layer)
  end
  for i,tile in ipairs(out.tiles) do
    setmetatable(tile, Tile)
  end
  return out.layers, out.tiles, out.boxes
end

return Loader
