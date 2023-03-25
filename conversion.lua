local geom = require 'geom'

local module = {}

function module.screen_to_coord(x, block_size, camera)
    local temp = geom.add(x, camera)
    return {temp[1] / block_size / SCALE, temp[2] / block_size / SCALE}
end

function module.coord_to_screen(x, block_size, camera)
    local tmp = {x[1] * block_size * SCALE, x[2] * block_size * SCALE}
    return geom.add(tmp, geom.minus(camera))
end

---translate chunk local coordinate to index
---@param v local_coord
---@param size number
---@return local_index
function module.chunk_coord_to_index(v, size)
    return v[1] * size + v[2]
end

---translate local index to local coordinate
---@param x local_index
---@param size number
---@return local_coord
function module.index_to_chunk_coord(x, size) 
    return {math.floor(x / size), math.floor(x % size)}
end

---converts plane coordinate to chunk block coordinate
---@param x plane_coord
---@return local_coord
function module.plane_to_chunk_block(x)
    return {math.floor(x[1]), math.floor(x[2])}
end

return module