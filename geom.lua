module = {}

function module.add(x, y)
    return {x[1] + y[1], x[2] + y[2]}
end

function module.difference(x, y)
    return {x[1] - y[1], x[2] - y[2]}
end

function module.minus(x)
    return {-x[1], -x[2]}
end

function module.norm(x) 
    return math.sqrt(x[1] * x[1] + x[2]  * x[2])
end

function module.mult(x, c)
    return {x[1] * c, x[2] * c}
end

function module.normalize(x)
    local tmp = module.norm(x) 
    x[1] = x[1] / tmp
    x[2] = x[2] / tmp
end

function module.scale(x, s) 
    x[1] = x[1] * s 
    x[2] = x[2] * s
end

function module.shift(x, shift)
    x[1] = x[1] + shift[1]
    x[2] = x[2] + shift[2]
end

function module.dot(x, y)
    return x[1] * y[1] + x[2] * y[2]
end

function module.project_x_onto_y(x, y)
    if module.norm(x) < EPSILON then
        return {0, 0}
    end
    if(module.norm(y)) < EPSILON then
        return {0, 0}
    end
    local ratio = module.dot(x, y) / module.norm(y)
    return module.mult(y, ratio)
end

return module