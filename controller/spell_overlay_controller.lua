local Spells    = require("lua_spell_overlay.entity.spell_overlay_entity"):new():load()
local Utils     = require("lua_simple_conditions.utils.simple_conditions_utils")
local AIO       = AIO or require("AIO")

local SpellOverlay = {
    Data = "SpellOverlay",
    CLIENT = {
        SHOW_FRAME = "ShowFrame",
        HIDE_FRAME = "HideFrame",
        ADDON_NAME = "SpellOverlay",
    }
}

local Client = AIO.AddHandlers(SpellOverlay.CLIENT.ADDON_NAME, {})

function SpellOverlay.handleEvent(player, condition_id)
    if ( condition_id ) then
        local playerData = player:GetData(SpellOverlay.Data)
        Spells.results = Spells.simple_condition:GetCollectionByCondition(condition_id).results
        if ( not Spells.results ) then return end

        local spell = Spells.results
        if ( not spell ) then return end

        local spell_entry = spell:GetSpellId()
        if (playerData) then
            if (playerData.spell_id ~= spell_entry) then
                AIO.Handle(player, SpellOverlay.CLIENT.ADDON_NAME, SpellOverlay.CLIENT.HIDE_FRAME)
                AIO.Handle(player, SpellOverlay.CLIENT.ADDON_NAME, SpellOverlay.CLIENT.SHOW_FRAME, spell:GetTexture(), spell_entry)
                player:SetData(SpellOverlay.Data, {
                    spell_id = spell_entry,
                    frame_show = true,
                })
            end
        else
            AIO.Handle(player, SpellOverlay.CLIENT.ADDON_NAME, SpellOverlay.CLIENT.SHOW_FRAME, spell:GetTexture(), spell_entry)
            player:SetData(SpellOverlay.Data, {
                spell_id = spell_entry,
                frame_show = true,
            })
        end
    else
        local playerData = player:GetData(SpellOverlay.Data)
        if ( playerData ) then
            AIO.Handle(player, SpellOverlay.CLIENT.ADDON_NAME, SpellOverlay.CLIENT.HIDE_FRAME)
            player:SetData(SpellOverlay.Data, nil)
        end
    end
end

function Client.Cast(player, spellId)
    local player_data = player:GetData(SpellOverlay.Data)
    if (not player_data) then
        return
    end

    local spell = player_data.spell_id
    if (not spellId ~= spell) then
        player:CastSpell(player, spellId, false)
    end
end

Utils.InitAndAddCallbackIn( SpellOverlay.handleEvent, Spells.simple_condition )