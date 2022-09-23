local Controls = class({
    name = "controls"
})

local btn_ctrl_scale = 0.25
local gap = 32
local alpha = 0.5

function Controls:new()
    self.enabled = true
    self.should_draw = true
    self.images = Assets.load_images("controls")
    self.objects = {}
    self.orders = {"btn_a", "btn_b", "btn_left", "btn_right"}
    self.alpha = 1
    self:load()

    Events.register(self, "start_battle")
    Events.register(self, "end_battle")
    Events.register(self, "on_dialogue_end")
end

function Controls:on_dialogue_end()
    self.enabled = false
end

function Controls:load()
    local b_width, b_height = self.images.btn_b:getDimensions()
    self.objects.btn_b = Sprite({
        image = self.images.btn_b,
        x = WW - b_width * btn_ctrl_scale * 0.5 - gap,
        y = WH - b_height * btn_ctrl_scale * 0.5 - gap * 0.5,
        sx = btn_ctrl_scale, sy = btn_ctrl_scale,
        ox = b_width * 0.5, oy = b_height * 0.5,
        is_hoverable = true, is_clickable = true,
        alpha = alpha,
    })

    local a_width, a_height = self.images.btn_a:getDimensions()
    self.objects.btn_a = Sprite({
        image = self.images.btn_a,
        x = self.objects.btn_b.x - a_width * btn_ctrl_scale * 0.5 - gap * 2,
        y = self.objects.btn_b.y,
        sx = btn_ctrl_scale, sy = btn_ctrl_scale,
        ox = a_width * 0.5, oy = a_height * 0.5,
        is_hoverable = true, is_clickable = true,
        alpha = alpha,
    })

    local l_width, l_height = self.images.btn_left:getDimensions()
    self.objects.btn_left = Sprite({
        image = self.images.btn_left,
        x = l_width * btn_ctrl_scale * 0.5 + gap,
        y = self.objects.btn_b.y,
        sx = btn_ctrl_scale, sy = btn_ctrl_scale,
        ox = l_width * 0.5, oy = l_height * 0.5,
        is_hoverable = true, is_clickable = true,
        alpha = alpha,
    })

    local r_width, r_height = self.images.btn_right:getDimensions()
    self.objects.btn_right = Sprite({
        image = self.images.btn_right,
        x = self.objects.btn_left.x + r_width * btn_ctrl_scale * 0.5 + gap * 2,
        y = self.objects.btn_left.y,
        sx = btn_ctrl_scale, sy = btn_ctrl_scale,
        ox = r_width * 0.5, oy = r_height * 0.5,
        is_hoverable = true, is_clickable = true,
        alpha = alpha,
    })

    self.objects.btn_a.on_clicked = function()
        Events.emit("on_clicked_a")
    end

    self.objects.btn_b.on_clicked = function()
        Events.emit("on_clicked_b")
    end

    self.objects.btn_left.on_down = function()
        Events.emit("on_down_left")
    end

    self.objects.btn_right.on_down = function()
        Events.emit("on_down_right")
    end
end

function Controls:start_battle()
    self.enabled = false
    self.alpha = 0
    for _, obj in pairs(self.objects) do obj.alpha = self.alpha end
end

function Controls:end_battle()
    self.enabled = true
    self.alpha = 1
    for _, obj in pairs(self.objects) do obj.alpha = self.alpha end
end

function Controls:update(dt)
    if not self.enabled then return end
    iter_objects(self.orders, self.objects, "update", dt)
end

function Controls:draw()
    if not self.should_draw then return end
    love.graphics.setColor(1, 1, 1, 1)
    iter_objects(self.orders, self.objects, "draw")
    love.graphics.setColor(1, 1, 1, 1)
end

function Controls:mousepressed(mx, my, mb)
    if not self.enabled then return end
    for _, key in ipairs(self.orders) do
        local btn = self.objects[key]
        if btn then
            local res = btn:mousepressed(mx, my, mb)
            if res then return end
        end
    end
end

function Controls:mousereleased(mx, my, mb)
    if not self.enabled then return end
    for _, key in ipairs(self.orders) do
        local btn = self.objects[key]
        if btn then
            local res = btn:mousereleased(mx, my, mb)
            if res then return end
        end
    end
end

return Controls
