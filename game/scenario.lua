local Scenario = class({
    name = "scenario"
})

local target_w = 576
local target_h = 324

local function get_longest_str(texts)
    local current = ""
    for _, str in ipairs(texts) do
        if #str > #current then
            current = str
        end
    end
    return current
end

function Scenario:new(index)
    assert(index and type(index) == "number" and index > 0)
    local id = self:type()
    local idn = id .. tostring(index)
    self.images = Assets.load_images(idn)
    self.sources = Assets.load_sources(idn)
    self.texts = require("data." .. idn)

    self.objects = {}
    self.orders = {"pic"}
    self.current_index = 1
    self.subtext_index = 1
    self.max_index = #self.texts
    self.font24 = Assets.fonts.impact24
    self.font32 = Assets.fonts.impact32

    self.alpha = 0
end

function Scenario:load()
    self.sources.bgm:play()

    local gap = 32
    local scale = 0.3
    local pic_width, pic_height = self.images.pic1:getDimensions()
    local pic = "pic" .. self.current_index
    local texts = self.texts[self.current_index]
    local text = texts[1]
    local longest = get_longest_str(texts)

    self.objects.pic = Button({
        image = self.images[pic],
        x = HALF_WW, y = gap,
        ox = pic_width * 0.5, oy = 0,
        sx = scale, sy = scale,
        is_clickable = false, is_hoverable = false,
        force_non_interactive = true,
        text = text,
        font = self.font24,
        tx = HALF_WW, ty = gap * 2 + pic_height * scale,
        tox = self.font24:getWidth(longest) * 0.5, toy = 0,
    })
end

function Scenario:next_slide()
    self.subtext_index = self.subtext_index + 1
    if not self.texts[self.current_index] then return end

    if self.subtext_index > #self.texts[self.current_index] then
        self.current_index = self.current_index + 1
        self.subtext_index = 1
        if self.current_index > self.max_index then
            self.fadeout_timer = timer(3,
                function(progress)
                    self.alpha = progress
                end,
                function()
                    -- Go to next scene
                    self.fadeout_timer = nil
                end)
            return
        end
    end

    local pic = self.images["pic" .. self.current_index]
    local texts = self.texts[self.current_index]
    local longest = get_longest_str(texts)
    local text
    if (self.subtext_index - 1) > 0 then
        text = texts[self.subtext_index - 1] .. "\n" .. texts[self.subtext_index]
    else
        text = texts[self.subtext_index]
    end
    local obj_pic = self.objects.pic
    local font = pic and self.font24 or self.font32

    obj_pic.image = pic
    obj_pic.font = font

    if pic then
        local width, height = pic:getDimensions()
        obj_pic.sx = target_w/width
        obj_pic.sy = target_h/height
        obj_pic.ox = width * 0.5
    else
        obj_pic.ty = HALF_WH
        obj_pic.toy = font:getHeight() * 0.5
    end

    obj_pic.text = text
    obj_pic.tox = font:getWidth(longest) * 0.5
end

function Scenario:update(dt)
    if self.fadeout_timer then self.fadeout_timer:update(dt) end
    iter_objects(self.orders, self.objects, "update", dt)
end

function Scenario:draw()
    love.graphics.setColor(1, 1, 1, 1)
    iter_objects(self.orders, self.objects, "draw")

    love.graphics.setColor(0, 0, 0, self.alpha)
    love.graphics.rectangle("fill", 0, 0, WW, WH)
    love.graphics.setColor(1, 1, 1, 1)
end

function Scenario:mousepressed(mx, my, mb)
    if mb == 1 then
        self:next_slide()
    end
end

function Scenario:exit()
    self.sources.bgm:stop()
end

return Scenario
