local Game = class({
    name = "Game"
})

function Game:new(index)
    local id = self:type()
    local idn = string.lower(id) .. tostring(index)
    self.images = Assets.load_images(idn)
    self.ui = Assets.load_images("ui")
    self.controls = Controls()

    self.objects = {}
    self.orders = {
        "bg", "platform", "btn_pause",
        "box_bg", "box1", "box2"
    }

    Events.register(self, "on_clicked_a")
end

function Game:load()
    local bgw, bgh = self.images.bg:getDimensions()
    self.objects.bg = Sprite({
        image = self.images.bg,
        x = 0, y = 0,
        sx = WW/bgw, sy = WH/bgh,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
    })

    local padding = 64
    local bbw, bbh = self.ui.box_bg:getDimensions()
    local bbsx = (WW * 0.5)/bbw
    local bbsy = (WH - padding)/bbh
    local text = "PAGHAHANAP AT GAWAIN"
    local font = Assets.fonts.impact32
    self.objects.box_bg = Sprite({
        image = self.ui.box_bg,
        x = HALF_WW, y = HALF_WH,
        ox = bbw * 0.5, oy = bbh * 0.5,
        sx = bbsx, sy = bbsy,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        font = font, text = text,
        tox = font:getWidth(text) * 0.5,
        ty = HALF_WH - bbh * bbsy * 0.5 + padding,
        text_color = {0, 0, 0},
    })

    local bw, bh = self.ui.box:getDimensions()
    local font2 = Assets.fonts.impact20
    local text2 = "Talunin lahat ng kalaban"
    self.objects.box1 = Sprite({
        image = self.ui.box,
        x = HALF_WW - padding * 2.5,
        y = HALF_WH - padding,
        ox = bw * 0.5, oy = bh * 0.5,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        font = font2, text = text2,
        tx = self.objects.box_bg.x - padding * 2,
        toy = font2:getHeight() * 0.5,
        text_color = {0, 0, 0},
    })

    local text3 = "Tagpuin ang matandang ermitanyo"
    self.objects.box2 = Sprite({
        image = self.ui.box,
        x = self.objects.box1.x,
        y = self.objects.box1.y + padding * 2,
        ox = bw * 0.5, oy = bh * 0.5,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        font = font2, text = text3,
        tx = self.objects.box1.tx,
        toy = font2:getHeight() * 0.5,
        text_color = {0, 0, 0},
    })

    self.group_guide = {self.objects.box_bg, self.objects.box1, self.objects.box2}

    local p_width, p_height = self.images.platform:getDimensions()
    self.objects.platform = Sprite({
        image = self.images.platform,
        x = 0, y = WH - p_height,
        sx = WW/p_width,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        height = p_height,
    })

    local pause_w, pause_h = self.ui.pause:getDimensions()
    self.objects.btn_pause = Sprite({
        image = self.ui.pause,
        x = WW - pause_w * 0.5 - padding * 0.25,
        y = pause_h * 0.5 + padding * 0.25,
        ox = pause_w * 0.5, oy = pause_h * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0,
    })

    self.player = Player(WW * 0.15, self.objects.platform.y)
    self.player.dir = -1
    self.player.can_move = false
end

function Game:on_clicked_a()
    if self.objects.box_bg.alpha ~= 0 then
        for _, obj in ipairs(self.group_guide) do
            obj.alpha = 0
        end
        local btn_pause = self.objects.btn_pause
        btn_pause.alpha = 1
        btn_pause.is_hoverable = true
        btn_pause.is_clickable = true
        self.player.can_move = true
        Events.remove(self, "on_clicked_a")
        return true
    end
end

function Game:update(dt)
    self.controls:update(dt)
    iter_objects(self.orders, self.objects, "update", dt)
    self.player:update(dt, self.objects.platform.height)
end

function Game:draw()
    love.graphics.setColor(1, 1, 1, 1)
    iter_objects(self.orders, self.objects, "draw")
    self.player:draw()
    self.controls:draw()
    love.graphics.setColor(1, 1, 1, 1)
end

function Game:mousepressed(mx, my, mb)
    self.controls:mousepressed(mx, my, mb)
end

function Game:mousereleased(mx, my, mb)
    self.controls:mousereleased(mx, my, mb)
end

function Game:exit()
    Events.clear()
end

return Game
