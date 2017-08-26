log = require('log')
console = require('console')
db = require('db')

box.cfg {
    memtx_memory = (2 * 1024) * 1024 * 1024;
    memtx_dir = '/var/lib/tarantool/';
    wal_dir = '/var/lib/tarantool/';
    wal_mode = 'none';
}

console.listen('0.0.0.0:3302')

box.once('init_schema', db.init_schema)
db.load_data()

-- run http server
require('server')