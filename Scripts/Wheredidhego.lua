--[[#####   Where did he go? v0.6 by ViceVersa   #####]]--
--[[Draws a line to the location where enemys blink or flash to.]]

--Vars
local blink = {} --Blink Ability Array
local vayneUltEndTick = 0
local shacoIndex = 0


--Functions
function FindNearestNonWall(x0, y0, z0, maxRadius, precision) --returns the nearest non-wall-position of the given position(Credits to gReY)
    
    --Convert to vector
    local vec = D3DXVECTOR3(x0, y0, z0)
    
    --If the given position it a non-wall-position return it
    if not IsWall(vec) then return vec end
    
    --Optional arguments
    precision = precision or 50
    maxRadius = maxRadius and math.floor(maxRadius / precision) or math.huge
    
    --Round x, z
    x0, z0 = math.round(x0 / precision) * precision, math.round(z0 / precision) * precision

    --Init vars
    local radius = 1
    
    --Check if the given position is a non-wall position
    local function checkP(x, y) 
        vec.x, vec.z = x0 + x * precision, z0 + y * precision 
        return not IsWall(vec) 
    end
    
    --Loop through incremented radius until a non-wall-position is found or maxRadius is reached
    while radius <= maxRadius do
        --A lot of crazy math (ask gReY if you don't understand it. I don't)
        if checkP(0, radius) or checkP(radius, 0) or checkP(0, -radius) or checkP(-radius, 0) then 
            return vec 
        end
        local f, x, y = 1 - radius, 0, radius
        while x < y - 1 do
            x = x + 1
            if f < 0 then 
                f = f + 1 + 2 * x
            else 
                y, f = y - 1, f + 1 + 2 * (x - y)
            end
            if checkP(x, y) or checkP(-x, y) or checkP(x, -y) or checkP(-x, -y) or 
               checkP(y, x) or checkP(-y, x) or checkP(y, -x) or checkP(-y, -x) then 
                return vec 
            end
        end
        --Increment radius every iteration
        radius = radius + 1
    end
end
    
    
--Callbacks
function OnLoad() --Called one time on load
    
    --Fill the Blink Ability Array
    for i, heroObj in pairs(GetEnemyHeroes()) do
        
        --If the object exists and the player is in the enemy team
        if heroObj and heroObj.valid then
            
            --Summoner Flash
            if heroObj:GetSpellData(SUMMONER_1).name:find("Flash") or heroObj:GetSpellData(SUMMONER_2).name:find("Flash") then
                table.insert(blink,{name = "SummonerFlash"..heroObj.charName, maxRange = 400, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "Flash"})
            end
            
            --Aatrox Q
            if heroObj.charName == "Aatrox" then
                table.insert(blink,{name = "AatroxQ", maxRange = 650, radius = 275, delay = 1, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})
            
            --Ahri R
            elseif heroObj.charName == "Ahri" then
                table.insert(blink,{name = "AhriTumble", maxRange = 450, delay = 0.6, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})
            
            --Akali R
            elseif heroObj.charName == "Akali" then
                table.insert(blink,{name = "AkaliShadowDance", maxRange = 800, delay = 0.5, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})
            
            --Ezreal E
            elseif heroObj.charName == "Ezreal" then
                table.insert(blink,{name = "EzrealArcaneShift", maxRange = 475, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})
            
            --Fiora R
            elseif heroObj.charName == "Fiora" then
                table.insert(blink,{name = "FioraDance", maxRange = 700, delay = 1, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "R", target = {}, targetDead = false})
            
            --Kassadin R
            elseif heroObj.charName == "Kassadin" then
                table.insert(blink,{name = "RiftWalk", maxRange = 700, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "R"})
            
            --Katarina E
            elseif heroObj.charName == "Katarina" then
                table.insert(blink,{name = "KatarinaE", maxRange = 700, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})
            
            --Khazix E
            elseif heroObj.charName == "Khazix" then
                table.insert(blink,{name = "KhazixE", maxRange = 600, delay = 0.9, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})
                table.insert(blink,{name = "khazixelong", maxRange = 900, delay = 1, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E+"})
            
            --Leblanc W
            elseif heroObj.charName == "Leblanc" then
                table.insert(blink,{name = "LeblancSlide", maxRange = 600, delay = 0.5, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W"})
                table.insert(blink,{name = "leblancslidereturn", delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W(R)"})
                table.insert(blink,{name = "LeblancSlideM", maxRange = 600, delay = 0.5, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W+"})
                table.insert(blink,{name = "leblancslidereturnm", delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W+(R)"})
            
            --[[Lissandra E (wip)(ToDo: Draw where she blinks to only when she does)
            elseif heroObj.charName == "Lissandra" then
                table.insert(blink,{name= "LissandraE", maxRange = 700, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})]]
            
            --Master Yi Q
            elseif heroObj.charName == "MasterYi" then
                table.insert(blink,{name = "AlphaStrike", maxRange = 600, delay = 0.9, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "Q", target = {}, targetDead = false})
            
            --Shen E
            elseif heroObj.charName == "MasterYi" then
                table.insert(blink,{name = "AlphaStrike", maxRange = 600, delay = 0.9, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})
            
            --Shaco Q
            elseif heroObj.charName == "Shaco" then
                table.insert(blink,{name = "Deceive", maxRange = 400, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "Q", outOfBush = false})
                shacoIndex = #blink --Save the position of shacos Q

            --Talon E
            elseif heroObj.charName == "Talon" then
                table.insert(blink,{name = "TalonCutthroat", maxRange = 700, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})
            
            --Tryndamere W
            elseif heroObj.charName == "Tryndamere" then
                table.insert(blink,{name = "Slash", maxRange = 600, delay = 0.9, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W"})
            
            --Tristana W
            elseif heroObj.charName == "Tristana" then
                table.insert(blink,{name = "RocketJump", maxRange = 900, radius = 200, delay = 1.1, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W"})
            
            --Vayne Q
            elseif heroObj.charName == "Vayne" then
                table.insert(blink,{name = "VayneTumble", maxRange = 250, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "Q"})
                vayneUltEndTick = 1 --Start to check for Vayne's ult
            
            --Zac E
            elseif heroObj.charName == "Zac" then
                table.insert(blink,{name = "ZacE", maxRange = 1550, radius = 200, delay = 1.5, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "Q"})
            
            --[[Zed W (wip)(ToDo: Draw where he blinks when he swaps place with shadow)
            elseif heroObj.charName == "Zed" then
                table.insert(blink,{name= "ZedShadowDash", maxRange = 999, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W"})]]
            
            end
            
        end
    end
    
    --If something was added to the array
    if #blink > 0 then

        --Shift-Menu
        WDHGConfig = scriptConfig("Where did he go?","whereDidHeGo")
        WDHGConfig:addParam("wallPrediction",     "Use Wall Prediction",      SCRIPT_PARAM_ONOFF, false)
        WDHGConfig:addParam("displayTime",        "Display time (No Vision)", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
        WDHGConfig:addParam("displayTimeVisible", "Display time (Vision)",    SCRIPT_PARAM_SLICE, 1, 0.5, 3, 1)
        WDHGConfig:addParam("lineColor",          "Line Color",               SCRIPT_PARAM_COLOR, {255,255,255,0})
        WDHGConfig:addParam("lineWidth",          "Line Width",               SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
        WDHGConfig:addParam("circleColor",        "Circle Color",             SCRIPT_PARAM_COLOR, {255,255,25,0})
        WDHGConfig:addParam("circleSize",         "Circle Size",              SCRIPT_PARAM_SLICE, 100, 50, 300, 0)
    
        --Print Load-Message
        if #blink > 1 then
            print('<font color="#A0FF00">Where did he go? >> v0.6 loaded! (Found '..#blink..' abilitys)</font>')
        else
            print('<font color="#A0FF00">Where did he go? >> v0.6 loaded! (Found 1 ability)</font>')
        end
        
    else
        --Print Notice
        print('<font color="#FFFF25">Where did he go? >> No characters with supported abilitys or flash found!</font>')
    end
    
end

function OnProcessSpell(unit, spell)--When a spell is casted
    
    --If the casting unit is in the enemy team and if it is a champion-ability
    if unit and unit.valid and unit.team == TEAM_ENEMY and unit.type ~= "obj_AI_Minion" and unit.type ~= "obj_AI_Turret" then
        
        --If the spell is Vayne's R
        if vayneUltEndTick > 0 and spell.name == "vayneinquisition" then
            vayneUltEndTick = os.clock() + 6 + 2*spell.level
            return --skip the array
        end
        
        --For each skillshot in the array
        for i=1, #blink, 1 do
            
            --If the casted spell is in the array
            if spell.name == blink[i].name or spell.name..unit.charName == blink[i].name then                
                
                --local function to set the normal end position
                local function SetNormalEndPosition(i, spell)
                    --If the position the enemy clicked is inside the range of the ability set the end position to that position
                    if GetDistance(spell.startPos, spell.endPos) <= blink[i].maxRange then
                        --Set the end position
                        blink[i].endPos = { x = spell.endPos.x, y = spell.endPos.y, z = spell.endPos.z }
                    
                    --Else Calculate the true position if the enemy clicked outside of the ability range
                    else
                        local vStartPos = Vector(spell.startPos.x, spell.startPos.y, spell.startPos.z)
                        local vEndPos = Vector(spell.endPos.x, spell.endPos.y, spell.endPos.z)
                        local tEndPos = vStartPos - (vStartPos - vEndPos):normalized() * blink[i].maxRange
                        
                        --If enabled, Check if the position is in a wall and return the position where the player was really flashed to
                        if WDHGConfig.wallPrediction then
                            tEndPos = FindNearestNonWall(tEndPos.x, tEndPos.y, tEndPos.z, 1000)
                        end
                        
                        --Set the end position
                        blink[i].endPos = { x = tEndPos.x, y = tEndPos.y, z = tEndPos.z }
                    
                    end
                end
                
                --##### Champion-Specific-Stuff #####--
                --#Vayne#
                --Exit if the spell is Vayne's Q and her ult isn't running
                if blink[i].name == "VayneTumble" and os.clock() >= vayneUltEndTick then return end
                
                --#Shaco#
                --Set outOfBush to false if the spell can be tracked
                if blink[i].name == "Deceive" then
                    blink[i].outOfBush = false
                end
                
                --#Leblanc#
                --If the spell is a mirrored W
                if blink[i].name == "LeblancSlideM" then
                    
                    --Cancel the normal W
                    blink[i-2].casted = false
                    
                    --Set the start position to the start position of the first W
                    blink[i].startPos = { x = blink[i-2].startPos.x, y = blink[i-2].startPos.y, z = blink[i-2].startPos.z }
                    
                    --Set the normal end position
                    SetNormalEndPosition(i, spell)
                
                --If the spell is one of Leblanc's returns
                elseif blink[i].name == "leblancslidereturn" or blink[i].name == "leblancslidereturnm" then
                    
                    --Cancel the other W-spells if she returns
                    if blink[i].name == "leblancslidereturn" then
                        blink[i-1].casted = false
                        blink[i+1].casted = false
                        blink[i+2].casted = false
                    else
                        blink[i-3].casted = false
                        blink[i-2].casted = false
                        blink[i-1].casted = false
                    end
                    
                    --Set the normal start position
                    blink[i].startPos = { x = spell.startPos.x, y = spell.startPos.y, z = spell.startPos.z }
                    
                    --Set the end position to the start position of her last slide
                    blink[i].endPos = { x = blink[i-1].startPos.x, y = blink[i-1].startPos.y, z = blink[i-1].startPos.z }
                
                --#Fiora# / #MasterYi#
                elseif blink[i].name == "FioraDance" or blink[i].name == "AlphaStrike" then
                    
                    --Set the target minion
                    blink[i].target = spell.target
                    
                    --Set targetDead to false
                    blink[i].targetDead = false
                    
                    --Set the normal start position
                    blink[i].startPos = { x = spell.startPos.x, y = spell.startPos.y, z = spell.startPos.z }
                    
                    --Set the end position to the position of the targeted unit
                    blink[i].endPos = { x = blink[i].target.x, y = blink[i].target.y, z = blink[i].target.z }
                    
                    
                --##### End of Champion-Specific-Stuff #####--
                                
                --Else set the normal positions
                else
                    
                    --Set the start position
                    blink[i].startPos = { x = spell.startPos.x, y = spell.startPos.y, z = spell.startPos.z }
                    
                    --Set the end position
                    SetNormalEndPosition(i, spell)

                end
                
                --Set casted to true
                blink[i].casted = true
                
                --Set the time when the ability is casted
                blink[i].timeCasted = os.clock()
                                
                --Exit loop
                break
                
            end
            
        end
    end
end

function OnCreateObj(obj)
	if shacoIndex ~= 0 and obj and obj.valid and obj.name == "JackintheboxPoof2.troy" and not blink[shacoIndex].casted then
        --Set the start and end position of shacos Q to the position of the obj
        blink[shacoIndex].startPos = { x = obj.x, y = obj.y, z = obj.z }
        blink[shacoIndex].endPos = { x = obj.x, y = obj.y, z = obj.z }
        
        --Set casted to true
        blink[shacoIndex].casted = true
        
        --Set the time when the ability is casted
        blink[shacoIndex].timeCasted = os.clock()
        
        --Set outOfBush to true to draw the circle instead the line
        blink[shacoIndex].outOfBush = true
	end
end

function OnTick()
    --Loop through all abilitys
    for i=1, #blink, 1 do
        
        --If the ability was casted
        if blink[i].casted then
            
            --If the enemy is Fiora or Master Yi and the target is not dead
            if blink[i].name == "FioraDance" or blink[i].name == "AlphaStrike" and not blink[i].targetDead then
                if os.clock() > (blink[i].timeCasted + blink[i].delay + 0.2) then
                    blink[i].casted = false
                elseif blink[i].target.dead then
                    --Save startPos in a temp var
                    local tempPos = { x = blink[i].endPos.x, y = blink[i].endPos.y, z = blink[i].endPos.z }
                    --Set the end position to the start position
                    blink[i].endPos = { x = blink[i].startPos.x, y = blink[i].startPos.y, z = blink[i].startPos.z }
                    --Set the start position to the enemy position
                    blink[i].startPos = { x = tempPos.x, y = tempPos.y, z = tempPos.z }
                    --Set targetDead to true
                    blink[i].targetDead = true
                else
                    --Set the end position the the target unit
                    blink[i].endPos = { x = blink[i].target.x, y = blink[i].target.y, z = blink[i].target.z }
                end
            
            --If the champ is dead or display time is over stop the drawing
            elseif blink[i].castingHero.dead or (not blink[i].castingHero.visible and os.clock() > (blink[i].timeCasted + WDHGConfig.displayTime + blink[i].delay)) or (blink[i].castingHero.visible and os.clock() > (blink[i].timeCasted + WDHGConfig.displayTimeVisible + blink[i].delay)) then
                blink[i].casted = false
                
            --If the enemy is visible after the delay set the target to his position
            elseif not blink[i].outOfBush and blink[i].castingHero.visible and os.clock() > blink[i].timeCasted + blink[i].delay then
                --Set the end position the the current position of the enemy
                blink[i].endPos = { x = blink[i].castingHero.x, y = blink[i].castingHero.y, z = blink[i].castingHero.z }
                
            end
        end
    end
end

function OnDraw()
    --For each ability in the array
    for i=1, #blink, 1 do
        
        --If the ability is casted
        if blink[i].casted then
            
            --Change circle size for jump-abilitys
            local cSize = WDHGConfig.circleSize
            if blink[i].radius and os.clock() < (blink[i].timeCasted + blink[i].delay ) then
                cSize = blink[i].radius
            end
            
            --Convert 3D-coordinates to 2D-coordinates for DrawLine and InfoText
            local lineStartPos = WorldToScreen(D3DXVECTOR3(blink[i].startPos.x, blink[i].startPos.y, blink[i].startPos.z))
            local lineEndPos = WorldToScreen(D3DXVECTOR3(blink[i].endPos.x, blink[i].endPos.y, blink[i].endPos.z))            
            
            --If the ability is shacos Q out of a bush draw only a circle
            if blink[i].outOfBush then
                --Draw a circle showing the possible target
                for j=0, 3, 1 do
                    DrawCircle(blink[i].endPos.x , blink[i].endPos.y , blink[i].endPos.z, blink[i].maxRange+j*2, ARGB(255, 255, 25, 0))
                end
            
            --Else draw the normal circle with a line
            else
                --Draw Circle at target position
                for j=0, 3, 1 do
                    DrawCircle(blink[i].endPos.x , blink[i].endPos.y , blink[i].endPos.z , cSize+j*2, RGB(WDHGConfig.circleColor[2],WDHGConfig.circleColor[3],WDHGConfig.circleColor[4]))
                end
                                
                --Draw Line beetween the start and target position
                DrawLine(lineStartPos.x, lineStartPos.y, lineEndPos.x, lineEndPos.y, WDHGConfig.lineWidth, RGB(WDHGConfig.lineColor[2],WDHGConfig.lineColor[3],WDHGConfig.lineColor[4]))
            end
            
            --Draw the info text (Credits to Weee :3)
            local offset = 30
            local infoText = blink[i].castingHero.charName .. " " .. blink[i].shortName
            DrawLine(lineEndPos.x, lineEndPos.y, lineEndPos.x + offset, lineEndPos.y - offset, 1, ARGB(255,255,255,255))
            DrawLine(lineEndPos.x + offset, lineEndPos.y - offset, lineEndPos.x + offset + 6 * infoText:len(), lineEndPos.y - offset, 1, ARGB(255,255,255,255))
            DrawTextA(infoText, 12, lineEndPos.x + offset + 1, lineEndPos.y - offset, ARGB(255,255,255,255), "left", "bottom")

        end
    end
end