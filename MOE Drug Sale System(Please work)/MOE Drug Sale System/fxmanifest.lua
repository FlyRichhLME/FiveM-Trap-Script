fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'QBCore Compatible To-Do List App'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@qb-core/import.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'qb-core'
}