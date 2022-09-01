local Scene = class({
    name = "scene"
})

function Scene:new(index)
    assert(index and type(index) == "number" and index > 0)
    local id = self:type()
    local idn = id .. tostring(index)
    self.images = Assets.load_images(idn)
    self.sources = Assets.load_sources(idn)
    self.controls = Controls()

    self.objects = {}
    self.orders = {"platform", "bed", "fernando", "val"}

    self.dialogue = Dialogue({
        font = Assets.fonts.impact24,
        data = require("data.scene1"),
        align = "left",
        repeating = false,
    })

    Events.register(self, "on_dialogue_end")
end

function Scene:load()
    self.sources.bgm:play()
    self.sources.bgm:setLooping(true)

    local p_width, p_height = self.images.platform:getDimensions()
    self.objects.platform = Sprite({
        image = self.images.platform,
        x = 0, y = WH - p_height,
        sx = WW/p_width,
        is_hoverable = false, is_clickable = false,
        force_non_interactive = true,
        height = p_height,
    })

    local bed_width, bed_height = self.images.bed:getDimensions()
    self.objects.bed = Sprite({
        image = self.images.bed,
        x = WW * 0.15, y = WH - p_height - bed_height,
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
        r = math.pi/2,
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

    self.player = Player(WW * 0.7, self.objects.platform.y)
end

function Scene:on_dialogue_end()
    Events.emit("fadeout", 3, function()
        local game = require("game")
        StateManager:switch(game, 1)
    end)
end

function Scene:update(dt)
    self.controls:update(dt)
    iter_objects(self.orders, self.objects, "update", dt)
    iter_objects(self.orders, self.objects, "check_collision", self.player)
    self.player:update(dt, self.objects.platform.height)

    local val = self.objects.val
    val.sx = (self.player.x < val.x) and -1 or 1

    self.dialogue:update(dt)
end

function Scene:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local w, h = self.images.bg:getDimensions()
    local sx = WW/w
    local sy = WH/h
    love.graphics.draw(self.images.bg, 0, 0, 0, sx, sy)

    iter_objects(self.orders, self.objects, "draw")

    self.player:draw()
    self.dialogue:draw()
    self.controls:draw()
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
