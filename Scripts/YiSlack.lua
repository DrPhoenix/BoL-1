require "NotLib"
--[[
YiSlack
by Ivan[RUSSIA]

GPL v2 license
--]]

if myHero.charName ~= "MasterYi" then return end
local version = "final"

NotLib.spell()
NotLib.timer()
NotLib.object()
NotLib.upgrade()
NotLib.potion()
NotLib.bind()
NotLib.gui()
NotLib.smite()

-- init
upgrade.tick()
upgrade.creep()
upgrade.creepSpawn()
upgrade.spell(myHero)
-- init nashor/dragon special
local _objective = function(unit) if unit.data.class == "creep" and (unit.data.parent().data.name == "nashor" or unit.data.parent().data.name == "dragon") then upgrade.spell(unit) end end
for k,creep in pairs(object.creep) do _objective(creep) end
AddCreateObjCallback(_objective)
-- shop visit - item number - id - price - parent items
local items = {}
items[1] = spell.itemList()
items[1][1] = {1039,325,3106,3154,3160} -- machete
items[1][2] = {3106,450,3154,3160} -- madreds
items[2] = spell.itemList()
items[2][1] = {1080,700,3154,3160} -- spirit stone
items[3] = spell.itemList()
items[3][1] = {1001,325,3006,3254,3252,3250} -- boots +1
items[4] = spell.itemList()
items[4][1] = {3154,1025,3160} -- lantern
items[5] = spell.itemList()
items[5][1] = {3006,675,3254,3252,3250} -- boots +2
items[5][2] = {1053,800,3144,3153} -- lifesteal
items[5][3] = {1036,360,3144,3153} -- sword
items[5][4] = {3144,240,3153} -- cutlass
items[6] = spell.itemList()
items[6][1] = {3153,1800} -- botrk
-- spell list
local spells = {_Q,_W,_Q,_E,_Q,_R,_Q,_E,_Q}
local fastSpells = {_Q,_E,_Q,_W,_Q,_R,_Q,_E,_Q}
-- gui
gui("yi_name").transform("text").text = "YiSlack v."..version
-- combo gui
gui("yi_comboText").transform("text").text = "combo "
gui("yi_comboTick").transform("tick").changed = function(state) 
	if state == true then
		gui("yi_farmTick").value = false
		timer("combo").start(true)
	else
		timer("combo").stop()
	end 
end
bind("yi_space").callback = function(down) gui("yi_comboTick").value = down end
bind("yi_space").key = 0x20
gui("yi_meditateText").transform("text").text = "meditate"
gui("yi_meditateTick").transform("tick").value = true
gui("yi_dodgeText").transform("text").text = "dodge"
gui("yi_dodgeTick").transform("tick").value = true
gui("yi_combo").transform("line","yi_comboText","yi_comboTick","yi_meditateText","yi_meditateTick","yi_dodgeText","yi_dodgeTick")
-- farm gui
gui("yi_farmText").transform("text").text = "farm "
gui("yi_farmTick").transform("tick").changed = function(state) 
	if state == true then 
		gui("yi_comboTick").value = false
		timer("logic").start(true) 
	else
		gui("yi_progress").visible = false
		timer("logic").stop() 
	end 
end
bind("yi_f1").callback = function(down) if down == true and gui("yi_farm").visible == true then gui("yi_farmTick").value = not gui("yi_farmTick").value end end
bind("yi_f1").key = 0x70
bind("yi_rmb").callback = function(down) if down == true and gui("yi_farm").visible == true then gui("yi_farmTick").value = false end end
bind("yi_rmb").key = 0x2
gui("yi_smiteText").transform("text").text = "smite"
gui("yi_smiteText").visible = (spell.smite ~= nil)
gui("yi_smiteTick").transform("tick").visible = (spell.smite ~= nil)
gui("yi_fastText").transform("text").text = "fast"
gui("yi_fastTick").transform("tick")
gui("yi_farm").transform("line","yi_farmText","yi_farmTick","yi_smiteText","yi_smiteTick","yi_fastText","yi_fastTick").visible = (object.map == "classic" or object.map == "tt")
gui("yi_progressText").transform("text").text = "next shopping"
gui("yi_progressBar").transform("bar")
gui("yi_progress").transform("line","yi_progressText","yi_progressBar").visible = false
-- sticking gui
gui("yi_guiList").transform("list","yi_name","yi_combo","yi_farm","yi_progress")
gui("yi_gui").transform("anchor","yi_guiList")
gui("yi_gui").x,gui("yi_gui").y = 100,100
-- logic
local goSpawn = function()
	if myHero:GetDistance(object.allySpawn) > 600+myHero.ms*8 then CastSpell(RECALL)
	elseif myHero:GetDistance(object.allySpawn) > 150 then spell.move(object.allySpawn) end
