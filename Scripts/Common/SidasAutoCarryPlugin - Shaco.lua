local SkillQ = {spellKey = _Q, range = 500, speed = 1.7, delay = 600}
local SkillW = {spellKey = _W, range = 420, speed = 1.6, delay = 325}
local SkillE = {spellKey = _E, range = 620, speed = 1.6, delay = 325}
TargetPos = Vector(ts.target.x, ts.target.y, ts.target.z)
MyPos = Vector(myHero.x, myHero.y, myHero.z)
BackPos = TargetPos + (TargetPos-MyPos)*((50/GetDistance(ts.target)))

--Menu--
AutoCarry.PluginMenu:addParam("Combo", "Auto Win", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
AutoCarry.PluginMenu:addParam("ComboMix", "Auto Win", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
--EndOfMenu--
function PluginOnTick()
    if AutoCarry.PluginMenu.Combo or AutoCarry.PluginMenu.ComboMix then
        QCast()
        WCast()
        ECast()
    end
end
function QCast()
    for _, enemy in pairs(AutoCarry.EnemyTable) do
        if ValidTarget(enemy, QRange) and not enemy.dead and myHero:CanUseSpell(_Q) == READY then
            AutoCarry.CastSkillshot(SkillQ, BackPos)
        end
    end
end
function WCast()
    for _, enemy in pairs(AutoCarry.EnemyTable) do
        if ValidTarget(enemy, WRange) and not enemy.dead and myHero:CanUseSpell(_W) == READY then
            AutoCarry.CastSkillshot(SkillW, enemy)
        end
    end
end
function ECast()
    for _, enemy in pairs(AutoCarry.EnemyTable) do
        if ValidTarget(enemy, ERange) and not enemy.dead and myHero:CanUseSpell(_E) == READY then
            CastSpell(_E, enemy)
        end
    end
end

--UPDATEURL=
--HASH=5909DD4988F9FEA1E630606A9CC50C4E
