local Scene = class({
    name = "scene"
})

local objects = {
    { "bed", "fernando", "val" },
    { "ermitanyo" },
    { "don_diego", "don_pedro" },
    { "eagle", },
    { "salermo", "maria", },
}

local player_initial_pos

function Scene:new(index)
    print("scene", index)
    assert(index and type(index) == "number" and index > 0)
    local id = self:type()
    local idn = id .. tostring(index)
    self.index = index
    self.images = Assets.load_images(idn)
    self.sources = Assets.load_sources(id)
    self.controls = Controls()
    self.alpha = 0
    self.alpha2 = 0

    self.objects = {}
    self.orders = {"platform"}
    tablex.append_inplace(self.orders, objects[index])

    self.dialogue = Dialogue({
        id = "scene" .. index,
        font = Assets.fonts.impact24,
        data = require("data.scene" .. index),
        align = "left",
        repeating = false,
    })

    Events.register(self, "on_dialogue_show")
    Events.register(self, "on_dialogue_end")
    Events.register(self, "on_player_move_x")

    player_initial_pos = {
        {WW * 0.7, 1},
        {WW * 0.3, -1},
        {WW * 0.1, -1},
        {WW * 0.55, 1},
        {WW * 0.3, -1},
    }
end

function Scene:on_player_move_x() end

function Scene:load()
    self.sources.bgm:play()
    self.sources.bgm:setLooping(true)

    local p_width, p_height = self.images.platform:getDimensions()
    local p_sy = 1
    if self.index == 2 then
        p_sy = 1.5
    end
    self.objects.platform = Sprite({
        image = self.images.platform,
        x = 0, y = WH - p_height * p_sy,
        sx = WW / p_width, sy = p_sy,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        height = p_height,
    })

    if self.index == 1 then
        local bed_width, bed_height = self.images.bed:getDimensions()
        self.objects.bed = Sprite({
            image = self.images.bed,
            x = WW * 0.15, y = WH - p_height - bed_height,
            sx = -1,
            ox = bed_width * 0.5,
            is_hoverable = false, is_clickable = false,
            force_non_interactive = true,
        })

        local f_width, f_height = self.images.fernando:getDimensions()
        self.objects.fernando = Sprite({
            image = self.images.fernando,
            x = self.objects.bed.x,
            y = self.objects.bed.y + 8,
            sx = -1,
            sy = -1,
            r = math.pi / 2,
            ox = f_width * 0.5, oy = f_height * 0.5,
            is_hoverable = false, is_clickable = false,
            force_non_interactive = true,
            collider = {
                w = 164,
                h = 64,
                origin = "center"
            }
        })

        local v_width, v_height = self.images.valeriana:getDimensions()
        self.objects.val = Sprite({
            image = self.images.valeriana,
            x = WW * 0.4,
            y = WH - p_height - v_height,
            ox = v_width * 0.5,
            is_hoverable = false, is_clickable = false,
            force_non_interactive = true,
        })
        self.looking_npc = self.objects.val
    elseif self.index == 2 then
        local e_width, e_height = self.images.ermitanyo:getDimensions()
        self.objects.ermitanyo = Sprite({
            image = self.images.ermitanyo,
            x = WW * 0.6,
            y = self.objects.platform.y - e_height * 0.5,
            sx = -1,
            ox = e_width * 0.5, oy = e_height * 0.5,
            is_hoverable = false, is_clickable = false,
            force_non_interactive = true,
            collider = {
                w = 23,
                h = 48,
                origin = "center"
            }
        })
        self.looking_npc = self.objects.ermitanyo
    elseif self.index == 3 then
        local ddw, ddh = self.images.don_diego:getDimensions()
        self.objects.don_diego = Sprite({
            image = self.images.don_diego,
            x = WW * 0.35,
            y = self.objects.platform.y - ddh * 0.5,
            sx = 1, sy = 1,
            ox = ddw * 0.5, oy = ddh * 0.5,
            force_non_interactive = true,
            is_clickable = false, is_hoverable = false,
            collider = {
                w = 20,
                h = 47,
                origin = "center"
            }
        })

        local dpw, dph = self.images.don_pedro:getDimensions()
        self.objects.don_pedro = Sprite({
            image = self.images.don_pedro,
            x = WW * 0.4,
            y = self.objects.platform.y - dph * 0.5,
            sx = 1, sy = 1,
            ox = dpw * 0.5, oy = dph * 0.5,
            force_non_interactive = true,
            is_clickable = false, is_hoverable = false,
            collider = {
                w = 20,
                h = 47,
                origin = "center"
            }
        })
    elseif self.index == 4 then
        local ew, eh = self.images.eagle:getDimensions()
        self.objects.eagle = Sprite({
            image = self.images.eagle,
            x = WW * 0.35,
            y = self.objects.platform.y - eh * 0.5,
            sx = 1, sy = 1,
            ox = ew * 0.5, oy = eh * 0.5,
            force_non_interactive = true,
            is_clickable = false, is_hoverable = false,
            collider = {
                w = 225,
                h = 205,
                origin = "center"
            }
        })
        self.looking_npc = self.objects.eagle
    elseif self.index == 5 then
        local sw, sh = self.images.salermo:getDimensions()
        self.objects.salermo = Sprite({
            image = self.images.salermo,
            x = WW * 0.65,
            y = self.objects.platform.y - sh * 0.5,
            sx = 1, sy = 1,
            ox = sw * 0.5, oy = sh * 0.5,
            force_non_interactive = true,
            is_clickable = false, is_hoverable = false,
            collider = {
                w = 26,
                h = 63,
                origin = "center"
            }
        })
        local mw, mh = self.images.maria:getDimensions()
        self.objects.maria = Sprite({
            image = self.images.maria,
            x = WW * 0.7,
            y = self.objects.platform.y - mh * 0.5,
            sx = 1, sy = 1,
            ox = mw * 0.5, oy = mh * 0.5,
            force_non_interactive = true,
            is_clickable = false, is_hoverable = false,
        })

        self.looking_npc = self.objects.salermo
        self.looking_npc2 = self.objects.maria
    end

    local px, dir = unpack(player_initial_pos[self.index])
    self.player = Player(px, self.objects.platform.y * p_sy)
    self.player.show_health = false
    self.player.dir = dir
