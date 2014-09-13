--[[
	SAC Anivia plugin

	Version: 1.01 
	- Initial release
--]]

local SkillQ = {spellKey = _Q, range = 1100, speed = 860.05, delay = 250, width = 110}
local wRange = 1000
local eRange = 700
local rRange = 615

local lastMana = 0

local qMana = {80, 100, 120, 140, 160}
local wMana = {70, 90, 110, 130, 150}
local eMana = {50, 60, 70, 80, 90}
local rMana = 75

local GlacialStorm = false

local qObject = nil

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 1100
	PluginMenu = AutoCarry.PluginMenu
	MainMenu = AutoCarry.MainMenu
	QREADY, WREADY, EREADY, RREADY = false, false, false, false
	lastMana = myHero.mana

	PluginMenu:addParam("sep1", "-- Spell Cast Options --", SCRIPT_PARAM_INFO, "")
	PluginMenu:addParam("MaxPercentage", "Max percentage of mana for Ult",SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

end 

function PluginOnTick()
	RREADY = (myHero:CanUseSpell(_R) == READY)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)

	Target = AutoCarry.GetAttackTarget()	

	if GlacialStorm then
		MonitorUltimate() 
	end 

	if Target and qObject ~= nil then
		if GetDistance(qObject, Target) <= 50 then
			CastSpell(_Q)
		end
	end

	-- AutoCarry
	if Target and MainMenu.AutoCarry then 

		if WREADY and CalculateDamage(Target) >= Target.health and GetDistance(Target) <= wRange then
			PlaceWall()
		end


		if QREADY and qObject == nil and GetDistance(Target) <= SkillQ.range then
			AutoCarry.CastSkillshot(SkillQ, Target)
		end

		if EREADY and IsChilled(Target) and GetDistance(Target) <= eRange then
			CastSpell(_E, Target)
		end

		if RREADY and not GlacialStorm and myHero.mana > 200 and GetDistance(Target) <= rRange then
			CastSpell(_R, Target.x, Target.z)
		end
	end


end

function PluginOnCreateObj(obj)
	if obj.name:find("cryo_storm") then
  		GlacialStorm = true
  		lastMana = myHero.mana
 	elseif obj.name:find("FlashFrost_mis") then
 		qObject = obj
 	end
end

function PluginOnDeleteObj(obj)
    if obj.name:find("cryo_storm") then
  		GlacialStorm = false
 	elseif obj.name:find("FlashFrost_mis") then
 		qObject = nil
 	end
end

function PluginOnDraw() 
	if Target then
		DrawCircle(Target.x, Target.y, Target.z, 65, 0x00FF00)
		local text = ""
		if Target.health <= CalculateDamage(Target) then
			text = "Killable"
		else
			text = "Wait for Cooldowns"
		end
		PrintFloatText(Target, 0, text)
	end
end
function IsChilled(enemy)
	return TargetHaveBuff("Chilled", enemy) 
end

function CalculateDamage(enemy) 
	local totalDamage = 0
	local currentMana = myHero.mana 
	local qReady = QREADY and currentMana >= qMana[myHero:GetSpellData(_Q).level]
	local wReady = WREADY and currentMana >= wMana[myHero:GetSpellData(_W).level]
	local eReady = EREADY and currentMana >= eMana[myHero:GetSpellData(_E).level]
	local rReady = RREADY and currentMana >= rMana 
	if qReady then totalDamage = totalDamage + getDmg("Q", enemy, myHero) end
	if wReady then totalDamage = totalDamage + getDmg("W", enemy, myHero) end
	if eReady then totalDamage = totalDamage + getDmg("E", enemy, myHero) end
	if rReady then totalDamage = totalDamage + getDmg("R", enemy, myHero) end
	return totalDamage

end

function PlaceWall(enemy) 
	if WREADY and GetDistance(enemy) <= wRange then
		local TargetPosition = Vector(enemy.x, enemy.y, enemy.z)
		local MyPosition = Vector(myHero.x, myHero.y, myHero.z)		
		local WallPosition = TargetPosition + (TargetPosition - MyPosition)*((150/GetDistance(enemy)))
		CastSpell(_W, WallPosition.x, WallPosition.z)
	end
end

function MonitorUltimate() 
	local maxMana = myHero.maxMana * (PluginMenu.MaxPercentage / 100)
	if (lastMana - myHero.mana) > maxMana then 
		DisableUltimate()
	end
end

function DisableUltimate()
	if RREADY and GlacialStorm then
		CastSpell(_R)
	end
end

--UPDATEURL=
--HASH=6C7DC4DD07D8EE853C27A1C22098560F
