fx_version 'cerulean'
game 'gta5'

description 'aq-TowJob'
version '1.0.0'

shared_scripts { 
	'@aq-core/import.lua',
	'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/gui.lua'
}

server_script 'server/main.lua'