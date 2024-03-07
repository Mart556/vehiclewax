fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Mart556'
description 'Simple script for vehicle waxing.'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependency 'ox_lib'
