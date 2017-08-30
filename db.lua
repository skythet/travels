local module = {}

local utils = require("utils")
local cjson = require("cjson")
local msgpack = require("msgpack")
local log = require("log")
local fiber = require("fiber")

function module.init_schema()
    box.schema.space.create('users')
    box.space.users:create_index('primary', {parts = {1, 'integer'}})

    box.schema.space.create('locations')
    box.space.locations:create_index('primary', {parts = {1, 'integer'}})
    box.space.locations:create_index('country', {parts = {3, 'string'}, unique = false})

    box.schema.space.create('visits')
    box.space.visits:create_index('primary', {parts = {1, 'integer'}})
    box.space.visits:create_index('user_visit', {parts = {3, 'integer', 4, 'integer'}, unique = false})
    box.space.visits:create_index('location', {parts = {2, 'integer'}, unique = false})

    box.schema.user.grant('guest', 'read,write,execute', 'universe')
end

-- module.locations_cache = {}
-- module.users_cache = {}

function module.load_file(file_name, cond)
    -- log.error("Start loading file "..file_name)
    local content = read_file(file_name)
    local entities = cjson.decode(content)
    
    if entities.users then
        for _, user in pairs(entities.users) do
            box.space.users:insert{
                user.id, user.email, user.first_name, user.last_name, user.gender, user.birth_date,
                utils.get_user_age(user.birth_date),
                -- cjson.encode(user)
            }
        end
    end

    if entities.locations then
        for _, location in pairs(entities.locations) do
            box.space.locations:insert{
                location.id, location.place, location.country, location.city, location.distance,
                -- cjson.encode(location)
            }
        end
    end

    if entities.visits then
        for _, visit in pairs(entities.visits) do
            local gender = msgpack.NULL
            local birth_date = msgpack.NULL
            local place = msgpack.NULL
            local distance = msgpack.NULL
            local country = msgpack.NULL

            -- if not module.locations_cache[visit.location] then
            --     module.locations_cache[visit.location] = box.space.locations:get(visit.location):totable()
            -- end

            -- if not module.users_cache[visit.user] then
            --     module.users_cache[visit.user] = box.space.users:get(visit.user):totable()
            -- end

            box.space.visits:insert{
                visit.id, 
                visit.location, 
                visit.user, 
                visit.visited_at, 
                visit.mark,
                -- cjson.encode(visit)
                -- module.locations_cache[visit.location][5], -- distance
                -- module.locations_cache[visit.location][2], -- place
                -- module.users_cache[visit.user][5], -- gender
                -- utils.get_user_age(module.users_cache[visit.user][6]), -- user age
                -- module.locations_cache[visit.location][3],
            }
        end 
    end

    -- log.error("File loaded "..file_name)
end

-- https://stackoverflow.com/questions/4990990/lua-check-if-a-file-exists
function file_exists(name)
   local f = io.open(name, "r")
   if f ~= nil then io.close(f) return true else return false end
end

function module.load_data(entity_name)
    local data_dir = '/srv/data/'
    local extension = '.json'

    log.error('Load data: '..entity_name..'...')

    local count = 1
    local fibers = {}
    while true do
        local file_name = data_dir..entity_name.."_"..tostring(count)..".json"
        if file_exists(file_name) then
            module.load_file(file_name)
        else
            break
        end
        count = count + 1
    end
    log.error('All data for '..entity_name..' loaded')
end

function read_file(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end


return module