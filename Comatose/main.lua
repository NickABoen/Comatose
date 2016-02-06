--hi nick I wrote this in vim ;)
function spellingCorrection(str)
    return string.gsub(str, "emacs", "vim")
end

require('TiledMapLoader')

local Secs = require('secs')
local world = Secs.new()

-- create the components
world:addComponent("position", {x = 0, y = 0})
world:addComponent("boundingBox", {width = 10, height = 10})
world:addComponent("hasInput", {})
world:addComponent("renderable",{})

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
        for entity in pairs(world:query("renderable position boundingBox")) do
            love.graphics.rectangle(
                "fill",
                entity.position.x,
                entity.position.y,
                entity.boundingBox.width,
                entity.boundingBox.height
            )
        end
    end
})

-- create a player entity at position (100, 100)
local player = world:addEntity({
    position = {x = 100, y = 100},
    boundingBox = {},
    hasInput = {},
    renderable = {}
})

-- create a large, generic rectangle entity at position (200, 0)
world:addEntity({
    position = { x = 200},
    boundingBox = { width = 20, height = 30}
})

testMap = Map.new('Maps', 'test')

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

    testMap:draw(0, 0)

    world:draw()

    love.graphics.print(tostring(str1) .. "=" .. tostring(spellingCorrection(str1)), 0,0)
    love.graphics.print(tostring(str2) .. "=" .. tostring(spellingCorrection(str2)), 0,10)
    love.graphics.print(tostring(str3) .. "=" .. tostring(spellingCorrection(str3)), 0,20)
end
