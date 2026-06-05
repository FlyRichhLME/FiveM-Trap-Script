fx_version 'cerulean'
game 'gta5'

author 'MOE Studios'
description 'QBCore Drug Sale System with Prepaid Phone UI, Custom Drugs, Customer Interest, and Bulk Delivery'
version '1.5.0'

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
