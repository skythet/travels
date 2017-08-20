log = require('log')
console = require('console')
db = require('db')

box.cfg {
    memtx_memory = 128 * 1024 * 1024;
    memtx_dir = '/var/lib/tarantool/';
    wal_dir = '/var/lib/tarantool/';
}

console.listen('0.0.0.0:3301')

box.once('init_schema', db.init_schema)
db.load_data()

-- run http server
require('server')