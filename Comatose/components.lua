
-- create the components
world:addComponent("position", { pos = vector(0,0)})
world:addComponent("velocity", { maxSpeed = 100, currentSpeed = 100, vec = vector(0,0)})
world:addComponent("boundingBox", {width = 10, height = 10})
world:addComponent("hasInput", {})
world:addComponent("player", {state = player_states.neutral})
--world:addComponent("witch", {state = player_states.neutral})
world:addComponent("debug",{ name = ''})
world:addComponent("renderable",{z = 0, draw = function() end})
world:addComponent("damage", {amount = 0})
world:addComponent("timers", {maxTimes = {}, timers = {}})
world:addComponent("witch",{hitPlayer = false, hitWall = false, freq = 1, amp = 1, speed = 100, target = nil})
-- phase transitions are functions. Without parameter (besides entity) they should return if phase 
-- change criteria has been met, otherwise if a new phase is passed they supply the 
-- transition function to make the change phase functions deal with behavior that occurs 
-- from substates and reactions to players
world:addComponent("phases",{current = 1, transitions = {}, functions  = {}})
world:addComponent("boss", {state = boss_states.idle})
world:addComponent("collideObject", {type = {}, shape = HC.rectangle(200, 200, 10, 10), event = function() end})
world:addComponent("collideWorld", {type = {}, world = HC.new(), objects = {}})
world:addComponent("health", {value = 0, min = 0, max = 1500})
world:addComponent("hunger", {value = 100, min = 0, max = 400})
world:addComponent("glucose", {value = 100, min = 0, max = 400})
world:addComponent("insulin", {value = 10, min = 0, max = 20})
world:addComponent("action", {cost = 1, action = function() end})
world:addComponent("toPerform", {})

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
local dKey = world:addEntity({
    key = {id = 'd'}
})

-- create a player entity at position (100, 100)
local player = world:addEntity({

    glucose = {value = 90},
    hunger = {value = 90},
    insulin = {value = 10},
    health = {value = 1500},
    position = {pos = vector(600,445)},
    velocity = {maxSpeed = 100, currentSpeed = 100},
    boundingBox = {},
    hasInput = {},
    player = {state = player_states.neutral},
    collideObject = {
      type = {"actor", "player"},
      shape = HC.rectangle(200, 200, 10, 10),
      event = function(entity, collider, obj, dt)
        if obj then print("you hit the witch!") end
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
        DrawInstance (Player, player.position.pos.x, player.position.pos.y)
        Player.size_scale = 2
      end
    }
})

--[[
-- create a player entity at position (200, 200)
local witch = world:addEntity({
    position = {pos = vector(200,200)},
    velocity = {maxSpeed = 100, currentSpeed = 100},
    boundingBox = {},
    timers = {maxTimes = {1}, timers = {1}},
    witch = {state = player_states.neutral},
    renderable = {
      z = 0.5,
      draw = function(witch)
        DrawInstance (Witch, witch.position.pos.x, witch.position.pos.y)
        Witch.curr_anim = Witch.sprite.animations_names[2]
        Witch.size_scale = 4
      end
    }
})
--]]

local layers, tiles, boxes = Loader.load('Maps', 'level1_1')
--add the map
world:addEntity({renderable = {
  draw = function(entity)
    for i, layer in ipairs(layers) do
      layer:draw()
    end
  end
}})

function witchPhase1Transition(entity, phase)
   if phase then -- phase was supplied and we should handle the actual transition
   else -- phase was not supplied so we only need to return if we're ready to transfer
    return entity.phases.current
   end
