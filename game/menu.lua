local Menu = class({
    name = "menu"
})

local options = {"MAGUMPISA", "MAGPATULOY", "LUMISAN"}

function Menu:new()
    local id = self:type()
    self.images = Assets.load_images(id)

    self.objects = {}
    self.orders = {
        "title", "ibong_adarna",
        "btn_gear", "btn_trophy",
    }

    for _, opt in ipairs(options) do
        table.insert(self.orders, "btn_" .. string.lower(opt))
    end
end

function Menu:load()
    local title_sx, title_sy = 1.25, 0.8
    local title_w, title_h = self.images.title:getDimensions()
    self.objects.title = Button({
        image = self.images.title,
        x = HALF_WW,
        y = WH * 0.25,
        sx = title_sx, sy = title_sy,
        ox = title_w * 0.5, oy = title_h * 0.5,
        is_hoverable = false, is_clickable = false,
    })

    local ia_w, ia_h = self.images.ibong_adarna:getDimensions()
    local ia_scale = 0.75
    self.objects.ibong_adarna = Button({
        image = self.images.ibong_adarna,
        x = self.objects.title.x - title_w * 0.6,
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

    local bb_scale = 0.5
    local bb_w, bb_h = self.images.box_button:getDimensions()
    for i, opt in ipairs(options) do
        self.objects["btn_" .. string.lower(opt)] = Button({
            image = self.images.box_button,
            x = HALF_WW,
            y = WH * 0.4 + (pad + bb_h * bb_scale) * i,
            ox = bb_w * 0.5,
            oy = bb_h * 0.5,
            sx = bb_scale, sy = bb_scale,
        })
    end
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
end

function Menu:mousereleased(mx, my, mb)
end

function Menu:mousemoved(mx, my, dmx, dmy, istouch)
end

function Menu:mousefocus(focus)
end

function Menu:exit()
end

return Menu
