log = require('log')
console = require('console')
db = require('db')

box.cfg {
    memtx_memory = (1 * 1024) * 1024 * 1024;
    vinyl_memory = (2 * 1024) * 1024 * 1024;
    vinyl_dir = '/var/lib/tarantool/';
    memtx_dir = '/var/lib/tarantool/';
    wal_dir = '/var/lib/tarantool/';
    -- wal_mode = 'none';
}

console.listen('0.0.0.0:3302')

box.once('init_schema', db.init_schema)

load_file = db.load_file

local x = os.clock()
db.load_data('users')
db.load_data('locations')
db.load_data('visits')
print(string.format("Data load elapsed time: %.2f\n", os.clock() - x))

-- run http server
require('server')