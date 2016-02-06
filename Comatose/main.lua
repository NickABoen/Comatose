--------------------------------------------------
--                    Comatose                  --
--------------------------------------------------
local debug = true

vector = require('hump/vector')
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

-- create the components
world:addComponent("position", { pos = vector(0,0)})
world:addComponent("velocity", { maxSpeed = 100, currentSpeed = 100, vec = vector(0,0)})
world:addComponent("boundingBox", {width = 10, height = 10})
world:addComponent("hasInput", {})
world:addComponent("player", {state = player_states.neutral})
world:addComponent("renderable",{})
world:addComponent("debug",{ name = ''})

-- adding an input system
-- this system will handle processing user input
world:addSystem("input",{
    update = function(self, dt)
        for entity in pairs(world:query("hasInput velocity")) do
            local velocity = entity.velocity
            local currentSpeed = entity.velocity.currentSpeed
            local player = entity.player

            if love.keyboard.isDown("escape") then
                love.event.quit()
            end

            if player.state == player_states.neutral then
            
                if love.keyboard.isDown("up") then
                    velocity.vec.y = -1
                elseif love.keyboard.isDown("down") then
                    velocity.vec.y = 1
                else
                    velocity.vec.y = 0
                end

                if love.keyboard.isDown("left") then
                    velocity.vec.x = -1
                elseif love.keyboard.isDown("right") then
                    velocity.vec.x = 1
                else
                    velocity.vec.x = 0
                end

                velocity.vec = velocity.vec:normalized()

                if love.keyboard.isDown("space") then
                    player.state = player_states.rolling
                end

            elseif player.state == player_states.rolling then
                -- the player should have no or limited actions in this state
            elseif player.state == player_states.jumping then
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
        for entity in pairs(world:query("renderable position boundingBox debug")) do
            love.graphics.rectangle(
                "fill",
                entity.position.pos.x,
                entity.position.pos.y,
                entity.boundingBox.width,
                entity.boundingBox.height
            )
        end
    end
})

-- create a player entity at position (100, 100)
local player = world:addEntity({
    position = {pos = vector(100,100)},
    boundingBox = {},
    hasInput = {},
    renderable = {},
    debug = {name = 'player'},
    player = {},
    velocity = {maxSpeed = 100, currentSpeed = 100}
})

function love.load()
    printNotice('Trace system online.', trace.styles.green)
end

function love.update(dt)
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end

    world:update(dt)
end

function love.draw(dt)
    world:draw()
    trace.draw()
    printFPS()
end
