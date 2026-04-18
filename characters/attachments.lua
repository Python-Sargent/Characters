
characters.registered_attachments = {}

characters.register_attachment = function(def)
    def.entity_name = "characters:attachment_"..def.name
    characters.registered_attachments[def.name] = def
    core.register_entity("characters:attachment_"..def.name, def.entity_def)
end

characters.attachments = {}

characters.get_attachment = function(name)
    return characters.registered_attachments[name]
end

characters.summon_attachment = function(name)
    return core.add_entity(vector.zero(), name, nil)
end

characters.detach = function(player, attachment, first_only)
    if characters.attachments[player:get_player_name()] ~= nil then
        for k,v in pairs(characters.attachments[player:get_player_name()]) do
            if v.entity_name == attachment.entity_name and core.objects_by_guid[v.guid] ~= nil then
                local obj = core.objects_by_guid[v.guid]
                obj:set_detach() -- don't know if this is needed
                obj:remove()
                characters.attachments[player:get_player_name()][k] = nil
                if first_only then
                    return true, "Detached " .. attachment.name
                end
            end
        end
        return true, "Detached all " .. attachment.name .. "(s)"
    else
        return false, "No '" .. attachment.name .. "' is attached"
    end
end

characters.detach_all = function(player)
    for k,v in pairs(characters.attachments[player:get_player_name()]) do
        if core.objects_by_guid[v.guid] ~= nil then
            local obj = core.objects_by_guid[v.guid]
            obj:set_detach() -- don't know if this is needed
            obj:remove()
            characters.attachments[player:get_player_name()][k] = nil
        end
    end
end

characters.get_saved_attachments = function(player)
    local s = characters.mod_storage:get_string(player:get_player_name() .. "_attachments")
    return core.deserialize(s, true) or {}
end

characters.save_attachments = function(player)
    if characters.attachments[player:get_player_name()] ~= nil then
        local s = characters.get_saved_attachments(player)
        for k, v in pairs(characters.attachments[player:get_player_name()]) do
            if core.objects_by_guid[v.guid] ~= nil then -- is valid attachment
                --core.log(dump(v))
                table.insert(s, characters.get_attachment(v.name))
            end
        end
        characters.mod_storage:set_string(player:get_player_name() .. "_attachments", core.serialize(s))
    end
end

characters.attach = function(player, attachment)
    if not core.settings:get_bool("characters_attachments", true) then
        return false, "Cosmetics are disabled"
    end
    if attachment ~= nil then
        local obj = characters.summon_attachment(attachment.entity_name)
        if obj ~= nil then
            if characters.attachments[player:get_player_name()] ~= nil then
                table.insert(characters.attachments[player:get_player_name()], {guid=obj:get_guid(),entity_name=obj:get_luaentity().name, name=attachment.name})
            else
                characters.attachments[player:get_player_name()] = {{guid=obj:get_guid(), entity_name=obj:get_luaentity().name, name=attachment.name}}
            end
            obj:set_attach(player, attachment.bone or "", attachment.pos or vector.new(0, 0, 0), attachment.rot or vector.new(0, 0, 0), attachment.force_visible or false)
            characters.save_attachments(player)
            return true, "Cosmetic succesfully attached"
        else
            return false, "Cannot attach nil"
        end
    else
        return false, "Cannot attach unknown Cosmetic"
    end
end

characters.load_attachments = function(player)
    local s = characters.get_saved_attachments(player)

    --core.log(dump(s))

    for k, v in pairs(s) do
        characters.attach(player, v)
    end
end

core.register_on_joinplayer(function(player)
    characters.load_attachments(player)
end)

core.register_on_leaveplayer(function(player, timed_out)
    characters.save_attachments(player)
    characters.detach_all(player)
end)

core.register_chatcommand("attach", {
	description = "Attach an attachment to yourself",
    params = "attach <attachment_name>",
	func = function(name, param)
        local p = param:split(" ")

        local player = core.get_player_by_name(name)
		if player then
            if p[1] ~= nil then
                return characters.attach(player, characters.get_attachment(p[1]))
            end
		else
			return false, "Must be a player to have attachments"
		end
	end
})

core.register_chatcommand("detach", {
	description = "Detach an attachment from yourself",
    params = "detach all|(<attachment_name> [all])",
	func = function(name, param)
        local p = param:split(" ")

        local player = core.get_player_by_name(name)
		if player then
            if p[1] ~= nil then
                return characters.detach(player, characters.get_attachment(p[1]), true)
            end
		else
			return false, "Must be a player to have attachments"
		end
	end
})

characters.register_attachment({
    name = "tophat",
    bone = "Neck",
    pos = vector.new(0, -0.05, 0),
    rot = vector.new(0, 0, 0),
    force_visible = false,
    entity_def = {
        initial_properties = {
            hp_max = 1,
            physical = false,
            pointable = false,
            visual = "mesh",
            visual_size = {x = 0.6, y = 0.6, z = 0.6},
            mesh = "characters_attachment_hat.glb",
            textures = {},
        },
        on_detach = function(self, parent)
            if self.object ~= nil then
                self.object:remove()
            end
        end,
    }
})