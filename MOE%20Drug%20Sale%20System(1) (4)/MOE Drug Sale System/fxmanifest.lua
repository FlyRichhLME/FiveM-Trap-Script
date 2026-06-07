fx_version 'cerulean'
game 'gta5'

author 'MOE Studios'
description 'QBCore Trap Phone Drug Sale & Delivery System with Reputation, HV Buyers, and NUI'
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

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

dependencies {
    'qb-core',
    'ox_lib'
}
