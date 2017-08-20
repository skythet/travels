local module = {}

local turbo = require("turbo")
local db = require('db')
local cjson = require('cjson') 
local utils = require('utils')
local log = require("log")

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
        -- todo check country
        local locations = nil
        if country then
            locations = box.space.locations.index.country:select{country}
        end

        local visits = {}
        for _, visit_tuple in box.space.visits.index.user:pairs{id} do
            local correct = true
            if from_date and visit_tuple[4] < tonumber(from_date) then
                correct = false
            end

            if correct and to_date and visit_tuple[4] > tonumber(to_date) then
                correct = false
            end

            if correct and to_distance and visit_tuple[6] > tonumber(to_distance) then
                correct = false
            end
            
            if correct and locations then
                local found = false
                for i = 1, #locations, 1 do
                    if locations[i][1] == visit_tuple[2] then
                        found = true
                        break
                    end
                end
                if found ~= true then
                    correct = false
                end
            end

            if correct then
                table.insert(visits, {
                    mark = visit_tuple[5],
                    visited_at = visit_tuple[4],
                    place = visit_tuple[7]
                })
            end
        end

        table.sort(visits, function(visit1, visit2)
            return visit1.visited_at < visit2.visited_at
        end)
        self:write(cjson.encode({
            visits = visits
        }))
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
            distance = location[5],
        }))
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
        end

        local mark_sum = 0;
        local mark_count = 0;
        local avg = 0;
        for _, visit_tuple in box.space.visits.index.location:pairs(id) do
            local correct = true
            if from_date and visit_tuple[4] < tonumber(from_date) then
                correct = false
            end

            if correct and to_date and visit_tuple[4] > tonumber(to_date) then
                correct = false
            end

            if correct and gender and visit_tuple[8] ~= gender then
                correct = false
            end

            local user_age = os.date('%Y', os.time() - (visit_tuple[9])) - 1970
            if correct and from_age and from_age > user_age then
                correct = false
            end

            if correct and to_age and to_age < user_age then
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
            avg = avg
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
            mark = visit[5],
        }))
        self:set_header('Content-Type', 'application/json')
        return
    end
    error(turbo.web.HTTPError(404))
end

local app = turbo.web.Application:new({
    {"/users/(%d+)/?$", UserHandler},
    {"/users/(%d+)/visits/?$", UserVisitsHandler},
    {"/locations/(%d+)/?$", LocationHandler},
    {"/locations/(%d+)/avg/?$", LocationAvgHandler},
    {"/visits/(%d+)/?$", VisitHandler}
})

app:listen(80)
turbo.ioloop.instance():start()

return module