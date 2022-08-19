local Scene = class({
    name = "scene"
})

function Scene:new(index)
    assert(index and type(index) == "number" and index > 0)
    local id = self:type()
    local idn = id .. tostring(index)
    self.images = Assets.load_images(idn)
    self.controls = Controls(self)

    self.objects = {}
    self.orders = {"platform"}
end

function Scene:load()
    local p_width, p_height = self.images.platform:getDimensions()
    self.platform = {
        image = self.images.platform,
        x = 0, y = WH - p_height,
        sx = WW/p_width,
        height = p_height,
    }

    self.player = Player(HALF_WW, self.platform.y)
end

function Scene:update(dt)
    self.controls:update(dt)
    iter_objects(self.orders, self.objects, "update", dt)
    self.player:update(dt, self.platform.height)
end

function Scene:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local w, h = self.images.bg:getDimensions()
    local sx = w/WW
    local sy = h/WH
    love.graphics.draw(self.images.bg, 0, 0, 0, sx, sy)

    local platform = self.platform
    love.graphics.draw(platform.image, platform.x, platform.y, 0, platform.sx)

    self.player:draw()

    iter_objects(self.orders, self.objects, "draw")

    self.controls:draw()
end

function Scene:mousepressed(mx, my, mb)
    self.controls:mousepressed(mx, my, mb)
end

function Scene:mousereleased(mx, my, mb)
    self.controls:mousereleased(mx, my, mb)
end

function Scene:exit()
    Events.clear()
end

return Scene
