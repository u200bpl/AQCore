fx_version 'cerulean'
game 'gta5'

description 'aq-Weapons'
version '1.0.0'

shared_scripts { 
	'@aq-core/import.lua',
	'config.lua'
}

server_script 'server/main.lua'
client_script 'client/main.lua'

files {
    'weaponsnspistol.meta',
}

data_file 'WEAPONINFO_FILE_PATCH' 'weaponsnspistol.meta'