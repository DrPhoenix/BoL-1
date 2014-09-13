local version = "1.004"

if myHero.charName ~= "Yorick" or not VIP_USER then return end
--SimpleYorickRelease.lua

local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Jusbol/scripts/master/SimpleYorickRelease.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."SimpleYorickRelease.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function _AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Yorick, The King Of Rock'n Roll:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
        local ServerData = GetWebResult(UPDATE_HOST, "/Jusbol/scripts/master/VersionFiles/Yorick.version")
        if ServerData then
                ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
                if ServerVersion then
                        if tonumber(version) < ServerVersion then
                                _AutoupdaterMsg("New version available"..ServerVersion)
                                _AutoupdaterMsg("Updating, please don't press F9")
                                DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () _AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
                        else
                                _AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
                        end
                end
        else
                _AutoupdaterMsg("Error downloading version info")
        end
end

local myPlayer	=	GetMyHero()


--[[Skills]]
local YorickSpectral	=	{	
	range = 125,
	delay = 0.25,
	speed = 20		
}
local YorickDecayed		=	{	
	range = 600,
	delay = 0.25,
	speed = 20
}
local YorickRavenous	=	{	
	range = 550,
	delay = 0.25,
	speed = 20
}
local YorickReviveAlly	=	{	
	range = 850,
	delay = 0.5,
	speed = 1500
}
local UltimateUsed = false

--[[items]]
local Items = {
			["Brtk"]   	= 	{ready = false, range = 450, SlotId = 3153, slot = nil}, --Blade of the Ruined King
			["Bc"]     	= 	{ready = false, range = 450, SlotId = 3144, slot = nil},
			["Rh"]     	= 	{ready = false, range = 400, SlotId = 3074, slot = nil}, --Ravenous Hydra
			["Tiamat"] 	= 	{ready = false, range = 400, SlotId = 3077, slot = nil},
			["Hg"]     	= 	{ready = false, range = 700, SlotId = 3146, slot = nil},
			["Yg"]     	= 	{ready = false, range = 150, SlotId = 3142, slot = nil}, --Youmuu's Ghostblade
			["RO"]     	= 	{ready = false, range = 500, SlotId = 3143, slot = nil}, --Randuin\'s Omen
			["SD"]	   	=	{ready = false, range = 150, SlotId = 3131, slot = nil}, --Sword of the Divine			
			["MU"]		=	{ready = false, range = 150, SlotId = 3042, slot = nil}, --Muramana
			["MA"]		=	{ready = false, range = 150, SlotId	= 3004, slot = nil}, --Manamune
			["Tear"]	=	{ready = false, range = 150, SlotId = 3070, slot = nil}	 --Tear of the Goddess
			}
local HP_MANA = { 
				["Hppotion"] 	= {SlotId = 2003, ready = false, slot = nil},
				["Manapotion"] 	= {SlotId = 2004 , ready = false, slot = nil}				  
				}
local FoundItems 							= {}
local BuffNames 							= { "regenerationpotion",
 												"flaskofcrystalwater",
  												"recall" , 
  												"yorickreviveallyguide",
   												"muramana"}
local UsandoHP, UsandoMana, UsandoRecall, UltimateUsed, MuramanaUsed	= false, false, false, false, false
--[[spells]]
local IgniteSpell   = 	{spellSlot = "SummonerDot", slot = nil, range = 600, ready = false}
local BarreiraSpell = 	{spellSlot = "SummonerBarrier", slot = nil, range = 0, ready = false}
--[[Menu variables]]
local skilllist		=	{_Q, _W, _E, _R}
local Allys			=	GetAllyHeroes()
local TargetManager	=	nil
local Target 		= 	nil
local DrawAlly		= 	nil

--[[orbwalk]]
local lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
local myTrueRange = 0

function OnLoad()
	Menu()
	PrintChat("<font color=\"#6699ff\"><b>Yorick, The King Of Rock'n Roll by Jus loaded !Good Luck!</b></font> ]-")
