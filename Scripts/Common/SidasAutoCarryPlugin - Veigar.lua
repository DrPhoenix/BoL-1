--[[
		
	Sida's Auto Carry, Veigar Plugin.

	
	Features:
		- Mixed Mode:
			- Farm with Q.
			- Harras with Q.
		
		- Last Hit:
			- Farm with Q.
		
		- Lane Clean:
			- Farm with Q
			
		- Auto Carry Mode:
			- Automatically smart combos the enemy saving mana per kill.
			- Will not cast W unless target cannot move.
			
		- Shift Menu:
			- Use Q to Farm. Will use Q to farm creeps.
			- Min Mana to Farm with Q. The percentage of Mana required to farm with Q.
	

	Version 1.0
	- Public Release
	
	Version 1.1
	- Fixed Q Farm
	- Added option to use R or not in Combo
	- Auto W if target is stunned.
	
	Version 1.2
	- Disabled Q Farm
	- Fixed rDmg = nil error
	
	Version 1.3
	- Better Smart Combo
		- Note: E may miss due to no prediction.
	
	Instructions on saving the file:
	- Save the file as:
		- SidasAutoCarryPlugin - Veigar.lua
		
		
	This is for you, God: http://botoflegends.com/forum/topic/520-veigars-super-fun-house/page-12#entry32766
		
--]]


require "AoE_Skillshot_Position"
local SkillW = {spellKey = _W, range = 900, speed = 1.5, delay = 1.350 , width = 185}
function PluginOnLoad()
Menu = AutoCarry.PluginMenu
AutoCarry.SkillsCrosshair.range = 1100
VeigarMenu()
end
function PluginOnTick()
	ReadyChecks()
	if Target then
		if MM.AutoCarry then
			smartCombo()
		end
		if MM.MixedMode then
			CastSpell(_Q, Target)
		end
	--[[if (MM.LastHit or MM.MixedMode or MM.LaneClear) and Menu.QFarm then
			if (myHero.mana / myHero.maxMana) < Menu.MinMana then
				QFarm()
			end
		end]]
	end
end
--[[function QFarm()
for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if ValidTarget(minion) and QREADY and GetDistance(minion) <= qRange then
					if minion.health < getDmg("Q", minion, myHero) then
						CastSpell(_Q, minion)
					end
				end
			end
end]]
function VeigarMenu()
Menu:addParam("sep", "-- Skills --", SCRIPT_PARAM_INFO, "")
Menu:addParam("QFarm", "Use Q to Farm", SCRIPT_PARAM_ONOFF, false)
Menu:addParam("MinMana", "Min Mana to Farm with Q", SCRIPT_PARAM_SLICE, 0.5, 0.1, 0.9, 1)
Menu:addParam("UseR", "Use R in the combo", SCRIPT_PARAM_ONOFF, true)
end
function ReadyChecks()
	MM = AutoCarry.MainMenu
    Target = AutoCarry.GetAttackTarget()
    QREADY = (myHero:GetSpellData(_Q).level > 0 and myHero:CanUseSpell(_Q) == READY )
    WREADY = (myHero:GetSpellData(_W).level > 0 and myHero:CanUseSpell(_W) == READY )
	EREADY = (myHero:GetSpellData(_E).level > 0 and myHero:CanUseSpell(_E) == READY )
    RREADY = (myHero:GetSpellData(_R).level > 0 and myHero:CanUseSpell(_R) == READY ) 
	qRange = 650
	wRange = 900
	eRange = 625 + 270 
	rRange = 650
