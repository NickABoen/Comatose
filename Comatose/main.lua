--------------------------------------------------
--                    Comatose                  --
--------------------------------------------------
local debug = true

vector = require('hump/vector')
HC = require 'HC'
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

-- create the components
world:addComponent("position", { pos = vector(0,0)})
world:addComponent("velocity", { maxSpeed = 100, currentSpeed = 100, vec = vector(0,0)})
world:addComponent("boundingBox", {width = 10, height = 10})
world:addComponent("hasInput", {})
world:addComponent("player", {state = player_states.neutral})
world:addComponent("debug",{ name = ''})
world:addComponent("renderable",{z = 0, draw = function() end})
world:addComponent("player", {state = player_states.neutral})
world:addComponent("collideObject", {type = {}, shape = HC.rectangle(200, 200, 10, 10), event = function() end})
world:addComponent("collideWorld", {type = {}, world = HC.new() })

local function typeMatch(set, types)
    for k, v in ipairs(types) do
      if set[v] then return true end
    end
    return false
end

world:addSystem("collide",
  {update = function(self, dt)
    --print("updating collision")
    for collider in pairs(world:query("collideWorld")) do
      --print("going though worlds")
      for entity in pairs(world:query("collideObject position")) do
        --print("going though objects")
        for shape, delta in pairs(collider.collideWorld.world:collisions(entity.collideObject.shape)) do
          if typeMatch(collider.collideWorld.type, entity.collideObject.type) then
            --print("found collision")
            --move them away by the current vector
            entity.collideObject.event(entity, collider, dt)
          end
        end
      end
    end
  end})
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
           --print(position.pos, vec, speed)
           position.pos = position.pos + (vec * speed * dt)
        end
        for entity in pairs(world:query("position collideObject")) do
          local bx, by, bx2, by2 = entity.collideObject.shape:bbox()
          local bw, bh = bx2 - bx, by2 - by
          local pos = entity.position.pos
          entity.collideObject.shape:moveTo(pos.x + bw/2, pos.y + bh/2)
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
          --print(k)
          table.insert(rens, k)
        end
        --sort them
        table.sort(rens, function(r1, r2)
          return r1.renderable.z < r2.renderable.z
        end)
        --print(#rens)
        --now draw all of them
        for i, entity in ipairs(rens) do
          entity.renderable.draw(entity)
        end
    end
})

-- create a player entity at position (100, 100)
local player = world:addEntity({
    position = {pos = vector(200,200)},
    boundingBox = {},
    hasInput = {},
    velocity = {},
    player = {},
    collideObject = {
      type = {"actor", "player"},
      event = function(entity, collider, dt)
        print("collide!")
        local position = entity.position
        local vec = entity.velocity.vec
        local speed = entity.velocity.currentSpeed
        position.pos = position.pos - (vec * speed * dt)
      end
    },
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
print(boxes, #boxes)

local mapBox = world:addEntity({collideWorld = {
  type = {actor = true},
}})

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

function love.load()
  printNotice('Trace system online.', trace.styles.green)
  for k, box in pairs(boxes) do
    print(box:bbox())
    mapBox.collideWorld.world:register(box)
  end
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
