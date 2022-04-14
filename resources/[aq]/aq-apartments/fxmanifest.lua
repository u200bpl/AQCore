fx_version 'cerulean'
game 'gta5'

description 'aq-Apartments'
version '1.0.0'

shared_script 'config.lua'

server_script 'server/main.lua'

client_scripts {
	'client/main.lua',
	'client/gui.lua'
}

dependencies {
	'aq-core',
	'aq-interior',
	'aq-clothing',
	'aq-weathersync'
}

lua54 'yes'