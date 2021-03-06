local module = {}

local turbo = require("turbo")
local db = require('db')
local cjson = require('cjson') 
local utils = require('utils')
local log = require("log")
local msgpack = require("msgpack")

local UserHandler = class("UserHandler", turbo.web.RequestHandler)
function UserHandler:get(id)
    local user = box.space.users:get(tonumber(id))
    if user then
        self:write(cjson.encode({
            id = user[1],
            email = user[2],
            first_name = user[3],
            last_name = user[4],
            gender = user[5],
            birth_date = user[6]
        }))
        self:set_header('Content-Type', 'application/json')
        return
    end
    error(turbo.web.HTTPError(404))
end

function UserHandler:post(id)
    id = tonumber(id)
    local user = box.space.users:get(id)
    if user then
        user = user:totable()
        user_new = utils.json_decode(self)
        local update_table = {}
        if user_new.email then
            table.insert(update_table, {'=', 2, user_new.email})
        end
        if user_new.first_name then
            table.insert( update_table,{'=', 3, user_new.first_name} )
        end
        if user_new.last_name then
            table.insert( update_table,{'=', 4, user_new.last_name} )
        end
        if user_new.gender then
            table.insert( update_table,{'=', 5, user_new.gender} )
            user[5] = user_new.gender
        end
        if user_new.birth_date then
            utils.check_is_integer(user_new.birth_date)
            table.insert( update_table,{'=', 6, user_new.birth_date} )
            table.insert( update_table,{'=', 7, utils.get_user_age(user_new.birth_date)} )
            user[6] = user_new.birth_date
        end

        box.space.users:update(id, update_table)

        self:write('{}')
        self:set_header('Content-Type', 'application/json')
        return
    end
    error(turbo.web.HTTPError(404))
end

local UserNewHandler = class("UserNewHandler", turbo.web.RequestHandler)
function UserNewHandler:post()
    local user_new = utils.json_decode(self)

    box.space.users:insert({
        user_new.id,
        user_new.email,
        user_new.first_name,
        user_new.last_name,
        user_new.gender,
        user_new.birth_date,
        utils.get_user_age(user_new.birth_date),
    })

    self:write('{}')
    self:set_header('Content-Type', 'application/json')
end

local UserVisitsHandler = class("UserVisitsHandler", turbo.web.RequestHandler)
function UserVisitsHandler:get(id)
    id = tonumber(id)
    local user = box.space.users:get(id)
    if user then
        local from_date = utils.get_argument(self, 'fromDate')
        utils.check_is_integer(from_date)

        local to_date = utils.get_argument(self, 'toDate')
        utils.check_is_integer(to_date)

        local to_distance = utils.get_argument(self, 'toDistance')
        utils.check_is_integer(to_distance)

        local country = utils.get_argument(self, 'country')

        local visits = {}
        for _, visit_tuple in box.space.visits.index.user_visit:pairs({id, nil}, {iterator = box.index.EQ}) do
            local correct = true

            local location = box.space.locations:get(visit_tuple[2])

            if from_date and visit_tuple[4] ~= msgpack.NULL and visit_tuple[4] <= tonumber(from_date) then
                correct = false
            end

            if correct and to_date and visit_tuple[4] ~= msgpack.NULL and visit_tuple[4] >= tonumber(to_date) then
                correct = false
            end

            if correct and to_distance and (location[5] >= tonumber(to_distance)) then
                correct = false
            end
            
            if correct and country and (country ~= location[3]) then
                correct = false
            end

            if correct then
                table.insert(visits, {
                    mark = visit_tuple[5],
                    visited_at = visit_tuple[4],
                    place = location[2]
                })
            end
        end
        
        if table.maxn(visits) == 0 then
            self:write('{"visits": []}')
        else
            self:write(cjson.encode({
                visits = visits
            }))
        end
        self:set_header('Content-Type', 'application/json')

        return
    end
    error(turbo.web.HTTPError(404))
end

local LocationHandler = class("LocationHandler", turbo.web.RequestHandler)
function LocationHandler:get(id)
    local location = box.space.locations:get(tonumber(id))
    if location then
        self:write(cjson.encode({
            id = location[1],
            place = location[2],
            country = location[3],
            city = location[4],
            distance = location[5]
        }))
        self:set_header('Content-Type', 'application/json')
        return
    end
    error(turbo.web.HTTPError(404))
end

local LocationNewHandler = class("LocationNewHandler", turbo.web.RequestHandler)
function LocationNewHandler:post()
    local location_new = utils.json_decode(self)

    box.space.locations:insert({
        location_new.id,
        location_new.place,
        location_new.country,
        location_new.city,
        location_new.distance,
    })

    self:write('{}')
    self:set_header('Content-Type', 'application/json')
end

