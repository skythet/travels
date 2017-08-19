local module = {}

local turbo = require("turbo")
db = require('db') 

local HelloWorldHandler = class("HelloWorldHandler", turbo.web.RequestHandler)
function HelloWorldHandler:get()
    self:write("Stopped!")
end

local app = turbo.web.Application:new({
    {"/stop", HelloWorldHandler}
})

app:listen(80)
turbo.ioloop.instance():start()

return module