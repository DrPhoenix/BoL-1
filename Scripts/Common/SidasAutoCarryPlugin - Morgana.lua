--[[ Sida's Auto Carry Plugin: Morgana ]]--
--[[ Version 1.0 ]]--

--Local variables
 RRange = 625
 QRange = 1300
 WRange = 900
    
function PluginOnLoad()
  AutoCarry.SkillsCrosshair.range = 1800
  SkillQ = {spellKey = _Q, range = 1300, speed = 1.2, delay = 265, width = 50}
  Menu = AutoCarry.PluginMenu
  Cast = AutoCarry.CastSkillshot
  Col = AutoCarry.GetCollision
  -- Ingame menu
  AutoCarry.PluginMenu:addParam("scriptActive", "Use Combo in Carry mode", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("drawcircle", "Draw ult range", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useW", "Auto use W on snared target", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useult", "Auto ult on 2 or more enemies", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("shieldUlt", "Auto Shield on self before ult", SCRIPT_PARAM_ONOFF, true)
end
 -- OnTick funtion
 function PluginOnTick()
   checks()
   target = AutoCarry.GetAttackTarget(true)
   if AutoCarry.MainMenu.AutoCarry and target ~= nil then
     if Menu.useQ then AutoQ() end
     if Menu.useW then AutoW() end
     if Menu.useult then AutoUlt() end
   end
   if Menu.useW and target ~= nil then
     if GetDistance(target)<=900 then
       AutoW()
       Woverride()
     end
   end
 end
   
-- Q  
 function AutoQ()
   if QREADY and Menu.useQ and not Col(SkillQ, myHero, target) then Cast(SkillQ, target) end
 end
 
-- W
 function AutoW()
   if WREADY and not target.canMove then CastSpell(_W, target) end
 end
 
-- Enemies Near 
 function CountEnemies(point, range)
 local ChampCount = 0
 for i, enemy in ipairs(GetEnemyHeroes()) do
  if not enemy.dead and GetDistance(enemy, point) <= range then
   ChampCount = ChampCount + 1
  end
 end  
 return ChampCount
end

--W Override
 function Woverride()
  if not myHero.dead then
    for i, enemy in ipairs(GetEnemyHeroes()) do
      local wDmg = getDmg("W", enemy, myHero)
      if enemy and not enemy.dead and enemy.health <= (wDmg) then
        CastSpell(_W, enemy)
      end
    end
  end
end

-- R
 function AutoUlt()
   local ultrangehero = CountEnemies(myHero, RRange)
   if ultrangehero >= 2 and RREADY then
     if Menu.shieldUlt and EREADY then CastSpell(_E, myHero) end
     CastSpell(_R)
   end
 end
 -- Check function
 function checks()
   QREADY = (myHero:CanUseSpell(_Q) == READY)
   WREADY = (myHero:CanUseSpell(_W) == READY)
   EREADY = (myHero:CanUseSpell(_E) == READY)
   RREADY = (myHero:CanUseSpell(_R) == READY)
 end
-- Draw stuff 
 function PluginOnDraw()
   if AutoCarry.PluginMenu.drawcircle and not myHero.dead then
     if RREADY then DrawCircle (myHero.x, myHero.y, myHero.z, RRange, 0x19A712) end
     if QREADY then DrawCircle (myHero.x, myHero.y, myHero.z, QRange, 0x0000FF) end
   end
 end

--UPDATEURL=
--HASH=3DDEE12C0430539DD6200FBE5D4FD95A
