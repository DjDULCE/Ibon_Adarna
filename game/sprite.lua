local Sprite = class({
    name = "Sprite"
})

function Sprite:new(opts)
    self.name = opts.name
    self.image = opts.image
    self.width = self.image:getWidth()
    self.height = opts.height
    self.x, self.y = opts.x, opts.y
    self.orig_x, self.orig_y = self.x, self.y
    self.r = opts.r or 0
    self.sx, self.sy = opts.sx or 1, opts.sy or 1
    self.ox, self.oy = opts.ox or 0, opts.oy or 0
    self.sx_dt = opts.sx_dt or 0.1
    self.sy_dt = opts.sy_dt or 0.1
    self.color = opts.color or {1, 1, 1}

    self.animated = opts.animated
    if self.animated then
        local g = Anim8.newGrid(self.animated.w, self.animated.h, self.image:getDimensions())
        self.anim8 = Anim8.newAnimation(
            g(self.animated.g, 1),
            self.animated.speed,
            self.animated.on_loop
        )

        if self.animated.start_frame then
            self.anim8:gotoFrame(self.animated.start_frame)
        end
    end

    local w, h = self.image:getDimensions()
    w, h = w * self.sx, h * self.sy
    self.size = vec2(w, h)
    self.half_size = vec2(w * 0.5, h * 0.5)

    local rx = self.x - self.ox * self.sx
    local ry = self.y - self.oy * self.sy
    self.pos = vec2(rx, ry)
    self.center_pos = vec2(rx + (w * 0.5), ry + (h * 0.5))

    self.mouse = vec2()
    self.is_overlap = false
    self.alpha = opts.alpha or 1
    self.max_alpha = opts.max_alpha or 1
    self.is_clickable = true
    self.is_hoverable = true
    self.on_click_sound = opts.on_click_sound

    if opts.is_clickable ~= nil then
        self.is_clickable = opts.is_clickable
    end
    if opts.is_hoverable ~= nil then
        self.is_hoverable = opts.is_hoverable
    end

    self.text_color = opts.text_color or {1, 1, 1}
    self.text_alpha = opts.text_alpha
    self.text = opts.text
    self.font = opts.font
    self.tx = opts.tx or self.x
    self.ty = opts.ty or self.y
    self.tox = opts.tox or 0
    self.toy = opts.toy or 0
    self.tsx = opts.tsx or 1
    self.tsy = opts.tsy or 1

    self.choice_letter = opts.choice_letter

    self.is_printf = opts.is_printf
    self.limit = opts.limit
    self.align = opts.align or "left"
    self.collision_include_text = opts.collision_include_text

    self.value = opts.value
    self.force_non_interactive = opts.force_non_interactive
    self.target_x = opts.target_x
    self.target_y = opts.target_y

    self.collider = opts.collider
    if self.collider then
        local x = self.collider.x or self.x
        local y = self.collider.y or self.y
        self.vpos = vec2(x, y)
        self.vsize = vec2(self.collider.w * 0.5, self.collider.h * 0.5)
    end

    self.parallax_x = opts.parallax_x
    self.speed = opts.speed or 64
    if self.parallax_x then
        Events.register(self, "on_player_move_x")
        local iw, ih = self.image:getDimensions()
        self.quad = love.graphics.newQuad(0, 0, iw, ih, iw, ih)
        self.image:setWrap("repeat")
    end

    self.sound = opts.sound
    if self.sound then
        self.sound:setLooping(false)
    end
end

function Sprite:add_collider(tbl)
    self.collider = tbl
    local x = self.collider.x or self.x
    local y = self.collider.y or self.y
    self.vpos = vec2(x, y)
    self.vsize = vec2(self.collider.w * 0.5, self.collider.h * 0.5)
end

function Sprite:on_player_move_x(dir, dt)
    local x, y, w, h = self.quad:getViewport()
    local rw, rh = self.quad:getTextureDimensions()
    self.quad:setViewport(x + self.speed * dt * dir, y, w, h, rw, rh)
end

function Sprite:update_y(y)
    self.y = y
    self.pos.y = y

    local h = self.image:getHeight() * self.sy
    local ry = self.y - self.oy * self.sy
    self.center_pos.y = ry + (h * 0.5)
end

