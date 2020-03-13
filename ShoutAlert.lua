_addon.name = 'ShoutAlert'
_addon.author = 'Icy'
_addon.version = '1.0.0.0'
_addon.commands = {'shoutalert','sa'}

require('luau')
require('tables')
texts = require('texts')
require('logger')

default = {
	words = S{'Ambuscade','Zerde','Vinipata','Albumen'},
	doublebass = true,
	text = {text={size=10}},
}
settings = config.load(default)

display_box = function()
    local str
	str = ' ShoutAlert \n'
	for word in pairs(settings.words) do
		str = str..'> '..tostring(word)..'\n'
	end
    
    return str
end
sa_status = texts.new(display_box(),settings.text,settings)

function addon_command(...)
    local commands = {...}
	
	if commands[1] then
		commands[1] = commands[1]:lower()
		if commands[1] == 'add' or commands[1] == 'a' then
			settings.words:add(commands[2])
			log('Added', commands[2])
		elseif commands[1] == 'remove' or commands[1] == 'r' then
			if not commands[2] then return end
			for k in pairs(settings.words) do
				if k:lower() == commands[2]:lower() then
					settings.words[k] = nil
					log('Removed', commands[2])
					break
				end
			end
		elseif commands[1] == 'clear' or commands[1] == 'c' then
			for k in pairs(settings.words) do
				settings.words[k] = nil
			end
			log('list cleared.')
		elseif commands[1] == 'save' then
			settings:save()
			log('list saved.')
		end
	end
	sa_status:text(display_box())
end

function loaded()
	sa_status:text(display_box())
	sa_status:show()
end

windower.register_event("incoming text", function(original,modified,original_mode,modified_mode, blocked)
    if original_mode == 11 then
        for w in pairs(settings.words) do
            if(windower.wc_match(original, "*"..w.."*")) then
				if settings.doublebass then
					windower.play_sound(windower.addon_path..'sounds/doublebass.wav')
				else
					windower.play_sound(windower.addon_path..'sounds/chime.wav')
				end
				log(w, 'found in shout!')
				break
            end
        end
    end
end)

windower.register_event('addon command', addon_command)
windower.register_event('job change','login','load', loaded)


