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
world:addComponent("renderable",{z = 0, draw = function() end})
world:addComponent("collideObject", {type = {}, shape = HC.rectangle(200, 200, 10, 10), event = function() end})
world:addComponent("collideWorld", {type = {}, world = HC.new(), objects = {}})
world:addComponent("health", {value = 0, min = 0, max = 1500})
world:addComponent("hunger", {value = 100, min = 0, max = 400})
world:addComponent("glucose", {value = 100, min = 0, max = 400})
world:addComponent("insulin", {value = 10, min = 0, max = 20})
world:addComponent("action", {cost = 1, action = function() end})
world:addComponent("food", {dhunger = 10, dglucose = 10})
world:addComponent("candy", {})
world:addComponent("toPerform", {})

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
    position = {pos = vector(545,240)},
    velocity = {maxSpeed = 100, currentSpeed = 100},
    boundingBox = {},
    hasInput = {},
    player = {state = player_states.neutral},
    collideObject = {
      type = {"actor", "player"},
      event = function(entity, collider, obj, dt)
        local position = entity.position
        local vec = entity.velocity.vec
        local speed = entity.velocity.currentSpeed
        if obj then
          world:attach(obj, {toPerform = {}})
          obj.position.pos = obj.position.pos + 0.0005*entity.glucose.value*(obj.position.pos - position.pos)
        end
        position.pos = position.pos - 0.3*(vec * speed * dt)
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

local layers, tiles, boxes = Loader.load('Maps', 'level1_3')
--add the map
world:addEntity({renderable = {
  draw = function(entity)
    for i, layer in ipairs(layers) do
      layer:draw()
    end
  end
}})

local furnitureIdTable = {6832, 6833, 6831, 6830, 7286}
local furniture = {}
for i = 1, 10 do
  local tile = tiles[furnitureIdTable[i % 5 + 1]]
  furniture[i] = world:addEntity({
    action = {
      cost = 0.1,
      action = function(entity)
        local e = entity
        print(e)
        entity.velocity.vec.x, entity.velocity.vec.y = player.velocity.vec.x, player.velocity.vec.y
        Timer.after(0.15, function()
          print("STOP!")
          e.velocity.vec.x = 0
          e.velocity.vec.y = 0
        end)
        --printDebug(Timer)
        print("tried to push the box")
      end
    },
    velocity = {maxSpeed = 70, currentSpeed = 70, vec = vector(0,0)},
    position = {pos = vector(i * 17, 240)},
    renderable = {
      z = 0.3,
      draw = function(entity)
        tile:draw(entity.position.pos.x,entity.position.pos.y)
      end
    },
    collideObject = {
      type = {"object", "chairs"},
      shape = HC.rectangle(i * 17+2, 240+2, 12, 12),
      event = function(entity, collider, obj, dt)
        local vol = entity.velocity
        local vec = vol.vec
        local speed = vol.currentSpeed
        entity.position.pos = entity.position.pos - 0.3*speed * vec * dt
        if obj then
          vol = obj.velocity
          vec = vol.vec
          speed = vol.currentSpeed
          obj.position.pos = obj.position.pos - speed * vec * dt
          obj.position.pos = obj.position.pos + 0.05*(obj.position.pos - entity.position.pos)
        else
          entity.position.pos = entity.position.pos - 0.7*speed * vec * dt
          entity.position.pos = entity.position.pos + 0.05*(player.position.pos - entity.position.pos)
          print("did I get here?")
        end
      end
    }
  })
end

local mapBox = world:addEntity({collideWorld = {
  type = {player=true}
}})
for k, box in pairs(boxes) do
  addShape(mapBox, box)
end
local furnWorld = world:addEntity({collideWorld = {
  type = {player=true, chairs=true}
}})
for k, furn in pairs(furniture) do
  addInteractable(furnWorld, furn)
end

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
