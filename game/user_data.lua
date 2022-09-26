local JSON = require("libs.json.json")

local UserData = {
    filename = "data.json",
    data = {
        music = 1,
        sound = 1,
        score = { 0, 0, 0 },
        difficulty = 1,
        stage = 1,
        life = 10,
    },
}

function UserData:init()
    if not love.filesystem.getInfo(self.filename) then
        UserData:reset_progress()
        local data = JSON.encode(self.data)
        love.filesystem.write(self.filename, data)
        pretty.print(self.data)
    else
        local str_data = love.filesystem.read(self.filename)
        self.data = JSON.decode(str_data)
        print("loaded save data")
        pretty.print(self.data)
    end
end

function UserData:save()
    local data = JSON.encode(self.data)
    love.filesystem.write(self.filename, data)
    print("saved save data")
    pretty.print(self.data)
end

function UserData:reset_progress()
    local data = UserData.data
    local score = data.score
    for i = 1, #score do
        score[i] = 0
    end
    data.difficulty = 1
    data.stage = 1
end

return UserData
