local Menu = class({
    name = "menu"
})

local options = {"MAGUMPISA", "MAGPATULOY", "LUMISAN"}

function Menu:new()
    local id = self:type()
    self.images = Assets.load_images(id)

    self.objects = {}
    self.orders = {
        "box_title", "ibong_adarna", "title",
        "btn_gear", "btn_trophy", "btn_credits",
        "settings_box", "box_settings", "box_settings_controls1",
        "box_settings_controls2", "btn_reset",
        "btn_music_left", "btn_music_right",
        "btn_sound_left", "btn_sound_right",
    }

    for _, opt in ipairs(options) do
        table.insert(self.orders, 6, "btn_" .. string.lower(opt))
    end
end

function Menu:load()
    local box_title_sx, box_title_sy = 1.75, 1
    local box_title_w, box_title_h = self.images.box_title:getDimensions()
    self.objects.box_title = Button({
        image = self.images.box_title,
        x = HALF_WW,
        y = WH * 0.25,
        sx = box_title_sx, sy = box_title_sy,
        ox = box_title_w * 0.5, oy = box_title_h * 0.5,
        is_hoverable = false, is_clickable = false,
    })

    local title_w, title_h = self.images.title:getDimensions()
    local title_sx, title_sy = 1.65, 1.5
    self.objects.title = Button({
        image = self.images.title,
        x = HALF_WW,
        y = self.objects.box_title.y,
        ox = title_w * 0.5, oy = title_h * 0.5,
        sx = title_sx, sy = title_sy,
        is_hoverable = false, is_clickable = false,
    })

    local ia_w, ia_h = self.images.ibong_adarna:getDimensions()
    local ia_scale = 0.65
    self.objects.ibong_adarna = Button({
        image = self.images.ibong_adarna,
        x = self.objects.title.x - box_title_w * box_title_sx * 0.5,
        y = self.objects.title.y,
        ox = ia_w * 0.5,
        oy = ia_h * 0.5,
        sx = ia_scale, sy = ia_scale,
        is_hoverable = false, is_clickable = false,
    })

    local pad = 16
    local btn_scale = 1.25
    local gear_w, gear_h = self.images.btn_gear:getDimensions()
    self.objects.btn_gear = Button({
        image = self.images.btn_gear,
        x = WW - gear_w * 0.5 - pad,
        y = gear_h * 0.5 + pad,
        sx = btn_scale, sy = btn_scale,
        ox = gear_w * 0.5, oy = gear_h * 0.5,
    })

    local trophy_w, trophy_h = self.images.btn_trophy:getDimensions()
    self.objects.btn_trophy = Button({
        image = self.images.btn_trophy,
        x = WW - trophy_w * 0.5 - pad,
        y = WH - trophy_h * 0.5 - pad,
        sx = btn_scale, sy = btn_scale,
        ox = trophy_w * 0.5, oy = trophy_h * 0.5,
    })

    local bb_sx, bb_sy = 0.55, 0.5
    local bb_w, bb_h = self.images.box_button:getDimensions()
    local text_color = {0, 0, 0, 1}
    local font = Assets.fonts.impact
    for i, opt in ipairs(options) do
        local y = WH * 0.4 + (pad + bb_h * bb_sy) * i
        self.objects["btn_" .. string.lower(opt)] = Button({
            image = self.images.box_button,
            x = HALF_WW, y = y,
            ox = bb_w * 0.5,
            oy = bb_h * 0.5,
            sx = bb_sx, sy = bb_sy,
            text = opt,
            text_color = text_color,
            font = font,
            tx = HALF_WW - font:getWidth(opt) * 0.5,
            ty = y - font:getHeight() * 0.5,
        })
    end


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
        tx = credits_x - font:getWidth("CREDITS") * 0.5,
        ty = credits_y - font:getHeight() * 0.5,
    })

    local sb_width, sb_height = self.images.settings_box:getDimensions()
    self.objects.settings_box = Button({
        image = self.images.settings_box,
        x = HALF_WW, y = HALF_WH,
        ox = sb_width * 0.5, oy = sb_height * 0.5,
        is_clickable = false, is_hoverable = false,
        alpha = 0,
    })

    local bs_width, bs_height = self.images.box_settings:getDimensions()
    local bs_y = self.objects.settings_box.y - sb_height * 0.5
    local bs_sx, bs_sy = 0.5, 0.75
    self.objects.box_settings = Button({
        image = self.images.box_settings,
        x = HALF_WW, y = bs_y,
        ox = bs_width * 0.5, oy = bs_height * 0.5,
        sx = bs_sx, sy = bs_sy,
        text = "SETTINGS",
        text_color = text_color,
        font = font,
        tx = HALF_WW - font:getWidth("SETTINGS") * 0.5,
        ty = bs_y - font:getHeight() * 0.5,
        is_clickable = false, is_hoverable = false,
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
            font = font,
            tx = self.objects.settings_box.x - sb_width * 0.5 + font:getWidth(text) * 0.5,
            ty = bsc_y - font:getHeight() * 0.5,
            is_clickable = false, is_hoverable = false,
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
            font = font,
            text_color = {1, 1, 1},
            tx = left_x - font:getWidth("ON") * 0.5,
            ty = self.objects[ref].y - font:getHeight() * 0.5,
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
            font = font,
            tx = right_x - font:getWidth("OFF") * 0.5,
            ty = self.objects[ref].y - font:getHeight() * 0.5,
            sx_dt = btn_control_scale_dt, sy_dt = btn_control_scale_dt,
            is_clickable = false, is_hoverable = false,
            alpha = 0,
        })
    end

    local reset_sx, reset_sy = 0.5, 0.5
    local reset_y = self.objects.settings_box.y + sb_height * 0.5 - bs_height * 0.5
    self.objects.btn_reset = Button({
        image = self.images.box_settings,
        x = HALF_WW, y = reset_y,
        ox = bs_width * 0.5, oy = bs_height * 0.5,
        sx = reset_sx, sy = reset_sy,
        text = "I-RESET",
        text_color = text_color,
        font = font,
        tx = HALF_WW - font:getWidth("I-RESET") * 0.5,
        ty = reset_y - font:getHeight() * 0.5,
        is_clickable = false, is_hoverable = false,
        alpha = 0,
    })

    self.objects.btn_gear.on_clicked = function()
        for _, opt in ipairs(options) do
            local key = "btn_" .. string.lower(opt)
            self.objects[key].is_clickable = false
            self.objects[key].is_hoverable = false
        end

        self.objects.settings_box.alpha = 1
        self.objects.box_settings.alpha = 1
        self.objects.box_settings_controls1.alpha = 1
        self.objects.box_settings_controls2.alpha = 1
        self.objects.btn_music_left.alpha = 1
        self.objects.btn_music_left.is_clickable = true
        self.objects.btn_music_left.is_hoverable = true
        self.objects.btn_music_right.alpha = 1
        self.objects.btn_music_right.is_clickable = true
        self.objects.btn_music_right.is_hoverable = true
        self.objects.btn_sound_left.alpha = 1
        self.objects.btn_sound_left.is_clickable = true
        self.objects.btn_sound_left.is_hoverable = true
        self.objects.btn_sound_right.alpha = 1
        self.objects.btn_sound_right.is_clickable = true
        self.objects.btn_sound_right.is_hoverable = true
        self.objects.btn_reset.alpha = 1
        self.objects.btn_reset.is_clickable = true
        self.objects.btn_reset.is_hoverable = true
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

function Menu:update(dt)
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
