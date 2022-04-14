fx_version 'cerulean'
game 'gta5'

description 'aq-SmallResources'
version '1.0.0'

shared_scripts { 
	'@aq-core/import.lua',
	'config.lua'
}

server_script 'server/*.lua'
client_script 'client/*.lua'

data_file 'FIVEM_LOVES_YOU_4B38E96CC036038F' 'events.meta'
data_file 'FIVEM_LOVES_YOU_341B23A2F0E0F131' 'popgroups.ymt'

files {
	'events.meta',
	'popgroups.ymt',
	'relationships.dat'
}

exports {
	'HasHarness'
}
