local f18Key = hs.keycodes.map["f18"]
local f18Down = false
local f18Used = false

local capsTap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
    local isDown = event:getType() == hs.eventtap.event.types.keyDown

    if event:getKeyCode() == f18Key then
        if isDown and not f18Down then
            f18Down = true
            f18Used = false
        elseif not isDown and f18Down then
            f18Down = false
            if not f18Used then
                hs.eventtap.keyStroke({}, "escape", 0)
            end
        end
        return true
    end

    if f18Down then
        f18Used = true
        local flags = event:getFlags()
        flags.ctrl = true
        event:setFlags(flags)
        return false
    end

    return false
end)

capsTap:start()
