--------------------------------------------------
--                    Comatose                  --
--------------------------------------------------
local debug = true 

timer = require('hump/timer')
Gamestate = require('hump/gamestate')
Camera = require('hump/camera')
vector = require('hump/vector')
Timer = require('hump/timer')
require('TiledLoader')
Secs = require('secs')
HC = require 'HC'
require 'trace'
require 'util'
require "animations/AnimatedSprite"
bgMusic = nil
sounds = {}
stepsCooldown = 0.5

function getPlayer(world)
  for player in pairs(world:query("player")) do
    return player
  end
end

--read in the worlds
local leadinWorld = require('leadin/leadin')
local menuWorld = require('menu/menu')
local testWorld = require('PushTest/pushtest')
local level_1_1World = require('level_1_1/level_1_1')
local level_1_2World = require('level_1_2/level_1_2')
local level_1_3World = require('level_1_3/level_1_3')
--make the game states (ensure these are global)
--here is the code for the leadin
leadin = {}
function leadin:update(dt)
  leadinWorld:update(dt)
  stepsCooldown = stepsCooldown - dt
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

pushtest = {}
function pushtest:update(dt)
  testWorld:update(dt)
  stepsCooldown = stepsCooldown - dt
end
function pushtest:draw()
  cam:attach()
  testWorld:draw()
  cam:detach()
  trace.draw()
  printFPS()
  local player = getPlayer(testWorld)
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

-- useful "enums"
player_states = {neutral = "neutral", rolling = "rolling"}
key_states = {up = 'up', down = 'down', pressed = 'pressed', released = 'released'}
boss_states = {preparing = 'preparing', telling = 'telling', attacking = 'attacking', 
                idle = 'idle', transPhase = 'transPhase'}
timer_states = {stop = 'stop', restart = 'restart'}
witch_timers = {floatTimer = 1, stateTimer = 2}

level_1_1 = {}
function level_1_1:update(dt)
  level_1_1World:update(dt)
  stepsCooldown = stepsCooldown - dt
end
function level_1_1:draw()
  cam:attach()
  level_1_1World:draw()
  cam:detach()
  trace.draw()
  printFPS()
end

level_1_2 = {}
function level_1_2:update(dt)
  level_1_2World:update(dt)
  stepsCooldown = stepsCooldown - dt
end
function level_1_2:draw()
  cam:attach()
  level_1_2World:draw()
  cam:detach()
  trace.draw()
  printFPS()
end

level_1_3 = {}
function level_1_3:update(dt)
  level_1_3World:update(dt)
  stepsCooldown = stepsCooldown - dt
end
function level_1_3:draw()
  cam:attach()
  level_1_3World:draw()
  cam:detach()
  trace.draw()
  printFPS()
  local player = getPlayer(level_1_3World)
end

function love.load()
  --Witch = GetInstance ("WitchSprite.lua")
  --Player = GetInstance ("PlayerSprite.lua")
  bgMusic = love.audio.newSource("SoundAndMusic/Mesmerize.mp3")
  bgMusic:setVolume(0.6)
  bgMusic:setLooping(true)
  bgMusic:play()

  sounds['fs1'] = love.audio.newSource("SoundAndMusic/footstep01.ogg", 'static')
  sounds['fs2'] = love.audio.newSource("SoundAndMusic/footstep02.ogg", 'static')
  sounds['fs3'] = love.audio.newSource("SoundAndMusic/footstep03.ogg", 'static')
  sounds['chair'] = love.audio.newSource("SoundAndMusic/chair_move.wav",'static')
  sounds['magic'] = love.audio.newSource("SoundAndMusic/magic1.wav", 'static')
  sounds['roll'] = love.audio.newSource("SoundAndMusic/roll_sound.wav", 'static')

  local stepVolume = 0.06
  sounds['fs1']:setVolume(stepVolume)
  sounds['fs2']:setVolume(stepVolume)
  sounds['fs3']:setVolume(stepVolume)

  printNotice('Trace system online.', trace.styles.green)
  local width, height = love.graphics.getDimensions()
  cam = Camera(100, 100)
  cam:zoom(2.5)
  cam.smoother = Camera.smooth.linear(1000)
  --init the game states
  Gamestate.registerEvents()
  Gamestate.switch(level_1_1)
end
