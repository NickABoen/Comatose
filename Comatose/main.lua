--------------------------------------------------
--                    Comatose                  --
--------------------------------------------------
local debug = false

vector = require('hump/vector')
require('TiledLoader')
Secs = require('secs')
world = Secs.new()
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

require 'components'
require 'systems'
require "AnimatedSprite"

function love.load()

  Witch = GetInstance ("WitchSprite.lua")
  Player = GetInstance ("PlayerSprite.lua")

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
