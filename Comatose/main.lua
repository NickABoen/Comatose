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
local menuWorld = require('menu/menu')

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
menu = {}
function menu:update(dt)
  menuWorld:update(dt)
end
local hospitalImg = love.graphics.newImage('images/Hospital.png')
function menu:draw()
  cam:attach()
  menuWorld:draw()
  cam:detach()
end
function menu:keyreleased(key, code)
    if key == 'return' then
        Gamestate.switch(leadin)
    end
end

function love.load()
  --Witch = GetInstance ("WitchSprite.lua")
  --Player = GetInstance ("PlayerSprite.lua")

  printNotice('Trace system online.', trace.styles.green)
  local width, height = love.graphics.getDimensions()
  cam = Camera(width/8 + 10, height/8 + 10)
  cam:zoom(3.75)
  --init the game states
  Gamestate.registerEvents()
  Gamestate.switch(menu)
end
