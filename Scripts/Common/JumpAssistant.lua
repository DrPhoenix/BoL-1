-- Jump assistant by blackiechan v0.5
-- Stable version
-- Supports: Riven, Nidalee, Gragas, Graves, Caitlyn, Tristana, Renekton, Lucian, Shen, Fizz
-- Implemented walls: Nidalee's for now, everyone else can dash over those but some champions have more walls, I need a list
-- Default hotkey is Z but i suggest you to change it to something that doesn't conflict with any other script
-- Planned: Suggestions?
-- Credits : BoL Community for their scripts/knowledges


if myHero.charName ~= "Nidalee" and myHero.charName ~= "Renekton" and myHero.charName ~= "Riven" and myHero.charName ~= "Gragas" and
myHero.charName ~= "Graves" and myHero.charName ~= "Caitlyn" and myHero.charName ~= "Tristana" and myHero.charName ~= "Lucian" and myHero.charName ~= "Shen" and myHero.charName ~= "Fizz"
then return end

minRange = 100
displayRange = 1000
rotateMultiplier = 3 -- Bigger = faster jump, less accurate, 5 is safest but slow, 10 is smooth, 15 is smoothest but can fail

function jumpNeedsRotate() 
	if (myHero.charName == "Nidalee" or myHero.charName == "Riven") then
		return true
	else
		return false
	end
end

