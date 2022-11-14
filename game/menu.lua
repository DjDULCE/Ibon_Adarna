local Menu = class({
    name = "menu"
})

local options = {
    "MAGUMPISA", "MAGPATULOY", "LUMISAN",
    "MADALI", "NORMAL", "MAHIRAP"
}
local pad = 16
local btn_scale = 1.25
local text_color = { 0, 0, 0 }
local font_impact32, font_impact28
local ctrl_text1 = "MGA PANGUNAHING KONTROL"
local ctrl_text2 = "Mga Kontrol Para Sa Instraksyon"

local function update_group(tbl, alpha, interactive)
    for i = 1, #tbl do
        local obj = tbl[i]
        if obj then
            obj.alpha = alpha
            obj.is_hoverable = interactive
            obj.is_clickable = interactive
        end
    end
end

function Menu:new()
    local id = self:type()
    self.images = Assets.load_images(id)
    self.images_control = Assets.load_images("controls")
    self.ui = Assets.load_images("ui")
    self.faces = Assets.load_images("faces")
    self.sources = Assets.load_sources("menu")
    self.sfx = Assets.load_sources("sfx", "static")

    self.objects = {}
    self.orders = {
        "box_title", "ibong_adarna", "title",
        "btn_gear", "btn_trophy", "btn_credits",
        "box_bg", "denice", "jayson", "veronica",
        "menu_box", "box_settings", "btn_start", "btn_back",
        "box_settings_controls1", "box_settings_controls2",
        "btn_music_left", "btn_music_right",
        "btn_sound_left", "btn_sound_right", "btn_x",
        "box_leaderboards",
        "box_score1", "box_score2", "box_score3",
        "avatar1", "avatar2", "avatar3",
        "btn_reset", "ctrl_avatar",
        "btn_a", "btn_b", "btn_left", "btn_right",
    }

    for _, opt in ipairs(options) do
        table.insert(self.orders, 6, "btn_" .. string.lower(opt))
    end

    font_impact32 = Assets.fonts.impact32
    font_impact28 = Assets.fonts.impact24
    self.in_controls = false
end