function LocationHandler:post(id)
    id = tonumber(id)
    local location = box.space.locations:get(id)
    if location then
        location = location:totable()
        location_new = utils.json_decode(self)
        local update_table = {}
        if location_new.place then
            location[2] = location_new.place
            table.insert(update_table, {'=', 2, location_new.place})
        end
        if location_new.country then
            location[3] = location_new.country
            table.insert(update_table, {'=', 3, location_new.country})
        end
        if location_new.city then
            location[4] = location_new.city
            table.insert(update_table, {'=', 4, location_new.city})
        end
        if location_new.distance then
            location[5] = location_new.distance
            table.insert(update_table, {'=', 5, location_new.distance})
        end

        box.space.locations:update(id, update_table)

        self:write('{}')
        self:set_header('Content-Type', 'application/json')
        return
    end
    error(turbo.web.HTTPError(404))
end

local LocationAvgHandler = class("LocationAvgHandler", turbo.web.RequestHandler)
function LocationAvgHandler:get(id)
    id = tonumber(id)
    local location = box.space.locations:get(id)
    if location then
        local from_date = utils.get_argument(self, 'fromDate')
        utils.check_is_integer(from_date)

        local to_date = utils.get_argument(self, 'toDate')
        utils.check_is_integer(to_date)

        local from_age = utils.get_argument(self, 'fromAge')
        utils.check_is_integer(from_age)

        local to_age = utils.get_argument(self, 'toAge')
        utils.check_is_integer(to_age)

        local gender = utils.get_argument(self, 'gender')
        if gender and gender ~= 'f' and gender ~= 'm' then
            error(turbo.web.HTTPError(400))
            return
        end

        local mark_sum = 0;
        local mark_count = 0;
        local avg = 0;
        for _, visit_tuple in box.space.visits.index.location:pairs(id) do
            local correct = true

            local user = box.space.users:get(visit_tuple[3])

            if from_date and visit_tuple[4] ~= msgpack.NULL and visit_tuple[4] < tonumber(from_date) then
                correct = false
            end

            if correct and to_date and visit_tuple[4] ~= msgpack.NULL and visit_tuple[4] >= tonumber(to_date) then
                correct = false
            end

            if correct and gender and (user[5] ~= gender) then
                correct = false
            end
            
            if correct and from_age and (user[7] < tonumber(from_age)) then
                correct = false
            end

            if correct and to_age and (tonumber(to_age) <= user[7]) then
                correct = false
            end

            if correct then
                mark_sum = mark_sum + visit_tuple[5]
                mark_count = mark_count + 1
            end
        end

        if mark_count > 0 then
            avg = mark_sum / mark_count
        end
        self:write(cjson.encode({
            avg = utils.round(avg, 5)
        }))
        self:set_header('Content-Type', 'application/json')
        return
    end
    error(turbo.web.HTTPError(404))
end

local VisitHandler = class("VisitHandler", turbo.web.RequestHandler)
function VisitHandler:get(id)
    local visit = box.space.visits:get(tonumber(id))
    if visit then
        self:write(cjson.encode({
            id = visit[1],
            location = visit[2],
            user = visit[3],
            visited_at = visit[4],
            mark = visit[5]
        }))
        self:set_header('Content-Type', 'application/json')
        return
    end
    error(turbo.web.HTTPError(404))
end

local VisitNewHandler = class("VisitNewHandler", turbo.web.RequestHandler)
function VisitNewHandler:post()
    local visit_new = utils.json_decode(self)

    box.space.visits:insert{
        visit_new.id, 
        visit_new.location, 
        visit_new.user, 
        visit_new.visited_at, 
        visit_new.mark,
    }

    self:write('{}')
    self:set_header('Content-Type', 'application/json')
end

function VisitHandler:post(id)
    id = tonumber(id)
    local visit = box.space.visits:get(id)
    if visit then
        visit = visit:totable()
        visit_new = utils.json_decode(self)
        local update_table = {}
        if visit_new.location then
            visit[2] = visit_new.location
            table.insert(update_table, {'=', 2, visit_new.location})
        end
        if visit_new.user then
            visit[3] = visit_new.user
            table.insert(update_table, {'=', 3, visit_new.user})
        end
        if visit_new.visited_at then
            visit[4] = visit_new.visited_at
            table.insert(update_table, {'=', 4, visit_new.visited_at})
        end
        if visit_new.mark then
            visit[5] = visit_new.mark
            table.insert(update_table, {'=', 5, visit_new.mark})
        end
        box.space.visits:update(id, update_table)

        self:write('{}')
        self:set_header('Content-Type', 'application/json')
        return
    end
    error(turbo.web.HTTPError(404))
end

local app = turbo.web.Application:new({
    {"^/users/(%d+)/?$", UserHandler},
    {"^/users/new/?$", UserNewHandler},
    {"^/users/(%d+)/visits/?$", UserVisitsHandler},
    {"^/locations/(%d+)/?$", LocationHandler},
    {"^/locations/(%d+)/avg/?$", LocationAvgHandler},
    {"^/locations/new/?$", LocationNewHandler},
    {"^/visits/(%d+)/?$", VisitHandler},
    {"^/visits/new/?$", VisitNewHandler}
})

turbo.log.categories = {
    ["success"] = false,
    ["notice"] = false,
    ["warning"] = false,
    ["error"] = true,
    ["debug"] = false,
    ["development"] = false
}

app:listen(80)

turbo.ioloop.instance():add_signal_handler(turbo.signal.SIGINT, function() 
    turbo.ioloop.instance():close()
end)

turbo.ioloop.instance():start()


return module