pouncePosition = {
	{
		pA = {x = 6393.7299804688, y = -63.87451171875, z = 8341.7451171875},
		pB = {x = 6612.1625976563, y = 56.018413543701, z = 8574.7412109375}
	},
	{
		pA = {x = 7041.7885742188, y = 0, z = 8810.1787109375},
		pB = {x = 7296.0341796875, y = 55.610824584961, z = 9056.4638671875}
	},
	{
		pA = {x = 4546.0258789063, y = 54.257415771484, z = 2548.966796875},
		pB = {x = 4185.0786132813, y = 109.35539245605, z = 2526.5520019531}
	},
	{
		pA = {x = 2805.4074707031, y = 55.182941436768, z = 6140.130859375},
		pB = {x = 2614.3215332031, y = 60.193073272705, z = 5816.9438476563}
	},
	{
		pA =  {x = 6696.486328125, y = 61.310482025146, z = 5377.4013671875},
		pB = {x = 6868.6918945313, y = 55.616455078125, z = 5698.1455078125}
	},
	{
		pA =  {x = 1677.9854736328, y = 54.923847198486, z = 8319.9345703125},
		pB = {x = 1270.2786865234, y = 50.334892272949, z = 8286.544921875}
	},
	{
		pA =  {x = 2809.3254394531, y = -58.759708404541, z = 10178.6328125},
		pB = {x = 2553.8962402344, y = 53.364395141602, z = 9974.4677734375}
	},
	{
		pA =  {x = 5102.642578125, y = -62.845260620117, z = 10322.375976563},
		pB = {x = 5483, y = 54.5009765625, z = 10427}
	},
	{
		pA =  {x = 6000.2373046875, y = 39.544124603271, z = 11763.544921875},
		pB = {x = 6056.666015625, y = 54.385917663574, z = 11388.752929688}
	},
	{
		pA =  {x = 1742.34375, y = 53.561042785645, z = 7647.1557617188},
		pB = {x = 1884.5321044922, y = 54.930736541748, z = 7995.1459960938}
	},
	{
		pA =  {x = 3319.087890625, y = 55.027889251709, z = 7472.4760742188},
		pB = {x = 3388.0522460938, y = 54.486026763916, z = 7101.2568359375}
	},
	{
		pA =  {x = 3989.9423828125, y = 51.94282913208, z = 7929.3422851563},
		pB = {x = 3671.623046875, y = 53.906265258789, z = 7723.146484375}
	},
	{
		pA =  {x = 4936.8452148438, y = -63.064865112305, z = 10547.737304688},
		pB = {x = 5156.7397460938, y = 52.951190948486, z = 10853.216796875}
	},
	{
		pA =  {x = 5028.1235351563, y = -63.082695007324, z = 10115.602539063},
		pB = {x = 5423, y = 55.15357208252, z = 10127}
	},
	{
		pA =  {x = 6035.4819335938, y = 53.918266296387, z = 10973.666015625},
		pB = {x = 6385.4013671875, y = 54.63500213623, z = 10827.455078125}
	},
	{
		pA =  {x = 4747.0625, y = 41.584358215332, z = 11866.421875},
		pB = {x = 4743.23046875, y = 51.196254730225, z = 11505.842773438}
	},
	{
		pA =  {x = 6749.4487304688, y = 44.903495788574, z = 12980.83984375},
		pB = {x = 6701.4965820313, y = 52.563804626465, z = 12610.278320313}
	},
	{
		pA =  {x = 3114.1865234375, y = -42.718975067139, z = 9420.5078125},
		pB = {x = 2757, y = 53.77322769165, z = 9255}
	},
	{
		pA =  {x = 2786.8354492188, y = 53.645294189453, z = 9547.8935546875},
		pB = {x = 3002.0930175781, y = -53.198081970215, z = 9854.39453125}
	},
	{
		pA =  {x = 3803.9470214844, y = 53.730079650879, z = 7197.9018554688},
		pB = {x = 3664.1088867188, y = 54.18229675293, z = 7543.572265625}
	},
	{
		pA =  {x = 2340.0886230469, y = 60.165466308594, z = 6387.072265625},
		pB = {x = 2695.6096191406, y = 54.339839935303, z = 6374.0634765625}
	},
	{
		pA =  {x = 3249.791015625, y = 55.605854034424, z = 6446.986328125},
		pB = {x = 3157.4558105469, y = 54.080295562744, z = 6791.4458007813}
	},
	{
		pA =  {x = 3823.6242675781, y = 55.420352935791, z = 5923.9130859375},
		pB = {x = 3584.2561035156, y = 55.6123046875, z = 6215.4931640625}
	},
	{
		pA =  {x = 5796.4809570313, y = 51.673671722412, z = 5060.4116210938},
		pB = {x = 5730.3081054688, y = 54.921173095703, z = 5430.1635742188}
	},
	{
		pA =  {x = 6007.3481445313, y = 51.673641204834, z = 4985.3803710938},
		pB = {x = 6388.783203125, y = 51.673400878906, z = 4987}
	},
	{
		pA =  {x = 7040.9892578125, y = 57.192108154297, z = 3964.6728515625},
		pB = {x = 6668.0073242188, y = 51.671356201172, z = 3993.609375}
	},	
	{
		pA =  {x = 7763.541015625, y = 54.872283935547, z = 3294.3481445313},
		pB = {x = 7629.421875, y = 56.908012390137, z = 3648.0581054688}
	},
	{
		pA =  {x = 4705.830078125, y = -62.586814880371, z = 9440.6572265625},
		pB = {x = 4779.9809570313, y = -63.09009552002, z = 9809.9091796875}
	},
	{
		pA =  {x = 4056.7907714844, y = -63.152275085449, z = 10216.12109375},
		pB = {x = 3680.1550292969, y = -63.701038360596, z = 10182.296875}
	},
	{
		pA =  {x = 4470.0883789063, y = 41.59789276123, z = 12000.479492188},
		pB = {x = 4232.9799804688, y = 49.295585632324, z = 11706.015625}
	},
	{
		pA =  {x = 5415.5708007813, y = 40.682685852051, z = 12640.216796875},
		pB = {x = 5564.4409179688, y = 41.373748779297, z = 12985.860351563}
	},
	{
		pA =  {x = 6053.779296875, y = 40.587882995605, z = 12567.381835938},
		pB = {x = 6045.4555664063, y = 41.211364746094, z = 12942.313476563}
	},
	{
		pA =  {x = 4454.66015625, y = 42.799690246582, z = 8057.1313476563},
		pB = {x = 4577.8681640625, y = 53.31339263916, z = 7699.3686523438}
	},
	{
		pA =  {x = 7754.7700195313, y = 52.890430450439, z = 10449.736328125},
		pB = {x = 8096.2885742188, y = 53.66955947876, z = 10288.80078125}
	},
	{
		pA =  {x = 7625.3139648438, y = 55.008113861084, z = 9465.7001953125},
		pB = {x = 7995.986328125, y = 53.530490875244, z = 9398.1982421875}
	},
	{
		pA =  {x = 9767, y = 53.044532775879, z = 8839},
		pB = {x = 9653.1220703125, y = 53.697280883789, z = 9174.7626953125}
	},
	{
		pA =  {x = 10775.653320313, y = 55.35241317749, z = 7612.6943359375},
		pB = {x = 10665.490234375, y = 65.222145080566, z = 7956.310546875}
	},
	{
		pA =  {x = 10398.484375, y = 66.200691223145, z = 8257.8642578125},
		pB = {x = 10176.104492188, y = 64.849853515625, z = 8544.984375}
	},
	{
		pA =  {x = 11198.071289063, y = 67.641044616699, z = 8440.4638671875},
		pB = {x = 11531.436523438, y = 53.454048156738, z = 8611.0087890625}
	},
	{
		pA =  {x = 11686.700195313, y = 55.458232879639, z = 8055.9624023438},
		pB = {x = 11314.19140625, y = 58.438243865967, z = 8005.4946289063}
	},
	{
		pA =  {x = 10707.119140625, y = 55.350387573242, z = 7335.1752929688},
		pB = {x = 10693, y = 54.870254516602, z = 6943}
	},
	{
		pA =  {x = 10395.380859375, y = 54.869094848633, z = 6938.5009765625},
		pB = {x = 10454.955078125, y = 55.308219909668, z = 7316.7041015625}
	},
	{
		pA =  {x = 10358.5859375, y = 54.86909866333, z = 6677.1704101563},
		pB = {x = 10070.067382813, y = 55.294486999512, z = 6434.0815429688}
	},
	{
		pA =  {x = 11161.98828125, y = 53.730766296387, z = 5070.447265625},
		pB = {x = 10783, y = -63.57177734375, z = 4965}
	},
	{
		pA =  {x = 11167.081054688, y = -62.898971557617, z = 4613.9829101563},
		pB = {x = 11501, y = 54.571090698242, z = 4823}
	},
	{
		pA =  {x = 11743.823242188, y = 52.005855560303, z = 4387.4672851563},
		pB = {x = 11379, y = -61.565242767334, z = 4239}
	},
	{
		pA =  {x = 10388.120117188, y = -63.61775970459, z = 4267.1796875},
		pB = {x = 10033.036132813, y = -60.332069396973, z = 4147.1669921875}
	},
	{
		pA =  {x = 8964.7607421875, y = -63.284225463867, z = 4214.3833007813},
		pB = {x = 8569, y = 55.544258117676, z = 4241}
	},
	{
		pA =  {x = 5554.8657226563, y = 51.680099487305, z = 4346.75390625},
		pB = {x = 5414.0634765625, y = 51.611679077148, z = 4695.6860351563}
	},
	{
		pA =  {x = 7311.3393554688, y = 54.153884887695, z = 10553.6015625},
		pB = {x = 6938.5209960938, y = 54.441242218018, z = 10535.8515625}
	},
	{
		pA =  {x = 7669.353515625, y = -64.488967895508, z = 5960.5717773438},
		pB =  {x = 7441.2182617188, y = 54.347793579102, z = 5761.8989257813}
	},
	{
		pA =  {x = 7949.65625, y = 54.276401519775, z = 2647.0490722656},
		pB = {x = 7863.0063476563, y = 55.178623199463, z = 3013.7814941406}
	},
	{
		pA =  {x = 8698.263671875, y = 57.178703308105, z = 3783.1169433594},
		pB = {x = 9041, y = -63.242683410645, z = 3975}
	},
	{
		pA =  {x = 9063, y = 68.192077636719, z = 3401},
		pB = {x = 9275.0751953125, y = -63.257461547852, z = 3712.8935546875}
	},
	{
		pA =  {x = 12064.340820313, y = 54.830627441406, z = 6424.11328125},
		pB = {x = 12267.9375, y = 54.83561706543, z = 6742.9453125}
	},
	{
		pA =  {x = 12797.838867188, y = 58.281986236572, z = 5814.9653320313},
		pB = {x = 12422.740234375, y = 54.815074920654, z = 5860.931640625}
	},
	{
		pA =  {x = 11913.165039063, y = 54.050819396973, z = 5373.34375},
		pB = {x = 11569.1953125, y = 57.787326812744, z = 5211.7143554688}
	},	{
		pA =  {x = 9237.3603515625, y = 67.796775817871, z = 2522.8937988281},
		pB = {x = 9344.2041015625, y = 65.500213623047, z = 2884.958984375}
	},
	{
		pA =  {x = 7324.2783203125, y = 52.594970703125, z = 1461.2199707031},
		pB = {x = 7357.3852539063, y = 54.282878875732, z = 1837.4309082031}
	}


	
}

