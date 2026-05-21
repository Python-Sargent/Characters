-- characters_api/init.lua

characters.api = {}

characters.api.update_model = function(player, override)
    if characters.api.model ~= nil then -- model set, then apply it to the player
        local properties = characters.api.model
        properties.visual = properties.visual or "mesh"
        properties.mesh = properties.mesh or nil

        if override then
            for k, v in pairs(override) do
                properties[k] = v
            end
        end

        player:set_properties(properties)
    end
end

characters.api.set_base_properties = function(properties)
    characters.api.model = properties
end

core.register_on_joinplayer(function(player, last_join) 
    core.after(0, characters.api.update_model, player)
end)

characters.api.steps = {}

characters.api.add_step = function(stepfunc, gameid)
    if gameid == nil or gameid == core.get_game_info().id then -- don't bother adding steps for other games while running only one game
        characters.api.steps[core.get_game_info().id] = stepfunc -- replaces any existing steps, there should be only one api step per game for now
    end
end

core.register_globalstep(function(dtime)
	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()

        for gameid, step in pairs(characters.api.steps) do
            if step ~= nil and gameid == core.get_game_info().id then
                step(player, dtime)
            end
        end
    end
end)



--- Player API Deconstruction

if core.get_modpath("player_api") then -- nuke player_api to stop it from conflicting
    core.register_on_mods_loaded(function()
        player_api.globalstep = function(_) end
    end)

    player_api.register_model = function() end -- make player_api functions no-ops
    player_api.set_animation = function() end
    player_api.set_textures = function() end
    
   
    core.register_on_joinplayer(function(player) -- force players handled by player_api into attached mode (failsafe)
        local name = player:get_player_name()
        player_api.player_attached[name] = true
    end)

    if core.settings:get_bool("characters_player_api_warnings", true) then
        core.log("warn", "[Characters API]:\n"..core.colorize("red",    "Characters API has removed functionality from the Player API, this may affect stability.\n") ..
                                                core.colorize("orange", "It is suggested to remove the Player API mod from your game or world to prevent possible confliction.\n") ..
                                                                        "To disable this warning go to Characters API settings and turn off 'Player API Warnings'"
        )
    end
end