local module = {}

http_server = require('http.server')
db = require('db') 

httpd = http_server.new('0.0.0.0', 8888, {
    display_errors = true,
    log_requests = true
})

httpd:route({ path = '/' }, function(req) 
    local resp = req:render({text = req.method..' '..req.path })
    resp.headers['x-test-header'] = 'test';
    resp.status = 201
    return resp
end)

httpd:start()

return module