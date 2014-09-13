-- AntiBreak v0.2, by idea of eXtragoZ :D --
local lastAnimation = "Run"

function PluginOnAnimation(unit, animationName)
	if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
	--if unit.isMe and animationName ~= "Run" then PrintChat(animationName) end
end

function isChanneling()
	if lastAnimation == "Spell4" then
		return true
	else
		return false
	end
end

function PluginOnTick()
	if isChanneling() then
		AutoCarry.CanAttack = false
		AutoCarry.CanMove = false
	else
		AutoCarry.CanAttack = true
		AutoCarry.CanMove = true
	end
end

--UPDATEURL=
--HASH=29777BD2190B76F0950ECBC18E6E790D
