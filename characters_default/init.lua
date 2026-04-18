characters.api.set_base_properties({
    mesh = "characters_default_player.glb",
    textures = {
        "characters_default_layer0.png",
        "characters_default_layer1.png"
    },
    visual_size = { x = 7, y = 7 },
    eye_height = 1.6,
})

characters.register_animation({
	name = "idle",
	range = {x = 65, y = 80}, 
	speed = 5,
	blend = 0.1,
	loop = true
})

characters.register_animation({
	name = "walk",
	range = {x = 0, y = 20},
	speed = 0, -- overridden by dynamic animaiton
	blend = 0.1,
	loop = true
})

characters.register_animation({
	name = "strafe",
	range = {x = 85, y = 95}, 
	speed = 0, -- overridden by dynamic animaiton
	blend = 0.1,
	loop = true
})

characters.register_animation({
	name = "fall",
	range = {x = 100, y = 120}, 
	speed = 15,
	blend = 0.5,
	loop = true
})

characters.register_animation({
	name = "fly",
	range = {x = 165, y = 175}, 
	speed = 10,
	blend = 0.5,
	loop = true
})

characters.register_animation({
	name = "swim",
	range = {x = 125, y = 145}, 
	speed = 10,
	blend = 2,
	loop = true
})

characters.register_animation({
	name = "swim_idle",
	range = {x = 150, y = 160}, 
	speed = 10,
	blend = 1,
	loop = true
})

characters.api.moving = function(player)
    local cont = player:get_player_control()
    local deadstick = 0.01 -- needed for keyboard users as well because the movement controls are leaky apparently
    return {
        x=math.abs(cont.movement_x) > deadstick,
        y=math.abs(cont.movement_y) > deadstick,
    }
end

local swimmable = function(player)
    --local feet = core.get_node(player:get_pos())
    local eyes = core.get_node(vector.offset(player:get_pos(), 0, 1.5, 0))
    --(core.registered_nodes[feet.name].drawtype == "liquid" or core.registered_nodes[feet.name].drawtype == "flowingliquid") and
    return (core.registered_nodes[eyes.name].drawtype == "liquid" or core.registered_nodes[eyes.name].drawtype == "flowingliquid")
end

characters.is_on_ground = function(player)
    local stand = core.get_node(vector.offset(player:get_pos(), 0, -0.5, 0))
    return core.registered_nodes[stand.name].walkable == true
end

characters.api.step(function(player, dtime)
    local vel = player:get_velocity()
    local look = player:get_look_dir()
    local cont = player:get_player_control()
    local stand = core.get_node(player:get_pos())
    local eyes = core.get_node(vector.offset(player:get_pos(), 0, 1, 0))
    --local ph = player:get_physics_override()

    local speed = math.abs(vel.x) + math.abs(vel.z)

    --core.log(dump(speed))

    player:set_bone_override("Neck", { position = nil, rotation = {vec=vector.new((1-look.y+270)*1.6, 0, 0), interpolation=0.1}})
    
    if cont.sneak then
        
    end
    -- for movement, speed of animation should be affected by velocity
    if core.registered_nodes[stand.name].drawtype == "liquid" or core.registered_nodes[stand.name].drawtype == "flowingliquid" then
        if characters.api.moving(player).y then
            -- swimming normally
            if speed > 0.2 then
                characters.set_animation(player, {name="swim"})
                player:set_animation_frame_speed(5*speed)
            else
                characters.set_animation(player, {name="swim_idle"})
            end
            characters.set_animation(player, {name="swim"})
        elseif characters.api.moving(player).x then
            -- swimming on side
            if speed > 0.2 then
                characters.set_animation(player, {name="swim_idle"}) -- use swim idle for now till I get around to doing a swim strafe
                --player:set_animation_frame_speed(5*speed)
            else
                characters.set_animation(player, {name="swim_idle"})
            end
        else
            -- treading water
            characters.set_animation(player, {name="swim_idle"})
        end
    elseif vel.y < -20.1 then -- max flight speed is 20
        -- falling
        characters.set_animation(player, {name="fall"})
    elseif speed > 0.2 then
        if characters.is_on_ground(player) then
            if characters.api.moving(player).x and not characters.api.moving(player).y then
                -- sidestepping
                characters.set_animation(player, {name="strafe"})
                player:set_animation_frame_speed(13*speed)
            elseif characters.api.moving(player).y then
                -- walking
                characters.set_animation(player, {name="walk"})
                player:set_animation_frame_speed(9*speed)
            else
                characters.set_animation(player, {name="idle"})
            end
        elseif speed > 19 then
            characters.set_animation(player, {name="fly"})
        else
            player:set_animation_frame_speed(1*speed)
            --characters.set_animation(player, {name="idle"})
        end
        -- no good way to check if player is using fast mode, sprinting will have to wait
    else
        -- idling
        characters.set_animation(player, {name="idle"})
    end
end)