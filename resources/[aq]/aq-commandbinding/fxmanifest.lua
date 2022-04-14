fx_version 'cerulean'
game 'gta5'

description 'aq-CommandBinding'
version '1.0.0'

ui_page 'html/index.html'

shared_script '@aq-core/import.lua'
server_script 'server/main.lua'
client_script 'client/main.lua'

files {
	'html/*'
}