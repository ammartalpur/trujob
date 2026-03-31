fx_version "cerulean"

description "Truck Job"
author "Ammar Talpur"
version '1.0.0'

lua54 'yes'

games {
  "gta5"
}

ui_page 'web/build/index.html'

client_script "client/**/*"
server_script "server/**/*"

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua'
}

files {
	'web/build/index.html',
	'web/build/**/*',
}

dependencies {
  'ox_lib',
  'qbx_core'
}
