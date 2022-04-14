fx_version 'cerulean'
game 'gta5'

description 'aq-VehicleKeys'
version '1.0.0'

shared_script '@aq-core/import.lua'
server_script 'server/main.lua'

client_script {
    'client/main.lua',
    'config.lua'
}

dependencies {
    'aq-core',
    'aq-skillbar'
}

lua54 'yes'