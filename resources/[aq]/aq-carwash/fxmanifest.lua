fx_version 'cerulean'
game 'gta5'

description 'aq-Carwash'
version '1.0.0'

shared_scripts { 
	'@aq-core/import.lua',
	'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'