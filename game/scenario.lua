local Scenario = class({
    name = "scenario"
})

-- local target_w = 576
-- local target_h = 324
--
-- local function get_longest_str(texts)
--     local current = ""
--     for _, str in ipairs(texts) do
--         if #str > #current then
--             current = str
--         end
--     end
--     return current
-- end

function Scenario:new(index)
    print("scenario", index)
    assert(index and type(index) == "number" and index > 0)
    self.index = index
    local id = self:type()
    local idn = id .. tostring(index)

    self.video = Assets.load_video(idn)
    local vw, vh = self.video:getDimensions()
    self.vsx = WW/vw
    self.vsy = WH/vh
    self.alpha = 0

    -- self.images = Assets.load_images(idn)
    -- self.sources = Assets.load_sources(id)
    -- self.texts = require("data." .. idn)
    --
    -- self.objects = {}
    -- self.orders = {"pic"}
    -- self.current_index = 1
    -- self.subtext_index = 1
    -- self.max_index = #self.texts
    -- self.font24 = Assets.fonts.impact24
    -- self.font32 = Assets.fonts.impact32
end

function Scenario:load()
    self.video:play()
    self.video_has_started = true
    -- self.sources.bgm:play()
    -- self.sources.bgm:setLooping(true)
    --
    -- local gap = 32
    -- local scale = 0.3
    -- local pic_width, pic_height = self.images.pic1:getDimensions()
    -- local pic = "pic" .. self.current_index
    -- local texts = self.texts[self.current_index]
    -- local text = texts[1]
    -- local longest = get_longest_str(texts)
    --
    -- self.objects.pic = Sprite({
    --     image = self.images[pic],
    --     x = HALF_WW, y = gap,
    --     ox = pic_width * 0.5, oy = 0,
    --     sx = scale, sy = scale,
    --     is_clickable = false, is_hoverable = false,
    --     force_non_interactive = true,
    --     text = text,
    --     font = self.font24,
    --     tx = HALF_WW, ty = gap * 2 + pic_height * scale,
    --     tox = self.font24:getWidth(longest) * 0.5, toy = 0,
    -- })
end

function Scenario:next_slide()
    -- self.subtext_index = self.subtext_index + 1
    -- if not self.texts[self.current_index] then return end
    --
    -- if self.subtext_index > #self.texts[self.current_index] then
    --     self.current_index = self.current_index + 1
    --     self.subtext_index = 1
    --     if self.current_index > self.max_index then
    --         Events.emit("fadeout", 3, function()
    --             self.alpha = 1
    --             Events.emit("fadein", 1, function()
    --                 print("index", self.index)
    --                 if self.index == 1 or self.index == 3 then
    --                     local scene = require("scene")
    --                     StateManager:switch(scene, self.index)
    --                 end
    --             end)
    --         end)
    --         return
    --     end
    -- end
    --
    -- local pic = self.images["pic" .. self.current_index]
    -- local texts = self.texts[self.current_index]
    -- local longest = get_longest_str(texts)
    -- local text
    -- if (self.subtext_index - 1) > 0 then
    --     text = texts[self.subtext_index - 1] .. "\n" .. texts[self.subtext_index]
    -- else
    --     text = texts[self.subtext_index]
    -- end
    -- local obj_pic = self.objects.pic
    -- local font = pic and self.font24 or self.font32
    --
    -- obj_pic.image = pic
    -- obj_pic.font = font
    --
    -- if pic then
    --     local width, height = pic:getDimensions()
    --     obj_pic.sx = target_w/width
    --     obj_pic.sy = target_h/height
    --     obj_pic.ox = width * 0.5
    -- else
    --     obj_pic.ty = HALF_WH
    --     obj_pic.toy = font:getHeight() * 0.5
    -- end
    --
    -- obj_pic.text = text
    -- obj_pic.tox = font:getWidth(longest) * 0.5
end

function Scenario:update(dt)
    -- iter_objects(self.orders, self.objects, "update", dt)
    if self.video_has_started and not self.video:isPlaying() and not self.fade_out then
        self.fade_out = true
        print("scene video done for", self.index)
        Events.emit("fadeout", 3, function()
            self.alpha = 1
            Events.emit("fadein", 2, function()
                if self.index == 1 or self.index == 3 then
                    local scene = require("scene")
                    StateManager:switch(scene, self.index)
                elseif self.index == 4 or self.index == 5 then
                    local game = require("game")
                    StateManager:switch(game, self.index)
                end
            end)
        end)
    end
end

function Scenario:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.video, 0, 0, 0, self.vsx, self.vsy)
    -- iter_objects(self.orders, self.objects, "draw")
    love.graphics.setColor(0, 0, 0, self.alpha)
    love.graphics.push()
    love.graphics.scale(SCALE_X, SCALE_Y)
    love.graphics.rectangle("fill", 0, 0, 4096, 4096)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function Scenario:mousepressed(mx, my, mb)
    -- if mb == 1 then self:next_slide() end
    -- if DEV and mb == 1 then
    --     self.video:seek(2 * 60 + 10)
    --     self.video:getSource():seek(1 * 60 + 54)
    -- end
end

function Scenario:exit()
    self.video:pause()
    self.video:getSource():pause()
    -- self.sources.bgm:stop()
end

return Scenario
