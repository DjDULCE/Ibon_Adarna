local Assets = {
    fonts = {}
}

local ASSETS_PATH = "assets/"
local SOURCES_PATH = ASSETS_PATH .. "sources/"
local VIDEOS_PATH = ASSETS_PATH .. "videos/"
local IMPACT_PATH = ASSETS_PATH .. "impact.ttf"
local font_sizes = {18, 20, 24, 28, 32}

function Assets.init()
    for _, size in ipairs(font_sizes) do
        Assets.fonts["impact" .. size] = love.graphics.newFont(IMPACT_PATH, size)
    end
end

function Assets.load_images(id)
    local images = {}
    local path = ASSETS_PATH .. id .. "/"
    local files = love.filesystem.getDirectoryItems(path)
    for _, filename in ipairs(files) do
        local key = filename:sub(0, -5)
        print("loading", filename)
        images[key] = love.graphics.newImage(path .. filename)
    end
    return images
end

function Assets.load_sources(id)
    local sources = {}
    local path = SOURCES_PATH .. id .. "/"
    local files = love.filesystem.getDirectoryItems(path)
    for _, filename in ipairs(files) do
        local key = filename:sub(0, -5)
        print("loading", filename)
        sources[key] = love.audio.newSource(path .. filename, "stream")
    end
    return sources
end

function Assets.load_video(id)
    print("loading video", id)
    return love.graphics.newVideo(VIDEOS_PATH .. id .. ".ogv")
end

return Assets