function Sprite:check_collision(player)
    local col = self.collider
    if not col then return end
    local res = intersect.aabb_aabb_overlap(self.vpos, self.vsize, player.vpos, player.vsize)
    if res then
        self.in_collision = true
        Events.emit("on_collide", self)
    elseif self.in_collision then
        self.in_collision = false
        Events.emit("on_remove_collide", self)
    end
end


function Sprite:update(dt)
    local mx, my = love.mouse.getPosition()
    self.mouse.x, self.mouse.y = mx, my

    local col = self.collider
    if col then
        local x = self.collider.x or self.x
        local y = self.collider.y or self.y
        self.vpos.x, self.vpos.y = x, y
        self.vsize.x, self.vsize.y = self.collider.w * 0.5, self.collider.h * 0.5
    end

    local cp = self.center_pos
    local hs = self.half_size

    if self.collision_include_text then
        local fw = self.font:getWidth(self.text) * 0.5
        cp = cp:sadd(fw, 0)
        hs = hs:sadd(fw, 0)
    end

    self.is_overlap = intersect.point_aabb_overlap(self.mouse, cp, hs)

    if self.on_down and self.is_overlap and love.mouse.isDown(1) then
        self.on_down()
    end

    if self.anim8 then
        self.anim8:update(dt)
    end

    if self.force_non_interactive then
        self.is_clickable = false
        self.is_hoverable = false
    end
end

function Sprite:draw()
    local sx, sy = self.sx, self.sy
    if (self.is_hoverable and self.is_overlap) or self.is_hovered then
        sx = sx + self.sx_dt
        sy = sy + self.sy_dt
    end

    local r, g, b = unpack(self.color)
    love.graphics.setColor(r, g, b, self.alpha)

    if self.image then
        if self.anim8 then
            self.anim8:draw(self.image, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
        elseif self.quad then
            love.graphics.draw(self.image, self.quad, self.x, self.y, self.r, sx, sy, self.ox, self.oy)
        else
            love.graphics.draw(self.image, self.x, self.y, self.r, sx, sy, self.ox, self.oy)
        end
    end

    if self.text then
        local tmp_font
        if self.font then
            tmp_font = love.graphics.getFont()
            love.graphics.setFont(self.font)
        end

        local tsx, tsy = self.tsx, self.tsy
        if self.is_hoverable and self.is_overlap then
            tsx = tsx + self.sx_dt
            tsy = tsy + self.sy_dt
        end

        local tr, tg, tb = unpack(self.text_color)
        love.graphics.setColor(tr, tg, tb, self.text_alpha or self.alpha)

        if not self.is_printf then
            love.graphics.print(self.text, self.tx, self.ty, 0, tsx, tsy, self.tox, self.toy)
        else
            love.graphics.printf(self.text, self.tx, self.ty, self.limit, self.align,
             0, tsx, tsy, self.tox, self.toy)
        end

        if self.choice_letter then
            love.graphics.print(
                self.choice_letter,
                self.x, self.y,
                0,
                tsx, tsy,
                self.font:getWidth(self.choice_letter) * 0.5,
                self.font:getHeight() * 0.5
            )
        end

        if self.font then
            love.graphics.setFont(tmp_font)
        end
    end

    -- local col = self.collider
    -- if col then
    --     love.graphics.setColor(1, 0, 0, 1)
    --
    --     local x = col.x or self.x
    --     local y = col.y or self.y
    --     if col.origin == "center" then
    --         x = x - col.w * 0.5
    --         y = y - col.h * 0.5
    --     end
    --
    --     love.graphics.rectangle("line",
    --         x, y,
    --         col.w, col.h
    --     )
    -- end

    love.graphics.setColor(1, 1, 1, 1)
end

function Sprite:mousepressed(mx, my, mb)
    if not self.is_clickable then return end
end

function Sprite:mousereleased(mx, my, mb)
    if self.force_non_interactive then return end
    if not self.is_clickable then return end
    if mb == 1 and self.is_overlap and self.on_clicked then
        if self.on_click_sound then
            self.on_click_sound:play()
            self.on_click_sound:setLooping(false)
        end
        self:on_clicked()
        self.is_overlap = false

        if self.sound then
            if self.sound:isPlaying() then
                self.sound:stop()
            end
            self.sound:play()
        end

        return true
    end
end

return Sprite
