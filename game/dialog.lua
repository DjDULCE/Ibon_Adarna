local Dialog = class({
    name = "Dialog"
})

local padding = 64

function Dialog:new(opt)
    self.x = opt.x
    self.y = opt.y
    self.w = opt.w or WW
    self.h = WH * 0.4
    self.align = opt.align or "center"
    self.sx = opt.sx or 1
    self.sy = opt.sy or 1
    self.font = opt.font
    self.text = opt.text
    self.alpha = opt.alpha or 1
    self.color = opt.color or {1, 1, 1}
    self.speed = opt.speed or 0.1

    self.dt = 0
    self.t = 1
    self.skipped = false

    if opt.auto then
        local width, wrapped_texts = self.font:getWrap(self.text, self.w)
        self.x = HALF_WW - width * 0.5
        self.y = WH - self.font:getHeight() * #wrapped_texts
    end

    self.images = Assets.load_images("dialog")

    Events.register(self, "on_clicked_a")
end

function Dialog:update(dt)
    if self.skipped then return end
    self.dt = math.min(self.t, self.dt + dt * self.speed)
end

function Dialog:draw()
    local r, g, b = unpack(self.color)
    love.graphics.setColor(r, g, b, self.alpha)

    local bg_w, bg_h = self.images.bg:getDimensions()
    local bg_sx = (self.w + padding)/bg_w
    local bg_sy = (self.h + padding)/bg_h
    local bg_x = self.x + self.w * 0.5
    local bg_y = self.y + self.h * 0.5
    love.graphics.draw(self.images.bg, bg_x, bg_y, 0, bg_sx, bg_sy, bg_w * 0.5, bg_h * 0.5)

    love.graphics.setFont(self.font)
    reflowprint(self.dt/self.t, self.text, self.x, self.y, self.w, self.align, self.sx, self.sy)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function Dialog:on_clicked_a()
    if not self.skipped then
        self.dt = self.dt + 1000
        self.skipped = true
    end
end

return Dialog
