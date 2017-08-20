local module = {}

local lfs = require("lfs")
local utils = require("utils")
local cjson = require("cjson")

function module.init_schema()
    box.schema.create_space('users')
    box.space.users:create_index('primary', {parts = {1, 'integer'}})

    box.schema.create_space('locations')
    box.space.locations:create_index('primary', {parts = {1, 'integer'}})
    box.space.locations:create_index('country', {parts = {3, 'string'}, unique = false})

    box.schema.create_space('visits')
    box.space.visits:create_index('primary', {parts = {1, 'integer'}})
    box.space.visits:create_index('user', {parts = {3, 'integer'}, unique = false})
    box.space.visits:create_index('location', {parts = {2, 'integer'}, unique = false})

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
                    local location = box.space.locations:get(visit.location)
                    local user = box.space.users:get(visit.user)
                    box.space.visits:insert{
                        visit.id, 
                        visit.location, 
                        visit.user, 
                        visit.visited_at, 
                        visit.mark,
                        location[5],
                        location[2],
                        user[5], -- gender
                        user[6] -- birth date
                    }
                end 
            end
        end
    end
end

return module