
-- create the components
world:addComponent("position", { pos = vector(0,0)})
world:addComponent("velocity", { maxSpeed = 100, currentSpeed = 100, vec = vector(0,0)})
world:addComponent("boundingBox", {width = 10, height = 10})
world:addComponent("hasInput", {})
world:addComponent("player", {state = player_states.neutral})
world:addComponent("debug",{ name = ''})
world:addComponent("renderable",{z = 0, draw = function() end})
world:addComponent("collideObject", {type = {}, shape = HC.rectangle(200, 200, 10, 10), event = function() end})
world:addComponent("collideWorld", {type = {}, world = HC.new(), objects = {}})
world:addComponent("health", {value = 0})
world:addComponent("hunger", {value = 150})
world:addComponent("glucose", {value = 150})
world:addComponent("insulin", {value = 150})
world:addComponent("action", {cost = 1, action = function() end})
world:addComponent("toPerform", {cost = 1, action = function() end})

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

-- create a player entity at position (100, 100)
local player = world:addEntity({
    position = {pos = vector(200,200)},
    velocity = {maxSpeed = 100, currentSpeed = 100},
    boundingBox = {},
    hasInput = {},
    player = {state = player_states.neutral},
    collideObject = {
      type = {"actor", "player"},
      shape = HC.rectangle(200, 200, 10, 10),
      event = function(entity, collider, obj, dt)
        if obj then print("you hit the witch!") end
        print("collide!")
        local position = entity.position
        local vec = entity.velocity.vec
        local speed = entity.velocity.currentSpeed
        position.pos = position.pos - (vec * speed * dt)
      end
    },
    renderable = {
      z = 0.5,
      draw = function(player)
        love.graphics.rectangle(
            "fill",
            player.position.pos.x,
            player.position.pos.y,
            player.boundingBox.width,
            player.boundingBox.height
        )
      end
    }
})

local layers, tiles, boxes = Loader.load('Maps', 'testmap')
--add the map
world:addEntity({renderable = {
  draw = function(entity)
    for i, layer in ipairs(layers) do
      layer:draw()
    end
  end
}})

local witch = world:addEntity({
  position = {pos = vector(300,300)},
  boundingBox = {},
  velocity = {},
  collideObject = {
    type = {"actor", "witch"},
    shape = HC.rectangle(300, 300, 10, 10),
    event = function(entity, collider, obj, dt)
      print("the witch hit you!")
    end
  },
  renderable = {
    z = 0.5,
    draw = function(player)
      love.graphics.rectangle(
          "fill",
          player.position.pos.x,
          player.position.pos.y,
          player.boundingBox.width,
          player.boundingBox.height
      )
    end
  }
})

local mapBox = world:addEntity({collideWorld = {
  type = {player=true}
}})

for k, box in pairs(boxes) do
  addShape(mapBox, box)
end
addInteractable(mapBox, witch)

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
