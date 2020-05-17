_addon.name = 'ShoutAlert'
_addon.author = 'Icy'
_addon.version = '1.0.3'
_addon.commands = {'shoutalert','sa'}

-- 1.0.3: Display now wraps the added words in quotes, so spaces can be identified. ie: " Ou "
-- 1.0.2: ignores your shouts if a word matches

require('luau')
require('tables')
texts = require('texts')
require('logger')

default = {
	words = S{'Ambuscade','Zerde','Vinipata','Albumen'},
	ignores = S{},
	doublebass = true,
	text = {text={size=10}},
}
settings = config.load(default)

self = windower.ffxi.get_player().name

display_box = function()
	local header = ' [ Shout Alerts ] \n'
    local str = header
	for word in pairs(settings.words) do
		str = str..'> "'..tostring(word)..'" \n'
	end
	if str == header then str = str..'Add cmd: //sa a "Text to find" \n' end
	
	str = str..' [ Ignoring ]\n'
	for name in pairs(settings.ignores) do
		str = str..'> '..tostring(name)..' \n'
	end
    return str
end
sa_status = texts.new(display_box(),settings.text,settings)

function addon_command(...)
    local commands = {...}
	local helpmsg = help_msg()
	
	if commands[1] then
		commands[1] = commands[1]:lower()
		if commands[1] == 'ignore' or commands[1] == 'i' then
			if commands[2] == 'add' or commands[2] == 'a' then
				settings.ignores:add(commands[3])
				log('Ignoring shouts from:', commands[3])
			elseif commands[2] == 'remove' or commands[2] == 'r' then
				if not commands[3] then return end
				for p in pairs(settings.ignores) do
					if p:lower() == commands[3]:lower() then
						settings.ignores[p] = nil
						log('Removed', commands[3])
						break
					end
				end
			end
		elseif commands[1] == 'add' or commands[1] == 'a' then
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
			local clearalerts, clearignores = false
			if commands[2] then
				if commands[2] == 'alerts' or commands[2] == 'a' then
					clearalerts = true
				elseif commands[2] == 'ignores' or commands[2] == 'i' then
					clearignores = true
				end
			else
				clearalerts, clearignores = true
			end
			if clearalerts then
				for k in pairs(settings.words) do
					settings.words[k] = nil
				end
			end
			if clearignores then
				for p in pairs(settings.ignores) do
					settings.ignores[p] = nil
				end
			end
		elseif commands[1] == 'save' then
			settings:save()
			log('lists saved.')
		elseif commands[1] == 'help' or commands[1] == 'h' then
			log(helpmsg)
		end
	else
		log(helpmsg)
	end
	
	sa_status:text(display_box())
end

function help_msg()
	return [[Commands
	Alerting on text in shout
	 //sa [add|remove] [StringToAlertOn] - adds or removes the alert text from the list.
	Ignoring specific player shouts
	 //sa [ignore|i] [add|remove] [PlayerName] - adds or removes the player from the list.
	Clearing lists
	 //sa [clear|c] - clears all alerts and shouts
	 //sa [clear|c] [alerts|a|ingores|i] - clears specified list
	Saving lists
	 //sa [save] - saves the lists to the settings.xml
	]]
end

function loaded()
	sa_status:text(display_box())
	sa_status:show()
end

windower.register_event("incoming text", function(original,modified,original_mode,modified_mode, blocked)
    if original_mode == 11 then
		--log(original)
        for w in pairs(settings.words) do
            if (windower.wc_match(original, "*"..w.."*")) and not ignore_shout(original) then
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

function ignore_shout(str)
	if windower.wc_match(str, "*"..self.."*") then
		return true
	end
	
	for w in pairs(settings.ignores) do
		if (windower.wc_match(str, "*"..w.."*")) then
			return true
		end
	end
	return false
end

windower.register_event('addon command', addon_command)
windower.register_event('job change','login','load', loaded)


