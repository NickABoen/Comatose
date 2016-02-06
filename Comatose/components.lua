
-- create the components
world:addComponent("position", { pos = vector(0,0)})
world:addComponent("velocity", { maxSpeed = 100, currentSpeed = 100, vec = vector(0,0)})
world:addComponent("boundingBox", {width = 10, height = 10})
world:addComponent("hasInput", {})
world:addComponent("player", {state = player_states.neutral})
world:addComponent("debug",{ name = ''})
world:addComponent("renderable",{z = 0, draw = function() end})

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
    position = {pos = vector(100,100)},
    velocity = {maxSpeed = 100, currentSpeed = 100},
    boundingBox = {},
    hasInput = {},
    player = {state = player_states.neutral},
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
