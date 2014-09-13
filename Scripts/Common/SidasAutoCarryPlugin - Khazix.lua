--[[
	
	SAC Kha'Zix Plugin

--]]

local SkillW = {spellKey = _W, range = 1030, speed = 1835, delay = 225, width = 110}

local qRange = 325
local eRange = 600

local qMana = 25
local wMana = { 55, 60, 65, 70, 75}
local eMana = 50
local rMana = 100

function PluginOnLoad() 
	AutoCarry.SkillsCrosshair.range = 1000
	PluginMenu = AutoCarry.PluginMenu
	MainMenu = AutoCarry.MainMenu
	QREADY, WREADY, EREADY, RREADY = false, false, false, false

	PluginMenu:addParam("UseR", "Auto-Enable R when low health", SCRIPT_PARAM_ONOFF, true)
	PluginMenu:addParam("RPercentage", "Percentage of health to use R",SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	PluginMenu:addParam("EJump", "Distance to jump in with E (when not killable)",SCRIPT_PARAM_SLICE, 400, 0, eRange, 0)
end

function PluginOnTick() 

	RREADY = (myHero:CanUseSpell(_R) == READY)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)

	Target = AutoCarry.GetAttackTarget()

	CheckEvolution()

	if Target and MainMenu.MixedMode then
		if WREADY and GetDistance(Target) <= SkillW.range then
			Skillshot(SkillW, Target)
		end
		if QREADY and GetDistance(Target) <= qRange then
			CastSpell(_Q, Target)
		end
	end

	--> AutoCarry
	if Target and MainMenu.AutoCarry then

		--> O'Shit R 
		if RREADY and PluginMenu.UseR and myHero.health <= myHero.maxHealth * (PluginMenu.RPercentage / 100) then
			CastSpell(_R) 
		end

		--> Dive in
		if EREADY and CalculateDamage(Target) >= Target.health and GetDistance(Target) <= eRange then
			CastSpell(_E, Target.x, Target.z)
		end
		
		if EREADY and GetDistance(Target) <= PluginMenu.EJump and  myHero.health > myHero.maxHealth * (PluginMenu.RPercentage / 100) then 
			CastSpell(_E, Target.x, Target.z)
		end	

		if QREADY and GetDistance(Target) <= qRange then
			CastSpell(_Q, Target)
		end

		if WREADY and GetDistance(Target) <= SkillW.range then
			Skillshot(SkillW, Target)
		end
	end
end 

function Skillshot(spell, target) 
    if not AutoCarry.GetCollision(spell, myHero, target) then
        AutoCarry.CastSkillshot(spell, target)
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

function CalculateDamage(enemy) 
	local totalDamage = 0
	local currentMana = myHero.mana 
	local qReady = QREADY and currentMana >= qMana
	local wReady = WREADY and currentMana >= wMana[myHero:GetSpellData(_W).level]
	local eReady = EREADY and currentMana >= eMana
	if qReady then totalDamage = totalDamage + getDmg("Q", enemy, myHero) end
	if wReady then totalDamage = totalDamage + getDmg("W", enemy, myHero) end
	if eReady then totalDamage = totalDamage + getDmg("E", enemy, myHero) end
	return totalDamage
end

function CheckEvolution()
	if myHero:GetSpellData(_E).name == "khazixelong" then
  		eRange = 900
 	else
  		eRange = 600
 	end
 	if myHero:GetSpellData(_Q).name == "khazixqlong" then
  		qRange = 375
 	else
  		qRange = 325
 	end
end

--UPDATEURL=
--HASH=2AD7CDD6182B4FEA0736F8F0F39F16D0