end
function witchPhase1(witch, dt)
    printDebug("witch phase = "..witch.boss.state)
    local timers = witch.timers
    if witch.boss.state == boss_states.idle then
        witch.position.pos = vector(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
        witch.velocity.vec = vector(0,0)
        if timers.timers[witch_timers.stateTimer] == 0 then
            witch.boss.state = boss_states.preparing
            timers.maxTimes[witch_timers.stateTimer] = 4
            timers.timers[witch_timers.stateTimer] = timers.maxTimes[witch_timers.stateTimer]
        end
        witch.witch.freq = 1
        witch.witch.amp = 5
    elseif witch.boss.state == boss_states.preparing then
        --Slow floating
            --slowing formula is:
            -- amp = (-0.5 * arctan(x-3)) + (1 - 0.625) where x is thi timer value
        local v = 2
        local k = 1.8
        local w = 2
        witch.witch.amp = (k * math.atan(timers.timers[witch_timers.stateTimer] - v)) + w

        if timers.timers[witch_timers.stateTimer] == 0 then
            witch.boss.state = boss_states.telling
            timers.maxTimes[witch_timers.stateTimer] = 1
            timers.timers[witch_timers.stateTimer] = timers.maxTimes[witch_timers.stateTimer]
        end
    elseif witch.boss.state == boss_states.telling then
        --Stop for a second
        witch.witch.amp = 0

        if timers.timers[witch_timers.stateTimer] == 0 then
            witch.boss.state = boss_states.attacking
            timers.maxTimes[witch_timers.stateTimer] = 5
            timers.timers[witch_timers.stateTimer] = timers.maxTimes[witch_timers.stateTimer]
        end
    elseif witch.boss.state == boss_states.attacking then
        --fly at the player

        local witchPos = witch.position.pos
        if witch.witch.target == nil then
            local playerPos = getPlayer().position.pos

            witch.witch.target = playerPos - witchPos
            witch.witch.target = witch.witch.target:normalized()
        end

        local timeLeft = timers.timers[witch_timers.stateTimer]

        local k= 15
        local z = 8.4
        local w = 30
        local speed = ((-1 * math.log(timeLeft * k) + w) * z )

        printDebug("speed = "..speed)

        witch.velocity.vec = witch.witch.target
        witch.velocity.currentSpeed = math.min(speed, witch.velocity.maxSpeed)

        if timers.timers[witch_timers.stateTimer] == 0 then
            witch.boss.state = boss_states.idle
            timers.maxTimes[witch_timers.stateTimer] = 4
            timers.timers[witch_timers.stateTimer] = timers.maxTimes[witch_timers.stateTimer]
            witch.witch.target = nil
        end
    end
    --
            if witch.witch.target ~= nil then
                printDebug("target = ("..witch.witch.target.x..", "..witch.witch.target.y..")")
            end
end
local spawnWitch = function()
    world:addEntity({
      position = {pos = vector(love.graphics.getWidth()/2,love.graphics.getHeight()/2)},
      boundingBox = {},
      phases = {transitions = {witchPhase1Transition}, functions = {witchPhase1}},
      boss = {},
      witch = {freq = 6, amp = 5, target = nil},
      timers = {maxTimes = {1,2}, timers = {1,2}},
      velocity = {maxSpeed = 1000},
      collideObject = {
        type = {"actor", "witch"},
        shape = HC.rectangle(300, 300, 10, 10),
        event = function(entity, collider, obj, dt)
          print("the witch hit you!")
        end
      },
      renderable = {
        z = 0.5,
        draw = function(entity)
          --for witch in pairs(world:query("witch")) do
              local timers = entity.timers
              local floatTimer = timers.timers[witch_timers.floatTimer]
              local newPos = (math.sin(entity.witch.freq * floatTimer * 2 * math.pi) * entity.witch.amp) + entity.position.pos.y

              if floatTimer == 0 then
                timers.timers[witch_timers.floatTimer] = timers.maxTimes[witch_timers.floatTimer]
              end

                DrawInstance (Witch, entity.position.pos.y, newPos)
                Witch.curr_anim = Witch.sprite.animations_names[2]
                Witch.size_scale = 3

          --end
        end
      }
    })
end
spawnWitch()

local mapBox = world:addEntity({collideWorld = {
  type = {player=true}
}})

for k, box in pairs(boxes) do
  addShape(mapBox, box)
end

--addInteractable(mapBox, witch)

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
