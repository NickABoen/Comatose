--------------------------------------------------
--                    Comatose                  --
--------------------------------------------------
local debug = true

Camera = require('hump/camera')
vector = require('hump/vector')
require('TiledLoader')
Secs = require('secs')
world = Secs.new()
HC = require 'HC'
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
player_states = {neutral = "neutral", rolling = "rolling"}
key_states = {up = 'up', down = 'down', pressed = 'pressed', released = 'released'}

require 'systems'
require 'components'


function love.load()
  print(love.graphics.getBlendMode())
  printNotice('Trace system online.', trace.styles.green)
  --love.graphics.setBackgroundColor(0, 255, 0)
  --love.graphics.setBlendMode("alpha")
  cam = Camera(100, 100)
  cam:zoom(2.5)
end

function love.update(dt)
    world:update(dt)
end

function love.draw(dt)
    cam:attach()
    world:draw()
    cam:detach()
    trace.draw()
    printFPS()
    local player = getPlayer()
    love.graphics.printf("health: " .. player.health.value, 0, 20, love.graphics.getWidth(), 'right')
    love.graphics.printf("hunger: " .. player.hunger.value, 0, 40, love.graphics.getWidth(), 'right')
    love.graphics.printf("glucose: " .. player.glucose.value, 0, 60, love.graphics.getWidth(), 'right')
    love.graphics.printf("insulin: " .. player.insulin.value, 0, 80, love.graphics.getWidth(), 'right')
end
