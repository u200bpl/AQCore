fx_version 'cerulean'
game 'gta5'

description 'aq-Traphouse'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts { 
	'@aq-core/import.lua',
	'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

server_exports {
    'AddHouseItem',
    'RemoveHouseItem',
    'GetInventoryData',
    'CanItemBeSaled'
}

files {
    'html/*'
}