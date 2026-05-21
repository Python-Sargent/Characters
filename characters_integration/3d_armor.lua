-- characters_integration/3d_armor.lua

-- NOTE: The official 3D Armor mod is made exclusively for PlayerAPI (Minetest Game)
--       Characters API will eventually include armor API for users playing other games
--       (Or people who wish to play without additional modpacks besides Characters API)
-- See README.md for more info.

if core.get_modpath("3d_armor") then
    armor.update_player_visuals = function(self, player)
        if not player then
            return
        end
        local name = player:get_player_name()

        -- TODO: update the armor

        self:run_callbacks("on_update", player)
    end
end
