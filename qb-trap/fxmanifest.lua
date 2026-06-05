fx_version 'cerulean'
game 'gta5'

author 'ChatGPT'
description 'Advanced QBCore Trap Script'
version '2.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'ox_lib'
}
