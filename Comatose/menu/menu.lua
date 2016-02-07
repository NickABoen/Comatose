local world = Secs.new()

--construct the two
assert(loadfile("menu/systems.lua"))(world)
assert(loadfile("menu/componets.lua"))(world)

--return the ESC world
return world
