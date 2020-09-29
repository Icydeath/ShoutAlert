_addon.name = 'ShoutAlert'
_addon.author = 'Icy'
_addon.version = '1.0.4'
_addon.commands = {'shoutalert','sa'}

-- 1.0.4: Added new commands. //sa ls - shows last shouts for alert words, //sa sound - toggles alert sounds on/off.
-- 1.0.3: Display now wraps the added words in quotes, so spaces can be identified. ie: " Ou "
-- 1.0.2: ignores your shouts if a word matches

require('luau')
require('tables')
texts = require('texts')
require('logger')

self = windower.ffxi.get_player().name

default = {
	words = S{'Ambuscade','Zerde','Vinipata','Albumen'},
	ignores = S{},
	doublebass = true,
	text = {text={size=10}},
	shout_text = {text={size=10}},
}
settings = config.load(default)

sound_enabled = true
show_last_shout = false
last_shouts = {}

function count(list)
	local cnt = 0
	for x in pairs(list) do
		cnt = cnt + 1
	end
	return cnt
end

display_box = function()
	local header = ' [ Shout Alerts ]  ♫ '..(sound_enabled and "on" or "off")..' \n'
    local str = header
	for word in pairs(settings.words) do
		str = str..'> "'..tostring(word)..'" \n'
	end
	if str == header then str = str..'Add cmd: //sa a "Text to find" \n' end
	
	if count(settings.ignores) > 0 then
		str = str..' [ Ignored Players ]\n'
		for name in pairs(settings.ignores) do
			str = str..'> '..tostring(name)..' \n'
		end
	end
    return str
end
sa_status = texts.new(display_box(),settings.text,settings)

ls_display_box = function()
	local header = '[ S h o u t  A l e r t  -  S h o u t  L o g ] \n'
	local str = header
	for word, shout in pairs(last_shouts) do
		if str == header then
			str = str..'  <'..word..' @ '..shout
		else
			str = str..'\n  <'..word..' @ '..shout
		end
	end
	if str == header then
		str = str..' '
	end
	
	return str
end
ls_status = texts.new(ls_display_box(),settings.shout_text,settings)

function addon_command(...)
    local commands = {...}
	local helpmsg = help_msg()
	
	if commands[1] then
		commands[1] = commands[1]:lower()
		if commands[1] == 'sound' then
			sound_enabled = not sound_enabled
			if sound_enabled then log('alert sound enabled.')
			else log('alert sound disabled.') end
		elseif commands[1] == 'ls' then
			if not show_last_shout then
				show_last_shout = true
				ls_status:text(ls_display_box())
				ls_status:show()
			else
				show_last_shout = false
				ls_status:hide()
			end
			if show_last_shout then
				log('show last shouts enabled.')
			else
				log('show last shouts disabled.')
			end
		elseif commands[1] == 'ignore' or commands[1] == 'i' then
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
	if show_last_shout then
		ls_status:text(ls_display_box())
	end
end

function help_msg()
	return [[Commands
	Alerting on text in shout
	 //sa <add | remove> <StringToAlertOn> - adds or removes the alert text from the list
	Ignoring specific player shouts
	 //sa <ignore | i> <add | remove> <PlayerName> - adds or removes the player from the list
	Clearing lists
	 //sa <clear | c> - clears all alerts and shouts
	 //sa <clear | c> <alerts | a | ingores | i> - clears specified list
	Toggles
	 //sa sound - Toggles the alert sound on/off
	 //sa ls - Shows a window with the last shout for each alert
	Saving lists
	 //sa <save> - saves the lists to the settings.xml
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
				if sound_enabled then
					if settings.doublebass then
						windower.play_sound(windower.addon_path..'sounds/doublebass.wav')
					else
						windower.play_sound(windower.addon_path..'sounds/chime.wav')
					end
				end
				log(w, 'found in shout!')
				if show_last_shout then
					local t = os.date('%I:%M%p')
					last_shouts[w] = t:lower()..'> '..windower.convert_auto_trans(original):strip_format():gsub('%[.-%]','')
					ls_status:text(ls_display_box())
				end
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


