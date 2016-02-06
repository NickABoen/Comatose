--hi nick I wrote this in vim ;)
function spellingCorrection(str)
    return string.gsub(str, "emacs", "vim")
end

local Loader = require('TiledLoader')
local Secs = require('secs')
local world = Secs.new()

-- create the components
world:addComponent("position", {x = 0, y = 0})
world:addComponent("boundingBox", {width = 10, height = 10})
world:addComponent("hasInput", {})
world:addComponent("renderable",{z = 0, draw = function() end})

-- adding an input system
-- this system will handle processing user input
world:addSystem("input",{
    speed = 100,
    update = function(self, dt)
        for entity in pairs(world:query("hasInput position")) do
            local pos = entity.position

            if love.keyboard.isDown("up") then
                pos.y = pos.y - self.speed * dt
            end

            if love.keyboard.isDown("down") then
                pos.y = pos.y + self.speed * dt
            end

            if love.keyboard.isDown("left") then
                pos.x = pos.x - self.speed * dt
            end

            if love.keyboard.isDown("right") then
                pos.x = pos.x + self.speed * dt
            end

            if love.keyboard.isDown("escape") then
                love.event.quit()
            end

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

-- create a player entity at position (100, 100)
local player = world:addEntity({
    position = {x = 100, y = 100},
    boundingBox = {},
    hasInput = {},
    renderable = {
      z = 0.5,
      draw = function(player)
        love.graphics.rectangle(
            "fill",
            player.position.x,
            player.position.y,
            player.boundingBox.width,
            player.boundingBox.height
        )
      end
    }
})

local layers, tiles, boxes = Loader.load('Maps', 'testmap')
--add the map
world:addEntity({renderable = {
  draw = function(entity)
    for i, layer in ipairs(layers) do
      layer:draw()
    end
  end
}})

function love.load()

end

function love.update(dt)
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end

    world:update(dt)
end

function love.draw(dt)
    local str1 = "emacs"
    local str2 = "emacsemacs emacs"
    local str3 = "themacs and cheese"

    world:draw()

    love.graphics.print(tostring(str1) .. "=" .. tostring(spellingCorrection(str1)), 0,0)
    love.graphics.print(tostring(str2) .. "=" .. tostring(spellingCorrection(str2)), 0,10)
    love.graphics.print(tostring(str3) .. "=" .. tostring(spellingCorrection(str3)), 0,20)
end