end
function smartCombo()
		if ValidTarget(Target) then
			local qDmg = getDmg("Q",Target,myHero)
            local wDmg = getDmg("W",Target,myHero)
            local rDmg = getDmg("R",Target,myHero)
			local myMana = (myHero.mana)
			local qMana = myHero:GetSpellData(_Q).mana
			local wMana = myHero:GetSpellData(_W).mana
			local eMana = myHero:GetSpellData(_E).mana
			local rMana = myHero:GetSpellData(_R).mana
						

			if Target and myHero:GetSpellData(_Q).level > 0 and Target.health <= qDmg then
					if QREADY and qMana <= myMana and GetDistance(Target) <= qRange then
						if QREADY then CastSpell(_Q, Target) end
					end
			end
			if Target and myHero:GetSpellData(_W).level > 0 then
					if WREADY and wMana <= myMana and GetDistance(Target) <= wRange and not Target.canMove then
						if WREADY then CastSpell(_W, Target) end
					end
			end
			if Target and myHero:GetSpellData(_Q).level > 0 and Target.health <= qDmg then
					if QREADY and qMana and EREADY and eMana <= myMana and GetDistance(Target) <= eRange then
						if QREADY then CastSpell(_Q, Target) end
						if EREADY then 
						alpha = math.atan(math.abs(Target.z-myHero.z)/math.abs(Target.x-myHero.x))
                locX = math.cos(alpha)*(GetDistance(Target) - 270) -- TEST THIS OUT, New E Prediction, unless you got your own.
                locZ = math.sin(alpha)*(GetDistance(Target) - 270) -- I'll leave it in the combo so you can just add it to the other lines or remove it if you wish.
                CastSpell(_E, math.sign(Target.x-myHero.x)*locX+myHero.x, math.sign(Target.z-myHero.z)*locZ+myHero.z)
						end
					end
			end
			
			if Target and myHero:GetSpellData(_Q).level > 0 and Target.health <= qDmg + wDmg then
				ComboMana = qMana + wMana
					if ComboMana <= myMana and GetDistance(Target) <= wRange then
						if QREADY then CastSpell(_Q, Target) end
						if WREADY and Target.canMove == false then AutoCarry.CastSkillshot(SkillW, Target) end
					end
			end
			if Target and myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and Target.health <= qDmg + wDmg then
				ComboMana = qMana + wMana + eMana
					if ComboMana <= myMana and GetDistance(Target) <= wRange then
						if QREADY then CastSpell(_Q, Target) end
						if WREADY and Target.canMove == false then AutoCarry.CastSkillshot(SkillW, Target) end
						if EREADY then 
						alpha = math.atan(math.abs(Target.z-myHero.z)/math.abs(Target.x-myHero.x))
                locX = math.cos(alpha)*(GetDistance(Target) - 270) -- TEST THIS OUT, New E Prediction, unless you got your own.
                locZ = math.sin(alpha)*(GetDistance(Target) - 270) -- I'll leave it in the combo so you can just add it to the other lines or remove it if you wish.
                CastSpell(_E, math.sign(Target.x-myHero.x)*locX+myHero.x, math.sign(Target.z-myHero.z)*locZ+myHero.z)
					end
					end
			end
						if Target and myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and Target.health >= qDmg + wDmg then
				ComboMana = qMana + wMana + eMana
					if ComboMana <= myMana and GetDistance(Target) <= wRange then
						if QREADY then CastSpell(_Q, Target) end
						if WREADY and Target.canMove == false then AutoCarry.CastSkillshot(SkillW, Target) end
						if EREADY then 
						alpha = math.atan(math.abs(Target.z-myHero.z)/math.abs(Target.x-myHero.x))
                locX = math.cos(alpha)*(GetDistance(Target) - 270) -- TEST THIS OUT, New E Prediction, unless you got your own.
                locZ = math.sin(alpha)*(GetDistance(Target) - 270) -- I'll leave it in the combo so you can just add it to the other lines or remove it if you wish.
                CastSpell(_E, math.sign(Target.x-myHero.x)*locX+myHero.x, math.sign(Target.z-myHero.z)*locZ+myHero.z)
					end
					end
			end
						if myHero:GetSpellData(_R).level > 0 then
			if Target and myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_R).level > 0 and Target.health <= rDmg + qDmg + wDmg then
				ComboMana = rMana + qMana + wMana 
				if ComboMana <= myMana and GetDistance(Target) <= wRange then 
				if Menu.UseR then
					if RREADY and GetDistance(Target) <= rRange then CastSpell(_R, Target) end end
					if QREADY and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
					if WREADY and GetDistance(Target) <= wRange and Target.canMove == false then AutoCarry.CastSkillshot(SkillW, Target) end
				end
			end

			if Target and myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_R).level > 0 and Target.health <= rDmg + qDmg + wDmg then
				ComboMana = rMana + qMana + wMana + eMana
				if ComboMana <= myMana and GetDistance(Target) <= wRange then
				if Menu.UseR then
					if RREADY and GetDistance(Target) <= rRange then CastSpell(_R, Target) end end
					if QREADY and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
					if WREADY and GetDistance(Target) <= wRange and Target.canMove == false then AutoCarry.CastSkillshot(SkillW, Target) end
					if EREADY then 
						alpha = math.atan(math.abs(Target.z-myHero.z)/math.abs(Target.x-myHero.x))
                locX = math.cos(alpha)*(GetDistance(Target) - 270) -- TEST THIS OUT, New E Prediction, unless you got your own.
                locZ = math.sin(alpha)*(GetDistance(Target) - 270) -- I'll leave it in the combo so you can just add it to the other lines or remove it if you wish.
                CastSpell(_E, math.sign(Target.x-myHero.x)*locX+myHero.x, math.sign(Target.z-myHero.z)*locZ+myHero.z)
					end
				end
			end
		end
		if Target and myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_R).level > 0 and Target.health <= rDmg + qDmg + wDmg then
				if GetDistance(Target) <= wRange then
				if Menu.UseR then
					if RREADY and GetDistance(Target) <= rRange then CastSpell(_R, Target) end end
					if QREADY and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
					if WREADY and GetDistance(Target) <= wRange and Target.canMove == false then AutoCarry.CastSkillshot(SkillW, Target) end
					if EREADY then 
						alpha = math.atan(math.abs(Target.z-myHero.z)/math.abs(Target.x-myHero.x))
                locX = math.cos(alpha)*(GetDistance(Target) - 270) -- TEST THIS OUT, New E Prediction, unless you got your own.
                locZ = math.sin(alpha)*(GetDistance(Target) - 270) -- I'll leave it in the combo so you can just add it to the other lines or remove it if you wish.
                CastSpell(_E, math.sign(Target.x-myHero.x)*locX+myHero.x, math.sign(Target.z-myHero.z)*locZ+myHero.z)
					end
				end
			end
		end
end
function math.sign(x)
 if x < 0 then
  return -1
 elseif x > 0 then
  return 1
 else
  return 0
 end
end

--UPDATEURL=
--HASH=D4E85BA9707BF05E4703564EEF7157A9
