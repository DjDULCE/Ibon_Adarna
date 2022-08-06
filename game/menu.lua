local Menu = class({
    name = "menu"
})

local options = {
    "MAGUMPISA", "MAGPATULOY", "LUMISAN",
    "MADALI", "NORMAL", "MAHIRAP"
}
local pad = 16
local btn_scale = 1.25
local text_color = {0, 0, 0}
local font_impact32

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

    self.objects = {}
    self.orders = {
        "box_title", "ibong_adarna", "title",
        "btn_gear", "btn_trophy", "btn_credits",
        "menu_box", "box_settings", "btn_start", "btn_back",
        "box_settings_controls1", "box_settings_controls2",
        "btn_music_left", "btn_music_right",
        "btn_sound_left", "btn_sound_right", "btn_x",
        "box_leaderboards",
        "box_score1", "box_score2", "box_score3",
        "avatar1", "avatar2", "avatar3",
        "btn_reset",
    }

    for _, opt in ipairs(options) do
        table.insert(self.orders, 6, "btn_" .. string.lower(opt))
    end

    font_impact32 = Assets.fonts.impact32
end

function Menu:load()
    local box_title_sx, box_title_sy = 1.75, 1
    local box_title_w, box_title_h = self.images.box_title:getDimensions()

    self.objects.box_title = Button({
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
    self.objects.title = Button({
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
    self.objects.ibong_adarna = Button({
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
    self.objects.btn_gear = Button({
        image = self.images.btn_gear,
        x = WW - gear_w * 0.5 - pad,
        y = gear_h * 0.5 + pad,
        sx = btn_scale, sy = btn_scale,
        ox = gear_w * 0.5, oy = gear_h * 0.5,
        alpha = 0,
    })

    local trophy_w, trophy_h = self.images.btn_trophy:getDimensions()
    self.objects.btn_trophy = Button({
        image = self.images.btn_trophy,
        x = WW - trophy_w * 0.5 - pad,
        y = WH - trophy_h * 0.5 - pad,
        sx = btn_scale, sy = btn_scale,
        ox = trophy_w * 0.5, oy = trophy_h * 0.5,
        alpha = 0,
    })

    local bb_sx, bb_sy = 0.55, 0.5
    local bb_w, bb_h = self.images.box_button:getDimensions()
    local font = Assets.fonts.impact24
    for i = 1, #options do
        local opt = options[i]
        local y = WH * 0.4 + (pad + bb_h * bb_sy) * (((i - 1) % 3) + 1)
        self.objects["btn_" .. string.lower(opt)] = Button({
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
        })
    end

    self.objects.btn_start = Button({
        image = self.images.box_button,
        x = HALF_WW, y = WH * 0.75,
        ox = bb_w * 0.5,
        oy = bb_h * 0.5,
        sx = bb_sx, sy = bb_sy,
        text = "MAGSIMULA",
        text_color = text_color,
        font = font,
        tx = HALF_WW, ty = WH * 0.75,
        tox = font:getWidth("MAGSIMULA") * 0.5,
        toy = font:getHeight() * 0.5,
    })

    local credits_x = bb_w * bb_sx * 0.5 + pad
    local credits_y = WH - bb_h * bb_sy * 0.5 - pad
    self.objects.btn_credits = Button({
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
    })

    local back_y = bb_h * bb_sy * 0.5 + pad
    self.objects.btn_back = Button({
        image = self.images.box_button,
        x = credits_x, y = back_y,
        sx = bb_sx, sy = bb_sy,
        ox = bb_w * 0.5, oy = bb_h * 0.5,
        text = "BUMALIK",
        text_color = text_color,
        font = font,
        tx = credits_x, ty = back_y,
        tox = font:getWidth("BUMALIK") * 0.5,
        toy = font:getHeight() * 0.5,
        alpha = 0,
        is_hoverable = false, is_clickable = false,
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
        self.objects.btn_start.is_clickable = false
        self.objects.btn_start.is_hoverable = false

        self.timer = timer(1.25,
            function(progress)
                local bird = self.objects.ibong_adarna
                local box_title = self.objects.box_title
                local title = self.objects.title
                bird.x = mathx.lerp(bird.x, bird.target_x, progress)
                bird.y = mathx.lerp(bird.y, bird.target_y, progress)
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

    self.objects.btn_back.on_clicked = function()
        update_group(self.group_start, 0, false)
        update_group(self.group_main, 1, true)
    end

    self:setup_settings()
    self:setup_leaderboards()
end

function Menu:setup_settings()
    local mb_width, mb_height = self.images.menu_box:getDimensions()
    self.objects.menu_box = Button({
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
    self.objects.box_settings = Button({
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
    local settings_texts = {"MUSIKA", "TUNOG"}
    for i = 1, 2 do
        local key = "box_settings_controls" .. i
        local text = settings_texts[i]
        local bsc_x = HALF_WW + pad * 2
        local bsc_y = self.objects.box_settings.y + bs_height * bs_sy + pad
        bsc_y = bsc_y + (bsc_height * bsc_sy * (i - 1)) + pad * (i - 1)
        self.objects[key] = Button({
            image= self.images.box_settings_controls,
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
        })
    end

    local btn_control_scale_dt = 0.05
    local total_width = (bsc_width * bsc_sx) - pad * 2
    local total_height = (bsc_height * bsc_sy) - pad
    local btn_control_width, btn_control_height = self.images.btn_control:getDimensions()
    local btn_control_sx = (total_width * 0.5)/btn_control_width
    local btn_control_sy = total_height/btn_control_height
    local ctrl_data = {
        {
            "music",
            UserData.data.music == 1 and {1, 1, 1} or {0, 0, 0},
            UserData.data.music == 1 and {0, 0, 0} or {1, 1, 1},
        },
        {
            "sound",
            UserData.data.sound == 1 and {1, 1, 1} or {0, 0, 0},
            UserData.data.sound == 1 and {0, 0, 0} or {1, 1, 1},
        },
    }

    for i = 1, 2 do
        local control, left_color, right_color = unpack(ctrl_data[i])
        local key = string.format("btn_%s_left", control)
        local key2 = string.format("btn_%s_right", control)
        local ref = "box_settings_controls" .. i

        local left_x = self.objects[ref].x - total_width * 0.25 - pad * 0.5
        self.objects[key] = Button({
            image = self.images.btn_control,
            x = left_x, y = self.objects[ref].y,
            ox = btn_control_width * 0.5, oy = btn_control_height * 0.5,
            sx = btn_control_sx, sy = btn_control_sy,
            color = left_color,
            text = "ON",
            font = font_impact32,
            text_color = {1, 1, 1},
            tx = left_x, ty = self.objects[ref].y,
            tox = font_impact32:getWidth("ON") * 0.5,
            toy = font_impact32:getHeight() * 0.5,
            sx_dt = btn_control_scale_dt, sy_dt = btn_control_scale_dt,
            is_clickable = false, is_hoverable = false,
            alpha = 0,
        })

        local right_x = self.objects[key].x + btn_control_width * btn_control_sx + pad * 0.5
        self.objects[key2] = Button({
            image = self.images.btn_control,
            x = right_x,
            y = self.objects[ref].y,
            ox = btn_control_width * 0.5, oy = btn_control_height * 0.5,
            sx = btn_control_sx, sy = btn_control_sy,
            color = right_color,
            text = "OFF",
            text_color = {1, 1, 1},
            font = font_impact32,
            tx = right_x, ty = self.objects[ref].y,
            tox = font_impact32:getWidth("OFF") * 0.5,
            toy = font_impact32:getHeight() * 0.5,
            sx_dt = btn_control_scale_dt, sy_dt = btn_control_scale_dt,
            is_clickable = false, is_hoverable = false,
            alpha = 0,
        })
    end

    local x_width, x_height = self.images.btn_x:getDimensions()
    local x_scale = 0.2
    self.objects.btn_x = Button({
        image = self.images.btn_x,
        x = self.objects.menu_box.x + mb_width * 0.5 - pad,
        y = self.objects.menu_box.y - mb_height * 0.5 + pad,
        ox = x_width * 0.5, oy = x_height * 0.5,
        sx = x_scale, sy = x_scale,
        sx_dt = btn_control_scale_dt, sy_dt = btn_control_scale_dt,
        is_clickable = false, is_hoverable = false,
        alpha = 0,
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
        btn_music_left.color = {1, 1, 1}
        btn_music_right.color = {0, 0, 0}
        UserData.data.music = 1
    elseif btn == btn_music_right then
        btn_music_left.color = {0, 0, 0}
        btn_music_right.color = {1, 1, 1}
        UserData.data.music = 0
    elseif btn == btn_sound_left then
        btn_sound_left.color = {1, 1, 1}
        btn_sound_right.color = {0, 0, 0}
        UserData.data.sound = 1
    elseif btn == btn_sound_right then
        btn_sound_left.color = {0, 0, 0}
        btn_sound_right.color = {1, 1, 1}
        UserData.data.sound = 0
    end
    UserData:save()
end

function Menu:setup_leaderboards()
    local mb_width, mb_height = self.images.menu_box:getDimensions()

    local bs_width, bs_height = self.images.box_settings:getDimensions()
    local bl_y = self.objects.menu_box.y - mb_height * 0.5
    local bl_sx, bl_sy = 0.75, 0.75
    self.objects.box_leaderboards = Button({
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
    })

    local reset_sx, reset_sy = 0.5, 0.4
    local reset_y = self.objects.menu_box.y + mb_height * 0.5 - bs_height * 0.5 + pad * 0.5
    self.objects.btn_reset = Button({
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
    })

    local avatar_width, avatar_height = self.images.avatar:getDimensions()
    local avatar_scale = 0.25
    local score_width, score_height = self.images.box_score:getDimensions()
    local bs_sx = 0.6
    local bs_sy = 0.5
    local texts = {"Iskor ng Madali", "Iskor ng Normal", "Iskor ng Mahirap"}
    local score = UserData.data.score
    local spaces = string.rep(" ", 8)
    for i = 1, 3 do
        local key = "avatar" .. i
        local avatar_y = self.objects.box_leaderboards.y + bs_height * bl_sy * 0.5 + pad * 2
        avatar_y = avatar_y + avatar_height * avatar_scale * (i - 1) + (pad * (i - 1))
        self.objects[key] = Button({
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
        self.objects[key2] = Button({
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
    end
end

function Menu:update(dt)
    if self.timer then self.timer:update(dt) end
    iter_objects(self.orders, self.objects, "update", dt)
end

function Menu:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local bg_w, bg_h = self.images.bg:getDimensions()
    local bg_sx, bg_sy = WW/bg_w, WH/bg_h
    love.graphics.draw(self.images.bg, 0, 0, 0, bg_sx, bg_sy)

    iter_objects(self.orders, self.objects, "draw")
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
end

return Menu
