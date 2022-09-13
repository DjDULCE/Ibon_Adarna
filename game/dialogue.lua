local Dialogue = class({
    name = "Dialogue"
})

local padding = 32

function Dialogue:new(opt)
    self.images = Assets.load_images("dialogue")
    self.faces = Assets.load_images("faces")

    self.enabled = not not opt.enabled
    self.repeating = opt.repeating

    self.data = opt.data
    self.current = 1
    self.text_index = 0

    self.w = opt.w or WW * 0.6
    self.bg_w = WW * 0.85
    self.h = WH * 0.3
    self.align = opt.align or "center"
    self.font = opt.font
    self.alpha = opt.alpha or 1
    self.color = opt.color or {1, 1, 1}
    self.speed = opt.speed or 1

    self.y = WH - self.font:getHeight() * 6 - padding * 0.25

    local bg_w, bg_h = self.images.bg:getDimensions()
    self.bg = {
        x = HALF_WW,
        y = self.y + self.h * 0.5,
        sx = (self.bg_w + padding * 1.5)/bg_w,
        sy = (self.h + padding * 1.5)/bg_h,
        ox = bg_w * 0.5,
        oy = bg_h * 0.5,
    }

    Events.register(self, "on_down_left")
    Events.register(self, "on_down_right")
    Events.register(self, "on_clicked_a")
    Events.register(self, "on_clicked_b")
    Events.register(self, "on_dialogue_show")

    if self.enabled then
        self:show()
    end
end

function Dialogue:on_dialogue_show()
    self.enabled = true
    self:show()
end

function Dialogue:show()
    if not self.enabled then return end
    local data = self.data[self.current]
    if not data then
        self.enabled = false
        Events.emit("on_dialogue_end")

        if self.repeating then
            self.current = 1
            self.text_index = 0
        end
        return
    end

    self.text_index = self.text_index + 1
    if self.text_index > #data then
        self.current = self.current + 1
        self.text_index = 0
        self:show()
        return
    end

    local next_text = data[self.text_index]
    if not next_text then return end

    self.text = next_text
    self.dt = 0
    self.t = 1
    self.skipped = false

    local face
    if data.name == "Don Juan" then
        face = "player"
    elseif data.name == "Don Fernando" then
        face = "fernando"
    elseif data.name == "Ermitanyo" then
        face = "ermitanyo"
    end

    local face_image = self.faces[face]
    local fw, fh = face_image:getDimensions()
    self.face = face_image
    self.fy = self.y + fh * 0.5
    self.fox = fw * 0.5
    self.foy = fh * 0.5

    if data.side == "left" then
        self.fx = self.bg.x - self.bg.ox + fw + padding
        self.x = self.fx + fw * 0.5 + padding
        self.fsx = 1
    elseif data.side == "right" then
        self.x = self.bg.x - self.bg.ox + fw * 0.5 + padding
        self.fx = self.x + self.w + fw * 0.5 + padding
        self.fsx = -1
    end
end

function Dialogue:update(dt)
    if not self.enabled then return end
    if self.skipped then return end
    self.dt = math.min(self.t, self.dt + dt * self.speed)
end

function Dialogue:draw()
    if not self.enabled then return end
    local r, g, b = unpack(self.color)
    love.graphics.setColor(r, g, b, self.alpha)

    love.graphics.draw(
        self.images.bg,
        self.bg.x, self.bg.y, 0,
        self.bg.sx, self.bg.sy,
        self.bg.ox, self.bg.oy
    )

    love.graphics.draw(self.face, self.fx, self.fy, 0, self.fsx, 1, self.fox, self.foy)

    love.graphics.setFont(self.font)
    reflowprint(self.dt/self.t, self.text, self.x, self.y, self.w, self.align)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    -- love.graphics.rectangle("line", self.fx, self.fy, self.face:getDimensions())
    love.graphics.setColor(1, 1, 1, 1)
end

function Dialogue:on_clicked_a()
    if not self.enabled then return end
    if self.dt >= self.t then
        self:show()
        return true
    end
    if not self.skipped then
        self.dt = self.dt + 1000
        self.skipped = true
        return true
    end
    return true
end

function Dialogue:on_down_left() if self.enabled then return true end end
function Dialogue:on_down_right() if self.enabled then return true end end

return Dialogue
