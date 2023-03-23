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
    }
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


---@alias CHUNK table<number, boolean|nil>

---generates chunk
---@return CHUNK
local function generate_map() 
    local chunk = {}

    -- each chunk is 100x100
    for i = 0, CHUNK_SIZE - 1 do
        for j = 0, CHUNK_SIZE - 1 do
            if love.math.random(2) > 1 then
                chunk[coord_to_index({i, j}, CHUNK_SIZE)] = true
            end
        end
    end

    chunk[0] = nil
    return chunk
end

SCALE = 5
BLOCK_SIZE_DISPLAY = 10

local function add(x, y)
    return {x[1] + y[1], x[2] + y[2]}
end

local function minus(x)
    return {-x[1], -x[2]}
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

local width, height = love.window.getMode()
local tmp = coord_to_screen(PLAYER.position, BLOCK_SIZE_DISPLAY, {0, 0})

CAMERA = {-width / 2 + tmp[1], -height / 2 + tmp[2]}
-- CAMERA = add(PLAYER.position, ({width / 2, height / 2}))

function love.update()
    
end

function love.draw()
    draw_chunk(CHUNK, CAMERA)
    draw_player(CAMERA)
end