closest = minRange+1
startPoint = {}
endPoint = {}
directionVector = {}
directionPos = {}
lastUsedStart = {}
lastUsedEnd = {}

busy = false
rivenCanJump = false

function oppositeCast()
	if (myHero.charName == "Caitlyn") then
		return true
	end
	return false
end
function SpellToCast()
	if myHero.charName == "Riven" then
		return _Q
	elseif myHero.charName == "Nidalee" then
		return _W
	elseif myHero.charName == "Fizz" then
		return _E
	elseif myHero.charName == "Gragas" then
		return _E
	elseif myHero.charName == "Lucian" then
		return _E
	elseif myHero.charName == "Graves" then
		return _E
	elseif myHero.charName == "Shen" then
		return _E
	elseif myHero.charName == "Renekton" then
		return _E
	elseif myHero.charName == "Caitlyn" then
		return _E
	elseif myHero.charName == "Tristana" then
		return _W
		
	end
	
end

function changeDirection1()
	if (jumpNeedsRotate()) then
		myHero:HoldPosition()
		Packet('S_MOVE', {x = startPoint.x+directionVector.x/rotateMultiplier, y = startPoint.z+directionVector.z/rotateMultiplier}):send()

		directionPos = Vector(startPoint)
		directionPos.x = startPoint.x+directionVector.x/rotateMultiplier
		directionPos.y = startPoint.y+directionVector.y/rotateMultiplier
		directionPos.z = startPoint.z+directionVector.z/rotateMultiplier
		
		delay = 0.06
		MyDelayAction(changeDirection2,delay)
	else 
			CastJump()
	end
