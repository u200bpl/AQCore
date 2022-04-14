fx_version 'cerulean'
game 'gta5'

description 'aq-Drugs'
version '1.0.0'

shared_scripts { 
	'@aq-core/import.lua',
	'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/deliveries.lua',
    'client/cornerselling.lua'
}

server_scripts {
    'server/deliveries.lua',
    'server/cornerselling.lua'
}

server_exports {
    'GetDealers'
}

lua54 'yes'