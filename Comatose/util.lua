local fps

-- Useful trace functions that manage some writing
function printDebug(text)
    if debug then
        --trace.print(text, trace.styles.white)
    end
end
function printNotice(text)
    if debug then
        --trace.print(text, trace.styles.green)
    end
end
function printFPS()
    if debug then
        --love.graphics.printf("Current FPS: " .. tostring(love.timer.getFPS()), 0,0, love.graphics.getWidth(), 'right')
    end
end