end

function changeDirection2()
   
	Packet('S_MOVE', {x = startPoint.x, y = startPoint.z}):send()
	delay = 0.070
	MyDelayAction(CastJump,delay)
end

function CastJump()
	if (oppositeCast()) then
		CastSpell(SpellToCast(),startPoint.x+directionVector.x, startPoint.z+directionVector.z)
	else
		CastSpell(SpellToCast(),endPoint.x, endPoint.z)
	end
	myHero:HoldPosition()
	MyDelayAction(freeFunction,1)
end

function freeFunction()
	busy = false
end

--[[
Record wall jumps with nidalee
For Dev/Testing only
function EndPosition() 
lastUsedEnd.x = myHero.x
lastUsedEnd.y = myHero.y
	lastUsedEnd.z = myHero.z
	if (GetDistance(lastUsedStart) >= 150) then
		file = io.open("walls.txt", "a")
		file:write("\t{\n")
		file:write("\t\tpA =  {x = ".. lastUsedStart.x ..", y = ".. lastUsedStart.y ..", z = ".. lastUsedStart.z .."},\n")
		file:write("\t\tpB = {x = ".. lastUsedEnd.x ..", y = ".. lastUsedEnd.y ..", z = ".. lastUsedEnd.z .."}\n")
		file:write("\t},\n")
		file:close()
		print("wrote");
	end
end

function OnProcessSpell(object,spellProc)
	if (object == myHero and spellProc.name == "Pounce") then
		lastUsedStart.x = myHero.x
		lastUsedStart.y = myHero.y
		lastUsedStart.z = myHero.z
		DelayAction(EndPosition,0.9)
	end
end
--]]--

