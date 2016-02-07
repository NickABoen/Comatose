local world = Secs.new()

-- useful "enums"
player_states = {neutral = "neutral", rolling = "rolling"}
key_states = {up = 'up', down = 'down', pressed = 'pressed', released = 'released'}
boss_states = {preparing = 'preparing', telling = 'telling', attacking = 'attacking',
                idle = 'idle', transPhase = 'transPhase'}
timer_states = {stop = 'stop', restart = 'restart'}
witch_timers = {floatTimer = 1, stateTimer = 2}

--construct the two
assert(loadfile("level_1_2/systems.lua"))(world)
assert(loadfile("level_1_2/componets.lua"))(world)

--return the ESC world
return world
