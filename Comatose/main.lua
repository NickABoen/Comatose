--------------------------------------------------
--                    Comatose                  --
--------------------------------------------------
local debug = true

vector = require('hump/vector')
local Loader = require('TiledLoader')
local Secs = require('secs')
local world = Secs.new()
require 'trace'

local fps

-- Useful trace functions that manage some writing
function printDebug(text)
    if debug then
        trace.print(text, trace.styles.white)
    end
end
function printNotice(text)
    if debug then
        trace.print(text, trace.styles.green)
    end
end
function printFPS()
    if debug then
        love.graphics.printf("Current FPS: " .. tostring(love.timer.getFPS()), 0,0, love.graphics.getWidth(), 'right')
    end
end

-- useful "enums"
local player_states = {neutral = "neutral", rolling = "rolling"}
local key_states = {up = 'up', down = 'down', pressed = 'pressed', released = 'released'}

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

-- adding an input system
-- this system will handle processing user input
world:addSystem("input",{
    update = function(self, dt)
        local keys = {}

        for key in pairs(world:query("key"))do
            -- update old value
            key.key.was = key.key.is

            -- set current key
            if love.keyboard.isDown(key.key.id) then
                key.key.is = key_states.down
            else
                key.key.is = key_states.up
            end

            -- update state
            if (key.key.was == key_states.up) and (key.key.is == key_states.up) then --key hasn't been touched and is up
                key.key.state = key_states.up
            elseif (key.key.was == key_states.up) and (key.key.is == key_states.down) then -- key has just been pressed
                key.key.state = key_states.pressed
            elseif (key.key.was == key_states.down) and (key.key.is == key_states.up) then -- key has just been released
                key.key.state = key_states.released
            elseif (key.key.was == key_states.down) and (key.key.is == key_states.down) then --key is being held down
                key.key.state = key_states.down
            end


            keys[key.key.id] = key
        end

        for entity in pairs(world:query("hasInput velocity")) do
            local velocity = entity.velocity
            local currentSpeed = entity.velocity.currentSpeed
            local player = entity.player

            if keys['escape'].key.state == key_states.released then
                love.event.quit()
            end

            if player.state == player_states.neutral then

                if (keys['up'].key.state == key_states.pressed) or (keys['up'].key.state == key_states.down) then
                    velocity.vec.y = -1
                elseif (keys['down'].key.state == key_states.pressed) or (keys['down'].key.state == key_states.down) then
                    velocity.vec.y = 1
                else
                    velocity.vec.y = 0
                end

                if (keys['left'].key.state == key_states.pressed) or (keys['left'].key.state == key_states.down) then
                    velocity.vec.x = -1
                elseif (keys['right'].key.state == key_states.pressed) or (keys['right'].key.state == key_states.down) then
                    velocity.vec.x = 1
                else
                    velocity.vec.x = 0
                end
            
                velocity.vec = velocity.vec:normalized()

                if keys['space'].key.state == key_states.pressed then
                    player.state = player_states.rolling
                end

            elseif player.state == player_states.rolling then
                -- the player should have no or limited actions in this state
            end
        end
    end
})

-- add a "movement" system with a update callback
-- this system updates the position components of all entities with a velocity component
world:addSystem("movement", {
    update = function(self, dt)
        for entity in pairs(world:query("position velocity")) do
           local position = entity.position
           local vec = entity.velocity.vec
           local speed = entity.velocity.currentSpeed

           position.pos = position.pos + (vec * speed * dt)
        end
    end
})

-- add a "render" system with a draw callback
-- this system will handle rendering rectangles
world:addSystem("render", {
    draw = function(self)
        --get the renderables
        local rens = {}
        for k in pairs(world:query("renderable")) do
          print(k)
          table.insert(rens, k)
        end
        --sort them
        table.sort(rens, function(r1, r2)
          return r1.renderable.z < r2.renderable.z
        end)
        print(#rens)
        --now draw all of them
        for i, entity in ipairs(rens) do
          entity.renderable.draw(entity)
        end
    end
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

function love.load()
  printNotice('Trace system online.', trace.styles.green)
end

function love.update(dt)
    world:update(dt)
end

function love.draw(dt)
    world:draw()
    trace.draw()
    printFPS()
end
