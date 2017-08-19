log = require('log')
console = require('console')
db = require('db')

box.cfg {
    -- listen = '0.0.0.0:3301';
    memtx_memory = 128 * 1024 * 1024;
    memtx_dir = 'data/';
    wal_dir = 'data/';
    -- vinyl_cache = 0;
    -- checkpoint_interval = 3600;
    -- checkpoint_count = 3;
}

console.listen('0.0.0.0:3302')

box.once('init_schema', db.init_schema)

-- run http server
require('server')