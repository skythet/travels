log = require('log')
console = require('console')
db = require('db')
console = require('console')


box.cfg {
    memtx_memory = 128 * 1024 * 1024;
    memtx_dir = '/var/lib/tarantool/';
    wal_dir = '/var/lib/tarantool/';
}

console.listen('/var/lib/tarantool/admin.sock')

box.once('init_schema', db.init_schema)
db.load_data()

-- run http server
require('server')