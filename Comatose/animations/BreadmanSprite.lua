print("Breadman.lua loaded")

require "love.graphics"


local image_w = 1000 --This info can be accessed with a Löve2D call
local image_h = 1000 --		after the image has been loaded. I'm creating these for readability.


return {
	serialization_version = 1.0, -- The version of this serialization process
	sprite_sheet = "images/breadman.png", -- The path to the spritesheet
	sprite_name = "breadman", -- The name of the sprite

	frame_duration = 0.10,


	--This will work as an array.
	animations_names = {
    "idle",
		"fly"
	},

	--The list with all the frames mapped to their respective animations
	animations = {

    idle = {
		  --	love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H)
			love.graphics.newQuad( 1, 1, 16, 16, image_w, image_h ),
    },

		fly = {
		  --	love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H)
			love.graphics.newQuad( 0, 1, 16, 16, image_w, image_h ),
			love.graphics.newQuad( 20, 0, 16, 16, image_w, image_h ),
			love.graphics.newQuad( 35, 0, 16, 16, image_w, image_h ),
			love.graphics.newQuad( 56, 0, 16, 16, image_w, image_h ),
   }

	} --animations

} --return (end of file)
