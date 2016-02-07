--------------------------------------------------
--                    Comatose                  --
--------------------------------------------------
local debug = true

timer = require('hump/timer')
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
boss_states = {attacking = 'attacking', idle = 'idle', transPhase = 'transPhase'}
timer_states = {stop = 'stop', restart = 'restart'}

require 'systems'
require 'components'


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
