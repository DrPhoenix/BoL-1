-- ###################################################################################################### --
-- #                                                                                                    # --
-- #                                              Attack Range                                          # --
-- #                                                by Sida                                             # --
-- #                                                                                                    # --
-- ###################################################################################################### --

if myHero == nil then myHero = GetMyHero() end

local showAllyRange = true -- Choose whether to also display range for your own team

function OnDraw()
	if not myHero.dead then
			DrawCircle(myHero.x, myHero.y, myHero.z, getMyTrueRange(), 0x19A712)	
		drawChampionHitBoxes()
	end
end

function getHitBoxRadius(target)
	return GetDistance(target.minBBox, target.maxBBox)/2
end

function getMyTrueRange()
	return myHero.range + GetDistance(myHero, myHero.minBBox) 
end

function drawChampionHitBoxes()
	for i=1, heroManager.iCount do
		enemy = heroManager:GetHero(i)
		if enemy ~= nil then
			if not enemy.dead and enemy.visible then
				if (showAllyRange == false and enemy.team ~= myHero.team) or showAllyRange then
					DrawCircle(enemy.x, enemy.y, enemy.z, getHitBoxRadius(enemy) + enemy.range, 0x19A712)
				end
			end
		end
	end
end


--UPDATEURL=
--HASH=DC3ACB817A90903D7ADCA4DF47B35EB7
