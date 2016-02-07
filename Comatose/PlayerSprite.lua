print("Player.lua loaded")

require "love.graphics"


local image_w = 1000 --This info can be accessed with a Löve2D call
local image_h = 1000 --		after the image has been loaded. I'm creating these for readability.


return {
	serialization_version = 1.0, -- The version of this serialization process

	sprite_sheet = "images/player.png", -- The path to the spritesheet
	sprite_name = "player", -- The name of the sprite

	frame_duration = 0.10,


	--This will work as an array.
	--So, these names can be accessed with numeric indexes starting at 1.
	--If you use < #sprite.animations_names > it will return the total number
	--		of animations in in here.
	animations_names = {
    "idle",
		"roll"
	},

	--The list with all the frames mapped to their respective animations
	--	each one can be accessed like this:
	--	mySprite.animations["idle"][1], or even
	animations = {
    idle = {
		--	love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H)
			love.graphics.newQuad( 1, 1, 16, 16, image_w, image_h ),
    },

		roll = {
		--	love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H)
    love.graphics.newQuad( 20, 4, 16, 16, image_w, image_h ),
    love.graphics.newQuad( 44, 4, 16, 16, image_w, image_h ),
    love.graphics.newQuad( 20, 4, 16, 16, image_w, image_h ),
    love.graphics.newQuad( 44, 4, 16, 16, image_w, image_h ),
    love.graphics.newQuad( 20, 4, 16, 16, image_w, image_h ),
    love.graphics.newQuad( 44, 4, 16, 16, image_w, image_h ),
    love.graphics.newQuad( 20, 4, 16, 16, image_w, image_h ),
    love.graphics.newQuad( 44, 4, 16, 16, image_w, image_h ),
    love.graphics.newQuad( 20, 4, 16, 16, image_w, image_h ),
    love.graphics.newQuad( 44, 4, 16, 16, image_w, image_h ),
}

	} --animations

} --return (end of file)
