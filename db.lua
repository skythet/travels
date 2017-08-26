local module = {}

local lfs = require("lfs")
local utils = require("utils")
local cjson = require("cjson")
local msgpack = require("msgpack")
local log = require("log")

function module.init_schema()
    box.schema.create_space('users')
    box.space.users:create_index('primary', {parts = {1, 'integer'}})

    box.schema.create_space('locations')
    box.space.locations:create_index('primary', {parts = {1, 'integer'}})
    box.space.locations:create_index('country', {parts = {3, 'string'}, unique = false})

    box.schema.create_space('visits')
    box.space.visits:create_index('primary', {parts = {1, 'integer'}})
    box.space.visits:create_index('user_visit', {parts = {3, 'integer', 4, 'integer'}, unique = false})
    box.space.visits:create_index('location', {parts = {2, 'integer'}, unique = false})

    box.schema.user.grant('guest', 'read,write,execute', 'universe')
end
function load_file(file_name)
    local content = read_file(file_name)
    local entities = cjson.decode(content)
    
    if entities.users then
        box.begin()
        for _, user in pairs(entities.users) do
            box.space.users:insert{
                user.id, user.email, user.first_name, user.last_name, user.gender, user.birth_date,
                cjson.encode(user)
            }
        end
        box.commit()
    end

    if entities.locations then
        box.begin()
        for _, location in pairs(entities.locations) do
            box.space.locations:insert{
                location.id, location.place, location.country, location.city, location.distance,
                cjson.encode(location)
            }
        end 
        box.commit()
    end

    if entities.visits then
        for _, visit in pairs(entities.visits) do
            local gender = msgpack.NULL
            local birth_date = msgpack.NULL
            local place = msgpack.NULL
            local distance = msgpack.NULL
            local country = msgpack.NULL

            local location = box.space.locations:get(visit.location)
            if location ~= nil then
                place = location[2]
                distance = location[5]
                country = location[3]
            end

            local user = box.space.users:get(visit.user)
            if user ~= nil then
                gender = user[5]
                birth_date = user[6]
            end

            box.space.visits:insert{
                visit.id, 
                visit.location, 
                visit.user, 
                visit.visited_at, 
                visit.mark,
                distance, -- distance
                place, -- place
                gender, -- gender
                birth_date, -- birth date
                country,
                cjson.encode(visit)
            }
        end 
    end
end

-- https://stackoverflow.com/questions/4990990/lua-check-if-a-file-exists
function file_exists(name)
   local f = io.open(name, "r")
   if f ~= nil then io.close(f) return true else return false end
end

function module.load_data()
    local data_dir = '/srv/data/'
    local extension = '.json'

    log.error('Load data...')

    local count = 1
    while true do
        local file_name = data_dir.."/users_"..tostring(count)..".json"
        if file_exists(file_name) then
            load_file(file_name)
        else
            break
        end
        count = count + 1
    end

    count = 1
    while true do
        local file_name = data_dir.."/locations_"..tostring(count)..".json"
        if file_exists(file_name) then
            load_file(file_name)
        else
            break
        end
        count = count + 1
    end

    count = 1
    while true do
        local file_name = data_dir.."/visits_"..tostring(count)..".json"
        if file_exists(file_name) then
            load_file(file_name)
        else
            break
        end
        count = count + 1
    end

    log.error('All data loaded')
end

function read_file(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end


return module