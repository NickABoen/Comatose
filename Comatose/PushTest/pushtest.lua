local world = Secs.new()

-- useful "enums"
player_states = {neutral = "neutral", rolling = "rolling"}
key_states = {up = 'up', down = 'down', pressed = 'pressed', released = 'released'}

--construct the two
assert(loadfile("PushTest/systems.lua"))(world)
assert(loadfile("PushTest/componets.lua"))(world)

--return the ESC world
return world
