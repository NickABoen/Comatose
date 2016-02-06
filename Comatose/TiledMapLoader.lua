Map = {}
Map.__index = Map

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
  end
end

local function convertNum(num, width, height, spacing, px, py)
  num = num - 1
  local y = math.floor(num / width)
  local x = num % width
  local ix = spacing * x + px * x
  local iy = spacing * y + py * y
  return ix, iy
end

local function makeBatch(batch, data, mw, mh, tx, ty, sx, sy, spacing, tsw, tsh)
  local loc = 1
  for x=0, mw-1 do
    for y=0, mh-1 do
      if data[loc] ~= 0 then
        local ix, iy = convertNum(data[loc], tsw, tsw, spacing, tx, ty)
        print(tsw, tsw, ix, iy, tx, ty, sx, sy)
        local q = love.graphics.newQuad(ix, iy, tx, ty, sx, sy)
        ix, iy = convertNum(loc, mw, mh, 0, tx, ty)
        batch:add(q, ix, iy)
      end
      loc = loc + 1
    end
  end
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
    print(mlayer.data)
    local data = mlayer.data
    local tx = tset.tilewidth
    local ty = tset.tileheight
    local sx = tset.width
    local sy = tset.height
    local spacing = tset.spacing
    makeBatch(
      layer.batch,
      data,
      out.mapwidth, out.mapheight,
      tx, ty,
      sx, sy,
      spacing,
      tset.tileswidth, tset.tilesheight)
    table.insert(out.layers, layer)
  end
end

function Map.new(dir, path)
  local out = {map = require(dir .. "." .. path)}
  out.tilesets = {}
  out.layers = {}
  out.mapwidth = out.map.width
  out.mapheight = out.map.height
  loadTilesets(dir, out)
  createBatches(out)
  return setmetatable(out, Map)
end

function Map:draw(...)
  for i=1, #self.layers do
    love.graphics.draw(self.layers[i].batch, ...)
  end
end
