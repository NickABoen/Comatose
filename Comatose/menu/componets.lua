local world = ...

world:addComponent("renderable",{z = 0, draw = function() end})

local hospitalImg = love.graphics.newImage('images/Hospital.png')

world:addEntity({
  renderable = {
    z = 0,
    draw = function()
      love.graphics.draw(hospitalImg)
    end
  }
})

world:addEntity({
  renderable = {
    z = 0.5,
    draw = function()
      love.graphics.setColor(0, 0, 0)
      love.graphics.print("Comatose", 80, 30)
      love.graphics.print("Press Enter", 80, 120)
      love.graphics.setColor(255, 255, 255)
    end
  }
})
