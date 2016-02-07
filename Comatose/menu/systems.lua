local world = ...

world:addSystem("render", {
    draw = function(self)
        --get the renderables
        local rens = {}
        for k in pairs(world:query("renderable")) do
          --print(k)
          table.insert(rens, k)
        end
        --sort them
        table.sort(rens, function(r1, r2)
          return r1.renderable.z < r2.renderable.z
        end)
        --print(#rens)
        --now draw all of them
        for i, entity in ipairs(rens) do
          entity.renderable.draw(entity)
        end
    end
})
