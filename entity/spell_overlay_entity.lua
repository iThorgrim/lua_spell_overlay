local SimpleConditions  = {
    Utils   = require("lua_simple_conditions.utils.simple_conditions_utils"),
    Entity  = require("lua_simple_conditions.entity.simple_conditions_entity")
}

local Helper = require("lua_spell_overlay.helper.spell_overlay_helper")

local format = string.format

local Spell = { }
function Spell:new(data)
    local instance = { }
    setmetatable(instance, self)

    -- Reflection for auto-generate method
    for name, _ in pairs(data) do
        local methodName = "Get" .. SimpleConditions.Utils.ToCamelCase(name:sub(1,1):upper() .. name:sub(2))
        instance[methodName] = function (self, value)
            return data[name]
        end
    end

    return instance
end

---
local SpellBonus = { }
function SpellBonus:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self

    -- Load Simple Condition Entity
    self.simple_condition = SimpleConditions.Entity

    -- Reflection for auto-generate method
    for _, method in ipairs( Helper.ENUM.METHOD ) do
        local methodName = "GetBy" .. SimpleConditions.Utils.ToCamelCase(method:sub(1,1):upper() .. method:sub(2))
        instance[methodName] = function (self, value)
            if ( self.results ) then
                self.results = self.results[ value ]
            end
            return self
        end
    end

    return instance
end

function SpellBonus:loadSpells()
    WorldDBQuery( format( Helper.DATABASE.SPELLS.CREATE, Helper.DATABASE.NAME ) )

    local query = WorldDBQuery( format( Helper.DATABASE.SPELLS.READ, Helper.DATABASE.NAME ) )
    if ( query ) then
        local temp = { }
        repeat
            local id                = query:GetUInt32( 0 )
            local spell_id          = query:GetUInt32( 1 )
            local texture           = query:GetString( 2 )

            temp[ id ] = Spell:new({ spell_id = spell_id, texture = texture })
        until not query:NextRow()

        return temp
    end
end

function SpellBonus:load()
    local spells = self:loadSpells()

    self.simple_condition = self.simple_condition:new(Helper.DATABASE.NAME)
                                :load(Helper.DATABASE.CONDITIONS, Helper.DATABASE.RELATIONS, spells)

    return self
end

return SpellBonus