end
local findCreepSpawn = function(teleport)
	if GetTarget() ~= nil and GetTarget().data.class == "creep" then return GetTarget().data.parent() end
	return object.farmCreepSpawn(#items[1] == 0 or items[1].gold()-myHero.gold > 200,teleport)
end
timer("logic").callback = function()
	-- shopping
	while items[1].gold() == 0 and items[2] ~= nil do items[1].add(items[2]) table.remove(items,2) end 
	if myHero.dead == true or myHero:GetDistance(object.allySpawn) <= 600 then
		if myHero:getInventorySlot(ITEM_7) == 0 then if gui("yi_fastTick").value == false then BuyItem(3341) else BuyItem(3340) end end
		items[1].buy()
		if myHero.level == 1 and (spell.item(2003) or spell.item(2009) or spell.item(2010)) == nil then spell.buy(2003) end
	end
	-- shopping gui
	gui("yi_progress").visible,gui("yi_progressBar").min,gui("yi_progressBar").value = (#items[1] > 0),items[1].gold(),math.floor(math.max(0,items[1].gold()-myHero.gold)+0.5)
	-- leveling
	if gui("yi_fastTick").value == true then spell.level(fastSpells) else spell.level(spells) end
	-- glitch preventing
	if spell.buff("Recall") and myHero:GetDistance(object.allySpawn) < 600 then spell.move(object.allySpawn)
	-- regen
	elseif spell.buff("Recall") or myHero.dead == true or (myHero:GetDistance(object.allySpawn) < 1000
	and math.min(myHero.health/myHero.maxHealth+0.15,myHero.mana/myHero.maxMana+0.35) <= 1-0.1*(1000-myHero:GetDistance(object.allySpawn))/myHero.ms) then return
	-- farm
	else
		local creepSpawn = findCreepSpawn()
		if creepSpawn ~= nil then
			local creep = creepSpawn.data.target()
			if creep ~= nil then
				if creepSpawn.data.name == "nashor" or creepSpawn.data.name == "dragon" then
					if creep.data.spell("attack").target == myHero and math.abs(creep.data.spell("attack").tick+creep.data.spell("attack").windUpTime-GetTickCount()/1000) < 0.15 then
						if myHero:CanUseSpell(_Q) == READY then CastSpell(_Q,creep) return -- q objective
						elseif myHero:GetDistance(creep) <= spell.range(creep) and myHero:CanUseSpell(_W) == READY then CastSpell(_W) return end -- w objective
					end
					if creepSpawn.data.name == "nashor" and myHero:GetDistance(creep) < creep:GetDistance(creep.minBBox)-25 then
						spell.move(math.pos2d(creep,math.rad2d(creep,myHero),creep:GetDistance(creep.minBBox)+25)) return -- evade objective
					end
					if myHero:GetDistance(creep) > spell.range(creep) then
						myHero:Attack(creep)
					elseif myHero.data.spell("attack").windUp() == true or myHero.data.spell("attack").animation() == false then
						myHero:Attack(creep)
						if creepSpawn.data.health(creep,600) > myHero.totalDamage*5 then CastSpell(_E) end -- objective e
						if myHero.health/myHero.maxHealth < 0.55 then 
							CastSpell(_R) -- r objective
							if spell.item(3142) then CastSpell(spell.item(3142)) end -- ghostblade objective 
						end
					elseif myHero.data.spell("attack").animation() == true then
						if object.filter(object.visual,{name="PropelBubbles",visible=true,closest=true,range=200}) then
							spell.move(math.pos2d(creep,math.rad2d(creep,myHero)+1.046,creep:GetDistance(creep.minBBox)+25)) -- evade objective
						elseif (spell.item(3074) or spell.item(3077)) then CastSpell(spell.item(3074) or spell.item(3077)) end -- objective tiamat
					end
				else 
					if myHero:GetDistance(creep) > spell.range(creep) then
						if myHero.level >= 3 and myHero:CanUseSpell(_Q) == READY and creepSpawn.data.composition(creep,600) == creepSpawn.data.maxCreeps then CastSpell(_Q,creep) -- q gapclose
						else myHero:Attack(creep) end --  attack
					elseif myHero.data.spell("attack").windUp() == true or myHero.data.spell("attack").animation() == false then
						myHero:Attack(creep)
						if creepSpawn.data.health(creep,600) > myHero.totalDamage*5 then 
							CastSpell(_E) -- e
							if gui("yi_fastTick").value == true and (#items[1] == 0 or items[1].gold()-myHero.gold > 200) then CastSpell(_R) end -- r
						end
					elseif myHero.data.spell("attack").animation() == true then
						if spell.smite ~= nil and gui("yi_smiteTick").value == true and (gui("yi_fastTick").value == true or (creepSpawn.data.name ~= "red" and creepSpawn.data.name ~= "blue"))
						and #object.filter(object.player,{range=2000,dead=false}) == 1 and creep.health > 370+myHero.level*35 then CastSpell(spell.smite,creep) end -- smite
						if creepSpawn.data.health(creep,600) > myHero.totalDamage*4 or myHero.health/myHero.maxHealth < 0.33 then 
							CastSpell(_Q,creep) -- q
							if gui("yi_fastTick").value == true and (spell.item(1080) ~= nil or spell.item(3106) ~= nil or myHero.lifeSteal*myHero.totalDamage+10 >= 20) then CastSpell(_W) end -- w
						end 
						if (spell.item(3074) or spell.item(3077)) then CastSpell(spell.item(3074) or spell.item(3077)) end -- tiamat
					end
				end
			elseif gui("yi_fastTick").value == false and spell.item(0) ~= nil and myHero.pathCount-myHero.pathIndex <= 0 and #items[1] > 0 and myHero.gold+2.5*8 > items[1].gold() then goSpawn() -- shopping
			elseif gui("yi_fastTick").value == true and spell.item(0) ~= nil and myHero.health/myHero.maxHealth < 0.33 and #items[1] > 0 and myHero.gold+2.5*8 > items[1].gold() then goSpawn() -- shopping
			elseif gui("yi_fastTick").value == true and spell.item(0) ~= nil and object.creepSpawn["ogolem"].data.alive() == false and myHero:GetDistance(object.creepSpawn["ogolem"]) < 600 and #items[1] > 0 and myHero.gold+2.5*8 > items[1].gold() then goSpawn() -- shopping
			elseif gui("yi_fastTick").value == true and spell.item(0) ~= nil and object.creepSpawn["owight"].data.alive() == false and myHero:GetDistance(object.creepSpawn["owight"]) < 600 and #items[1] > 0 and myHero.gold+2.5*8 > items[1].gold() then goSpawn() -- shopping
			elseif gui("yi_fastTick").value == false and GetTickCount()/1000-myHero.data.spell("Meditate").tick < 4.2 and myHero.health < myHero.maxHealth then return -- w wait
			elseif gui("yi_fastTick").value == false and myHero.health/myHero.maxHealth < 0.5 and myHero.lifeSteal*myHero.totalDamage+10 < 20 and myHero:CanUseSpell(_W) == READY then CastSpell(_W)  -- w
			elseif GetTickCount()/1000-myHero.data.spell("SummonerTeleport").tick < 3.7 then return -- teleport wait
			elseif spell.teleport ~= nil and gui("yi_fastTick").value == true and GetInGameTimer() > 150 and myHero:CanUseSpell(spell.teleport) == READY and (#items[1] == 0 or (items[1][1][1] ~= 3154 and items[1].gold()-myHero.gold > 400))
			and myHero:GetDistance(findCreepSpawn(true)) > 6000 and object.filter("tower+ward",{team=myHero.team,dead=false,mid=false,closest=true,unit=findCreepSpawn(true),range=2850})
			and myHero:GetDistance(object.allySpawn) < 1000 then CastSpell(spell.teleport,object.filter("tower+ward",{team=myHero.team,dead=false,mid=false,closest=true,unit=findCreepSpawn(true),range=2850})) -- teleport
			elseif gui("yi_fastTick").value == true and myHero.level >= 3 and creepSpawn.data.number ==  5 and spell.ward() ~= nil and myHero:GetDistance(VEC(7900,3000)) < myHero:GetDistance(creepSpawn) then 
				if myHero:GetDistance(VEC(7900,3000)) > 100 then myHero:MoveTo(7900,3000)
				else spell.ward({VEC(8000,2750)},math.huge) end
			elseif gui("yi_fastTick").value == true and myHero.level >= 3 and creepSpawn.data.number ==  11 and spell.ward() ~= nil and myHero:GetDistance(VEC(6070,11475)) < myHero:GetDistance(creepSpawn) then
				if myHero:GetDistance(VEC(6070,11475)) > 100 then myHero:MoveTo(6070,11475)
				else spell.ward({VEC(6000,11725)},math.huge) end
			elseif myHero:GetDistance(creepSpawn) > 285 then spell.move(creepSpawn) end
		end
	end
end
timer("logic").cooldown = 0.033
-- pvp
local findTarget = function(plus)
	if GetTarget() ~= nil and GetTarget().data.class == "player" and GetTarget().team == TEAM_ENEMY then return GetTarget(),1 end
	local result = nil
	for k,enemy in pairs(object.filter(object.player,{team=TEAM_ENEMY,range=600+spell.range(myHero)+math.max(0,myHero.ms-355)+plus,visible=true,targetable=true,dead=false})) do 
		if enemy.bInvulnerable == 0 and (enemy.charName ~= "Jax" or spell.buff(enemy,"JaxCounterStrike") == false) 
		and (enemy.charName ~= "Karthus" or spell.buff(enemy,"KarthusDeathDefiedBuff") == false)
		and (enemy.charName ~= "Tryndamere" or enemy.health/enemy.maxHealth > 0.1 or spell.buff(enemy,"UndyingRage") == false) 
		and (enemy.charName ~= "Poppy" or spell.buff(enemy,"PoppyDiplomaticImmunity") == false or spell.buff("poppyditarget") == true) then
			if result == nil then result = enemy
			elseif myHero:CanUseSpell(_Q) == READY then
				if enemy.health/(myHero:CalcDamage(enemy,myHero.totalDamage)+myHero.totalDamage*0.2) < result.health/(myHero:CalcDamage(result,myHero.totalDamage)+myHero.totalDamage*0.2) then result = enemy end
			elseif myHero:GetDistance(enemy) <= spell.range(enemy)+math.max(0,myHero.ms-355) then
				if myHero:GetDistance(result) > spell.range(result)+math.max(0,myHero.ms-355) then result = enemy
				elseif enemy.health/(myHero:CalcDamage(enemy,myHero.totalDamage)+myHero.totalDamage*0.2) < result.health/(myHero:CalcDamage(result,myHero.totalDamage)+myHero.totalDamage*0.2) then result = enemy end
			elseif myHero:GetDistance(enemy) < myHero:GetDistance(result) then result = enemy end
		end
	end
	return result
end
local badTarget = function(target)
	if spell.item(target,3075) == true or spell.buff(target,"willrevive") == true or spell.buff(target,"ChronoShift") or target.charName == "Rammus" or target.armor > 150 -- thornmail and GA  and rammus and armor
	or (target.charName == "Skarner" and target:GetSpellData(_R).level > 0 and target:GetSpellData(_R).currentCd < 6) -- skarner
	or (target.charName == "Galio" and target:GetSpellData(_R).level > 0 and target:GetSpellData(_R).currentCd < 6) -- galio
	or (target.charName == "Amumu" and target:GetSpellData(_R).level > 0 and target:GetSpellData(_R).currentCd < 6) -- amumu
	or (spell.item(target,3157) == true and target:GetSpellData(spell.item(target,3157)).currentCd < 3) -- zonya
	or (target.charName == "Alistar" and ((target:GetSpellData(_Q).level > 0 and target:GetSpellData(_Q).currentCd < 3) or (target:GetSpellData(_W).level > 0 and target:GetSpellData(_W).currentCd < 3))) -- ignore alistar
	or (target.charName == "Morgana" and target:GetSpellData(_R).level > 0 and target:GetSpellData(_R).currentCd < 3) -- morgana
	or (target.charName == "Mundo" and target:GetSpellData(_R).level > 0 and target:GetSpellData(_R).currentCd < 3) -- mundo
	or (target.charName == "Zilean" and target:GetSpellData(_R).level > 0 and target:GetSpellData(_R).currentCd < 3) -- zilean
	or (target.charName == "Mundo" and target:GetSpellData(_W).level > 0 and target:GetSpellData(_W).currentCd < 3) -- vlad
	or (target.charName == "Shen" and target:GetSpellData(_W).level > 0 and target:GetSpellData(_W).currentCd < 3) -- shen
	or (target.charName == "Jax" and target:GetSpellData(_E).level > 0 and target:GetSpellData(_E).currentCd < 3) -- jax
	or (target.charName == "Lissandra" and target:GetSpellData(_R).level > 0 and target:GetSpellData(_R).currentCd < 3) -- lissandra
	or (target.charName == "Chogath" and target:GetSpellData(_Q).level > 0 and target:GetSpellData(_Q).currentCd < 3) -- chogath
	or (target.charName == "FiddleSticks" and target:GetSpellData(_Q).level > 0 and target:GetSpellData(_Q).currentCd < 3) then return true end -- fiddle
	return false
end
timer("combo").callback = function()
	local target = findTarget(0)
	if gui("yi_meditateTick").value == true and GetTickCount()/1000-myHero.data.spell("Meditate").tick < 4.2 then return -- w wait
	elseif gui("yi_meditateTick").value == true and myHero:CanUseSpell(_W) == READY and myHero.health/myHero.maxHealth < 0.25 then CastSpell(_W) -- w
	elseif target ~= nil then
		if badTarget(target) then target = findTarget(myHero.ms) end -- bad target detection
		if myHero:GetDistance(target) > spell.range(target) then
			if myHero:CanUseSpell(_Q) == READY then 
				if spell.item(3131) then CastSpell(3131) end -- sotd q
				CastSpell(_Q,target) -- q gapclose
			else myHero:Attack(target) end
		else
			if (spell.item(3153) or spell.item(3144) or spell.item(3146)) then CastSpell((spell.item(3153) or spell.item(3144) or spell.item(3146)),target) end -- biglewater
			if spell.barrier ~= nil and myHero.health/myHero.maxHealth < 0.25 then CastSpell(spell.barrier) end -- barrier
			if spell.exhaust ~= nil and myHero.health/myHero.maxHealth < math.min(0.7,target.health/target.maxHealth) then CastSpell(spell.exhaust,target) end -- exhaust
			if gui("yi_dodgeTick").value == false or myHero.health/myHero.maxHealth < 0.25 then CastSpell(_Q,target) end -- q
			if myHero.data.spell("attack").windUp() == true or myHero.data.spell("attack").animation() == false then
				CastSpell(_R) -- r
				CastSpell(_E) -- e
				if spell.item(3142) then CastSpell(spell.item(3142)) end -- ghostblade
				if spell.item(3131) then CastSpell(3131) end -- sotd
				myHero:Attack(target)
			elseif myHero.data.spell("attack").animation() == true then
				if gui("yi_meditateTick").value == false then CastSpell(_W) end -- w reset
				if (spell.item(3074) or spell.item(3077)) then CastSpell(spell.item(3074) or spell.item(3077)) end -- tiamat
				spell.follow(target)
			end
		end
	elseif myHero:GetDistance(mousePos) > 200 then spell.move(mousePos) end
end
-- cleanse
spell.OnGainBuff(function(unit,buff) if unit ~= nil and unit.isMe == true and IsKeyDown(0x20) == true and buff.source.team == TEAM_ENEMY and buff.duration > 0.7 then
		if buff.type == _G.BUFF_STUN or buff.type == _G.BUFF_TAUNT or buff.type == _G.BUFF_ROOT or buff.type == _G.BUFF_CHARM 
		or buff.type == _G.BUFF_SUPPRESS or buff.type == _G.BUFF_FEAR or buff.type == _G.BUFF_FLEE or  (buff.type == _G.BUFF_SILENCE and myHero:CanUseSpell(_Q) == READY)
		or ((buff.name == "SummonerDot" or buff.name == "SummonerExhaust") and spell.cleanse ~= nil)
		or ((buff.type == _G.BUFF_BLIND or buff.type == _G.BUFF_DISARM) and #object.filter(object.player,{team=TEAM_ENEMY,range=spell.range(myHero),visible=true,targetable=true,dead=false}) > 0) then
			if spell.cleanse ~= nil and CastSpell(spell.cleanse) then return 
			elseif spell.item(3140) ~= nil and CastSpell(spell.item(3140)) then return 
			elseif spell.item(3139) ~= nil and CastSpell(spell.item(3139)) then return end
		end
end end)
-- routine
AddProcessSpellCallback(function(unit,spell)
	if unit.isMe == true and spell.name:lower():find("attack") then
		unit.data.spell("meditate").reset()
	elseif unit.isMe == true and spell.name == "Meditate" then 
		unit.data.spell("attack").reset() -- w reset
	elseif (unit.isMe == true and spell.name == "MasterYiDoubleStrike") or (unit.data.class == "creep" and spell.name ==  "WrathoftheAncients") then 
		unit.data.spell("attack").tick,unit.data.spell("attack").windUpTime,unit.data.spell("attack").animationTime = GetTickCount()/1000,spell.windUpTime,spell.animationTime -- attack timer adjusting
	elseif unit.team == TEAM_ENEMY and gui("yi_dodgeTick").value == true and findTarget(0) ~= nil and findTarget(0).hash == unit.hash then 
		CastSpell(_Q,unit) -- dodge
	end
end)