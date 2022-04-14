fx_version 'cerulean'
game 'gta5'

description 'aq-Phone'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
	'@aq-core/import.lua',
    '@aq-apartments/config.lua',
    '@aq-garages/config.lua',
}

client_scripts {
    'client/main.lua',
    'client/animation.lua'
}

server_script 'server/main.lua'

files {
    'html/*.html',
    'html/js/*.js',
    'html/img/*.png',
    'html/css/*.css',
    'html/fonts/*.ttf',
    'html/fonts/*.otf',
    'html/fonts/*.woff',
    'html/img/backgrounds/*.png',
    'html/img/apps/*.png',
}
