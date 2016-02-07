local world = Secs.new()

-- useful "enums"
player_states = {neutral = "neutral", rolling = "rolling", finish_roll = "finish_roll"}
key_states = {up = 'up', down = 'down', pressed = 'pressed', released = 'released'}


--construct the two
assert(loadfile("leadin/systems.lua"))(world)
assert(loadfile("leadin/componets.lua"))(world)

--return the ESC world
return world
