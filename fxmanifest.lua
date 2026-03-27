fx_version 'cerulean'
game 'gta5'

name 'c8n_blips'
author 'c8n'
description 'Standalone FiveM blip management system'
version '1.0.0'

lua54 'yes'

shared_script 'config.lua'

client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}
