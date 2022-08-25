local Scene = class({
    name = "scene"
})

function Scene:new(index)
    assert(index and type(index) == "number" and index > 0)
    local id = self:type()
    local idn = id .. tostring(index)
    self.images = Assets.load_images(idn)
    self.controls = Controls(self)

    self.objects = {}
    self.orders = {"platform", "bed", "fernando", "val"}

    self.dialogue = Dialogue({
        font = Assets.fonts.impact24,
        data = require("data.scene1"),
        enabled = true,
    })
end

function Scene:load()
    local p_width, p_height = self.images.platform:getDimensions()
    self.platform = {
        image = self.images.platform,
        x = 0, y = WH - p_height,
        sx = WW/p_width,
        height = p_height,
    }

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

    self.player = Player(WW * 0.7, self.platform.y)
end

function Scene:update(dt)
    self.controls:update(dt)
    iter_objects(self.orders, self.objects, "update", dt)
    self.player:update(dt, self.platform.height)

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

    local platform = self.platform
    love.graphics.draw(platform.image, platform.x, platform.y, 0, platform.sx)

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
end

return Scene