functionDelay = 0;
functionToExecute = nil

function MyAccurateDelay() --For some reason DelayAction seems buggy as fuck, might be the Lua version spudgy is using.
		if (functionToExecute ~= nil and (functionDelay <= os.clock())) then
			functionDelay = nil
			functionToExecute()
			if (functionDelay == nil) then
				functionToExecute = nil
			end
		end
end

function MyDelayAction(b,a)
	functionDelay = a+os.clock()
	functionToExecute = b
end

function OnLoad()
        NidaleeConfig = scriptConfig("Jump Assistant", "JumpAssistant")
        NidaleeConfig:addParam("Jump", "Jump Assistant", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
        NidaleeConfig:permaShow("Jump")
        PrintChat(">> Jump Assistant 0.5 by blackiechan (VIP Version)")
end

function OnTick() 
		MyAccurateDelay()
		if (NidaleeConfig.Jump and busy == false and myHero:CanUseSpell(SpellToCast()) == READY and specialCondition()) then
				closest = minRange+1
				for i,group in pairs(pouncePosition) do
					if (GetDistance(group.pA) < closest or GetDistance(group.pB) < closest ) then
						busy = true
						if (GetDistance(group.pA) < GetDistance(group.pB)) then
							closest = GetDistance(group.pA)
							startPoint = group.pA
							endPoint = group.pB
						else
							closest = GetDistance(group.pB)
							startPoint = group.pB
							endPoint = group.pA
						 end
					end 
				end
				if (busy == true) then
					directionVector = Vector(startPoint):__sub(endPoint)
					myHero:HoldPosition()
					Packet('S_MOVE', {x = startPoint.x, y = startPoint.z}):send()
					delay = 0.19
					MyDelayAction(changeDirection1,delay)
				
				end
		end
		
end

function specialCondition()
	if (myHero.charName == "Riven") then
			return rivenCanJump;
	elseif (myHero.charName == "Nidalee") then
			if (myHero:GetSpellData(SpellToCast()).name == "Pounce") then 
				return true
			end
	else 
		return true
	end
	return false
end

function OnUpdateBuff(unit, buff) 
	if (unit == myHero and buff.name == "RivenTriCleave" and buff.stack == 2) then
		rivenCanJump = true
	end
end

function OnLoseBuff(unit, buff)
	if (unit == myHero and buff.name == "RivenTriCleave") then
		rivenCanJump = false
	end
end

function OnDraw()
			if (NidaleeConfig.Jump and specialCondition()) then
				for i,group in pairs(pouncePosition) do
					
					if (GetDistance(group.pA) < displayRange or GetDistance(group.pB) < displayRange) then
						DrawCircle(group.pA.x, group.pA.y, group.pA.z, minRange, 0x00FF00)
						DrawCircle(group.pB.x, group.pB.y, group.pB.z, minRange, 0x00FF00)
					end
			end
end
end

--UPDATEURL=
--HASH=719ED27D63AF5C55F14F7B43A022B8F5
