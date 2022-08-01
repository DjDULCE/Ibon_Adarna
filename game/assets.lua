local Assets = {}

local ASSETS_PATH = "assets/"

function Assets.load_images(id)
    local images = {}
    local path = ASSETS_PATH .. id .. "/"
    local files = love.filesystem.getDirectoryItems(path)
    for _, filename in ipairs(files) do
        local key = filename:sub(0, -5)
        print("loading " .. filename)
        images[key] = love.graphics.newImage(path .. filename)
    end
    return images
end

return Assets
