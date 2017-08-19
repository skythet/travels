local module = {}

function module.init_schema()
    box.schema.create_space('users', { if_not_exists = true })

    box.schema.user.grant('guest', 'read,write,execute', 'universe')
end

return module