end

function Menu()
	menu = scriptConfig("Yorick by Jus", "YorickJus")
	menu:addParam("Version", "Version Info", SCRIPT_PARAM_INFO, version)
	--[[combo]]
	menu:addSubMenu("[Combo System]", "combo")
	for i=1, #skilllist do
		menu.combo:addParam("use"..tostring(skilllist[i]), "Use "..myPlayer:GetSpellData(skilllist[i]).name, SCRIPT_PARAM_ONOFF, true)	
	end
	menu.combo:addParam("", "", SCRIPT_PARAM_INFO, "")
	menu.combo:addParam("key", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)	
	menu.combo:addSubMenu("[Ultimate Settings]", "ultimate")
		menu.combo.ultimate:addParam("autoultimate", "Use Auto Ultimate System", SCRIPT_PARAM_ONOFF, true)
		for i, aliados in pairs(Allys) do
			local nomealiado	=	aliados.charName
			menu.combo.ultimate:addParam("", "", SCRIPT_PARAM_INFO, "")			
			menu.combo.ultimate:addParam("use"..nomealiado, "Use in "..nomealiado, SCRIPT_PARAM_ONOFF, true)
			menu.combo.ultimate:addParam("health"..nomealiado, "Health missing in % "..nomealiado, SCRIPT_PARAM_SLICE, 30, 20, 80, -1)
		end
		menu.combo.ultimate:addParam("", "", SCRIPT_PARAM_INFO, "")
		menu.combo.ultimate:addParam("use"..myPlayer.charName, "Use in "..myPlayer.charName, SCRIPT_PARAM_ONOFF, true)
		menu.combo.ultimate:addParam("health"..myPlayer.charName, "Health missing in % "..myPlayer.charName, SCRIPT_PARAM_SLICE, 30, 20, 80, -1)
	--[[harass]]
	menu:addSubMenu("[Harass System]", "harass")
	menu.harass:addSubMenu("[Extra Harass System]", "extra")
	menu.harass.extra:addParam("tear", "Stack Tear in Minions Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	menu.harass.extra:addParam("w", "Stack Tear with W", SCRIPT_PARAM_ONOFF, false)
	menu.harass.extra:addParam("e", "Stack Tear with E", SCRIPT_PARAM_ONOFF, true)
	menu.harass:addParam("auto", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("M"))	
	menu.harass:addParam("w", "Use "..myPlayer:GetSpellData(_W).name, SCRIPT_PARAM_ONOFF, true)
	menu.harass:addParam("e", "Use "..myPlayer:GetSpellData(_E).name, SCRIPT_PARAM_ONOFF, true)
	menu.harass:addParam("", "", SCRIPT_PARAM_INFO, "")
	menu.harass:addParam("manastop", "Stop Harass if mana < %", SCRIPT_PARAM_SLICE, 30, 20, 80, -1)
	menu.harass:addParam("key1", "Manual Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	--[[extras]]
	menu:addSubMenu("[Extra System]", "extra")
	menu.extra:addParam("items", "Auto Use Inventory Items", SCRIPT_PARAM_ONOFF, true)
	--menu.extra:addParam("ignite", "Auto Use Ignite", SCRIPT_PARAM_ONOFF, true)
	menu.extra:addParam("", "", SCRIPT_PARAM_INFO, "")
	menu.extra:addParam("items2", "Use Consumable Items", SCRIPT_PARAM_ONOFF, true)
	menu.extra:addParam("hp", "Auto Use HP Potions", SCRIPT_PARAM_ONOFF, true)
	menu.extra:addParam("hppercent", "Use HP if my Health < %", SCRIPT_PARAM_SLICE, 60, 10, 90, -1)
	menu.extra:addParam("", "", SCRIPT_PARAM_INFO, "")
	menu.extra:addParam("mana", "Auto use Mana Potions", SCRIPT_PARAM_ONOFF, true)
	menu.extra:addParam("manapercent", "Use Mana if my Mana < %", SCRIPT_PARAM_SLICE, 70, 10, 90, -1)
	
	--menu.extra:addParam("barrier", "Auto Barrier", SCRIPT_PARAM_ONOFF, true)
	--menu.extra:addParam("barrierpercent", "Auto Use Barrier %", SCRIPT_PARAM_SLICE, 30, 10, 90, -1)
	--[[draw]]
	menu:addSubMenu("[Draw System]", "draw")
		menu.draw:addParam("w", "Use "..myPlayer:GetSpellData(_W).name, SCRIPT_PARAM_ONOFF, false)
		menu.draw:addParam("e", "Use "..myPlayer:GetSpellData(_E).name, SCRIPT_PARAM_ONOFF, true)
		menu.draw:addParam("r", "Use "..myPlayer:GetSpellData(_R).name, SCRIPT_PARAM_ONOFF, false)
		menu.draw:addParam("", "", SCRIPT_PARAM_INFO, "")
		menu.draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		--menu.draw:addParam("ally", "Draw Ally to Ultimate", SCRIPT_PARAM_ONOFF, false)
	--[[system]]
	menu:addSubMenu("[General System Settings]", "system")
		menu.system:addParam("packet", "Use Packets", SCRIPT_PARAM_ONOFF, true)
		menu.system:addParam("orbwalker", "Use Orbwalk", SCRIPT_PARAM_ONOFF, true)
	--[[permashow]]
	menu:permaShow("Version")
	menu.combo:permaShow("key")
	menu.harass.extra:permaShow("tear")
	menu.harass:permaShow("auto")
	menu.harass:permaShow("key1")
	--[[spells check slot]]	 -- need better
	if myPlayer:GetSpellData(SUMMONER_1).name:find(IgniteSpell.spellSlot) then IgniteSpell.slot = SUMMONER_1
	elseif myPlayer:GetSpellData(SUMMONER_2).name:find(IgniteSpell.spellSlot) then IgniteSpell.slot = SUMMONER_2 end	
	if myPlayer:GetSpellData(SUMMONER_1).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.slot = SUMMONER_1
	elseif myPlayer:GetSpellData(SUMMONER_2).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.slot = SUMMONER_2 end
	--[[target selector]]
	TargetManager		=	TargetSelector(TARGET_LOW_HP, 850, DAMAGE_PHYSICAL)
	TargetManager.name 	= 	"Yorick"
	menu:addTS(TargetManager)
	--[[minions lane]]
	laneminions = minionManager(MINION_ENEMY, 600, myPlayer, MINION_SORT_HEALTH_ASC)
	--[[orbwalk]]
	myTrueRange = myHero.range + GetDistance(myPlayer.minBBox)		
end

function SkillReady(skill_)
	return myPlayer:CanUseSpell(skill_) == READY
end

function CastQ(myTarget)
	local tick 		= 	os.clock()
	local packet_	=	menu.system.packet
	local skillName =	tostring(skilllist[1])
	local useq_		=	menu.combo["use"..skillName]
	local target_ 	=	ValidTarget(myTarget, YorickSpectral.range)
	if packet_ and SkillReady(skilllist[1]) and target_ and useq_ and tick ~= nil and os.clock() - tick < 1 then 
		tick = os.clock()
		Packet('S_CAST', { spellId = skilllist[1], targetNetworkId = myPlayer.networkID }):send()
	else
		if SkillReady(skilllist[1]) and useq_ then
			CastSpell(skilllist[1])
		end
	end
end

function CastW(myTarget)
	local tick 		= os.clock()
	local packet_	=	menu.system.packet 
	local skillName	=	tostring(skilllist[2])
	local usew_		=	menu.combo["use"..skillName]
	local target_ 	=	ValidTarget(myTarget, YorickDecayed.range)		
	if packet_ and target_ and SkillReady(skilllist[2]) and usew_ and tick ~= nil and os.clock() - tick < 1 then
		tick = os.clock()
		Packet('S_CAST', { spellId = skilllist[2], fromX = myTarget.x, fromY = myTarget.z,toX = myTarget.x, toY = myTarget.z }):send()
	else
		if target_ and SkillReady(skilllist[2]) and usew_  and tick ~= nil and os.clock() - tick < 1 then
			tick = os.clock()
			CastSpell(skilllist[2], myTarget.x, myTarget.z)
		end
	end
end

function CastE(myTarget)
	local tick 		= os.clock()
	local packet_	=	menu.system.packet
	local skillName	=	tostring(skilllist[3])
	local usee_		=	menu.combo["use"..skillName]
	local target_ 	=	ValidTarget(myTarget, YorickRavenous.range)
	if packet_ and target_ and SkillReady(skilllist[3]) and usee_ and tick ~= nil and os.clock() - tick < 1 then
		tick = os.clock()
		Packet('S_CAST', { spellId = skilllist[3], targetNetworkId = myTarget.networkID }):send()
	else
		if target_ and SkillReady(skilllist[3]) and usee_ and tick ~= nil and os.clock() - tick < 1 then
			tick = os.clock()
			CastSpell(skilllist[3], myTarget)
		end
	end
end

function updateallys()
	Allys = GetAllyHeroes()
end

function ValidAlly(allytarget, range)
	return allytarget ~= nil and not allytarget.dead and GetDistance(allytarget) <= range
end

function CastR(myTarget)
if not ValidTarget(myTarget) then return end
	--if UltimateUsed then
		--Packet('S_CAST', { spellId = skilllist[4], fromX = myTarget.x, fromY = myTarget.z,toX = myTarget.x, toY = myTarget.z }):send()	
	--return
	--end
	--local tick 		 
	local ultTick	=	GetTickCount() + GetLatency() / 2	
	updateallys()
	local packet_	=	menu.system.packet
	local skillName	=	tostring(skilllist[4])
	local user_		=	menu.combo["use"..skillName]
	local myHp			=	(myPlayer.health / myPlayer.maxHealth * 100)
	local myHpmenu		=	menu.combo.ultimate["use"..myPlayer.charName]
	local myHpmenuP		=	menu.combo.ultimate["health"..myPlayer.charName]		
	for i, aliado in pairs(Allys) do
		local nomealiado	=	aliado.charName
		local ValidAlly_	=	ValidAlly(aliado, YorickReviveAlly.range)
		if nomealiado ~= nil and user_ and SkillReady(skilllist[4]) then		
			local use_			=	menu.combo.ultimate["use"..nomealiado]
			local aliadopercem	=	menu.combo.ultimate["health"..nomealiado]
			local aliadoperceh	=	(aliado.health / aliado.maxHealth * 100)
			
										
			if aliadoperceh <= aliadopercem and use_ and ValidAlly_ then
				if packet_ then				
					Packet('S_CAST', { spellId = skilllist[4], targetNetworkId = aliado.networkID }):send()
				else					
					CastSpell(skilllist[4], aliado)
				end
			end			
		end
	end

	if myHp <= myHpmenuP and myHpmenu then
		if packet_ and not UltimateUsed then			
			Packet('S_CAST', { spellId = skilllist[4], targetNetworkId = myPlayer.networkID }):send()
		else			
			CastSpell(skilllist[4], myPlayer)
		end
	end

	if UltimateUsed then
		if GetTickCount() + GetLatency() / 2 > ultTick + 3000 and ValidTarget(myTarget) then
			CastSpell(skilllist[4], myTarget.x, myTarget.z)
			ultTick	= GetTickCount() + GetLatency() / 2
		end
		
	end


end

function updatetarget()
	TargetManager:update()
	return TargetManager.target
end

function OnGainBuff(unit, buff)		
	if unit.isMe then
		for i=1, #BuffNames do
			if buff.name:lower():find(BuffNames[i]) then
				if BuffNames[i] == "yorickreviveallyguide" then UltimateUsed = true end
				if BuffNames[i] == "muramana" then MuramanaUsed = true end
				if BuffNames[i] == "regenerationpotion" then UsandoHP = true end
				if BuffNames[i] == "flaskofcrystalwater" then UsandoMana = true end
				if BuffNames[i] == "recall" then UsandoRecall = true end				
			end
		end
	end	
end

function OnLoseBuff(unit, buff)	
	if unit.isMe then
		for i=1, #BuffNames do
			if buff.name:lower():find(BuffNames[i]) then
				if BuffNames[i] == "yorickreviveallyguide" then UltimateUsed = false end
				if BuffNames[i] == "muramana" then MuramanaUsed = false end
				if BuffNames[i] == "regenerationpotion" then UsandoHP = false end
				if BuffNames[i] == "flaskofcrystalwater" then UsandoMana = false end
				if BuffNames[i] == "recall" then UsandoRecall = false end				
			end
		end
	end	
end

--[[tear of godness farm stack]]
function FarmWETear()	
	local havetear	=	GetInventorySlotItem(3070)
	local haveMA	=	GetInventorySlotItem(3004)	
	--[[menu]]	
	local usew_		=	menu.harass.extra.w
	local usee_ 	=	menu.harass.extra.e	
	laneminions:update()
	for i, minion_ in pairs(laneminions.objects) do		
		--local BestPos, BestHit = GetBestCircularFarmPosition(YorickRavenous.range, 400, laneminions.objects)		
		if havetear ~= nil or haveMA ~= nil then
			if SkillReady(skilllist[2]) and usew_ then				
				CastSpell(skilllist[2], minion_.x, minion_.z)
			end	
			if SkillReady(skilllist[3]) and usee_ then							
				CastSpell(skilllist[3], minion_)
			end				
		end
	end
end

--[[cast Spells/items]]
function CheckItems(tabela)
	for ItemIndex, Value in pairs(tabela) do
		Value.slot = GetInventorySlotItem(Value.SlotId)			
			if Value.slot ~= nil and (myPlayer:CanUseSpell(Value.slot) == READY) then				
			FoundItems[#FoundItems+1] = ItemIndex	
		end
	end
end

function CastCommonItem(myTarget)
	CheckItems(Items)
	if #FoundItems ~= 0 then
		for i, Items_ in pairs(FoundItems) do
			if Target ~= nil then				
				if GetDistance(myTarget) <= Items[Items_].range then 
					if 	Items_ == "Brtk" or Items_ == "Bc" then
						CastSpell(Items[Items_].slot, Target)						
					else
						if Items_ == "MU" and not MuramanaUsed then
							CastSpell(Items[Items_].slot)
						end					
						CastSpell(Items[Items_].slot)					
					end
					--if Items_ == "MU" and 
				end
			end			 
		end	
	end
end

function CastSurviveItem()
	CheckItems(HP_MANA)	
	local hp_ 					= menu.extra.hp		
	local AutoHPPorcentagem_ 	= menu.extra.hppercent
	local mana_ 				= menu.extra.mana
	local AutoMANAPorcentagem_ 	= menu.extra.manapercent
	local HP_Porcentagem 		= (myPlayer.health / myPlayer.maxHealth *100)
	local MANA_Porcentagem		= (myPlayer.mana / myPlayer.maxMana *100)
	local UseBarreira_			= menu.extra.barrier
	local UseBarreiraPorcen_	= menu.extra.barrierpercent
	local UseBarreiraPorcen_1 	= (myPlayer.health / myPlayer.maxHealth *100)
	if #FoundItems ~= 0 then	
		for i, HP_MANA_ in pairs(FoundItems) do
			if HP_MANA_ == "Hppotion" and HP_Porcentagem <= AutoHPPorcentagem_  and not InFountain() and not UsandoHP and hp_ then
				CastSpell(HP_MANA[HP_MANA_].slot)
			end
			if HP_MANA_ == "Manapotion" and MANA_Porcentagem <= AutoMANAPorcentagem_  and not InFountain() and not UsandoMana and mana_ then
				CastSpell(HP_MANA[HP_MANA_].slot)
			end			
		FoundItems[i] = nil
		end
		--if BarreiraSpell.slot ~= nil and UseBarreira_ and UseBarreiraPorcen_1 <= UseBarreiraPorcen_ and not InFountain() then
		--	CastSpell(BarreiraSpell.slot)
		--end 
	end
end

function OnTick()
if myPlayer.dead then return end	
	--[[menu]]
	local key_		=	menu.combo.key
	local orb_ 		=	menu.system.orbwalker
	--[[harass]]
	local auto_		=	menu.harass.auto
	local keyh_		=	menu.harass.key1
	local usew_		=	menu.harass.w
	local usee_		=	menu.harass.e
	local stop_		=	menu.harass.manastop
	local myMana 	=	(myPlayer.mana / myPlayer.maxMana * 100)
	local tearkey 	=	menu.harass.extra.tear
	--[[extra]]
	local Items_ 	=	menu.extra.items
	local Items2_	=	menu.extra.items2
	
	--[[update target]]
	Target = updatetarget()	
	--[[tear stack]]
	if tearkey then FarmWETear() if orb_ then OrbWalk_() end  end	
	--[[combo]]
	if Items2_ then CastSurviveItem() end
	if key_ then				
		CastQ(Target)
		CastW(Target)
		CastE(Target)
		CastR(Target)
		if orb_ then OrbWalk_(Target) end
		if Items_ then CastCommonItem(Target) end		
	end
	--[[harass]]	
	if auto_ and not UsandoRecall then
		if myMana > stop_ then
			if usew_ then CastW(Target) end
			if usee_ then CastE(Target) end
		end	
	end
	if keyh_ then
		if myMana > stop_ then
			if orb_ then OrbWalk_(Target) end
			if usew_ then CastW(Target) end
			if usee_ then CastE(Target) end	
		end			
	end

end

function OnProcessSpell(object, spell)
	if object == myHero then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency() / 2
			lastWindUpTime = spell.windUpTime * 1000
			lastAttackCD = spell.animationTime * 1000
		end 
	end
end

function OrbWalk_(myTarget)	 
	if myTarget ~= nil and GetDistance(myTarget) <= myTrueRange then		
		if timeToShoot() then
			myHero:Attack(myTarget)
		elseif heroCanMove()  then
			moveToCursor()
		end
	else		
		moveToCursor() 
	end
end

function heroCanMove()
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastWindUpTime + 20 )
end 
 
function timeToShoot()
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastAttackCD )
end 
 
function moveToCursor()
	if GetDistance(mousePos) > 125 then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized() * 250
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end 
end

--[[Credits to barasia, vadash and viseversa for anti-lag circles]]--
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvl(x, y, z, radius, 1, color, 75)	
	end
end
--[[END]]--

function OnDraw()
	if myPlayer.dead then return end
	--[[skills]]
	local w_		=	menu.draw.w
	local e_ 		=	menu.draw.e
	local r_ 		=	menu.draw.r
	local dTarget	=	menu.draw.target
	local dAlly		=	menu.draw.ally

	if w_ then
		DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, YorickDecayed.range, ARGB(255, 000, 000, 255))
	end
	if e_ then
		DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, YorickRavenous.range, ARGB(255, 255, 000, 000))
	end
	if r_ then
		DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, YorickReviveAlly.range, ARGB(255, 255, 255, 255))
	end

	if dTarget and ValidTarget(Target) then
		for i=0, 3, 1 do
			DrawCircle2(Target.x, Target.y, Target.z, 80 + i , ARGB(255, 255, 000, 255))	
		end
	end
	--if dAlly and DrawAlly ~= nil then
	--	for i=0, 3, 1 do
	--		DrawCircle2(DrawAlly.x, DrawAlly.y, DrawAlly.z, 80 + i , ARGB(255, 255, 000, 000))	
	--	end
	--end
end