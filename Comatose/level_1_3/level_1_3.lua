local world = Secs.new()

-- useful "enums"
player_states = {neutral = "neutral", rolling = "rolling"}
key_states = {up = 'up', down = 'down', pressed = 'pressed', released = 'released'}


--construct the two
assert(loadfile("level_1_3/systems.lua"))(world)
assert(loadfile("level_1_3/componets.lua"))(world)

--return the ESC world
return world
