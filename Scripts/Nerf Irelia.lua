if myHero.charName ~= "Irelia" then return end
 -- [[  #Nerf Irelia by tyanitarx]] --
 
 require "VPrediction"



 local aarange, qrange, erange, rrange = 125, 650, 325, 1200
 local qspeed, espeed, rspeed = 2200, math.huge, 779
 local qdelay, edelay, rdelay = 0, 0.5, 0.5
 local rwidth = 30
 local ts
 local VP
 local igniteslot = nil
 local BWCslot = nil
 local trinityslot = nil
 local ruinedkingslot = nil

 
function OnProcessSpell(object, spell)
	if object == myHero then
	local ultcount
		if spell.name:lower():find("IreliaTranscendentBlades") then
		ultcount = ultcount + 1
		end
	end
end

function OnLoad()
 
ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1250)
Menu()
PrintChat(">>>#Nerf Irelia by tyanitarx Loaded!<<<<")
VP = VPrediction()
SummonerChecks()

 end
 
function OnTick()

ts:update()
ItemChecks()
Combo()
AutoKS()
AutoStun()
minionManager(MINION_ENEMY, 1300, myHero, MINIONS_SORT_HEALTH_ASC):update() 
FarmQ()
UseMinions()

end

function SummonerChecks()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
        igniteslot = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
        igniteslot = SUMMONER_2
	else 
		igniteslot = nil
    end
end


function ItemChecks()

BWCslot = GetInventorySlotItem(3144)
ruinedkingslot = GetInventorySlotItem(3153)
trinityslot = GetInventorySlotItem(3078)

end



function Combo()
	if menu.Combo and ts.target ~= nil then
		if GetDistance(ts.target, myHero) < 650 and myHero:CanUseSpell(_Q) == READY and myHero:CanUseSpell(_W) == READY then
		CastSpell(_W)
		CastSpell(_Q, ts.target)
		end
		
		if myHero:CanUseSpell(_Q) == READY then
		CastSpell(_Q, ts.target)
		end
		
		if myHero:CanUseSpell(_E) == READY then
		CastSpell(_E, ts.target)
		end
		
		if menu.UseR and myHero:CanUseSpell(_R) == READY and GetDistance(ts.target, myHero) < 300 then 
		
		CastPosition, HitChance, Position = VP:GetLineCastPosition(ts.target, rdelay, rwidth, rrange, rspeed, myHero)
			if HitChance >= 2 then
			CastSpell(_R, CastPosition.x, CastPosition.y)
			end
			
			ts:update()
			
			if ultcount == 1 then
				CastPosition2, HitChance, Position = VP:GetLineCastPosition(ts.target, rdelay, rwidth, rrange, rspeed, myHero)
				if HitChance >= 2 then
				CastSpell(_R, CastPosition2.x, CastPosition2.y)
				end
			end
			
			ts:update()
			
			if ultcount == 2 then
				CastPosition3, HitChance, Position = VP:GetLineCastPosition(ts.target, rdelay, rwidth, rrange, rspeed, myHero)
				if HitChance >= 2 then
				CastSpell(_R, CastPosition3.x, CastPosition3.y)
				end
			end 
			ts:update()
			
			if ultcount == 3 then
				CastPosition4, HitChance, Position = VP:GetLineCastPosition(ts.target, rdelay, rwidth, rrange, rspeed, myHero)
				if HitChance >= 2 then
				CastSpell(_R, CastPosition4.x, CastPosition4.y)
				end
			end
		end
	
		
		if menu.UseItems then
			if BWCslot ~= nil and myHero:CanUseSpell(BWCslot) == READY then
			CastSpell(BWCslot, ts.target)	
			end
			if ruinedkingslot ~= nil and myHero:CanUseSpell(ruinedkingslot) == READY then
			CastSpell(ruinedkingslot, ts.target)	
			end
			
		end
		
	end
end

function FarmQ() 
	if myHero:CanUseSpell(_Q) == READY and menu.FarmQ then
		for i, minion in pairs(minionManager(MINION_ENEMY, 1300, myHero, MINIONS_SORT_HEALTH_ASC).objects) do 
			if minion ~= nil and minion.valid and minion.health < (getDmg("Q", minion, myHero) + getDmg("AD", minion, myHero)) then
				CastSpell(_Q, minion)
			end
		end 
	end
end


function AutoKS()
	if menu.AutoKS and ts.target ~= nil  then
		if myHero:CanUseSpell(_Q) == READY and (getDmg("Q", ts.target, myHero) + getDmg("AD", ts.target, myHero)) > ts.target.health then
		CastSpell(_Q, ts.target)
		end
	end
end
	
function Ignite()
    if menu.UseSummoners and myHero:CanUseSpell(igniteslot) == READY then
        local ignitedmg = 0
        for i = 1, heroManager.iCount, 1 do
            local enemyhero = heroManager:getHero(i)
            if ValidTarget(enemyhero, 600) then
                ignitedmg = 50 + 20 * myHero.level
                if enemyhero.health <= ignitedmg then
                    CastSpell(igniteslot, enemyhero)
                end
            end
        end
    end
end

function AutoStun()
	if menu.AutoStun and ts.target ~= nil and myHero.health / myHero.maxHealth <= ts.target.health / ts.target.maxHealth and GetDistance(ts.target, myHero) < 425 then
	CastSpell(_E, ts.target)
	end
end

function MinionDistance(player, pd, md)
	for i, minion in pairs(minionManager(MINION_ENEMY, 1300, myHero).objects) do 
		if minion ~= nil and minion.valid and minion.health < (getDmg("Q", minion, myHero) + getDmg("AD", minion, myHero)) then
		player = myHero
		pd = player.y - player.x
		md = minion.y - minion.x
		return math.sqrt( pd * pd + md * md )
		end
	end
end

function TargetDistance(player, pd, td)
	if ts.target ~= nil then
		player = myHero
		pd = player.y - player.x
		td = ts.target.y - ts.target.x
		return math.sqrt( pd * pd + td * td )
	end
end

function UseMinions()
	for i, minion in pairs(minionManager(MINION_ENEMY, 1300, myHero).objects) do 
		if menu.UseMinions and minion ~= nil and minion.valid and minion.health < (getDmg("Q", minion, myHero) + getDmg("AD", minion, myHero)) then
			if myHero:CanUseSpell(_Q) == READY and ts.target ~= nil and menu.Combo and TargetDistance(player, pd, td) > MinionDistance(player, pd, md) and myHero.mana > 70 then 
			CastSpell(_Q, minion)
			elseif myHero:CanUseSpell(_Q) == READY and ts.target ~= nil and menu.AutoKS and TargetDistance(player, pd, td) > MinionDistance(player, pd, md) and myHero.mana > 70 and (getDmg("Q", ts.target, myHero) + getDmg("AD", ts.target, myHero)) > ts.target.health then
			CastSpell(_Q, minion)
			CastSpell(_Q, ts.target)
			end
		end
	end
end


function Menu()
menu = scriptConfig("#Nerf Irelia", "Irelia")
menu:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
menu:addParam("AutoKS", "AutoKS", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("X"))
menu:addParam("UseItems", "Use Items", SCRIPT_PARAM_ONOFF, false)
menu:addParam("UseSummoners", "Use Summoners", SCRIPT_PARAM_ONOFF, false)
menu:addParam("FarmQ", "Farm with Q", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("C"))
menu:addParam("AutoStun", "Auto Stun", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("M"))
menu:addParam("UseR", "Use Ult in Combo", SCRIPT_PARAM_ONOFF, false)
menu:addParam("UseMinions", "Use Minions to Catch Up", SCRIPT_PARAM_ONOFF, false)
menu:addSubMenu("Orbwalker", "Irelia Orbwalking")
ts.name = "Irelia"
menu:addTS(ts)
end