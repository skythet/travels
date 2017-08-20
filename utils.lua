local module = {}

function module.read_file(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

function module.check_is_integer(number_string)
    if number_string then
        local number = tonumber(number_string)
        if number ~= nil and number == math.floor(number) then
            return
        else
            error(turbo.web.HTTPError(400))
        end
    end
end


return module