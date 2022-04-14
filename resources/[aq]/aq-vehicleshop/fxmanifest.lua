fx_version 'cerulean'
game 'gta5'

description 'aq-VehicleShop'
version '2.0.0'

shared_scripts { 
	'@aq-core/import.lua',
	'config.lua'
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}
