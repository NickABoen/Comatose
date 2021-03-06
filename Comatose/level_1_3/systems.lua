
local world = ...

Player = GetInstance ("animations/PlayerSprite.lua")
Witch = GetInstance ("animations/WitchSprite.lua")

local function addInteractable(collider, obj)
  collider.collideWorld.objects[obj.collideObject.shape] = obj
  collider.collideWorld.world:register(obj.collideObject.shape)
end

local function addShape(collider, shape)
  --collider.collideWorld.objects[obj.collideObject.shape] = obj
  collider.collideWorld.world:register(shape)
end

local function typeMatch(set, types)
    for k, v in pairs(types) do
      if set[v] then return true end
    end
    return false
end

local function addInteractable(collider, obj)
  collider.collideWorld.objects[obj.collideObject.shape] = obj
  collider.collideWorld.world:register(obj.collideObject.shape)
end

local function addShape(collider, shape)
  --collider.collideWorld.objects[obj.collideObject.shape] = obj
  collider.collideWorld.world:register(shape)
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
            entity.collideObject.event(entity, collider, collider.collideWorld.objects[shape], dt)
          end
        end
      end
    end
  end})

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

            if player == nil then
              player = entity.witch
            end

            if keys['escape'].key.state == key_states.released then
                love.event.quit()
            end

            --if player.state == player_states.neutral then
              if Player.curr_anim == Player.sprite.animations_names[1] then
                local isFootstep = false

                if (keys['up'].key.state == key_states.pressed) or (keys['up'].key.state == key_states.down) then
                    velocity.vec.y = -1
                    isFootstep = true
                elseif (keys['down'].key.state == key_states.pressed) or (keys['down'].key.state == key_states.down) then
                    velocity.vec.y = 1
                    isFootstep = true
                else
                    velocity.vec.y = 0
                end

                if (keys['left'].key.state == key_states.pressed) or (keys['left'].key.state == key_states.down) then
                    velocity.vec.x = -1
                    isFootstep = true
                elseif (keys['right'].key.state == key_states.pressed) or (keys['right'].key.state == key_states.down) then
                    velocity.vec.x = 1
                    isFootstep = true
                else
                    velocity.vec.x = 0
                end

                if isFootstep and stepsCooldown <= 0 then
                    stepsCooldown = 0.5
                    local stepNum = love.math.random(1,3)
                    if stepNum == 1 then
                        sounds['fs1']:play()
                    else if stepNum == 2 then
                        sounds['fs2']:play()
                    else
                        sounds['fs3']:play()
                    end
                end

                if (keys['d'].key.state == key_states.pressed) or (keys['d'].key.state == key_states.down) then
                    Player.curr_anim = Player.sprite.animations_names[2]
                    player.state = player_states.rolling
                    sounds['roll']:play()
                  end

                velocity.vec = velocity.vec:normalized()

                --if keys['space'].key.state == key_states.pressed then
                    --player.state = player_states.rolling
                end

            elseif player.state == player_states.rolling then
                -- the player should have no or limited actions in this state
            end
        end
    end
})

world:addSystem("stateChange", {

})

-- add a "movement" system with a update callback
-- this system updates the position components of all entities with a velocity component
world:addSystem("movement", {
    update = function(self, dt)
        Timer.update(dt)
        for entity in pairs(world:query("position velocity")) do
           local position = entity.position
           local vec = entity.velocity.vec
           local speed = entity.velocity.currentSpeed
           position.pos = position.pos + (vec * speed * dt)
        end
        for entity in pairs(world:query("position collideObject")) do
          local bx, by, bx2, by2 = entity.collideObject.shape:bbox()
          local bw, bh = bx2 - bx, by2 - by
          local pos = entity.position.pos
          entity.collideObject.shape:moveTo(pos.x + bw/2, pos.y + bh/2)
        end
        for entity in pairs(world:query("player")) do
          local vec = entity.velocity.vec
          if math.abs(vec.x) > 0.001 or math.abs(vec.y) > 0.001 then
            entity.glucose.value = entity.glucose.value - 0.33 * dt
          end
          --printDebug("player moved cammera")
          cam:lookAt(math.ceil(entity.position.pos.x), math.ceil(entity.position.pos.y))
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
          if entity.renderable.hud then cam:detach() end
          entity.renderable.draw(entity)
          if entity.renderable.hud then cam:attach() end
        end
    end
})

