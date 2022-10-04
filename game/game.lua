local Game = class({
    name = "Game",
})

local enemies = {
    { "wolf", "snake", "boar", "spider" },
    { "boar", "eagle", "snake", "adarna" },
    { "spider", "bat", "giant", "serpent" },
    { "crow", "lion", "snake", "boar" },
    { "wolf", "eagle", "snake", "salermo" },
}
local additional_objs = {
    {},
    { "don_pedro", "don_diego", "ermitanyo", "statue1", "statue2", "tree", },
    { "juana", "leonora", },
    { "maria", },
    { "maria", "salermo2", },
}

local choices = { "a", "b", "c" }
local icon_scale = 0.2

local tasks = {
    {
        "Talunin lahat ng kalaban",
        "Tagpuin ang matandang ermitanyo",
    },
    {
        "Talunin lahat ng kalaban",
        "Tagpuin at talunin ang Ibong Adarna",
    },
    {
        "Talunin lahat ng kalaban, Higante at ang Serpyente",
        "Tagpuin ang dalawang prinsesa",
    },
    {
        "Talunin lahat ng kalaban",
        "Tagpuin ang si Prinsesa Maria",
    },
    {
        "Talunin lahat ng kalaban",
        "Talunin si Haring Salermo",
    },
}

if DEV then
    if #enemies ~= # additional_objs or #enemies ~= #tasks then
        error("mismatch tables lengths")
    end
end

local enemy_float = {
    crow = 36,
    eagle = 36,
}

function Game:new(index)
    print("game", index)
    UserData.data.stage = index
    UserData:save()
    local id = string.lower(self:type())
    local idn = id .. tostring(index)
    self.images = Assets.load_images(idn)
    self.ui = Assets.load_images("ui")
    self.sources = Assets.load_sources(id)
    self.controls = Controls()
    self.difficulty = UserData.data.difficulty
    self.index = index

    self.total_meters = 1000
    self.current_meter = 0
    self.pacing = DEV and 512 or 64
    self.current_enemy = 1
    self.fade_alpha = 0

    self.in_battle = false

    self.objects = {}
    self.orders = {
        "bg", "platform", "btn_pause",
        "bar", "icon_player",
        "question_bg", "choice_a", "choice_b", "choice_c",
        "box_bg", "box1", "box2",
    }

    local i = tablex.index_of(self.orders, "icon_player")
    for _, str in ipairs(enemies[self.index]) do
        table.insert(self.orders, i, "icon_" .. str)
    end

    local i2 = tablex.index_of(self.orders, "platform")
    for _, str in ipairs(additional_objs[self.index]) do
        table.insert(self.orders, i2, str)
    end

    self.damage_text = {
        font = Assets.fonts.impact24,
        color = { 1, 0, 0, 1 },
        x = -100, y = -100,
        text = "0"
    }

    self.dialogue = Dialogue({
        id = "end_dialogue" .. self.index,
        font = Assets.fonts.impact24,
        data = require("data.end_dialogue" .. self.index),
        align = "left",
        repeating = false,
        enabled = false,
    })

    if self.index == 2 then
        self.prologue = Dialogue({
            id = "prologue" .. self.index,
            font = Assets.fonts.impact24,
            data = require("data.prologue" .. self.index),
            align = "center",
            repeating = false,
            enabled = false,
            simple = true,
        })
    end

    Events.register(self, "on_clicked_a")
    Events.register(self, "start_battle")
    Events.register(self, "end_battle")
    Events.register(self, "post_battle")
    Events.register(self, "display_damage")
    Events.register(self, "finished_turn")
    Events.register(self, "on_dialogue_end")
end

