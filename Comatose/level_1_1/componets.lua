local world = ...

local function addInteractable(collider, obj)
  collider.collideWorld.objects[obj.collideObject.shape] = obj
  collider.collideWorld.world:register(obj.collideObject.shape)
end

local function addShape(collider, shape)
  --collider.collideWorld.objects[obj.collideObject.shape] = obj
  collider.collideWorld.world:register(shape)
end

-- create the components
world:addComponent("position", { pos = vector(0,0)})
world:addComponent("velocity", { maxSpeed = 100, currentSpeed = 100, vec = vector(0,0)})
world:addComponent("boundingBox", {width = 10, height = 10})
world:addComponent("hasInput", {})
world:addComponent("player", {state = player_states.neutral})
world:addComponent("witch", {state = player_states.neutral})
world:addComponent("debug",{ name = ''})
world:addComponent("renderable",{z = 0, draw = function() end, hud = false})
world:addComponent("collideObject", {type = {}, shape = HC.rectangle(200, 200, 10, 10), event = function() end})
world:addComponent("collideWorld", {type = {}, world = HC.new(), objects = {}})
world:addComponent("health", {value = 0, min = 0, max = 1500})
world:addComponent("hunger", {value = 100, min = 0, max = 200})
world:addComponent("glucose", {value = 100, min = 0, max = 200})
world:addComponent("insulin", {value = 10, min = 0, max = 20})
world:addComponent("action", {cost = 1, action = function() end})
world:addComponent("food", {dhunger = 10, dglucose = 10})
world:addComponent("candy", {})
world:addComponent("toPerform", {})
world:addComponent("animation", {})

--For this component 'was' and 'is' should only ever be up or down while
--state represents a 4 state button with up, pressed, down, and released
world:addComponent("key", { id = "something", was = key_states.up, is = key_states.up, state = key_states.up})

-- create key entities
local upKey = world:addEntity({
    key = {id = 'up'}
})
local leftKey = world:addEntity({
    key = {id = 'left'}
})
local downKey = world:addEntity({
    key = {id = 'down'}
})
local rightKey = world:addEntity({
    key = {id = 'right'}
})
local spaceKey = world:addEntity({
    key = {id = 'space'}
})
local escapeKey = world:addEntity({
    key = {id = 'escape'}
})
local dKey = world:addEntity({
    key = {id = 'd'}
})

-- create a player entity at position (100, 100)
local player = world:addEntity({
    glucose = {value = 90},
    hunger = {value = 90},
    insulin = {value = 10},
    health = {value = 1500},
    position = {pos = vector(600,400)},
    velocity = {maxSpeed = 100, currentSpeed = 100},
    boundingBox = {},
    animation = {},
    hasInput = {},
    player = {state = player_states.neutral},
    collideObject = {
      type = {"actor", "player"},
      event = function(entity, collider, obj, dt)
        if obj and obj.candy then
          entity.glucose.value = entity.glucose.value + obj.food.dglucose
          entity.hunger.value = entity.hunger.value + obj.food.dhunger
          world:delete(obj)
        elseif not obj then
          print("collide!")
          local position = entity.position
          local vec = entity.velocity.vec
          local speed = entity.velocity.currentSpeed
          --cam:lockPosition(position.pos.x, position.pos.y, Camera.smooth.linear(10000))
          position.pos = position.pos - (vec * speed * dt)
        end
      end
    },
    renderable = {
      z = 0.5,
      draw = function(player)
        DrawInstance (Player, player.position.pos.x, player.position.pos.y)
        Player.size_scale = 1.5
      end
    }
})

local layers, tiles, boxes = Loader.load('Maps', 'level1_1')
--add the map
world:addEntity({renderable = {
  draw = function(entity)
    for i, layer in ipairs(layers) do
      layer:draw()
    end
  end
}})

world:addEntity({renderable = {
  z = 1,
  hud = true,
  draw = function(entity)
    for player in pairs(world:query("player")) do
      local lowerX = 600
      local upperX = 600 + 180
      local height = 10
      love.graphics.setColor(255, 0, 0)
      love.graphics.rectangle('fill', lowerX, 10, upperX - lowerX, height)
      love.graphics.setColor(0, 255, 0)
      love.graphics.rectangle('fill', lowerX, 30, upperX - lowerX, height)
      love.graphics.setColor(0, 0, 255)
      love.graphics.rectangle('fill', lowerX, 50, upperX - lowerX, height)
      love.graphics.setColor(0, 0, 0)
      local xScale = (upperX - lowerX) / (player.hunger.max - player.hunger.min)
      local xLoc = lowerX + xScale * player.hunger.value
      love.graphics.rectangle('fill', xLoc, 5, 5, 20)
      local xScale = (upperX - lowerX) / (player.glucose.max - player.glucose.min)
      local xLoc = lowerX + xScale * player.glucose.value
      love.graphics.rectangle('fill', xLoc, 25, 5, 20)
      local xScale = (upperX - lowerX) / (player.insulin.max - player.insulin.min)
      local xLoc = lowerX + xScale * player.insulin.value
      love.graphics.rectangle('fill', xLoc, 45, 5, 20)
      love.graphics.setColor(255, 255, 255)
    end
  end
}})


local candyIdTable = {8432, 8433, 8434, 8435, 8436}
local candies = {}
for i = 0, 30 do
  local tile = tiles[ candyIdTable[i % 5 + 1] ]
  candies[#candies + 1] = world:addEntity({
    food = {
      dhunger = 1,
      dglucose = 3
    },
    candy = {},
    renderable = {
      z = 0.3,
      draw = function(entity)
        tile:draw(i * 17, 240)
      end
    },
    collideObject = {
      type = {"object", "candy"},
      shape = HC.rectangle(i * 17 + 4, 240 + 4, 8, 8)
    }
  })
end


local mapBox = world:addEntity({collideWorld = {
  type = {player=true}
}})
for k, box in pairs(boxes) do
  addShape(mapBox, box)
end

local candyLand = world:addEntity({collideWorld = {
  type = {player=true}
}})
--for k, candy in pairs(candies) do
  --addInteractable(candyLand, candy)
--end

--addInteractable(mapBox, witch)

if debug then
  world:addEntity({renderable = {
    z = 0.7,
    draw = function(entity)
      for k, box in pairs(boxes) do
        local x, y, x2, y2 = box:bbox()
        local w, h = x2 - x, y2 - y
        love.graphics.rectangle('line', x, y, w, h)
      end
      local x, y, x2, y2 = player.collideObject.shape:bbox()
      love.graphics.rectangle('line', x, y, x2 - x, y2 - y)
    end
  }})
end