end

function Scene:on_dialogue_show()
    if self.index == 5 and self.objects.maria then
        self.player.can_move = true
    else
        self.player.can_move = false
    end
end

function Scene:on_dialogue_end(obj_dialogue)
    print("on_dialogue_end", self.index, obj_dialogue.id)
    if self.index == 3 and obj_dialogue.id == "scene3" then
        self.dialogue = Dialogue({
            id = "scene" .. self.index .. "b",
            font = Assets.fonts.impact24,
            data = require("data.scene" .. self.index .. "b"),
            align = "center",
            repeating = false,
            enabled = false,
            simple = true,
        })
        self.controls.enabled = true
        Events.emit("on_dialogue_show", self.dialogue)
        return
    elseif self.index == 5 then
        if obj_dialogue.id == "scene5" then
            self.player.x = WW * 0.45
            self.dialogue = Dialogue({
                id = "scene" .. self.index .. "b",
                font = Assets.fonts.impact24,
                data = require("data.scene" .. self.index .. "b"),
                align = "center",
                repeating = false,
                enabled = false,
                simple = true,
            })
            self.alpha2 = 1
            self.controls.enabled = true
            Events.emit("on_dialogue_show", self.dialogue)
            return
        elseif obj_dialogue.id == "scene5b" then
            local sx = self.objects.salermo.x
            self.objects.salermo.x = self.objects.maria.x
            self.objects.maria.x = sx
            self.objects.salermo.collider = nil
            self.objects.maria:add_collider({
                w = 29,
                h = 48,
                origin = "center"
            })

            self.dialogue = Dialogue({
                id = "scene" .. self.index .. "c",
                font = Assets.fonts.impact24,
                data = require("data.scene" .. self.index .. "c"),
                align = "center",
                repeating = false,
                enabled = false,
            })
            self.objects.maria.dialogue = self.dialogue
            self.alpha2 = 0
            self.player.can_move = true
            self.controls.enabled = true
            return
        elseif obj_dialogue.id == "scene5c" then
            self.objects.maria = nil
            self.dialogue = Dialogue({
                id = "scene" .. self.index .. "d",
                font = Assets.fonts.impact24,
                data = require("data.scene" .. self.index .. "d"),
                align = "center",
                repeating = false,
                enabled = false,
                simple = true,
            })
            self.alpha2 = 1
            self.player.can_move = false
            self.controls.enabled = true
            Events.emit("on_dialogue_show", self.dialogue)
            return
        elseif obj_dialogue.id == "scene5d" then
            self.alpha = 1
            self.player.can_move = false
            self.controls.enabled = false
            self.controls.should_draw = false
            Events.emit("fadeout", 3, function()
                self.alpha = 1
                Events.emit("fadein", 1, function()
                    local game = require("game")
                    StateManager:switch(game, self.index)
                end)
            end)
            return
        end
    end

    self.player.can_move = false
    self.controls.enabled = false
    self.controls.should_draw = false
    Events.emit("fadeout", 3, function()
        self.alpha = 1
        Events.emit("fadein", 1, function()
            local game = require("game")
            StateManager:switch(game, self.index)
        end)
    end)
end

function Scene:update(dt)
    self.controls:update(dt)
    iter_objects(self.orders, self.objects, "update", dt)
    iter_objects(self.orders, self.objects, "check_collision", self.player)
    self.player:update(dt, self.objects.platform.height * self.objects.platform.sy)

    local looking_npc = self.looking_npc
    if looking_npc then looking_npc.sx = (self.player.x < looking_npc.x) and -1 or 1 end

    local looking_npc2 = self.looking_npc2
    if looking_npc2 then looking_npc2.sx = (self.player.x < looking_npc2.x) and -1 or 1 end

    self.dialogue:update(dt)
end

function Scene:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local w, h = self.images.bg:getDimensions()
    local sx = WW / w
    local sy = WH / h
    love.graphics.draw(self.images.bg, 0, 0, 0, sx, sy)

    iter_objects(self.orders, self.objects, "draw")

    self.player:draw()

    love.graphics.setColor(0, 0, 0, self.alpha2)
    local w, h = love.graphics.getDimensions()
    local dpi = love.graphics.getDPIScale()
    love.graphics.rectangle("fill", 0, 0, w * dpi, h * dpi)
    love.graphics.setColor(1, 1, 1, 1)

    self.dialogue:draw()
    self.controls:draw()

    love.graphics.setColor(0, 0, 0, self.alpha)
    love.graphics.rectangle("fill", 0, 0, 4096, 4096)
    love.graphics.setColor(1, 1, 1, 1)
end

function Scene:mousepressed(mx, my, mb)
    self.controls:mousepressed(mx, my, mb)
end

function Scene:mousereleased(mx, my, mb)
    self.controls:mousereleased(mx, my, mb)
end

function Scene:exit()
    Events.clear()
    self.sources.bgm:stop()
end

return Scene