function Menu:load(show_main)
    self.sources.bgm:play()
    self.sources.bgm:setLooping(true)
    local box_title_sx, box_title_sy = 1.75, 1
    local box_title_w, box_title_h = self.images.box_title:getDimensions()

    self.objects.box_title = Sprite({
        image = self.images.box_title,
        x = HALF_WW,
        y = WH * 0.4,
        target_y = WH * 0.25,
        sx = box_title_sx, sy = box_title_sy,
        ox = box_title_w * 0.5, oy = box_title_h * 0.5,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
    })

    local title_w, title_h = self.images.title:getDimensions()
    local title_sx, title_sy = 1.65, 1.5
    self.objects.title = Sprite({
        image = self.images.title,
        x = HALF_WW,
        y = self.objects.box_title.y,
        target_y = self.objects.box_title.y,
        ox = title_w * 0.5, oy = title_h * 0.5,
        sx = title_sx, sy = title_sy,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
    })

    local ia_w, ia_h = self.images.ibong_adarna:getDimensions()
    local ia_scale = 0.65
    self.objects.ibong_adarna = Sprite({
        image = self.images.ibong_adarna,
        x = self.objects.title.x - box_title_w * box_title_sx * 0.6,
        y = WH * 0.6,
        target_x = self.objects.title.x - box_title_w * box_title_sx * 0.5,
        target_y = self.objects.box_title.target_y,
        ox = ia_w * 0.5,
        oy = ia_h * 0.5,
        sx = ia_scale, sy = ia_scale,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
    })

    local gear_w, gear_h = self.images.btn_gear:getDimensions()
    self.objects.btn_gear = Sprite({
        image = self.images.btn_gear,
        x = WW - gear_w * 0.5 - pad,
        y = gear_h * 0.5 + pad,
        sx = btn_scale, sy = btn_scale,
        ox = gear_w * 0.5, oy = gear_h * 0.5,
        alpha = 0,
        sound = self.sfx.select,
    })

    local trophy_w, trophy_h = self.images.btn_trophy:getDimensions()
    self.objects.btn_trophy = Sprite({
        image = self.images.btn_trophy,
        x = WW - trophy_w * 0.5 - pad,
        y = WH - trophy_h * 0.5 - pad,
        sx = btn_scale, sy = btn_scale,
        ox = trophy_w * 0.5, oy = trophy_h * 0.5,
        alpha = 0,
        sound = self.sfx.select,
    })

    local bb_sx, bb_sy = 0.55, 0.5
    local bb_w, bb_h = self.images.box_button:getDimensions()
    local font = Assets.fonts.impact24
    for i = 1, #options do
        local opt = options[i]
        local y = WH * 0.4 + (pad + bb_h * bb_sy) * (((i - 1) % 3) + 1)
        local key = "btn_" .. string.lower(opt)
        self.objects[key] = Sprite({
            image = self.images.box_button,
            x = HALF_WW, y = y,
            ox = bb_w * 0.5,
            oy = bb_h * 0.5,
            sx = bb_sx, sy = bb_sy,
            text = opt,
            text_color = text_color,
            font = font,
            tx = HALF_WW, ty = y,
            tox = font:getWidth(opt) * 0.5,
            toy = font:getHeight() * 0.5,
            is_clickable = false, is_hoverable = false,
            alpha = 0,
            sound = self.sfx.select,
        })

        if i >= 4 then
            self.objects[key].on_clicked = function()
                update_group(self.group_main, 0, false)
                update_group(self.group_start, 0, false)
                update_group(self.group_settings, 0, false)
                update_group(self.group_leaderboards, 0, false)
                update_group(self.group_controls, 1, false)
                self.in_controls = true
                self.controls_timer = timer(2, nil, function()
                    self.controls_timer = timer(3,
                        function(progress)
                            update_group(self.group_controls, 1 - progress, false)
                        end,
                        function()
                            if key == "btn_madali" then
                                UserData.data.difficulty = 1
                            elseif key == "btn_normal" then
                                UserData.data.difficulty = 2
                            elseif key == "btn_mahirap" then
                                UserData.data.difficulty = 3
                            end
                            UserData:save()

                            update_group(self.group_controls, 0, false)
                            UserData.data.stage = 1
                            UserData.data.life = 10
                            UserData:save()
                            local Scenario = require("scenario")
                            StateManager:switch(Scenario, 1)
                        end)
                end)
            end
        end
    end

    self.objects.btn_start = Sprite({
        image = self.images.box_button,
        x = HALF_WW, y = WH * 0.75,
        ox = bb_w * 0.5,
        oy = bb_h * 0.5,
        sx = bb_sx, sy = bb_sy,
        alpha = 0, text_alpha = 1,
        text = "I-Tap ang Laro",
        text_color = text_color,
        font = font,
        tx = HALF_WW, ty = WH * 0.75,
        tox = font:getWidth("I-Tap ang Laro") * 0.5,
        toy = font:getHeight() * 0.5,
        sound = self.sfx.select,
    })

    local credits_x = bb_w * bb_sx * 0.5 + pad
    local credits_y = WH - bb_h * bb_sy * 0.5 - pad
    self.objects.btn_credits = Sprite({
        image = self.images.box_button,
        x = credits_x, y = credits_y,
        sx = bb_sx, sy = bb_sy,
        ox = bb_w * 0.5, oy = bb_h * 0.5,
        text = "CREDITS",
        text_color = text_color,
        font = font,
        tx = credits_x, ty = credits_y,
        tox = font:getWidth("CREDITS") * 0.5,
        toy = font:getHeight() * 0.5,
        alpha = 0,
        is_hoverable = false, is_clickable = false,
        sound = self.sfx.select,
    })

    self.objects.btn_lumisan.on_clicked = function()
        love.event.quit()
    end

    local font2 = Assets.fonts.impact18
    local bw, bh = self.ui.box_bg:getDimensions()
    local bsx = (WW * 0.6)/bw
    local bsy = (WH * 0.8)/bh
    self.objects.box_bg = Sprite({
        image = self.ui.box_bg,
        x = HALF_WW, y = HALF_WH,
        sx = bsx, sy = bsy,
        ox = bw * 0.5, oy = bh * 0.5,
        alpha = 0,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
    })

    local dw, dh = self.faces.player:getDimensions()
    local ds = 0.5
    self.objects.denice = Sprite({
        image = self.faces.dj,
        x = HALF_WW - bw * bsx * 0.5 + 64,
        y = HALF_WH - bh * bsy * 0.5 + 32 + font:getHeight() * 2 + dh * ds * 0.5,
        sx = ds, sy = ds,
        ox = dw * 0.5, oy = dh * 0.5,
        alpha = 0,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        text = "Denice Justine Dulce",
        text_color = text_color,
        font = font2,
        tx = HALF_WW - bw * bsx * 0.5 + 64 + dw * ds * 0.5 + 16,
        toy = font2:getHeight() * 0.5,
    })

    local jw, jh = self.faces.diego:getDimensions()
    self.objects.jayson = Sprite({
        image = self.faces.jayson,
        x = HALF_WW - bw * bsx * 0.5 + 64,
        y = self.objects.denice.y + dh * ds * 0.5 + jh * ds * 0.5 + 16,
        sx = ds, sy = ds,
        ox = jw * 0.5, oy = jh * 0.5,
        alpha = 0,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        text = "Jayson R. Pontigon",
        text_color = text_color,
        font = font2,
        tx = HALF_WW - bw * bsx * 0.5 + 64 + jw * ds * 0.5 + 16,
        toy = font2:getHeight() * 0.5,
    })

    local vw, vh = self.faces.juana:getDimensions()
    self.objects.veronica = Sprite({
        image = self.faces.veronica,
        x = HALF_WW + 64,
        y = self.objects.denice.y,
        sx = ds, sy = ds,
        ox = vw * 0.5, oy = vh * 0.5,
        alpha = 0,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        text = "Veronica Balasta",
        text_color = text_color,
        font = font2,
        tx = HALF_WW + 64 + vw * ds * 0.5 + 16,
        toy = font2:getHeight() * 0.5,
    })

    local back_y = bb_h * bb_sy * 0.5 + pad
    self.objects.btn_back = Sprite({
        image = self.ui.btn_back,
        x = credits_x, y = back_y,
        sx = bb_sx, sy = bb_sy,
        ox = bb_w * 0.5, oy = bb_h * 0.5,
        -- text = "BUMALIK",
        -- text_color = text_color,
        -- font = font,
        -- tx = credits_x, ty = back_y,
        -- tox = font:getWidth("BUMALIK") * 0.5,
        -- toy = font:getHeight() * 0.5,
        alpha = 0,
        is_hoverable = false, is_clickable = false,
        sound = self.sfx.select,
    })

    self.group_main = {
        self.objects.box_title,
        self.objects.title,
        self.objects.ibong_adarna,
        self.objects.btn_credits,
        self.objects.btn_gear,
        self.objects.btn_trophy,
    }
    self.group_start = {
        self.objects.box_title,
        self.objects.title,
        self.objects.ibong_adarna,
        self.objects.btn_back,
    }
    self.group_credits = {
        self.objects.box_bg,
        self.objects.denice,
        self.objects.jayson,
        self.objects.veronica,
    }
    for i, opt in ipairs(options) do
        local key = "btn_" .. string.lower(opt)
        if i <= 3 then
            table.insert(self.group_main, self.objects[key])
        else
            table.insert(self.group_start, self.objects[key])
        end
    end

    self.objects.btn_start.on_clicked = function()
        self.objects.btn_start.alpha = 0
        self.objects.btn_start.text_alpha = 0
        self.objects.btn_start.is_clickable = false
        self.objects.btn_start.is_hoverable = false

        local bird = self.objects.ibong_adarna
        local ox, oy = bird.x, bird.y
        self.timer = timer(0.75,
            function(progress)
                local box_title = self.objects.box_title
                local title = self.objects.title
                bird.x = mathx.lerp(ox, bird.target_x, progress)
                bird.y = mathx.lerp(oy, bird.target_y, progress)
                box_title.y = mathx.lerp(box_title.y, box_title.target_y, progress)
                title.y = box_title.y
            end,
            function()
                self.timer = timer(1,
                    function(progress)
                        for _, opt in ipairs(options) do
                            local key = "btn_" .. string.lower(opt)
                            self.objects[key].alpha = progress
                        end
                        self.objects.btn_credits.alpha = progress
                        self.objects.btn_gear.alpha = progress
                        self.objects.btn_trophy.alpha = progress
                    end,
                    function()
                        update_group(self.group_main, 1, true)
                        self.timer = nil
                    end)
            end)
    end

    self.objects.btn_magumpisa.on_clicked = function()
        update_group(self.group_main, 0, false)
        update_group(self.group_start, 1, true)
    end

    self.objects.btn_magpatuloy.on_clicked = function()
        local last = UserData.data.last_id
        if last then
            local n = require(last)
            StateManager:switch(n, UserData.data.stage)
        end
    end

    self.objects.btn_back.on_clicked = function()
        update_group(self.group_start, 0, false)
        update_group(self.group_credits, 0, false)
        update_group(self.group_main, 1, true)
    end

    self.objects.btn_credits.on_clicked = function()
        update_group(self.group_start, 0, false)
        update_group(self.group_main, 0, false)
        update_group(self.group_credits, 1, true)
        self.objects.btn_back.alpha = 1
        self.objects.btn_back.is_clickable = true
        self.objects.btn_back.is_hoverable = true
    end

    self:setup_settings()
    self:setup_leaderboards()
    self:setup_controls()

    if show_main then
        self.objects.btn_start.alpha = 0
        self.objects.btn_start.text_alpha = 0
        self.objects.btn_start.is_clickable = false
        self.objects.btn_start.is_hoverable = false

        local bird = self.objects.ibong_adarna
        local box_title = self.objects.box_title
        local title = self.objects.title
        bird.x = bird.target_x
        bird.y = bird.target_y
        box_title.y = box_title.target_y
        title.y = box_title.y
        for _, opt in ipairs(options) do
            local key = "btn_" .. string.lower(opt)
            self.objects[key].alpha = 1
        end
        self.objects.btn_credits.alpha = 1
        self.objects.btn_gear.alpha = 1
        self.objects.btn_trophy.alpha = 1
        update_group(self.group_main, 1, true)
    end
