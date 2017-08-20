local module = {}
local turbo = require("turbo")

function module.read_file(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

function module.check_is_integer(number_string)
    if number_string then
        local number = tonumber(number_string)
        if number and number == math.floor(number) then
            return
        else
            error(turbo.web.HTTPError(400))
        end
    end
end

function module.get_argument(r, arg_name)
    local value = nil
    if r.request.arguments and r.request.uri then
        value = r.request.arguments[arg_name]

        if value == nil and r.request.uri and (r.request.uri:match('?' .. arg_name ..'=') or r.request.uri:match('&' .. arg_name ..'=')) then
            error(turbo.web.HTTPError(400))
        end
        return value
    end
    return value
end


return module