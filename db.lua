local module = {}

local lfs = require("lfs")
local utils = require("utils")
local cjson = require("cjson")

function module.init_schema()
    box.schema.create_space('users', { if_not_exists = true })
    box.space.users:create_index('primary', {parts = {1, 'integer'}})

    box.schema.create_space('locations', { if_not_exists = true })
    box.space.locations:create_index('primary', {parts = {1, 'integer'}})

    box.schema.create_space('visits', { if_not_exists = true })
    box.space.visits:create_index('primary', {parts = {1, 'integer'}})

    box.schema.user.grant('guest', 'read,write,execute', 'universe')
end

function module.load_data()
    local data_dir = '/tmp/data/'
    local extension = '.json'
    for file in lfs.dir(data_dir) do
        if file:len() > extension:len() and file:sub((file:len() - extension:len()) + 1) == extension then
            local content = utils.read_file(data_dir .. file)
            local entities = cjson.decode(content)
            
            if entities.users then
                for _, user in pairs(entities.users) do
                    box.space.users:insert{user.id, user.email, user.first_name, user.last_name, user.gender, user.birth_date}
                end
            end

            if entities.locations then
                for _, location in pairs(entities.locations) do
                    box.space.locations:insert{location.id, location.place, location.country, location.city, location.distance}
                end 
            end

            if entities.visits then
                for _, visit in pairs(entities.visits) do
                    box.space.visits:insert{visit.id, visit.location, visit.user, visit.visited_at, visit.mark}
                end 
            end
        end
    end
end

return module