end

function Menu:setup_settings()
    local mb_width, mb_height = self.images.menu_box:getDimensions()
    self.objects.menu_box = Sprite({
        image = self.images.menu_box,
        x = HALF_WW, y = HALF_WH,
        ox = mb_width * 0.5, oy = mb_height * 0.5,
        is_clickable = false, is_hoverable = false,
        force_non_interactive = true,
        alpha = 0,
    })

    local bs_width, bs_height = self.images.box_settings:getDimensions()
    local bs_y = self.objects.menu_box.y - mb_height * 0.5
    local bs_sx, bs_sy = 0.5, 0.75
    self.objects.box_settings = Sprite({
        image = self.images.box_settings,
        x = HALF_WW, y = bs_y,
        ox = bs_width * 0.5, oy = bs_height * 0.5,
        sx = bs_sx, sy = bs_sy,
        text = "SETTINGS",
        text_color = text_color,
        font = font_impact32,
        tx = HALF_WW - font_impact32:getWidth("SETTINGS") * 0.5,
        ty = bs_y - font_impact32:getHeight() * 0.5,
        is_clickable = false, is_hoverable = false,
        force_non_interactive = true,
        alpha = 0,
    })

    local bsc_width, bsc_height = self.images.box_settings_controls:getDimensions()
    local bsc_sx, bsc_sy = 0.4, 0.4
    local settings_texts = { "MUSIKA", "TUNOG" }
    for i = 1, 2 do
        local key = "box_settings_controls" .. i
        local text = settings_texts[i]
        local bsc_x = HALF_WW + pad * 2
        local bsc_y = self.objects.box_settings.y + bs_height * bs_sy + pad
        bsc_y = bsc_y + (bsc_height * bsc_sy * (i - 1)) + pad * (i - 1)
        self.objects[key] = Sprite({
            image = self.images.box_settings_controls,
            x = bsc_x, y = bsc_y,
            ox = bsc_width * 0.5, oy = bsc_height * 0.5,
            sx = bsc_sx, sy = bsc_sy,
            text = text,
            text_color = text_color,
            font = font_impact32,
            tx = self.objects.menu_box.x - mb_width * 0.5 + font_impact32:getWidth(text) * 0.5,
            ty = bsc_y - font_impact32:getHeight() * 0.5,
            is_clickable = false, is_hoverable = false,
            force_non_interactive = true,
            alpha = 0,
            sound = self.sfx.select,
        })
    end

    local btn_control_scale_dt = 0.05
    local total_width = (bsc_width * bsc_sx) - pad * 2
    local total_height = (bsc_height * bsc_sy) - pad
    local btn_control_width, btn_control_height = self.images.btn_control:getDimensions()
    local btn_control_sx = (total_width * 0.5) / btn_control_width
    local btn_control_sy = total_height / btn_control_height
    local ctrl_data = {
        {
            "music",
            UserData.data.music == 1 and { 1, 1, 1 } or { 0, 0, 0 },
            UserData.data.music == 1 and { 0, 0, 0 } or { 1, 1, 1 },
        },
        {
            "sound",
            UserData.data.sound == 1 and { 1, 1, 1 } or { 0, 0, 0 },
            UserData.data.sound == 1 and { 0, 0, 0 } or { 1, 1, 1 },
        },
    }

    for i = 1, 2 do
        local control, left_color, right_color = unpack(ctrl_data[i])
        local key = string.format("btn_%s_left", control)
        local key2 = string.format("btn_%s_right", control)
        local ref = "box_settings_controls" .. i

        local left_x = self.objects[ref].x - total_width * 0.25 - pad * 0.5
        self.objects[key] = Sprite({
            image = self.images.btn_control,
            x = left_x, y = self.objects[ref].y,
            ox = btn_control_width * 0.5, oy = btn_control_height * 0.5,
            sx = btn_control_sx, sy = btn_control_sy,
            color = left_color,
            text = "ON",
            font = font_impact32,
            text_color = { 1, 1, 1 },
            tx = left_x, ty = self.objects[ref].y,
            tox = font_impact32:getWidth("ON") * 0.5,
            toy = font_impact32:getHeight() * 0.5,
            sx_dt = btn_control_scale_dt, sy_dt = btn_control_scale_dt,
            is_clickable = false, is_hoverable = false,
            alpha = 0,
            sound = self.sfx.select,
        })

        local right_x = self.objects[key].x + btn_control_width * btn_control_sx + pad * 0.5
        self.objects[key2] = Sprite({
            image = self.images.btn_control,
            x = right_x,
            y = self.objects[ref].y,
            ox = btn_control_width * 0.5, oy = btn_control_height * 0.5,
            sx = btn_control_sx, sy = btn_control_sy,
            color = right_color,
            text = "OFF",
            text_color = { 1, 1, 1 },
            font = font_impact32,
            tx = right_x, ty = self.objects[ref].y,
            tox = font_impact32:getWidth("OFF") * 0.5,
            toy = font_impact32:getHeight() * 0.5,
            sx_dt = btn_control_scale_dt, sy_dt = btn_control_scale_dt,
            is_clickable = false, is_hoverable = false,
            alpha = 0,
            sound = self.sfx.select,
        })
    end

    local x_width, x_height = self.images.btn_x:getDimensions()
    local x_scale = 0.2
    self.objects.btn_x = Sprite({
        image = self.images.btn_x,
        x = self.objects.menu_box.x + mb_width * 0.5 - pad,
        y = self.objects.menu_box.y - mb_height * 0.5 + pad,
        ox = x_width * 0.5, oy = x_height * 0.5,
        sx = x_scale, sy = x_scale,
        sx_dt = btn_control_scale_dt, sy_dt = btn_control_scale_dt,
        is_clickable = false, is_hoverable = false,
        alpha = 0,
        sound = self.sfx.close,
    })

    self.group_settings = {
        self.objects.menu_box,
        self.objects.box_settings,
        self.objects.box_settings_controls1,
        self.objects.box_settings_controls2,
        self.objects.btn_music_left,
        self.objects.btn_music_right,
        self.objects.btn_sound_left,
        self.objects.btn_sound_right,
        self.objects.btn_x,
    }

    self.objects.btn_gear.on_clicked = function()
        update_group(self.group_main, 0, false)
        update_group(self.group_start, 0, false)
        update_group(self.group_settings, 1, true)
    end

    self.objects.btn_x.on_clicked = function()
        update_group(self.group_main, 1, true)
        update_group(self.group_settings, 0, false)
        update_group(self.group_leaderboards, 0, false)
    end

    local btn_music_left = self.objects.btn_music_left
    local btn_music_right = self.objects.btn_music_right
    local btn_sound_left = self.objects.btn_sound_left
    local btn_sound_right = self.objects.btn_sound_right
    btn_music_left.on_clicked = function() self:toggle_control(btn_music_left) end
    btn_music_right.on_clicked = function() self:toggle_control(btn_music_right) end
    btn_sound_left.on_clicked = function() self:toggle_control(btn_sound_left) end
    btn_sound_right.on_clicked = function() self:toggle_control(btn_sound_right) end
