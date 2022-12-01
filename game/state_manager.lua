local StateManager = {
    current = nil
}

function StateManager:switch(next_state, ...)
    if self.current.exit then
        self.current:exit()
    end

    self.current = next_state(...)

    print("Switched to", t)
    if string.lower(self.current:type()) ~= "menu" then
        UserData.data.last_id = string.lower(self.current:type())
        UserData:save()
    end

    self.current:load(...)
end

function StateManager:load(...)
    self.current:load(...)
    print("Loaded", self.current:type())
end

function StateManager:update(dt)
    self.current:update(dt)

    if self.current.orders then
        for _, key in ipairs(self.current.orders) do
            local obj = self.current.objects[key]
            if obj and obj.sound then
                obj.sound:setVolume(UserData.data.sound * 0.5)
            end
        end
    end
    if self.current.sources then
        self.current.sources.bgm:setVolume(UserData.data.music * 0.5)
    end
end

function StateManager:draw()
    self.current:draw()
end

function StateManager:mousepressed(mx, my, mb)
    if self.current.mousepressed then
        self.current:mousepressed(mx, my, mb)
    end
end

function StateManager:mousereleased(mx, my, mb)
    if self.current.mousereleased then
        self.current:mousereleased(mx, my, mb)
    end
end

function StateManager:mousemoved(mx, my, dmx, dmy, istouch)
    if self.current.mousemoved then
        self.current:mousemoved(mx, my, dmx, dmy, istouch)
    end
end

function StateManager:keypressed(key)
    if self.current.keypressed then
        self.current:keypressed(key)
    end
end

function StateManager:textinput(text)
    if self.current.textinput then
        self.current:textinput(text)
    end
end

function StateManager:mousefocus(focus)
    if self.current.mousefocus then
        self.current:mousefocus(focus)
    end
end

return StateManager
