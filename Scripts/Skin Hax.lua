-- In game skin changer, by Shalzuth --

numSkins = {
Aatrox = 1,Ahri = 4,Akali = 6,Alistar = 7,
Amumu = 7,Anivia = 5,Annie = 8,Ashe = 6,
Blitzcrank = 7,Brand = 4,Braum = 1,Caitlyn = 5,
Cassiopeia = 4,Chogath = 5,Corki = 6,Darius = 3,
Diana = 2,Draven = 3,DrMundo = 7,Elise = 2,
Evelynn = 3,Ezreal = 6,Fiddlesticks = 8,Fiora = 3,
Fizz = 4,Galio = 4,Gangplank = 6,Garen = 6,
Gragas = 7,Graves = 5,Hecarim = 5,Heimerdinger = 5,
Irelia = 4,Janna = 5,JarvanIV = 5,Jax = 8,
Jayce = 2,Jinx = 1,Karma = 3,Karthus = 4,
Kassadin = 4,Katarina = 7,Kayle = 6,Kennen = 5,
Khazix = 1,KogMaw = 7,Leblanc = 3,LeeSin = 6,
Leona = 4,Lissandra = 2,Lucian = 2,Lulu = 4,
Lux = 5,Malphite = 5,Malzahar = 4,Maokai = 5,
Masteryi = 5,MasterYi = 5,
MissFortune = 6,MonkeyKing = 3,Mordekaiser = 4,Morgana = 5,
Nami = 2,Nasus = 5,Nautilus = 3,Nidalee = 6,
Nocturne = 5,Nunu = 6,Olaf = 4,Orianna = 4,
Pantheon = 6,Poppy = 6,Quinn = 2,Rammus = 6,
Random = 0,Renekton = 6,Rengar = 2,Riven = 5,
Rumble = 3,Ryze = 8,Sejuani = 4,Shaco = 6,
Shen = 6,Shyvana = 4,Singed = 6,Sion = 4,
Sivir = 6,Skarner = 2,Sona = 5,Soraka = 3,
Swain = 3,Syndra = 2,Talon = 3,Taric = 3,
Teemo = 7,Thresh = 2,Tristana = 6,Trundle = 3,
Tryndamere = 6,TwistedFate = 8,Twitch = 5,Udyr = 3,
Urgot = 3,Varus = 3,Vayne = 5,Veigar = 7,
Velkoz = 1,Viktor = 3,Vi = 2,Vladimir = 6,
Volibear = 3,Warwick = 7,Xerath = 3,XinZhao = 5,
Yasuo = 1,Yorick = 2,Zac = 1,Zed = 3,
Ziggs = 4,Zilean = 4,Zyra = 3
}
currSkinId = 0
canChange = true 
function OnLoad()
    print("<font color = '#00FFFF' >Skin Hax by Shalzuth</font>")
    Menu = scriptConfig('SkinHax', 'SkinHax')
    Menu:addParam('Cycle', 'Cycle Skins', SCRIPT_PARAM_ONKEYDOWN, false, 0x60)
end
function OnTick()
    if Menu.Cycle then
        if canChange then
            canChange = false
            GenModelPacket(myHero.charName, currSkinId)
            if (numSkins[myHero.charName] > currSkinId) then currSkinId = currSkinId + 1 else currSkinId = 0 end
        end
    else
        canChange = true
    end
end
function GenModelPacket(champ, skinId)
    p = CLoLPacket(0x97)
    p:EncodeF(myHero.networkID)
    p.pos = 1
    t1 = p:Decode1()
    t2 = p:Decode1()
    t3 = p:Decode1()
    t4 = p:Decode1()
    p:Encode1(t1)
    p:Encode1(t2)
    p:Encode1(t3)
    p:Encode1(bit32.band(t4,0xB))
    p:Encode1(1)--hardcode 1 bitfield
    p:Encode4(skinId)
    for i = 1, #champ do
        p:Encode1(string.byte(champ:sub(i,i)))
    end
    for i = #champ + 1, 64 do
        p:Encode1(0)
    end
    p:Hide()
    RecvPacket(p)
end