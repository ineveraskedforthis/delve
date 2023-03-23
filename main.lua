---@alias local_coord number[]
---@alias local_index number

love.math.setRandomSeed(1)

PLAYER = {
    hp = 100,
    max_hp = 100,
    position = {-5, 50},
    stats = {
        dexterity = 20,
        strength = 10
    },
    speed = 5
}

CHUNK_SIZE = 100

---translate chunk local coordinate to index
---@param v local_coord
---@param size number
---@return local_index
local function coord_to_index(v, size)
    return v[1] * size + v[2]
end




---translate local index to local coordinate
---@param x local_index
---@param size number
---@return local_coord
local function index_to_coord(x, size) 
    return {math.floor(x / size), x % size}
end

local function pos_neighbours(x, size) 
    local tmp = {}
    if x[1] + 1 < size then
        table.insert(tmp, {x[1] + 1, x[2]})
    end

    if x[1] - 1 >= 0 then
        table.insert(tmp, {x[1] - 1, x[2]})
    end
    
    if x[2] + 1 < size then
        table.insert(tmp, {x[1], x[2] + 1})
    end 

    if x[2] - 1 >= 0 then
        table.insert(tmp, {x[1], x[2] - 1})
    end

    return tmp
end

---@alias CHUNK table<number, boolean|nil>


function generate_tunnel(chunk, size, start, start_dir, length)
    local start_index = coord_to_index(start, size)
    chunk[start_index] = nil
    
    local n = pos_neighbours(start)    
end

---generates chunk
---@return CHUNK
local function generate_map() 
    local chunk = {}

    -- each chunk is 100x100
    for i = 0, CHUNK_SIZE - 1 do
        for j = 0, CHUNK_SIZE - 1 do
            if love.math.random(8) > 2 then
                chunk[coord_to_index({i, j}, CHUNK_SIZE)] = true
            end
        end
    end

    -- generate main tunnel
    local center = math.floor(CHUNK_SIZE / 2)
    for i = 0, CHUNK_SIZE / 5 do
        chunk[coord_to_index({i, center}, CHUNK_SIZE)] = nil
        chunk[coord_to_index({i, center - 1}, CHUNK_SIZE)] = nil
        chunk[coord_to_index({i, center + 1}, CHUNK_SIZE)] = nil

        chunk[coord_to_index({i, center - 2}, CHUNK_SIZE)] = nil
        chunk[coord_to_index({i, center + 2}, CHUNK_SIZE)] = nil
    end

    -- generate a web of tunnels


    chunk[0] = nil
    return chunk
end

SCALE = 1
BLOCK_SIZE_DISPLAY = 10

local function add(x, y)
    return {x[1] + y[1], x[2] + y[2]}
end

local function diff(x, y)
    return {x[1] - y[1], x[2] - y[2]}
end

local function minus(x)
    return {-x[1], -x[2]}
end

local function norm(x) 
    return math.sqrt(x[1] * x[1] + x[2]  * x[2])
end

local function mult(x, c)
    return {x[1] * c, x[2] * c}
end

local function normalize(x)
    local tmp = norm(x) 
    x[1] = x[1] / tmp
    x[2] = x[2] / tmp
end

local function scale(x, s) 
    x[1] = x[1] * s 
    x[2] = x[2] * s
end

local function shift(x, shift)
    x[1] = x[1] + shift[1]
    x[2] = x[2] + shift[2]
end

local function move_toward(x, target, speed)
    if (target == nil) then
        return
    end 
    local dir = diff(target, x)
    if norm(dir) <= speed + 0.001 then
        x[1] = target[1]
        x[2] = target[2]
        return
    end
    normalize(dir)
    scale(dir, speed)
    shift(x, dir)
end

local function screen_to_coord(x, block_size, camera)
    local temp = add(x, camera)
    return {temp[1] / block_size / SCALE, temp[2] / block_size / SCALE}
end

local function coord_to_screen(x, block_size, camera)
    local tmp = {x[1] * block_size * SCALE, x[2] * block_size * SCALE}
    return add(tmp, minus(camera))
end

---draw the chunk on a screen
---@param chunk CHUNK
local function draw_chunk(chunk, camera)
    for k, v in pairs(chunk) do
        if v == true then
            local coord = index_to_coord(k, CHUNK_SIZE)
            local tmp = coord_to_screen(coord, BLOCK_SIZE_DISPLAY, camera)
            love.graphics.rectangle("fill", tmp[1], tmp[2], BLOCK_SIZE_DISPLAY * SCALE, BLOCK_SIZE_DISPLAY * SCALE)
        end
    end
end

local function draw_player(camera)
    local tmp = coord_to_screen(PLAYER.position, BLOCK_SIZE_DISPLAY, camera)
    love.graphics.circle("line", tmp[1], tmp[2], BLOCK_SIZE_DISPLAY / 5 * SCALE)
end



CHUNK = generate_map()

function love.load()

end

local function update_camera()
    local width, height = love.window.getMode()
    local tmp = coord_to_screen(PLAYER.position, BLOCK_SIZE_DISPLAY, {0, 0})
    CAMERA = {-width / 2 + tmp[1], -height / 2 + tmp[2]}
end


-- CAMERA = add(PLAYER.position, ({width / 2, height / 2}))

function love.update(dt)
    move_toward(PLAYER.position, PLAYER.target, dt * PLAYER.speed)
    update_camera()
end

function love.draw()
    draw_chunk(CHUNK, CAMERA)
    draw_player(CAMERA)
end

function love.mousepressed(x, y, button, istouch, presses)
    local tmp = screen_to_coord({x, y}, BLOCK_SIZE_DISPLAY, CAMERA)
    PLAYER.target = tmp
end