
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

            if player.state == player_states.neutral then

                if (keys['up'].key.state == key_states.pressed) or (keys['up'].key.state == key_states.down) then
                    velocity.vec.y = -1
                elseif (keys['down'].key.state == key_states.pressed) or (keys['down'].key.state == key_states.down) then
                    velocity.vec.y = 1
                else
                    velocity.vec.y = 0
                end

                if (keys['left'].key.state == key_states.pressed) or (keys['left'].key.state == key_states.down) then
                    velocity.vec.x = -1
                elseif (keys['right'].key.state == key_states.pressed) or (keys['right'].key.state == key_states.down) then
                    velocity.vec.x = 1
                else
                    velocity.vec.x = 0
                end

                if (keys['d'].key.state == key_states.pressed) or (keys['d'].key.state == key_states.down) then
                  Player.curr_anim = Player.sprite.animations_names[2]
                  Player.curr_frame = 1
                else
                  Player.curr_anim = Player.sprite.animations_names[1]
                  Player.curr_frame = 1
                end

                velocity.vec = velocity.vec:normalized()

                if keys['space'].key.state == key_states.pressed then
                    player.state = player_states.rolling
                end

            elseif player.state == player_states.rolling then
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
        --get the renderables
        local rens = {}
        for k in pairs(world:query("renderable")) do
          print(k)
          table.insert(rens, k)
        end
        --sort them
        table.sort(rens, function(r1, r2)
          return r1.renderable.z < r2.renderable.z
        end)
        print(#rens)
        --now draw all of them
        for i, entity in ipairs(rens) do
          entity.renderable.draw(entity)
        end
    end
})
