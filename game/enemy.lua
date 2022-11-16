local Enemy = class({
    name = "enemy"
})

local damages_data = {1, 2, 4}
local attack_dist = 360

local translation = {
    wolf = "Lobo",
    snake = "Ahas",
    boar = "Baboy Damo",
    spider = "Gagamba",
    eagle = "Agila",
    adarna = "Ibong Adarna",
    bat = "Paniki",
    giant = "Higante",
    serpent = "Sepentye",
    crow = "Uwak",
    lion = "Leon",
    salermo = "Haring Salermo",
}

function Enemy:new(name, opts, images)
    self.sfx = Assets.load_sources("sfx", "static")
    self.sfx.enemy_attack:setLooping(false)
    local difficulty = UserData.data.difficulty
    self.name = name
    self.name_filipino = translation[name]
    self.health = 10
    self.max_health = self.health
    self.damage = damages_data[difficulty]

    self.sprite = Sprite(opts)
    self.images = images

    self.target_x = WW * 0.7

    local orig_x = self.sprite.x
    self.timer = timer(1,
        function(progress)
            self.sprite.x = mathx.lerp(orig_x, self.target_x, progress)
        end,
        function()
            self.timer = nil

            if self.dialogue then
                Events.emit("on_dialogue_show", self.dialogue)
            else
                Events.emit("start_battle", self)
            end
        end)

    Events.register(self, "enemy_start_attack")
    Events.register(self, "enemy_end_attack")
    Events.register(self, "damage_enemy")
    Events.register(self, "disappear")
end

function Enemy:damage_enemy(damage)
    Events.emit("display_damage", self.sprite, damage)
    self.health = self.health - damage

    if self.health <= 0 then
        self.timer_rotate = timer(0.25, nil, function()
                self.sprite.sx = self.sprite.sx * -1
                self.timer_rotate = timer(0.25, nil, function()
                    self.sprite.sx = self.sprite.sx * -1
                    self.timer_rotate = timer(0.25, nil, function()
                        self.sprite.sx = self.sprite.sx * -1
                        self.timer_rotate = timer(0.25, nil, function()
                            self.sprite.sx = self.sprite.sx * -1
                            self.timer_rotate = timer(0.25, nil, function()
                                self.sprite.sx = 1
                                self:disappear()
                            end)
                        end)
                    end)
                end)
            end)
    end
end

function Enemy:disappear()
    self.sprite.color = { 1, 0, 0 }
    self.timer_death = timer(1,
        function(progress)
            self.sprite.alpha = 1 - progress
        end,
        function()
            Events.emit("end_battle")
            Events.emit("post_battle", self.name)
            self.timer_death = nil
        end)

    --update score
    local difficulty = UserData.data.difficulty
    local score_inc = 0
    local max_score = 0
    if difficulty == 1 then
        score_inc = 2
        max_score = 40
    elseif difficulty == 2 then
        score_inc = 3
        max_score = 60
    elseif difficulty == 3 then
        score_inc = 4
        max_score = 80
    end
    local d = UserData.data.score
    d[difficulty] = d[difficulty] + score_inc
    if d[difficulty] > max_score then
        d[difficulty] = max_score
    end
    UserData:save()
end

function Enemy:enemy_start_attack()
    self.sfx.enemy_attack:play()
    self.sprite.target_x = self.sprite.x - attack_dist
    local triggered = false
    local orig_x = self.sprite.x
    self.timer_attack = timer(0.5,
        function(progress)
            self.sprite.x = mathx.lerp(orig_x, self.sprite.target_x, progress)
            if not triggered and progress >= 0.5 then
                triggered = true
            end
        end,
        function()
            Events.emit("damage_player", self.damage)
            self:enemy_end_attack()
        end)
end

function Enemy:enemy_end_attack()
    self.sprite.target_x = self.sprite.x + attack_dist
    local orig_x = self.sprite.x
    self.timer_attack = timer(0.5,
        function(progress)
            self.sprite.x = mathx.lerp(orig_x, self.sprite.target_x, progress)
        end,
        function()
            self.timer_attack = nil
            Events.emit("finished_turn")
        end)
end

function Enemy:update(dt)
    if self.timer then self.timer:update(dt) end
    if self.timer_attack then self.timer_attack:update(dt) end
    if self.timer_death then self.timer_death:update(dt) end
    if self.timer_rotate then self.timer_rotate:update(dt) end
end

function Enemy:draw()
    self.sprite:draw()

    local gap = 8
    local scale = 0.25
    local iw = self.images.icon:getWidth()
    local font = Assets.fonts.impact20
    local ix = WW - iw * scale
    love.graphics.draw(self.images.icon, ix - iw * scale, gap, 0, scale, scale)

    local hw, hh = self.images.heart:getDimensions()
    local hscale = 0.15
    local bx = ix - gap * 2 - iw * scale - hw * hscale * 0.5
    local by = gap * 3 + hh * hscale * 0.5
    for i = 1, self.max_health do
        if i <= self.health then
            love.graphics.setColor(1, 0, 0, 1)
        else
            love.graphics.setColor(0, 0, 0, 1)
        end
        local x = bx - (i - 1) * hw * hscale - gap * (i - 1)
        love.graphics.draw(self.images.heart, x, by, 0, hscale, hscale, hw * 0.5, hh * 0.5)
    end
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setFont(font)
    love.graphics.print(self.name_filipino,
        ix - gap * 2 - iw * scale,
        by + hh * scale * 0.5 + gap,
        0, 1, 1,
        font:getWidth(self.name_filipino), font:getHeight() * 0.5
    )
end

return Enemy