end

function Menu:toggle_control(btn)
    local btn_music_left = self.objects.btn_music_left
    local btn_music_right = self.objects.btn_music_right
    local btn_sound_left = self.objects.btn_sound_left
    local btn_sound_right = self.objects.btn_sound_right

    if btn == btn_music_left then
        btn_music_left.color = { 1, 1, 1 }
        btn_music_right.color = { 0, 0, 0 }
        UserData.data.music = 1
    elseif btn == btn_music_right then
        btn_music_left.color = { 0, 0, 0 }
        btn_music_right.color = { 1, 1, 1 }
        UserData.data.music = 0
    elseif btn == btn_sound_left then
        btn_sound_left.color = { 1, 1, 1 }
        btn_sound_right.color = { 0, 0, 0 }
        UserData.data.sound = 1
    elseif btn == btn_sound_right then
        btn_sound_left.color = { 0, 0, 0 }
        btn_sound_right.color = { 1, 1, 1 }
        UserData.data.sound = 0
    end

    for _, key in ipairs(self.orders) do
        local obj = self.objects[key]
        if obj and obj.sound then
            obj.sound:setVolume(UserData.data.sound)
        end
    end
    self.sources.bgm:setVolume(UserData.data.music)
    UserData:save()
end

function Menu:setup_leaderboards()
    local mb_width, mb_height = self.images.menu_box:getDimensions()

    local bs_width, bs_height = self.images.box_settings:getDimensions()
    local bl_y = self.objects.menu_box.y - mb_height * 0.5
    local bl_sx, bl_sy = 0.75, 0.75
    self.objects.box_leaderboards = Sprite({
        image = self.images.box_settings,
        x = HALF_WW, y = bl_y,
        ox = bs_width * 0.5, oy = bs_height * 0.5,
        sx = bl_sx, sy = bl_sy,
        text = "TALAAN NG ISKOR",
        text_color = text_color,
        font = font_impact32,
        tx = HALF_WW - font_impact32:getWidth("TALAAN NG ISKOR") * 0.5,
        ty = bl_y - font_impact32:getHeight() * 0.5,
        is_clickable = false, is_hoverable = false,
        force_non_interactive = true,
        alpha = 0,
        sound = self.sfx.select,
    })

    local reset_sx, reset_sy = 0.5, 0.4
    local reset_y = self.objects.menu_box.y + mb_height * 0.5 - bs_height * 0.5 + pad * 0.5
    self.objects.btn_reset = Sprite({
        image = self.images.box_settings,
        x = HALF_WW, y = reset_y,
        ox = bs_width * 0.5, oy = bs_height * 0.5,
        sx = reset_sx, sy = reset_sy,
        text = "I-RESET",
        text_color = text_color,
        font = font_impact32,
        tx = HALF_WW, ty = reset_y,
        tox = font_impact32:getWidth("I-RESET") * 0.5,
        toy = font_impact32:getHeight() * 0.5,
        is_clickable = false, is_hoverable = false,
        alpha = 0,
        sound = self.sfx.select,
    })

    local avatar_width, avatar_height = self.images.avatar:getDimensions()
    local avatar_scale = 0.25
    local score_width, score_height = self.images.box_score:getDimensions()
    local bs_sx = 0.6
    local bs_sy = 0.5
    local texts = { "Iskor ng Madali", "Iskor ng Normal", "Iskor ng Mahirap" }
    local score = UserData.data.score
    local spaces = string.rep(" ", 8)
    for i = 1, 3 do
        local key = "avatar" .. i
        local avatar_y = self.objects.box_leaderboards.y + bs_height * bl_sy * 0.5 + pad * 2
        avatar_y = avatar_y + avatar_height * avatar_scale * (i - 1) + (pad * (i - 1))
        self.objects[key] = Sprite({
            image = self.images.avatar,
            x = self.objects.menu_box.x - mb_width * 0.5 + pad * 4,
            y = avatar_y,
            ox = avatar_width * 0.5, oy = avatar_height * 0.5,
            sx = avatar_scale, sy = avatar_scale,
            is_clickable = false, is_hoverable = false,
            force_non_interactive = true,
            alpha = 0,
        })

        local key2 = "box_score" .. i
        local bs_x = self.objects[key].x + avatar_width * avatar_scale * 0.5 + pad * 2
        bs_x = bs_x + score_width * bs_sx * 0.5
        local text = string.format("%s:%s%d", texts[i], spaces, tostring(score[i]))
        self.objects[key2] = Sprite({
            image = self.images.box_score,
            x = bs_x, y = avatar_y,
            ox = score_width * 0.5, oy = score_height * 0.5,
            sx = bs_sx, sy = bs_sy,
            is_clickable = false, is_hoverable = false,
            text = text,
            text_color = text_color,
            font = font_impact32,
            tx = bs_x - score_width * bs_sx * 0.5 + pad,
            ty = avatar_y,
            toy = font_impact32:getHeight() * 0.5,
            force_non_interactive = true,
            alpha = 0,
        })
    end

    self.group_leaderboards = {
        self.objects.menu_box,
        self.objects.box_leaderboards,
        self.objects.btn_reset,
        self.objects.btn_x,
        self.objects.box_score1,
        self.objects.box_score2,
        self.objects.box_score3,
        self.objects.avatar1,
        self.objects.avatar2,
        self.objects.avatar3,
    }

    self.objects.btn_trophy.on_clicked = function()
        update_group(self.group_main, 0, false)
        update_group(self.group_start, 0, false)
        update_group(self.group_leaderboards, 1, true)
    end

    self.objects.btn_reset.on_clicked = function()
        UserData:reset_progress()
        UserData:save()

        for i = 1, 3 do
            local key = "box_score" .. i
            local text = string.format("%s:%s%d", texts[i], spaces, tostring(score[i]))
            self.objects[key].text = text
        end
    end
