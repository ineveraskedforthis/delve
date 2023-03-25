local geom = require 'geom'
local conversion = require 'conversion'

---@alias local_coord number[] coordinate of block in chunk
---@alias local_index number index of block in chunk
---@alias CHUNK table<number, boolean|nil>
---@alias plane_coord number[] coordinate on plane

EPSILON = 0.001
SCALE = 10
BLOCK_SIZE_DISPLAY = 10
START_POSITION = {25, 25}
CHUNK_SIZE = 50


-- local function pos_neighbours(x, size) 
--     local tmp = {}
--     if x[1] + 1 < size then
--         table.insert(tmp, {x[1] + 1, x[2]})
--     end

--     if x[1] - 1 >= 0 then
--         table.insert(tmp, {x[1] - 1, x[2]})
--     end
    
--     if x[2] + 1 < size then
--         table.insert(tmp, {x[1], x[2] + 1})
--     end 

--     if x[2] - 1 >= 0 then
--         table.insert(tmp, {x[1], x[2] - 1})
--     end

--     return tmp
-- end

---creates enemy at given block
---@param coord local_coord
local function create_enemy(coord)
    table.insert(ENEMIES, 
        {
            position = geom.add(coord, {0.5, 0.5})
        }
    )
end

local function generate_tunnel(chunk, size, start, start_dir, length)
    if length == 0 then
        return
    end

    local start_index = conversion.chunk_coord_to_index(start, size)
    chunk[start_index] = nil

    local direction = start_dir
    if love.math.random() > 0.8 then
        local direction_index = love.math.random(4)
        if direction_index == 1 then
            direction = {0, 1}
        elseif direction_index == 2 then
            direction = {1, 0}
        elseif direction_index == 3 then
            direction = {0, -1}
        elseif direction_index == 4 then
            direction = {-1, 0}
        end
    end

    local next_cell = geom.add(direction, start)
    generate_tunnel(chunk, size, next_cell, direction, length - 1)
end

---comment
---@param x local_coord
---@param chunk CHUNK
---@param size number
---@return boolean
local function valid_block(x, chunk, size)
    if chunk[conversion.chunk_coord_to_index(x, size)] then
        return false
    end

    return true
end


---generates chunk
---@return CHUNK
local function generate_map() 
    local chunk = {}
    -- each chunk is 100x100
    for i = 0, CHUNK_SIZE - 1 do
        for j = 0, CHUNK_SIZE - 1 do
            chunk[conversion.chunk_coord_to_index({i, j}, CHUNK_SIZE)] = true
        end
    end

    for i = 0, CHUNK_SIZE - 1 do
        for j = 0, CHUNK_SIZE - 1 do
            if love.math.random() > 0.98 then
                generate_tunnel(chunk, CHUNK_SIZE, {i, j}, {1, 0}, 30)
            end
        end
    end

    generate_tunnel(chunk, CHUNK_SIZE, START_POSITION, {0, 1}, 70)

    for i = 0, CHUNK_SIZE - 1 do
        for j = 0, CHUNK_SIZE - 1 do
            if valid_block({i, j}, chunk, CHUNK_SIZE) and love.math.random() > 0.6 then
                create_enemy({i, j})
            end
        end
    end
    
    return chunk
end

---moves x toward target
---@param x plane_coord
---@param target plane_coord
---@param speed number
local function move_toward(x, target, speed)
    if (target == nil) then
        return
    end 
    local dir = geom.difference(target, x)
    if geom.norm(dir) <= speed + 0.001 then
        x[1] = target[1]
        x[2] = target[2]
        return
    end
    geom.normalize(dir)
    geom.scale(dir, speed)

    local new_x_1 = {x[1] + dir[1] * 1.1, x[2]}
    local new_x_2 = {x[1], x[2] + dir[2] * 1.1}
    local new_block_1 = conversion.plane_to_chunk_block(new_x_1)
    local new_block_2 = conversion.plane_to_chunk_block(new_x_2)

    local dir_1 = 0
    local dir_2 = 0

    if valid_block(new_block_1, CHUNK, CHUNK_SIZE) then
        dir_1 = 1
    end
    if valid_block(new_block_2, CHUNK, CHUNK_SIZE) then
        dir_2 = 1
    end

    x[1] = x[1] + dir[1] * dir_1
    x[2] = x[2] + dir[2] * dir_2
end

---draw the chunk on a screen
---@param chunk CHUNK
local function draw_chunk(chunk, camera)
    for k, v in pairs(chunk) do
        if v == true then
            local coord = conversion.index_to_chunk_coord(k, CHUNK_SIZE)
            local tmp = conversion.coord_to_screen(coord, BLOCK_SIZE_DISPLAY, camera)
            love.graphics.rectangle("fill", tmp[1], tmp[2], BLOCK_SIZE_DISPLAY * SCALE, BLOCK_SIZE_DISPLAY * SCALE)
        end
    end
end

local function draw_player(camera)
    local tmp = conversion.coord_to_screen(PLAYER.position, BLOCK_SIZE_DISPLAY, camera)
    love.graphics.draw(PLAYER_IMAGE, tmp[1] - IMAGE_w / 2, tmp[2] - IMAGE_h / 2)
    -- love.graphics.circle("line", tmp[1], tmp[2], BLOCK_SIZE_DISPLAY / 5 * SCALE)
end

local function draw_enemies(camera)
    for _, x in pairs(ENEMIES) do
        local tmp = conversion.coord_to_screen(x.position, BLOCK_SIZE_DISPLAY, camera)
        love.graphics.draw(ENEMY_IMAGE, tmp[1] - ENEMY_IMAGE_w / 2, tmp[2] - ENEMY_IMAGE_h / 2)
    end
end


local function update_camera()
    local width, height = love.window.getMode()
    local tmp = conversion.coord_to_screen(PLAYER.position, BLOCK_SIZE_DISPLAY, {0, 0})
    CAMERA = {-width / 2 + tmp[1], -height / 2 + tmp[2]}
end

function love.load()
    PLAYER = {
        hp = 100,
        max_hp = 100,
        position = geom.add(START_POSITION, {0.5, 0.5}),
        stats = {
            dexterity = 20,
            strength = 10
        },
        speed = 5
    }

    PLAYER_IMAGE = love.graphics.newImage("face.png")
    IMAGE_w, IMAGE_h = PLAYER_IMAGE:getDimensions()

    ENEMY_IMAGE = love.graphics.newImage("enemy2.png")
    ENEMY_IMAGE_w, ENEMY_IMAGE_h = ENEMY_IMAGE:getDimensions()

    ENEMIES = {}

    love.math.setRandomSeed(1)
    CHUNK = generate_map()
    update_camera()
end

function love.update(dt)
    if love.mouse.isDown(1) then
        local x, y = love.mouse.getPosition()
        local tmp = conversion.screen_to_coord({x, y}, BLOCK_SIZE_DISPLAY, CAMERA)
        move_toward(PLAYER.position, tmp, dt * PLAYER.speed)
    end
    update_camera()
end

function love.draw()
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    draw_chunk(CHUNK, CAMERA)
    draw_player(CAMERA)
    draw_enemies(CAMERA)
end

function love.mousepressed(x, y, button, istouch, presses)
    local tmp = conversion.screen_to_coord({x, y}, BLOCK_SIZE_DISPLAY, CAMERA)
    PLAYER.target = tmp
end

function love.mousemoved(x, y)
    local tmp = conversion.screen_to_coord({x, y}, BLOCK_SIZE_DISPLAY, CAMERA)
    PLAYER.target = tmp
end