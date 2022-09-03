local Game = class({
    name = "Game"
})

local enemies = {"wolf", "snake", "boar", "spider"}
local icon_scale = 0.2

function Game:new(index)
    local id = self:type()
    local idn = string.lower(id) .. tostring(index)
    self.images = Assets.load_images(idn)
    self.ui = Assets.load_images("ui")
    self.controls = Controls()

    self.total_meters = 1000
    self.current_meter = 0
    self.pacing = 64
    self.current_enemy = 1

    self.in_battle = false

    self.objects = {}
    self.orders = {
        "bg", "platform", "btn_pause",
        "bar", "icon_player",
        "question_bg", "choice_a", "choice_b", "choice_c",
        "box_bg", "box1", "box2",
    }

    local i = tablex.index_of(self.orders, "icon_player")
    for _, str in ipairs(enemies) do
        table.insert(self.orders, i, "icon_" .. str)
    end

    Events.register(self, "on_clicked_a")
    Events.register(self, "start_battle")
    Events.register(self, "end_battle")
end

function Game:load()
    local bgw, bgh = self.images.bg:getDimensions()
    self.objects.bg = Sprite({
        image = self.images.bg,
        x = 0, y = 0,
        sx = WW/bgw, sy = WH/bgh,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        parallax_x = true,
        speed = 64,
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
    local p_scale = 3
    self.objects.platform = Sprite({
        image = self.images.platform,
        x = 0, y = WH - p_height * p_scale,
        sx = WW/p_width, sy = p_scale,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        height = p_height * p_scale,
        parallax_x = true,
        speed = 128,
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

    local bar_w, bar_h = self.ui.bar:getDimensions()
    local bar_sx = (WW * 0.7)/bar_w
    local bar_sy = 1
    self.objects.bar = Sprite({
        image = self.ui.bar,
        x = HALF_WW,
        y = self.objects.platform.y + p_height * p_scale * 0.5 - 4,
        ox = bar_w * 0.5, oy = bar_h * 0.5,
        sx = bar_sx, sy = bar_sy,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
    })

    local obj_bar = self.objects.bar
    local spacing = (bar_w * bar_sx)/(#enemies + 2)
    local offset = bar_w * bar_sx * 0.25
    for i, str in ipairs(enemies) do
        local key = "icon_" .. str
        local w, h = self.ui[key]:getDimensions()
        self.objects[key] = Sprite({
            image = self.ui[key],
            x = obj_bar.x - bar_w * bar_sx * 0.5 + spacing * (i - 1) + offset,
            y = obj_bar.y,
            ox = w * 0.5, oy = h * 0.5,
            sx = icon_scale, sy = icon_scale,
            is_hoverable = false, is_clickable = false,
            force_non_interactive = true,
        })
    end

    local ipw, iph = self.ui.icon_player:getDimensions()
    self.objects.icon_player = Sprite({
        image = self.ui.icon_player,
        x = obj_bar.x - bar_w * bar_sx * 0.5 + ipw * icon_scale,
        y = obj_bar.y,
        ox = ipw * 0.5, oy = iph * 0.5,
        sx = icon_scale, sy = icon_scale,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
    })

    local qbg_w, qbg_h = self.ui.question_bg:getDimensions()
    local bg_sx = (WW * 0.85)/qbg_w
    local bg_sy = (p_height * p_scale)/qbg_h
    self.objects.question_bg = Sprite({
        image = self.ui.question_bg,
        x = HALF_WW,
        y = self.objects.platform.y + p_height * p_scale * 0.5,
        ox = qbg_w * 0.5, oy = qbg_h * 0.5,
        sx = bg_sx, sy = bg_sy,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        alpha = 0,
        font = Assets.fonts.impact20,
        text_color = {0, 0, 0},
        is_printf = true, align = "center",
        limit = qbg_w * 0.8,
    })

    self.player = Player(WW * 0.2, self.objects.platform.y)
    self.player.dir = -1
    self.player.can_move = false
    self.player.fake_move = true

    Events.register(self, "on_player_move_x")
end

function Game:on_player_move_x(dir, dt)
    if self.in_battle then return end
    if not self.player.can_move then return end
    self.current_meter = self.current_meter + self.pacing * dt * dir
    self.player.current_meter = self.current_meter
    if self.current_meter < 0 then
        self.current_meter = 0
    elseif self.current_meter > self.total_meters then
        self.current_meter = self.total_meters
    end

    local obj_bar = self.objects.bar
    local progress = self.current_meter/self.total_meters
    local w = (obj_bar.width - 128) * obj_bar.sx
    local n = progress * w
    local obj_ip = self.objects.icon_player
    obj_ip.x = obj_ip.orig_x + n

    local allowance = 36
    local e = 256 * icon_scale * 0.5
    local target = (math.floor(self.total_meters/#enemies) * self.current_enemy) - e

    if self.current_meter >= (target - allowance) then
        self:show_enemy(enemies[self.current_enemy])
    end

    if self.current_meter >= (target - allowance * 0.5) then
        self.player.can_move = false
    end
end

function Game:on_clicked_a()
    if self.objects.box_bg.alpha == 0 then return end
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

function Game:show_enemy(enemy_name)
    local ew, eh = self.images[enemy_name]:getDimensions()
    local esx, esy = 1, 1
    self.enemy = Enemy(enemy_name, {
        image = self.images[enemy_name],
        x = WW + ew * esx,
        y = WH - self.objects.platform.height - eh * esy * 0.5,
        ox = ew * 0.5, oy = eh * 0.5,
        sx = esx, sy = esy,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
    })
end

function Game:start_battle(obj_enemy)
    self.in_battle = true

    local obj_question = self.objects.question_bg
    obj_question.alpha = 1

    local data = require("data." .. obj_enemy.name)
    local question = tablex.pick_random(data)
    local w, h = obj_question.image:getDimensions()
    obj_question.text = question.question
    obj_question.tx = obj_question.x - w * obj_question.sx * 0.5
    obj_question.ty = obj_question.y - h * obj_question.sy * 0.5 + 8
end

function Game:end_battle()
    self.in_battle = false
    self.current_enemy = self.current_enemy + 1
end

function Game:update(dt)
    self.controls:update(dt)
    iter_objects(self.orders, self.objects, "update", dt)
    self.player:update(dt, self.objects.platform.height)
    if self.enemy then self.enemy:update(dt) end
end

function Game:draw()
    love.graphics.setColor(1, 1, 1, 1)
    iter_objects(self.orders, self.objects, "draw")
    self.player:draw()
    if self.enemy then self.enemy:draw() end
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