end

function Menu:setup_controls()
    local btn_ctrl_scale = 0.25
    local gap = 16

    local a_width, a_height = self.images_control.btn_a:getDimensions()
    local a_text = "Tanggapin/Kausapin"
    self.objects.btn_a = Sprite({
        image = self.images_control.btn_a,
        x = HALF_WW, y = WH * 0.4,
        sx = btn_ctrl_scale, sy = btn_ctrl_scale,
        ox = a_width * 0.5, oy = a_height * 0.5,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        text = a_text,
        font = font_impact28,
        tx = HALF_WW + gap * 4,
        toy = font_impact28:getHeight() * 0.5,
        alpha = 0,
    })

    local b_width, b_height = self.images_control.btn_b:getDimensions()
    local b_text = "Ipagliban/Huwag Ipagpatuloy"
    self.objects.btn_b = Sprite({
        image = self.images_control.btn_b,
        x = HALF_WW,
        y = self.objects.btn_a.y + a_height * btn_ctrl_scale + gap,
        sx = btn_ctrl_scale, sy = btn_ctrl_scale,
        ox = b_width * 0.5, oy = b_height * 0.5,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        text = b_text,
        tx = HALF_WW + gap * 4,
        toy = font_impact28:getHeight() * 0.5,
        font = font_impact28,
        alpha = 0,
    })

    local l_width, l_height = self.images_control.btn_left:getDimensions()
    self.objects.btn_left = Sprite({
        image = self.images_control.btn_left,
        x = HALF_WW - l_width * btn_ctrl_scale,
        y = self.objects.btn_b.y + b_height * btn_ctrl_scale + gap,
        sx = btn_ctrl_scale, sy = btn_ctrl_scale,
        ox = l_width * 0.5, oy = l_height * 0.5,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        alpha = 0,
    })

    local dir_text = "Kontrol Para sa Paggalaw"
    local r_width, r_height = self.images_control.btn_right:getDimensions()
    self.objects.btn_right = Sprite({
        image = self.images_control.btn_right,
        x = HALF_WW + r_width * btn_ctrl_scale,
        y = self.objects.btn_left.y,
        sx = btn_ctrl_scale, sy = btn_ctrl_scale,
        ox = r_width * 0.5, oy = r_height * 0.5,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        text = dir_text,
        tx = HALF_WW + r_width * btn_ctrl_scale + gap * 4,
        toy = font_impact28:getHeight() * 0.5,
        font = font_impact28,
        alpha = 0,
    })

    local ca_width, ca_height = self.images_control.avatar:getDimensions()
    self.objects.ctrl_avatar = Sprite({
        image = self.images_control.avatar,
        x = self.objects.btn_left.x - l_width * btn_ctrl_scale * 2,
        y = self.objects.btn_left.y - gap * 2,
        sx = 1, sy = 1,
        ox = ca_width * 0.5, oy = ca_height * 0.5,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        alpha = 0,
    })

    self.group_controls = {
        self.objects.btn_a,
        self.objects.btn_b,
        self.objects.btn_left,
        self.objects.btn_right,
        self.objects.ctrl_avatar,
    }
