local GK1 = string.byte("X") -- Farm toggle

function PluginOnLoad()
	mainLoad()
	mainMenu()
end

function PluginOnTick()
	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	
	if Menu.autoks and QREADY then
		for i = 1, heroManager.iCount, 1 do
			local qTarget = heroManager:getHero(i)
			if ValidTarget(qTarget, qRange) then
				if qTarget.health <=  getDmg("Q", qTarget, myHero) then
					CastSpell(_Q, qTarget)
				end
			end
		end
	end
	
	if Target and Menu2.AutoCarry then
		if EREADY and Menu.useE and GetDistance(Target) <= eRange then
			CastSpell(_E)
		end
		if QREADY and Menu.useQ then
			if Menu.qChase and GetDistance(Target) > Menu.qDistance then
				CastSpell(_Q, Target)
			elseif Target.health < getDmg("Q", Target, myHero) then
				CastSpell(_Q, Target)
			end
		end
	end
	
	if Menu.qFarm and Menu2.LastHit then
		for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
			if ValidTarget(minion) and QREADY and GetDistance(minion) <= qRange then
				if minion.health < getDmg("Q", minion, myHero) then
					CastSpell(_Q, minion)
				end 
			end
		end
	end
end

function OnAttacked()
	if Target and Menu2.AutoCarry then
		if QREADY and Menu.useQ and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
	end
end

function PluginOnDraw()	
	if Menu.drawQ and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FF00)
	end
end

function mainLoad()
	AutoCarry.SkillsCrosshair.range = 700
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	qRange, eRange = 625, 600
	QREADY, EREADY  = false, false
end

function mainMenu()
	Menu:addParam("sep", "-- Cast Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("autoks", "Auto Kill with Parrrley!", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("qDistance", "Parrrley! buffer range",SCRIPT_PARAM_SLICE, 400, 0, 625, 0)
	Menu:addParam("qChase", "Parrrley! target when out of range", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("qFarm", "Farm with Parrrley!", SCRIPT_PARAM_ONKEYTOGGLE, false, GK1)
	Menu:addParam("sep", "-- Ability Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ", "Use - Parrrley!", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE", "Use - Raise Morale", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep2", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("drawQ", "Draw - Parrrley!", SCRIPT_PARAM_ONOFF, false)
end

--UPDATEURL=
--HASH=BA530FD06825CB7BA04B9B2AD64A05FC
