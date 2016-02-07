--------------------------------------------------
--                    Comatose                  --
--------------------------------------------------
debug = true

Gamestate = require('hump/gamestate')
Camera = require('hump/camera')
vector = require('hump/vector')
require('TiledLoader')
Secs = require('secs')
HC = require 'HC'
require 'trace'
require 'util'
require "AnimatedSprite"

function getPlayer(world)
  for player in pairs(world:query("player")) do
    return player
  end
end

--read in the worlds
local leadinWorld = require('leadin/leadin')

--make the game states (ensure these are global)
--here is the code for the leadin
leadin = {}
function leadin:update(dt)
  leadinWorld:update(dt)
end
function leadin:draw()
  cam:attach()
  leadinWorld:draw()
  cam:detach()
  trace.draw()
  printFPS()
  local player = getPlayer(leadinWorld)
  love.graphics.printf("health: " .. player.health.value, 0, 20, love.graphics.getWidth(), 'right')
  love.graphics.printf("hunger: " .. player.hunger.value, 0, 40, love.graphics.getWidth(), 'right')
  love.graphics.printf("glucose: " .. player.glucose.value, 0, 60, love.graphics.getWidth(), 'right')
  love.graphics.printf("insulin: " .. player.insulin.value, 0, 80, love.graphics.getWidth(), 'right')
end
--next other things could come

function love.load()
  --Witch = GetInstance ("WitchSprite.lua")
  --Player = GetInstance ("PlayerSprite.lua")

  printNotice('Trace system online.', trace.styles.green)
  cam = Camera(100, 100)
  cam:zoom(2.5)
  --init the game states
  Gamestate.registerEvents()
  Gamestate.switch(leadin)
end