end

function Menu:update(dt)
    if self.timer then self.timer:update(dt) end
    if self.controls_timer then self.controls_timer:update(dt) end
    iter_objects(self.orders, self.objects, "update", dt)
end

function Menu:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local bg_w, bg_h = self.images.bg:getDimensions()
    local bg_sx, bg_sy = WW / bg_w, WH / bg_h
    love.graphics.draw(self.images.bg, 0, 0, 0, bg_sx, bg_sy)

    if self.in_controls then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", 0, 0, 4096, 4096)

        love.graphics.setColor(1, 1, 1, self.objects.ctrl_avatar.alpha)
        love.graphics.setFont(font_impact32)
        love.graphics.print(ctrl_text1,
            HALF_WW, 64, 0, 1, 1,
            font_impact32:getWidth(ctrl_text1) * 0.5,
            font_impact32:getHeight()
        )
        love.graphics.setFont(font_impact28)
        love.graphics.print(ctrl_text2,
            HALF_WW,
            64 + font_impact32:getHeight() * 1.1, 0, 1, 1,
            font_impact28:getWidth(ctrl_text2) * 0.5,
            font_impact28:getHeight()
        )
    end

    iter_objects(self.orders, self.objects, "draw")

    local bb = self.objects.box_bg
    if bb.alpha == 1 then
        local font = Assets.fonts.impact18
        local bw, bh = self.ui.box_bg:getDimensions()
        love.graphics.setFont(font)
        love.graphics.setColor(0, 0, 0, 1)

        love.graphics.print(
            "Developed By:",
            bb.x - bw * bb.sx * 0.5 + 32,
            bb.y - bh * bb.sy * 0.5 + 32
        )
        love.graphics.print(
            "Voice over By:",
            bb.x + bw * bb.sx * 0.5 - 64,
            bb.y - bh * bb.sy * 0.5 + 32,
            0, 1, 1,
            font:getWidth("Voice over By:")
        )

        local j = self.objects.jayson
        local jh = self.faces.jayson:getHeight()
        love.graphics.print(
            "Dialog scripts By:\n- Jhulie_nyx",
            bb.x - bw * bb.sx * 0.5 + 32,
            j.y + jh * j.sy * 0.5 + 32
        )

        local vw = self.faces.veronica:getWidth()
        love.graphics.print(
            "Music By:\n- Always music\n- Orchestral\n- Dag reinhott",
            HALF_WW + vw * 0.5 * 0.5 + 16,
            j.y + jh * j.sy * 0.5 + 16
        )
    end


    love.graphics.setColor(1, 1, 1, 1)
end

function Menu:mousepressed(mx, my, mb)
    for _, key in ipairs(self.orders) do
        local btn = self.objects[key]
        if btn then
            local res = btn:mousepressed(mx, my, mb)
            if res then return end
        end
    end
end

function Menu:mousereleased(mx, my, mb)
    for _, key in ipairs(self.orders) do
        local btn = self.objects[key]
        if btn then
            local res = btn:mousereleased(mx, my, mb)
            if res then return end
        end
    end
end

function Menu:mousemoved(mx, my, dmx, dmy, istouch)
end

function Menu:mousefocus(focus)
end

function Menu:exit()
    self.sources.bgm:stop()
end

return Menu