function Game:load()
    self.sources.bgm:play()
    self.sources.bgm:setLooping(true)

    local bgw, bgh = self.images.bg:getDimensions()
    self.objects.bg = Sprite({
        image = self.images.bg,
        x = 0, y = 0,
        sx = WW / bgw, sy = WH / bgh,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        -- parallax_x = true,
        speed = 64,
    })

    local padding = 64
    local bbw, bbh = self.ui.box_bg:getDimensions()
    local bbsx = (WW * 0.5) / bbw
    local bbsy = (WH - padding) / bbh
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
        text_color = { 0, 0, 0 },
    })

    local bw, bh = self.ui.box:getDimensions()
    local font2 = Assets.fonts.impact20
    local text2 = tasks[self.index][1]
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
        text_color = { 0, 0, 0 },
    })

    local text3 = tasks[self.index][2]
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
        text_color = { 0, 0, 0 },
    })

    self.group_guide = { self.objects.box_bg, self.objects.box1, self.objects.box2 }

    local p_width, p_height = self.images.platform:getDimensions()
    local p_scale = 3
    self.objects.platform = Sprite({
        image = self.images.platform,
        x = 0, y = WH - p_height * p_scale,
        sx = WW / p_width, sy = p_scale,
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
    local bar_sx = (WW * 0.7) / bar_w
    local bar_sy = 0.9
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
    local spacing = (bar_w * bar_sx) / (#enemies[self.index] + 2)
    local offset = bar_w * bar_sx * 0.25
    for i, str in ipairs(enemies[self.index]) do
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
    local bg_sx = (WW * 0.85) / qbg_w
    local bg_sy = (p_height * p_scale) / qbg_h
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
        text_color = { 0, 0, 0 },
        is_printf = true, align = "center",
        limit = qbg_w * 0.8,
    })

    if self.index == 2 then
        self:load_stage2()
    end

    self.player = Player(WW * 0.2, self.objects.platform.y)
    self.player.dir = -1
    self.player.can_move = false
    self.player.fake_move = true

    Events.register(self, "on_player_move_x")
end

function Game:load_stage2()
    local tw, th = self.images.tree:getDimensions()
    local ts = 0.75
    self.objects.tree = Sprite({
        image = self.images.tree,
        x = WW * 1.5,
        y = self.objects.platform.y - th * 0.35 * ts,
        sx = ts, sy = ts,
        ox = tw * 0.5, oy = th * 0.5,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
    })
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
    local progress = self.current_meter / self.total_meters
    local w = (obj_bar.width - 128) * obj_bar.sx
    local n = progress * w
    local obj_ip = self.objects.icon_player
    obj_ip.x = obj_ip.orig_x + n

    local key_enemy = enemies[self.index][self.current_enemy]
    if key_enemy then
        local ip = self.objects.icon_player
        local ep = self.objects["icon_" .. key_enemy]

        if self.index == 3 and ip.x >= (ep.x - 64) then
            if key_enemy == "giant" and (not self.objects.juana) then
                self:show_other("juana")
                self.player.can_move = false
            elseif key_enemy == "serpent" and (not self.objects.leonora) then
                self:show_other("leonora")
                self.player.can_move = false
            end
        end

        if (not self.enemy) and (ip.x >= (ep.x - 36)) then
            self:show_enemy(enemies[self.index][self.current_enemy])
        end

        if ip.x >= ep.x then
            self.player.can_move = false
        end
    elseif self.current_meter >= self.total_meters then
        if self.index ~= 4 then
            self.player.can_move = false
            self.player.anim:gotoFrame(1)
        end

        if self.index == 1 then
            self.dialogue_timer = timer(2, nil, function()
                Events.emit("on_dialogue_show")
                self.dialogue_timer = nil
            end)
        elseif self.index == 4 and not self.objects.maria then
            self.player.can_move = false
            self.player.anim:gotoFrame(1)
            self:show_other("maria")
        end
    end
end

function Game:on_dialogue_end(obj_dialogue)
    self.controls.enabled = false
    print("Finished", obj_dialogue.id)

    if self.index == 2 then
        local res = self:handle_prologue_2(obj_dialogue)
        if res then return end
    elseif self.index == 3 then
        if obj_dialogue == self.enemy_dialogue then
            self.enemy_dialogue = nil
            Events.emit("start_battle", self.enemy)
            return
        elseif obj_dialogue == self.other_dialogue then
            if self.other_dialogue.id == "other_dialogue_juana" then
                self.other_dialogue = nil
                self.player.dir = 1
                self.player.fake_move2 = false
                local obj_juana = self.objects.juana
                obj_juana.sx = -1
                obj_juana.not_look = true
                local orig_x = obj_juana.x
                local orig_px = self.player.x
                self.player_go_timer = timer(3,
                    function(progress)
                        obj_juana.x = mathx.lerp(orig_x, -64, progress)
                        self.player.x = mathx.lerp(orig_px, WW * 0.2, progress)
                        self.player.notif.alpha = 0
                        self.player.anim:resume()
                        self.player.anim:update(love.timer.getDelta())
                    end,
                    function()
                        self.player.anim:gotoFrame(1)
                        self.player.dir = -1
                        self.objects.juana.collider = nil
                        self.player_go_timer = nil
                        self.player.fake_move = true
                        self.controls.enabled = true
                        self.in_battle = false
                    end
                )
                return
            elseif self.other_dialogue.id == "other_dialogue_leonora" then
                self.other_dialogue = nil
                self:goto_next("scenario")
                return
            end
        end
    elseif self.index == 4 then
        self.player.can_move = false
        self.controls.should_draw = false
        self.other_dialogue = nil
        self:goto_next("scene")
        return
    elseif self.index == 5 then
        self.player.can_move = false
        self.controls.should_draw = false
        self.other_dialogue = nil
        self:goto_next("scenario")
        return
    end

    if self.index == 1 then
        self:goto_next("scene")
    elseif self.index == 2 then
        self:goto_next("scenario")
    end
end

function Game:handle_prologue_2(obj_dialogue)
    if obj_dialogue.id == "end_dialogue2b" then return end

    if obj_dialogue.id == "prologue2" then
        self.player.x = WW * 0.55
        local ew, eh = self.images.ermitanyo:getDimensions()
        self.objects.ermitanyo = Sprite({
            image = self.images.ermitanyo,
            x = WW * 0.6,
            y = self.objects.platform.y - eh * 0.5,
            sx = -1, sy = 1,
            ox = ew * 0.5, oy = eh * 0.5,
            force_non_interactive = true,
            is_clickable = false, is_hoverable = false,
        })

        local sw, sh = self.images.statue:getDimensions()
        self.objects.statue1 = Sprite({
            image = self.images.statue,
            x = WW * 0.65,
            y = self.objects.platform.y - sh * 0.5,
            sx = 1, sy = 1,
            ox = sw * 0.5, oy = sh * 0.5,
            force_non_interactive = true,
            is_clickable = false, is_hoverable = false,
        })

        self.objects.statue2 = Sprite({
            image = self.images.statue,
            x = self.objects.statue1.x + sw * 0.5 + 8,
            y = self.objects.platform.y - sh * 0.5,
            sx = 1, sy = 1,
            ox = sw * 0.5, oy = sh * 0.5,
            force_non_interactive = true,
            is_clickable = false, is_hoverable = false,
        })

        self.controls.enabled = true
        self.objects.bar.alpha = 0
        self.objects.icon_player.alpha = 0
        for _, str in ipairs(enemies[self.index]) do self.objects["icon_" .. str].alpha = 0 end
        self.fade_timer = timer(1,
            function(progress) self.fade_alpha = 1 - progress end,
            function()
                self.fade_timer = nil
                Events.emit("on_dialogue_show", self.dialogue)
            end)
    elseif obj_dialogue.id == "prologue2b" then
        self.controls.enabled = true
        self.objects.statue1 = nil
        self.objects.statue2 = nil

        local ddw, ddh = self.images.don_diego:getDimensions()
        self.objects.don_diego = Sprite({
            image = self.images.don_diego,
            x = WW * 0.65,
            y = self.objects.platform.y - ddh * 0.5,
            sx = -1, sy = 1,
            ox = ddw * 0.5, oy = ddh * 0.5,
            force_non_interactive = true,
            is_clickable = false, is_hoverable = false,
        })

        local dpw, dph = self.images.don_pedro:getDimensions()
        self.objects.don_pedro = Sprite({
            image = self.images.don_pedro,
            x = WW * 0.68,
            y = self.objects.platform.y - dph * 0.5,
            sx = -1, sy = 1,
            ox = dpw * 0.5, oy = dph * 0.5,
            force_non_interactive = true,
            is_clickable = false, is_hoverable = false,
        })

        self.dialogue = Dialogue({
            id = "end_dialogue" .. self.index .. "b",
            font = Assets.fonts.impact24,
            data = require("data.end_dialogue" .. self.index .. "b"),
            align = "left",
            repeating = false,
            enabled = false,
        })
        self.fade_timer = timer(1,
            function(progress) self.fade_alpha = 1 - progress end,
            function()
                self.fade_timer = nil
                self.wait_timer = timer(1, nil, function()
                    Events.emit("on_dialogue_show", self.dialogue)
                end)
            end)
    elseif obj_dialogue.id == "end_dialogue2" then
        self.controls.enabled = true
        self.prologue = Dialogue({
            id = "prologue" .. self.index .. "b",
            font = Assets.fonts.impact24,
            data = require("data.prologue" .. self.index .. "b"),
            align = "center",
            repeating = false,
            enabled = false,
            simple = true,
        })
        self.fade_timer = timer(1,
            function(progress) self.fade_alpha = progress end,
            function()
                self.fade_timer = nil
                self.wait_timer = timer(1, nil, function()
                    Events.emit("on_dialogue_show", self.prologue)
                end)
            end)
    end
    return true
end

function Game:on_clicked_a()
    if self.objects.box_bg.alpha == 0 then return end
    for _, obj in ipairs(self.group_guide) do obj.alpha = 0 end

    if self.end_tasks_shown then
        self:goto_next(self.end_tasks_shown, true)
        Events.remove(self, "on_clicked_a")
        return true
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
    print("showing enemy:", enemy_name)
    local ew, eh = self.images[enemy_name]:getDimensions()
    local esx, esy = 1, 1
    local oy = enemy_float[enemy_name] or 0

    self.enemy = Enemy(enemy_name, {
        image = self.images[enemy_name],
        x = WW + ew * esx,
        y = WH - self.objects.platform.height - eh * esy * 0.5 - oy,
        ox = ew * 0.5, oy = eh * 0.5,
        sx = esx, sy = esy,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
    }, {
        heart = self.ui.heart,
        icon = self.ui["icon_" .. enemy_name],
    })

    if enemy_name == "adarna" then
        local obj_tree = self.objects.tree
        local tx = WW * 0.7
        local orig_x = obj_tree.x
        self.tree_timer = timer(1,
            function(tree_progress)
                obj_tree.x = mathx.lerp(orig_x, tx, tree_progress)
            end,
            function()
                self.tree_timer = nil
            end
        )
    elseif enemy_name == "giant" or enemy_name == "serpent" then
        self.enemy_dialogue = Dialogue({
            id = "enemy_dialogue_" .. enemy_name,
            font = Assets.fonts.impact24,
            data = require("data.enemy_dialogue_" .. enemy_name),
            align = "left",
            repeating = false,
            enabled = false,
        })
        self.enemy.dialogue = self.enemy_dialogue
    end
end

function Game:show_other(name)
    print("showing other:", name)
    local ow, oh = self.images[name]:getDimensions()
    local osx, osy = -1, 1
    self.objects[name] = Sprite({
        image = self.images[name],
        x = WW * 1.5 + ow * osx * 0.5,
        y = WH - self.objects.platform.height - oh * osy * 0.5,
        ox = ow * 0.5, oy = oh * 0.5,
        sx = osx, sy = osy,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        collider = {
            w = 24,
            h = 49,
            origin = "center"
        }
    })

    local tx = WW * 0.85
    local orig_x = self.objects[name].x
    self.show_timer = timer(1,
        function(progress)
            self.objects[name].x = mathx.lerp(orig_x, tx, progress)
        end,
        function()
            self.show_timer = nil
            self.player.can_move = true

            if self.index == 4 then
                self.player.fake_move2 = true
                self.player.fake_move = false
            end
        end
    )

    if name == "juana" or name == "leonora" then
        self.other_dialogue = Dialogue({
            id = "other_dialogue_" .. name,
            font = Assets.fonts.impact24,
            data = require("data.other_dialogue_" .. name),
            align = "left",
            repeating = false,
            enabled = false,
        })
        self.objects[name].dialogue = self.other_dialogue
    end
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
    obj_question.ty = obj_question.y - h * obj_question.sy * 0.5 + 16

    local font = Assets.fonts.impact18
    local offset = font:getWidth(" ") * 0.5
    local img_choice = self.ui.btn_choice
    local icw, ich = img_choice:getDimensions()
    local choice_scale = 0.5
    local bx = obj_question.x - w * obj_question.sx * 0.5 + 48 + icw * choice_scale * 0.5
    local last_str = ""
    for i, letter in ipairs(choices) do
        local key = "choice_" .. letter
        local str2 = string.format("%s       %s", string.upper(letter), question[letter])
        local ii = i - 1
        local x = bx + (font:getWidth(last_str) * ii) + (64 * ii)
        if i > 2 then x = x - 32 end
        self.objects[key] = Sprite({
            image = img_choice,
            x = x, y = obj_question.y + h * obj_question.sy * 0.5 - 48,
            ox = icw * 0.5, oy = ich * 0.5,
            sx = choice_scale, sy = choice_scale,
            font = font,
            text = str2,
            tx = x - offset * 2,
            toy = font:getHeight() * 0.5,
            text_color = { 0, 0, 0 },
            collision_include_text = true,
        })
        last_str = str2

        self.objects[key].on_clicked = function()
            print("Answered", letter, question.answer == letter)
            if question.answer == letter then
                Events.emit("start_attack")
            else
                Events.emit("enemy_start_attack")
            end

            for _, letter2 in ipairs(choices) do
                local key2 = "choice_" .. letter2
                self.objects[key2].is_hoverable = false
                self.objects[key2].is_clickable = false
            end
        end
    end
end

function Game:finished_turn()
    if not self.enemy then return end
    if self.enemy.health <= 0 then return end
    for _, letter in ipairs(choices) do
        local key = "choice_" .. letter
        self.objects[key].is_hoverable = true
        self.objects[key].is_clickable = true
    end
    self:start_battle(self.enemy)
end

function Game:end_battle()
    self.in_battle = false
    self.current_enemy = self.current_enemy + 1
    local obj_question = self.objects.question_bg
    obj_question.alpha = 0
    obj_question.text = ""
    for _, letter in ipairs(choices) do
        local key = "choice_" .. letter
        self.objects[key] = nil
    end
    self.enemy = nil
end

function Game:post_battle(enemy_name)
    if enemy_name == "adarna" then
        self.player.can_move = false
        self.player.show_health = false
        self.fade_timer = timer(1,
            function(progress)
                self.fade_alpha = progress
            end,
            function()
                self.fade_timer = nil
                self.wait_timer = timer(1, nil, function()
                    Events.emit("on_dialogue_show", self.prologue)
                end)
            end
        )
    elseif enemy_name == "giant" or enemy_name == "serpent" then
        self.player.can_move = true
        self.player.fake_move2 = true
        self.player.show_health = true
    elseif enemy_name == "salermo" then
        self.player.can_move = false
        self.player.fake_move2 = false
        self.player.show_health = false
        self.fade_timer = timer(1,
            function(progress)
                self.fade_alpha = progress
            end,
            function()
                local ow, oh = self.images.maria:getDimensions()
                local osx, osy = -1, 1
                self.objects.maria = Sprite({
                    image = self.images.maria,
                    x = WW * 0.5,
                    y = WH - self.objects.platform.height - oh * osy * 0.5,
                    ox = ow * 0.5, oy = oh * 0.5,
                    sx = osx, sy = osy,
                    is_hoverable = false, is_clickable = false,
                    force_non_interactive = true,
                })

                local sw, sh = self.images.salermo:getDimensions()
                local ssx, ssy = 1, 1
                self.objects.salermo2 = Sprite({
                    image = self.images.salermo,
                    x = WW * 0.75,
                    y = WH - self.objects.platform.height - sh * ssy * 0.5,
                    ox = sw * 0.5, oy = sh * 0.5,
                    sx = ssx, sy = ssy,
                    is_hoverable = false, is_clickable = false,
                    force_non_interactive = true,
                })

                self.player.x = WW * 0.6

                self.fade_timer = timer(1,
                    function(progress)
                        self.fade_alpha = 1 - progress
                    end,
                    function()
                        self.fade_timer = nil
                        Events.emit("on_dialogue_show", self.dialogue)
                    end
                )
            end
        )
    end
end

function Game:goto_next(str, shown_quest)
    if not shown_quest then
        self.controls.enabled = true
        self.objects.box1.image = self.ui.checked_box
        self.objects.box2.image = self.ui.checked_box
        for _, obj in ipairs(self.group_guide) do obj.alpha = 1 end
        self.end_tasks_shown = str
        Events.register(self, "on_clicked_a")
        return
    end
    Events.emit("fadeout", 3, function()
        self.fade_alpha = 1
        self.controls.should_draw = false
        Events.emit("fadein", 1, function()
            local next_state = require(str)
            StateManager:switch(next_state, self.index + 1)
        end)
    end)
end

function Game:display_damage(obj, damage)
    local d = self.damage_text
    d.text = tostring(damage)
    d.x, d.y = obj.x, obj.y - 16
    d.ty = d.y - 64
    self.hurt_timer = timer(0.5,
        function(progress)
            d.y = mathx.lerp(d.y, d.ty, progress)
        end,
        function()
            self.hurt_timer = nil
            d.x = -100
            d.y = -100
        end)
end

function Game:update(dt)
    if self.hurt_timer then self.hurt_timer:update(dt) end
    self.controls:update(dt)
    iter_objects(self.orders, self.objects, "update", dt)
    iter_objects(self.orders, self.objects, "check_collision", self.player)
    self.player:update(dt, self.objects.platform.height)
    if self.enemy then self.enemy:update(dt) end
    self.dialogue:update(dt)
    if self.enemy_dialogue then self.enemy_dialogue:update(dt) end
    if self.other_dialogue then self.other_dialogue:update(dt) end
    if self.prologue then self.prologue:update(dt) end
    if self.dialogue_timer then self.dialogue_timer:update(dt) end
    if self.tree_timer then self.tree_timer:update(dt) end
    if self.wait_timer then self.wait_timer:update(dt) end
    if self.fade_timer then self.fade_timer:update(dt) end
    if self.show_timer then self.show_timer:update(dt) end
    if self.player_go_timer then self.player_go_timer:update(dt) end

    local obj_juana = self.objects.juana
    if obj_juana and not obj_juana.not_look then
        obj_juana.sx = self.player.x <= obj_juana.x and -1 or 1
    end

    local obj_maria = self.objects.maria
    if obj_maria then
        obj_maria.sx = self.player.x <= obj_maria.x and -1 or 1
    end
end

function Game:draw()
    love.graphics.setColor(1, 1, 1, 1)
    iter_objects(self.orders, self.objects, "draw")

    local obj_bb = self.objects.box_bg
    local skip_player = false
    if obj_bb.alpha == 1 then
        local bbw, bbh = self.ui.box_bg:getDimensions()
        if self.player.x >= (obj_bb.x - bbw * 0.5 * obj_bb.sx) and
            self.player.x <= (obj_bb.x + bbw * 0.5 * obj_bb.sx) then
            skip_player = true
        end
    end

    if not skip_player then self.player:draw() end

    if self.enemy then self.enemy:draw() end
    self.dialogue:draw()
    if self.enemy_dialogue then self.enemy_dialogue:draw() end
    if self.other_dialogue then self.other_dialogue:draw() end

    love.graphics.setColor(0, 0, 0, self.fade_alpha)
    love.graphics.rectangle("fill", 0, 0, WW, WH)
    love.graphics.setColor(1, 1, 1, 1)

    if self.prologue then self.prologue:draw() end
    self.controls:draw()
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(self.damage_text.color)
    love.graphics.setFont(self.damage_text.font)
    love.graphics.print(self.damage_text.text, self.damage_text.x, self.damage_text.y)
    love.graphics.setColor(1, 1, 1, 1)
end

function Game:mousepressed(mx, my, mb)
    self.controls:mousepressed(mx, my, mb)
    iter_objects(self.orders, self.objects, "mousepressed", mx, my, mb)
end

function Game:mousereleased(mx, my, mb)
    self.controls:mousereleased(mx, my, mb)
    iter_objects(self.orders, self.objects, "mousereleased", mx, my, mb)
end

function Game:exit()
    self.player:exit()
    self.sources.bgm:stop()
    Events.clear()
end

return Game
