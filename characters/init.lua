characters = {}

characters.mod_storage = core.get_mod_storage()
local modpath = core.get_modpath("characters")

---- ANIMATION ----

characters.registered_animations = {}

characters.register_animation = function(animation)
    if characters.registered_animations[animation.name] == nil and animation.name ~= nil then
        characters.registered_animations[animation.name] = {}
    end
    characters.registered_animations[animation.name] = animation
end

characters.set_physics = function(player, physics)
    local phy = player:get_physics_override()

    if physics then
        for k, v in pairs(physics) do
            phy[k] = v
        end
    end

    player:set_physics_override(phy)
end

characters.reset_physics = function(player)
    player:set_physics_override(nil)
end

characters.set_bone = function(player, name, override)
    player:set_bone_override(name or "", override or nil)
end

local player_anims = {}

local update_animation_for_player = function(player, animation_name)
    player_anims[player:get_player_name()] = animation_name
end

characters.get_anim = function(player)
    return player_anims[player:get_player_name()] or nil -- shouldn't need the 'or nil' part but it is easier to understand
end

--characters.sequences = {}

local eye_offset_callbacks = {}

characters.register_eye_offset_callback = function(callback)
    table.insert(eye_offset_callbacks, callback)
end

characters.update_eyes = function(player, animation)
    -- TODO: eventually eye offset should be lerped

    for _, v in pairs(eye_offset_callbacks) do
        v(player, animation)
    end

    -- animation.eye_offset is either offset vector or table of offset vectors for each pov, must include all three (nillable)
    if animation.eye_offset ~= nil then
        player:set_eye_offset(animation.eye_offset.first or animation.eye_offset, animation.eye_offset.back or animation.eye_offset, animation.eye_offset.front or animation.eye_offset)
    else
        player:set_eye_offset(vector.new(0, 0, 0), vector.new(0, 0, 0), vector.new(0, 0, 0)) -- set back to regular eye height
    end

    -- should also update collisionbox
end

characters.animate = function(_, __) end

characters.animate = function(player, animation)

    local a = {}

    if animation ~= nil then
        if animation.name ~= nil then
            if characters.registered_animations[animation.name] ~= nil then
                -- if: is formatted to ask for registerred anim
                local anim = characters.registered_animations[animation.name]
                anim.speed = animation.speed or anim.speed -- allow you to override the registered values
                anim.blend = animation.blend or anim.blend
                anim.loop = animation.loop or anim.loop
                a = anim
                if not anim.loop then
                    core.after((anim.range.y - anim.range.x) / anim.speed, characters.animate, player, animation.next) -- see below
                elseif anim.loop and anim.length then
                    core.after(anim.length, characters.animate, player, animation.next) -- animate next (or reset) after anim finished
                end
            else
                core.after(0, characters.animate, player, nil)
            end
        else
            a = animation
            if animation.next ~= nil then
                core.after(0, characters.animate, player, animation.next)
            end
        end
    else -- if no anim defined then reset the anim to default
        --characters.sequences[player:get_player_name()] = nil
        if characters.registered_animations["idle"] ~= nil then
            --local anim = characters.registered_animations["idle"] -- idle animations should be looped otherwise thread recursion will occur
            core.after(0, characters.animate, player, {name="idle"})
        else
            a = {range={x=0,y=0}, speed=0, blend=nil, loop=false}
        end
    end

    if a.range ~= nil then
        characters.update_eyes(player, a)
        update_animation_for_player(player, animation.name)
        player:set_animation(a.range, a.speed, a.blend, a.loop)
    end
end

characters.set_animation = function(player, anim)
    --if characters.sequences[player:get_player_name()] == nil then
        if anim.name == nil then
            characters.animate(player, anim)
        elseif characters.get_anim(player) == nil or characters.get_anim(player) ~= anim.name then
            characters.animate(player, anim)
        end
    --end
end

--[[
characters.animate_sequence = function(player, seq)
    for i = 1, #seq - 1 do
        if seq[i + 1].loop and seq[i + 1].length == nil then -- looped untimed animations cannot be sequenced, as they do not end
            break
        end
        seq[i].next = seq[i + 1]
    end
    if seq[#seq] ~= nil then
        seq[#seq].next = nil
    end
    local anim = seq[1]
    characters.sequences[player:get_player_name()] = seq

    core.log("Sequence: "..dump(seq))

    characters.animate(player, anim)
end
]]

characters.lerp = function(x, y, a) return x * (1 - a) + y * a end

local lanimations = {}

characters.lanimate = function(x, y, delta, length, setter, name)
    if lanimations[name] ~= nil then
        lanimations[name].time = lanimations[name].time + delta
    else
        lanimations[name] = {}
        lanimations[name].time = delta
    end

    local d = characters.lerp(x, y, lanimations[name].time/length)
    if d == y then
        lanimations[name] = nil -- remove finished lanimation
    end

    return d
end

--dofile(modpath.."/attachments.lua")