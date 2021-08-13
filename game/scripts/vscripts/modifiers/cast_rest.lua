cast_rest = cast_rest or class({})

function cast_rest:GetTexture() return "skywrath_mage_arcane_bolt" end -- get the icon from a different ability

function cast_rest:IsPermanent() return true end
function cast_rest:RemoveOnDeath() return false end
function cast_rest:IsHidden() return false end 	-- we can hide the modifier
function cast_rest:IsDebuff() return false end 	-- make it red or green

function cast_rest:GetAttributes()
	return 0
		+ MODIFIER_ATTRIBUTE_PERMANENT           -- Modifier passively remains until strictly removed. 
		-- + MODIFIER_ATTRIBUTE_MULTIPLE            -- Allows modifier to stack with itself. 
		-- + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE -- Allows modifier to be assigned to invulnerable entities. 
end

function cast_rest:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end

function cast_rest:OnAbilityFullyCast(kv)
    if IsClient() then return end
	if kv.unit ~= self:GetParent() then return end
    if not kv.target then return end
    if not kv.ability or kv.ability:IsNull() then return end
    if not kv.target.IsHero then return end
    if not kv.target:IsHero() and BUTTINGS.AFFECT_CREEPS_TOO ~= 1 then return end

    local ability = kv.ability
    local target = kv.target

    local unit_types = DOTA_UNIT_TARGET_HERO
    if BUTTINGS.AFFECT_CREEPS_TOO == 1 then
        unit_types = unit_types + DOTA_UNIT_TARGET_CREEP
    end

    local units_found = FindUnitsInRadius(
        target:GetTeam(), 
        Vector(0,0,0), 
        nil, 
        FIND_UNITS_EVERYWHERE, 
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
        unit_types, 
        DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false)
    
    for _, unit in pairs(units_found) do
        if unit and not unit:IsNull() and unit ~= target then
            if ability:IsItem() and ability.GetCurrentCharges then
                ability:SetCurrentCharges(ability:GetCurrentCharges() + 1)
            end
            self:GetParent():SetCursorCastTarget(unit)
            ability:OnSpellStart()
        end
    end
end

