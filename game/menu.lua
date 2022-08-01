local Menu = class({
    name = "menu"
})

function Menu:new()
    local id = self:type()
    self.images = Assets.load_images(id)
end

function Menu:load()

end

function Menu:update(dt)
end

function Menu:draw()
    local bg_w, bg_h = self.images.bg:getDimensions()
    local bg_sx, bg_sy = WW/bg_w, WH/bg_h
    love.graphics.draw(self.images.bg, 0, 0, 0, bg_sx, bg_sy)
end

function Menu:mousepressed(mx, my, mb)
end

function Menu:mousereleased(mx, my, mb)
end

function Menu:mousemoved(mx, my, dmx, dmy, istouch)
end

function Menu:mousefocus(focus)
end

function Menu:exit()
end

return Menu