--add a "timer" system with an update callback
-- this system updates all registered timers each tick
world:addSystem("timer",{
    update = function(self, dt)
        for entity in pairs(world:query("timers")) do
            for i in ipairs(entity.timers.maxTimes) do
                local maxTime = entity.timers.maxTimes[i]
                local timers = entity.timers
                timers.timers[i] = timers.timers[i] - dt

                if timers.timers[i] < 0 then
                    timers.timers[i] = 0
                end
            end
        end
    end
})

world:addSystem("deathThingy", {
   update = function(self, dt)
     for player in pairs(world:query("player")) do
        if player.hunger.value <= 0 then
          Gamestate.switch(deathState)
          return
        end
     end
   end
})

--add a "ai" system with an update callback
-- this system handles the calls to an enemy logic update
world:addSystem("ai", {
    update = function(self, dt)
        for entity in pairs(world:query("phases boss")) do
            local bossState = entity.boss
            local phases = entity.phases

            printDebug("ai system boss state = "..bossState.state)

            if bossState.state == boss_states.transPhase then
                phases.transitions[phases.current](entity)
            else
               local newPhase = phases.transitions[phases.current](entity)

                if newPhase == phases.current then -- No need to change Phases
                    phases.functions[phases.current](entity, dt)
                else -- Phases didn't match so it's time to shift
                    phases.current = newPhase
                    bossState.state = boss_states.transPhase
                end
            end
        end
    end
})

local glucoseHarshness = 0.003
local hungerHarshness = 0.003
local glucoseHealth = 2
local hungerHealth = 2
local perfect = 100

world:addSystem("updateHealth", {
  update = function(entity, dt)
    for entity in pairs(world:query("health glucose hunger")) do
      local glucoseTerm = -glucoseHarshness*(entity.glucose.value - perfect)^2 + glucoseHealth
      local hungerTerm = -hungerHarshness*(entity.hunger.value - perfect)^2 + hungerHealth
      entity.health.value = entity.hunger.value + dt * glucoseTerm + dt * hungerTerm
      entity.health.value = math.min(entity.health.value, entity.health.max)
      entity.health.value = math.max(entity.health.value, entity.health.min)
    end
  end
})

world:addSystem("updateHunger", {
  update = function(entity, dt)
    for entity in pairs(world:query("glucose hunger")) do
      local glucoseTerm = -0.001*(entity.glucose.value - 100)^2
      entity.hunger.value = entity.hunger.value + dt * glucoseTerm
      entity.hunger.value = math.min(entity.hunger.value, entity.hunger.max)
      entity.hunger.value = math.max(entity.hunger.value, entity.hunger.min)
    end
  end
})

local hinderGlucose = 200

world:addSystem("performHinders", {
  update = function(entity, dt)
    --add this later perhaps
  end
})

local function getPlayer()
  for player in pairs(world:query("player")) do
    return player
  end
end

world:addSystem("preformList", {
  update = function(entity, dt)
    for toPerform in pairs(world:query("toPerform action")) do
      world:detach(toPerform, "toPerform")
      local player = getPlayer()
      if toPerform.action.cost < player.glucose.value then
        toPerform.action.action(toPerform)
        player.glucose.value = player.glucose.value - toPerform.action.cost
        player.insulin.value = 0.05 * player.glucose.value - toPerform.action.cost
        player.glucose.value = math.min(player.glucose.value, player.glucose.max)
        player.glucose.value = math.max(player.glucose.value, player.glucose.min)
        player.insulin.value = math.min(player.insulin.value, player.insulin.max)
        player.insulin.value = math.max(player.insulin.value, player.insulin.min)
      end
    end
  end
})

world:addSystem("playerAnimation", {
  update = function(entity, dt)
    actions = world:query("animation player")
    player = getPlayer()

    if Player.curr_anim == Player.sprite.animations_names[2] then
      if Player.curr_frame < 3  and player.glucose.value > 5 then
        if Player.curr_frame == 1 then
          player.velocity.currentSpeed = player.velocity.currentSpeed + 20
          player.glucose.value = player.glucose.value - 1
        end
        UpdateInstance(Player, dt)
      else
        Player.curr_frame = 1
        Player.curr_anim = Player.sprite.animations_names[1]
        player.state = player_states.neutral
        player.velocity.currentSpeed = player.velocity.maxSpeed
      end
    end
  end
})
