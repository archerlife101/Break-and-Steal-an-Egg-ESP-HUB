-- CRBF HUB V22 | Mastery square icon + in-game GUI access (self-contained; no external downloads)
-- Built on V16: retains its existing tracking, index, filters and ESP features
-- CRBF HUB V23 | Clean navigation and floating buttons
-- CRBF HUB V15 | Zone-first index, rarity backcards, responsive navigation
-- CRBF HUB V13.1 | Live Index synchronization + Zone Egg ESP
-- CRBF HUB V12.6 | Chilli-inspired split navigation, red/black theme, existing V11.1 logic retained
-- CRBF HUB V11.1 | Optimised standalone release
-- ESP + index tracker only. K hides the hub, not overlays.
local P=game:GetService('Players'); local U=game:GetService('UserInputService'); local H=game:GetService('HttpService')
local me=P.LocalPlayer; local pg=me:WaitForChild('PlayerGui')
for _,key in ipairs({'EggFarmingHubV103','EggFarmingHubV104','EggFarmingHubV105','EggFarmingHubV106','EggFarmingHubV107','EggFarmingHubV108','EggFarmingHubV109','EggFarmingHubV110','CRBFHubV111','CRBFHubV12'}) do local old=_G[key]; if type(old)=='table' and type(old.Stop)=='function' then pcall(old.Stop) end end
for _,name in ipairs({'EggFarmingHubV103','EggFarmingHubV104','EggFarmingHubV105','EggFarmingHubV106','EggFarmingHubV107','EggFarmingHubV108','EggFarmingHubV109','EggFarmingHubV110','CRBFHubV111','CRBFHubV12'}) do local g=pg:FindFirstChild(name); if g then g:Destroy() end end
local live=true; local con={}; local objects={}; local pages={}; local cache={}; local dirty=false; local settingsDirty=false
local rarities={'Common','Uncommon','Rare','Epic','Legendary','Mythic','Divine','Cosmic','Celestial','Secret','Void','Inferno','Omega','Spectral','Ethereal','Primordial'}
local mutations={'Gold','Diamond','Lightning','Frozen','Angelic','Hacker','Time','Void'}
local collections={'Normal','Gold','Diamond','Lightning','Frozen','Angelic','Hacker','Time','Void','Limited'}
local rc={Common='#D9D9D9',Uncommon='#91FF00',Rare='#00BFFF',Epic='#D000FF',Legendary='#FF4545',Mythic='#FFCA48',Divine='#2868FF',Cosmic='#8B00FF',Secret='#C9C9C9',Celestial='#FFCA28',Inferno='#FF5825',Void='#6200C9',Omega='#00DB8B',Spectral='#78D9FF',Ethereal='#A9FFE2',Primordial='#00C9A7',Exclusive='#FF89CA'}
local mc={Gold='#FFCD23',Diamond='#55EBFF',Lightning='#FFFF4B',Frozen='#64AFFF',Angelic='#FFFFE1',Hacker='#23FF55',Time='#FF64CD',Void='#9137E6'}
local function color(hex) return Color3.fromHex(hex or '#FFFFFF') end
local function rarityTint(name) return color(rc[tostring(name)] or '#FFFFFF') end
local function rarityGradient(target,name)
 if name~='Mythic' and name~='Ethereal' then return end
 local palette=name=='Mythic' and {'#FF4545','#FFCA28','#00DB8B','#2868FF','#D000FF'} or {'#FFE9A6','#FFB8E5','#B5B4FF','#A9FFE2','#FFE9A6'}
 local keys={}
 for i,hex in ipairs(palette) do keys[#keys+1]=ColorSequenceKeypoint.new((i-1)/(#palette-1),color(hex)) end
 local g=Instance.new('UIGradient');g.Color=ColorSequence.new(keys);g.Parent=target
end
local theme={bg=color('#0B111B'),side=color('#111E2B'),panel=color('#172638'),card=color('#203449'),border=color('#34546B'),blue=color('#26D6F5'),purple=color('#8EA7FF'),white=color('#F2FBFF'),muted=color('#9DB8C7'),green=color('#35DB95'),red=color('#ED5367')}
local cfg={playerStyle='Bubble Name',playerOutline=true,playerFill=false,playerThroughWalls=true,playerHeadSide=3,playerBubbleSize=25,playerBubbleBackground=false,playerBubbleDistance=false,playerOverrides={},moneyMode='Rarity Only',minimumIncomeText='20B',showAnimalIncome=true,playerSelection={},rarity=false,mutation=false,players=false,animalSize=15,playerSize=17,playerCardWidth=290,playerCardScale=100,playerAutoResize=true,playerColorHex='#FF5050',playerSeparateColors=false,playerHighlightHex='#FF5050',trans=.65,animalBG=.18,playerBG=.15,animalRange=1500,playerRange=1500,unlimitedPlayerRange=false,showIndexStatus=true,missingIndexOnly=false,prioritiseMissing=true,rgb={255,80,80},username=true,distance=true,health=true,speed=true,money=true,selectedR={},selectedM={},hideKey='K',panicKey='P',uiScale=100,uiOpacity=10,accentR=240,accentG=68,accentB=87,antiAFK=false,masteryPolling=true,masteryInterval=2,autoCloseInvites=false,masteryShortcut=true}
local folder='EggFarmingHub'; local cf=folder..'/CollectionCacheV111.json'; local sf=folder..'/SettingsV111.json'; local fileOK=type(readfile)=='function' and type(writefile)=='function' and type(isfile)=='function'
local function listen(sig,fn) local c=sig:Connect(fn); con[#con+1]=c; return c end
local function folderReady() if type(makefolder)=='function' then pcall(makefolder,folder) end end
local function read(path)
    if not fileOK then return nil end
    local ok,res=pcall(function()
        if isfile(path) then return H:JSONDecode(readfile(path)) end
        return nil
    end)
    if ok and type(res)=='table' and res.PlaceId==game.PlaceId and res.UserId==me.UserId then return res end
    return nil
end
local function write(path,data) if not fileOK then return false end; folderReady(); data.PlaceId=game.PlaceId; data.UserId=me.UserId; local ok=pcall(function() writefile(path,H:JSONEncode(data)) end); return ok end
local imported='None'; local verified=false
local function load() local s=read(sf) or read(folder..'/SettingsV110.json') or read(folder..'/SettingsV109.json') or read(folder..'/SettingsV108.json') or read(folder..'/SettingsV107.json') or read(folder..'/SettingsV106.json') or read(folder..'/SettingsV105.json') or read(folder..'/SettingsV104.json') or read(folder..'/SettingsV103.json') or read(folder..'/SettingsV102.json') or read(folder..'/SettingsV101.json'); if s then local source=s.Settings or s; for k,v in pairs(source) do if cfg[k]~=nil and type(v)==type(cfg[k]) then cfg[k]=v end end; if s.RarityESP~=nil then cfg.rarity=s.RarityESP end; if s.MutationESP~=nil then cfg.mutation=s.MutationESP end; if s.PlayerESP~=nil then cfg.players=s.PlayerESP end; cfg.selectedR=s.RaritySelected or cfg.selectedR; cfg.selectedM=s.MutationSelected or cfg.selectedM; cfg.rgb=s.PlayerRGB and {s.PlayerRGB.R or 255,s.PlayerRGB.G or 80,s.PlayerRGB.B or 80} or cfg.rgb end
for _,f in ipairs({cf,folder..'/CollectionCacheV110.json',folder..'/CollectionCacheV109.json',folder..'/CollectionCacheV108.json',folder..'/CollectionCacheV107.json',folder..'/CollectionCacheV106.json',folder..'/CollectionCacheV105.json',folder..'/CollectionCacheV104.json',folder..'/CollectionCacheV103.json',folder..'/CollectionCacheV102.json',folder..'/CollectionCacheV101.json',folder..'/CollectionCacheV100.json',folder..'/CollectionCacheV99.json',folder..'/CollectionCacheV98.json',folder..'/CollectionCacheV97.json',folder..'/CollectionCacheV96.json',folder..'/CollectionCacheV95.json'}) do local d=read(f); if d and type(d.Caches)=='table' then cache=d.Caches; imported=f; dirty=f~=cf; break end end end
load()
local function save() local ok=write(cf,{Version='11.1',Caches=cache}); if ok then local d=read(cf); verified=d and type(d.Caches)=='table' or false; if verified then dirty=false end end; write(sf,{Version='11.1',Settings=cfg}); settingsDirty=false; return verified end
local suffix={{1e36,'Ud'},{1e33,'Dc'},{1e30,'No'},{1e27,'Oc'},{1e24,'Sp'},{1e21,'Sx'},{1e18,'Qi'},{1e15,'Qa'},{1e12,'T'},{1e9,'B'},{1e6,'M'},{1e3,'K'}}
local function money(n) if type(n)~='number' then return 'N/A' end; if n~=n then return 'N/A' end; local sign=n<0 and '-$' or '$'; n=math.abs(n); for _,e in ipairs(suffix) do if n>=e[1] then local x=string.format('%.2f',math.floor(n/e[1]*100)/100):gsub('0+$',''):gsub('%.$',''); return sign..x..e[2] end end; return sign..math.floor(n) end
local function parseIncome(value)
    if type(value)=='number' then return value end
    if type(value)~='string' then return nil end
    local cleaned=value:gsub(',',''):gsub('%$',''):gsub('%s',''):gsub('/[sS]$','')
    local number,suf=cleaned:match('^([%d%.]+)(%a*)$')
    if not number then return nil end
    local n=tonumber(number); if not n then return nil end
    if suf=='' then return n end
    for _,v in ipairs(suffix) do if v[2]:lower()==suf:lower() then return n*v[1] end end
    return nil
end
local function animalIncome(model)
    for _,obj in ipairs({model,model:FindFirstChild('RootPart')}) do
        if obj then
            for _,key in ipairs({'MoneyPerSecond','IncomePerSecond','CashPerSecond','EarningsPerSecond','MoneyPS','Income','CashPerSec','ValuePerSecond'}) do
                local v=obj:GetAttribute(key)
                if v~=nil then local n=parseIncome(v); if n then return n end end
                local child=obj:FindFirstChild(key)
                if child and child:IsA('ValueBase') then local n=parseIncome(child.Value); if n then return n end end
            end
        end
    end
    -- Displayed $/s is used only when a numeric label can be read reliably.
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA('TextLabel') then
            local t=d.Text
            if t:find('%$') and (t:find('/s') or t:find('/S')) then
                local n=parseIncome(t:match('%$[%d%.,]+%a*') or '')
                if n then return n end
            end
        end
    end
    return nil
end
local function playerMoney(p)
    for _,host in ipairs({p:FindFirstChild('leaderstats'),p}) do
        if host then
            for _,name in ipairs({'Money','Cash','Coins','Currency','Gold','Balance','Dollars'}) do
                local v=host:FindFirstChild(name)
                if v and (v:IsA('IntValue') or v:IsA('NumberValue')) then return v.Value end
                local a=host:GetAttribute(name)
                if type(a)=='number' then return a end
            end
        end
    end
    return nil
end
local function mutationOf(m) for _,key in ipairs({'Mutation','MutationType'}) do local value=m:GetAttribute(key); if type(value)=='string' then for _,name in ipairs(mutations) do if value:match('^%s*(.-)%s*$'):lower()==name:lower() then return name end end end end; return nil end
local function new(class,parent,props) local x=Instance.new(class); for k,v in pairs(props or {}) do x[k]=v end; x.Parent=parent; return x end
local function round(x,r) new('UICorner',x,{CornerRadius=UDim.new(0,r or 8)}); return x end
local function border(x,c) return new('UIStroke',x,{Color=c or theme.border,Thickness=1.3}) end
local function text(parent,value,size,props) props=props or {}; props.Text=value; props.TextSize=size or 12; props.Font=props.Font or Enum.Font.Gotham; props.TextColor3=props.TextColor3 or theme.white; props.BackgroundTransparency=1; props.BorderSizePixel=0; props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left; return new('TextLabel',parent,props) end
local function erase(model) local d=objects[model]; if d then for _,x in ipairs(d) do pcall(function() x:Destroy() end) end; objects[model]=nil end end
local function bill(model,root,isPlayer) erase(model); local hl=new('Highlight',model,{Adornee=model,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,FillTransparency=isPlayer and cfg.trans or .72}); local gui=new('BillboardGui',root,{Name='EggHubCard102',Adornee=root,AlwaysOnTop=true,Size=UDim2.fromOffset(isPlayer and 290 or 260,isPlayer and 178 or 85),StudsOffset=Vector3.new(0,isPlayer and 5 or 4,0)}); local frame=round(new('Frame',gui,{Size=UDim2.fromScale(1,1),BackgroundColor3=theme.bg,BackgroundTransparency=isPlayer and cfg.playerBG or cfg.animalBG,BorderSizePixel=0}),10); local st=border(frame,theme.blue); objects[model]={hl,gui}; return {hl=hl,gui=gui,frame=frame,stroke=st} end
local function rootOf(m) return m:FindFirstChild('RootPart') or m.PrimaryPart or m:FindFirstChildWhichIsA('BasePart') end
local function distance(root) local c=me.Character; local r=c and c:FindFirstChild('HumanoidRootPart'); return r and math.floor((r.Position-root.Position).Magnitude) or 0 end
-- Index status is based on the specific mutation's saved collection.
-- Use the model's internal name first; never assume two similarly named animals match.
local function normalizeName(v)
    return tostring(v or ''):lower():gsub('^%s+',''):gsub('%s+$',''):gsub('[^%w]','')
end
local indexLookup={}; local indexCacheRef={}
local function lookupIndex(model,mutation)
    local collection=mutation or 'Normal'
    local snapshot=cache[collection]
    if not snapshot or type(snapshot.Entries)~='table' then
        return 'UNKNOWN',collection
    end
    if indexCacheRef[collection]~=snapshot then
        indexCacheRef[collection]=snapshot
        local byInternal,byDisplay={},{}
        for _,entry in ipairs(snapshot.Entries) do
            local internal=normalizeName(entry.InternalName)
            local display=normalizeName(entry.Name)
            if internal~='' then
                byInternal[internal]=byInternal[internal] or {}
                table.insert(byInternal[internal],entry)
            end
            if display~='' and display~='???' then
                byDisplay[display]=byDisplay[display] or {}
                table.insert(byDisplay[display],entry)
            end
        end
        indexLookup[collection]={byInternal,byDisplay}
    end
    local maps=indexLookup[collection]
    local internal=normalizeName(model.Name)
    local display=normalizeName(model:GetAttribute('AnimalName') or model.Name)
    local entries=maps[1][internal]
    if not entries or #entries~=1 then entries=maps[2][display] end
    if not entries or #entries~=1 then return 'UNKNOWN',collection end
    local status=entries[1].Status
    if status=='COLLECTED' then return 'COLLECTED',collection end
    if status=='MISSING' then return 'NEEDED',collection end
    return 'UNKNOWN',collection
end
local function animalESP() local folder=workspace:FindFirstChild('AnimalPickups'); local seen={}; if folder then for _,m in ipairs(folder:GetChildren()) do if m:IsA('Model') then local r=tostring(m:GetAttribute('Rarity') or ''); local mut=mutationOf(m); local rarityMatch=(cfg.rarity and cfg.selectedR[r]) or (cfg.mutation and mut and cfg.selectedM[mut]); local indexStatus,indexCollection=lookupIndex(m,mut); local income=animalIncome(m); local threshold=parseIncome(cfg.minimumIncomeText) or 0; local moneyMatch=income~=nil and income>=threshold; local missingMatch=indexStatus=='NEEDED'; local modeName=cfg.moneyMode; local match=modeName=='All Animals' or (modeName=='Rarity Only' and rarityMatch) or (modeName=='Rarity + Money' and rarityMatch and moneyMatch) or (modeName=='Rarity + Index Missing' and rarityMatch and missingMatch) or (modeName=='Rarity + Money + Index Missing' and rarityMatch and moneyMatch and missingMatch) or (modeName=='Money Only' and moneyMatch) or (modeName=='Money + Index Missing' and moneyMatch and missingMatch) or (modeName=='Index Missing Only' and missingMatch); if cfg.missingIndexOnly and not missingMatch then match=false end; local root=rootOf(m); if match and root and distance(root)<=cfg.animalRange then seen[m]=true; local d=objects[m]; if not d or d[2].Adornee~=root then local card=bill(m,root,false); d=objects[m]; d.kind='animal'; d.card=card; local bar=round(new('Frame',card.frame,{Size=UDim2.fromOffset(4,62),Position=UDim2.fromOffset(8,12),BorderSizePixel=0}),3); d.bar=bar; d.title=text(card.frame,'',cfg.animalSize,{Size=UDim2.new(1,-32,0,27),Position=UDim2.fromOffset(22,7),Font=Enum.Font.GothamBold}); d.rarity=text(card.frame,'',11,{Size=UDim2.new(.52,-22,0,20),Position=UDim2.fromOffset(22,35),Font=Enum.Font.GothamBold}); d.mutation=text(card.frame,'',11,{Size=UDim2.new(.48,0,0,20),Position=UDim2.new(.52,0,0,35),Font=Enum.Font.GothamBold}); d.dist=text(card.frame,'',11,{Size=UDim2.new(1,-32,0,20),Position=UDim2.fromOffset(22,59),TextColor3=theme.muted}); d.indexStatus=text(card.frame,'',11,{Size=UDim2.new(1,-28,0,21),Position=UDim2.fromOffset(22,80),Font=Enum.Font.GothamBold}); d.income=text(card.frame,'',11,{Size=UDim2.new(1,-28,0,20),Position=UDim2.fromOffset(22,101),Font=Enum.Font.GothamBold,TextColor3=theme.green}) end
local c=color((mut and cfg.mutation and cfg.selectedM[mut]) and mc[mut] or rc[r]); d[1].FillColor=c; d[1].OutlineColor=c; d.card.stroke.Color=c; d.bar.BackgroundColor3=c; d.card.frame.BackgroundTransparency=cfg.animalBG; d.title.Text=tostring(m:GetAttribute('AnimalName') or m.Name); d.title.TextSize=cfg.animalSize; d.rarity.Text=r:upper(); d.rarity.TextColor3=theme.white; d.rarity.TextSize=math.max(10,cfg.animalSize-4); d.mutation.Text=mut and ('★ '..mut:upper()) or ''; d.mutation.TextColor3=color(mc[mut]); d.dist.Text=distance(root)..' STUDS'; d.income.Visible=cfg.showAnimalIncome; d.income.Text=income and (money(income)..'/s') or 'INCOME UNKNOWN'; d.indexStatus.Visible=cfg.showIndexStatus; d.indexStatus.Text=indexStatus=='NEEDED' and ('● NEEDED / '..indexCollection:upper()..' INDEX') or indexStatus=='COLLECTED' and ('✓ COLLECTED / '..indexCollection:upper()) or ('? UNKNOWN / '..indexCollection:upper()..' INDEX'); d.indexStatus.TextColor3=indexStatus=='NEEDED' and theme.red or indexStatus=='COLLECTED' and theme.green or theme.muted; local urgent=cfg.prioritiseMissing and indexStatus=='NEEDED'; if urgent then d.card.stroke.Color=theme.red; d.card.stroke.Thickness=2.5; d.bar.BackgroundColor3=theme.red else d.card.stroke.Thickness=1.3 end; local scale=math.clamp(1-distance(root)/3000,.65,1); d[2].Size=UDim2.fromOffset(math.floor(260*scale),math.floor((85+(cfg.showIndexStatus and 23 or 0)+(cfg.showAnimalIncome and 21 or 0))*scale)) else erase(m) end end end end
for m,d in pairs(objects) do if d.kind=='animal' and not seen[m] then erase(m) end end end
local function validHex(v)
    if type(v)~='string' then return nil end
    local h=v:gsub('%s',''):gsub('^#',''):upper()
    if #h==6 and h:match('^[0-9A-F]+$') then return '#'..h end
    return nil
end
local function playerESP()
    local seen={}
    for _,p in ipairs(P:GetPlayers()) do
        if p~=me and p.Character then
            local m=p.Character
            local root=m:FindFirstChild('HumanoidRootPart')
            local head=m:FindFirstChild('Head') or root
            local hum=m:FindFirstChildOfClass('Humanoid')
            if cfg.players and cfg.playerSelection[tostring(p.UserId)]~=false and root and head and hum and hum.Health>0 and (cfg.unlimitedPlayerRange or distance(root)<=cfg.playerRange) then
                seen[m]=true
                local d=objects[m]
                if not d or not d[2] or d[2].Adornee~=head then
                    local card=bill(m,head,true)
                    d=objects[m]; d.kind='player'; d.card=card
                    d.name=text(card.frame,'',cfg.playerSize,{Font=Enum.Font.GothamBold,TextTruncate=Enum.TextTruncate.AtEnd})
                    d.user=text(card.frame,'',12,{TextColor3=theme.muted,TextTruncate=Enum.TextTruncate.AtEnd})
                    d.track=round(new('Frame',card.frame,{BackgroundColor3=theme.card,BorderSizePixel=0}),5)
                    d.fill=round(new('Frame',d.track,{Size=UDim2.fromScale(1,1),BackgroundColor3=theme.green,BorderSizePixel=0}),5)
                    d.hp=text(card.frame,'',12)
                    d.speed=text(card.frame,'',12)
                    d.dist=text(card.frame,'',12)
                    d.money=text(card.frame,'',14,{Font=Enum.Font.GothamBold,TextColor3=theme.green})
                end
                local override=cfg.playerOverrides[tostring(p.UserId)] or {}
                local style=override.style and override.style~='Default' and override.style or cfg.playerStyle
                local outline=override.outline=='On' and true or override.outline=='Off' and false or cfg.playerOutline
                local cardColor=color(validHex(override.color or cfg.playerColorHex) or '#FF5050')
                local highlightColor=cfg.playerSeparateColors and color(validHex(cfg.playerHighlightHex) or '#FF5050') or cardColor
                d[1].Enabled=outline or cfg.playerFill
                d[1].OutlineTransparency=outline and 0 or 1
                d[1].FillTransparency=cfg.playerFill and cfg.trans or 1
                d[1].FillColor=highlightColor; d[1].OutlineColor=highlightColor
                d[1].DepthMode=cfg.playerThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                d.card.stroke.Color=cardColor; d.card.frame.BackgroundTransparency=cfg.playerBG
                local width=math.clamp(tonumber(cfg.playerCardWidth) or 290,140,400)
                local scale=math.clamp((tonumber(cfg.playerCardScale) or 100)/100,.5,1.5)
                local pad=12; local inner=width-pad*2; local y=8
                local function place(label,h)
                    label.Visible=true; label.Position=UDim2.fromOffset(pad,y)
                    label.Size=UDim2.fromOffset(inner,h); y=y+h+4
                end
                for _,label in ipairs({d.name,d.user,d.track,d.hp,d.speed,d.dist,d.money}) do label.Visible=false end
                d.card.frame.Visible=style~='Outline Only'
                if style=='Bubble Name' then
                    width=math.clamp(tonumber(cfg.playerCardWidth) or 290,140,400)
                    inner=width-pad*2
                    d.name.Text=p.DisplayName; d.name.TextSize=cfg.playerBubbleSize
                    d.name.Font=Enum.Font.FredokaOne
                    d.name.TextXAlignment=Enum.TextXAlignment.Center
                    d.name.TextStrokeTransparency=.15
                    d.name.TextStrokeColor3=Color3.new(0,0,0)
                    d.name.TextColor3=cardColor
                    place(d.name,math.max(35,cfg.playerBubbleSize+13))
                    if cfg.playerBubbleDistance then
                        d.dist.Text=distance(root)..' STUDS'; d.dist.TextXAlignment=Enum.TextXAlignment.Center; place(d.dist,18)
                    end
                    d.card.frame.BackgroundTransparency=cfg.playerBubbleBackground and cfg.playerBG or 1
                    d.card.stroke.Enabled=cfg.playerBubbleBackground
                    d[2].StudsOffset=Vector3.new(0,3,0)
                elseif style~='Outline Only' then
                    d.name.Font=Enum.Font.GothamBold; d.name.TextXAlignment=Enum.TextXAlignment.Left
                    d.name.TextStrokeTransparency=1; d.name.TextColor3=theme.white
                    d.name.Text=p.DisplayName; d.name.TextSize=cfg.playerSize; place(d.name,math.max(23,cfg.playerSize+8))
                    if style=='Detailed' then
                        if cfg.username then d.user.Text='@'..p.Name; place(d.user,17) elseif not cfg.playerAutoResize then y=y+21 end
                        if cfg.health then
                            local pct=math.clamp(hum.Health/math.max(1,hum.MaxHealth),0,1)
                            d.track.Visible=true; d.track.Position=UDim2.fromOffset(pad,y); d.track.Size=UDim2.fromOffset(inner,8)
                            d.fill.Size=UDim2.fromScale(pct,1)
                            d.fill.BackgroundColor3=pct>.6 and theme.green or (pct>.3 and color('#FFCD46') or theme.red)
                            y=y+12; d.hp.Text=('HP %d/%d'):format(hum.Health,hum.MaxHealth); place(d.hp,17)
                        elseif not cfg.playerAutoResize then y=y+33 end
                    end
                    local fields={}
                    if cfg.speed then table.insert(fields,('SPD %.1f'):format(hum.WalkSpeed)) end
                    if cfg.distance then table.insert(fields,distance(root)..' STUDS') end
                    if #fields>0 then d.speed.Text=table.concat(fields,'  •  '); place(d.speed,20) end
                    if cfg.money then d.money.Text=money(playerMoney(p)); place(d.money,23) end
                    if style=='Compact' and cfg.health then
                        local pct=math.clamp(hum.Health/math.max(1,hum.MaxHealth),0,1)
                        d.track.Visible=true; d.track.Position=UDim2.fromOffset(pad,y); d.track.Size=UDim2.fromOffset(inner,5)
                        d.fill.Size=UDim2.fromScale(pct,1); y=y+9
                    end
                    d.card.stroke.Enabled=true
                    d[2].StudsOffset=Vector3.new(cfg.playerHeadSide,1,0)
                else
                    d[2].StudsOffset=Vector3.new(0,2,0)
                end
                local height=style=='Outline Only' and 1 or (cfg.playerAutoResize and math.max(39,y+5) or math.max(178,y+5))
                d[2].Enabled=style~='Outline Only'
                d[2].Size=UDim2.fromOffset(math.floor(width*scale),math.floor(height*scale))
            else erase(m) end
        end
    end
    for m,d in pairs(objects) do if d.kind=='player' and not seen[m] then erase(m) end end
end

-- Mark ESP objects by kind so stale entities can be removed without touching other overlays.
local originalBill=bill
bill=function(m,root,isPlayer) local d=originalBill(m,root,isPlayer); objects[m].kind=isPlayer and 'player' or 'animal'; return d end
local function index() local main=pg:FindFirstChild('MainGUI'); local frames=main and main:FindFirstChild('Frames'); return frames and frames:FindFirstChild('Index') end
local function progressText() local i=index(); local b=i and i:FindFirstChild('CompletionBar',true); local a=b and b:FindFirstChild('Amount'); return a and a.Text or 'Unknown' end
local function progressNumbers() local a,b=progressText():match('(%d+)%s*/%s*(%d+)'); return tonumber(a),tonumber(b) end
local function mutationSwap() local i=index(); return i and i:FindFirstChild('MutationsSwap',true) end
local function selectedMutation() local s=mutationSwap(); if not s then return end; local found; for _,name in ipairs(mutations) do local item=s:FindFirstChild(name); local b=item and item:FindFirstChild('Button'); if b and b:IsA('GuiObject') then local c=b.BackgroundColor3; if c.R>=.94 and c.G>=.94 and c.B>=.94 then if found then return end; found=name end end end; return found end
local function visible(obj,bound) while obj and obj~=bound do if obj:IsA('GuiObject') and not obj.Visible then return false end; obj=obj.Parent end; return true end
local function detect() local i=index(); if not i then return nil,'INDEX_MISSING' end; local _,n=progressNumbers(); if n==15 then return 'Limited','15_PROGRESS' end; if n~=120 then return nil,'UNKNOWN_PROGRESS' end; local s=mutationSwap(); local m=selectedMutation(); if m and s and visible(s,i) then return m,'MUTATION_SELECTED' end; if s and not visible(s,i) then return 'Normal','SELECTOR_HIDDEN' end; if not m then return 'Normal','NO_MUTATION' end; return nil,'AMBIGUOUS' end
local function scan() local entries={}; local seen={}; local i=index(); if not i then return entries end; for _,list in ipairs(i:GetDescendants()) do if list.Name=='AnimalList' then local zone=list.Parent and list.Parent.Name or 'Unknown'; for _,frame in ipairs(list:GetChildren()) do if frame:IsA('Frame') and frame.Name~='Template' then local inner=frame:FindFirstChild('Inner'); local label=inner and inner:FindFirstChild('Name'); if label and label:IsA('TextLabel') then local key=zone..'|'..frame.Name; if not seen[key] then seen[key]=true; local gradient=inner:FindFirstChild('UIGradient'); local rarity=gradient and gradient:GetAttribute('Rarity') or frame:GetAttribute('Rarity') or 'Unknown'; entries[#entries+1]={Zone=zone,InternalName=frame.Name,Name=label.Text=='???' and frame.Name or label.Text,Rarity=tostring(rarity),Status=label.Text=='???' and 'MISSING' or 'COLLECTED'} end end end end end end; table.sort(entries,function(a,b) if a.Zone~=b.Zone then local x=tonumber(a.Zone:match('[Zz]one(%d+)')); local y=tonumber(b.Zone:match('[Zz]one(%d+)')); if x and y then return x<y end; return x~=nil end; return a.InternalName<b.InternalName end); return entries end
local function stats(entries) local s={RegularTotal=0,RegularCollected=0,EventTotal=0,EventCollected=0}; for _,e in ipairs(entries) do local event=not e.Zone:match('[Zz]one%d+'); local prefix=event and 'Event' or 'Regular'; s[prefix..'Total']+=1; if e.Status=='COLLECTED' then s[prefix..'Collected']+=1 end end; return s end
local function capture(name,source) if not name then return false end; local entries=scan(); local s=stats(entries); local a,b=progressNumbers(); if s.RegularTotal~=120 or s.EventTotal~=15 then return false end; if name=='Limited' then if b~=15 or a~=s.EventCollected then return false end else if b~=120 or a~=s.RegularCollected then return false end end; local sig=H:JSONEncode(entries)..'|'..progressText(); if cache[name] and cache[name].Signature==sig then return false end; cache[name]={Entries=entries,Stats=s,Progress=progressText(),Signature=sig,Source=source or 'Manual',UpdatedAt=os.time()}; dirty=true; return true end
-- V13.1: Observe the game Index GUI independently of the CRBF Index tab.
-- This does not assume that a reward claim is needed. A verified game-Index
-- collection change invalidates the saved snapshot and the ESP lookup map.
local indexSync={signals={},root=nil,pending=false,lastSignature='',lastPoll=0}
local function indexSyncDisconnect()
    for _,connection in ipairs(indexSync.signals) do pcall(function() connection:Disconnect() end) end
    table.clear(indexSync.signals)
end
local function indexSyncRequest()
    indexSync.pending=true
end
local function indexSyncBind()
    local root=index()
    if root==indexSync.root then return end
    indexSyncDisconnect()
    indexSync.root=root
    indexSync.pending=true
    if not root then return end
    local function watch(node)
        if node:IsA('TextLabel') and (node.Name=='Name' or node.Name=='Amount') then
            table.insert(indexSync.signals,node:GetPropertyChangedSignal('Text'):Connect(indexSyncRequest))
        elseif node:IsA('GuiObject') and (node.Name=='MutationsSwap' or node.Name=='Button') then
            table.insert(indexSync.signals,node:GetPropertyChangedSignal('Visible'):Connect(indexSyncRequest))
            if node.Name=='Button' then
                table.insert(indexSync.signals,node:GetPropertyChangedSignal('BackgroundColor3'):Connect(indexSyncRequest))
            end
        end
    end
    for _,node in ipairs(root:GetDescendants()) do watch(node) end
    table.insert(indexSync.signals,root.DescendantAdded:Connect(function(node)
        watch(node)
        indexSyncRequest()
    end))
    table.insert(indexSync.signals,root.DescendantRemoving:Connect(indexSyncRequest))
end
local function indexSyncTick()
    indexSyncBind()
    local now=os.clock()
    if not indexSync.pending and now-indexSync.lastPoll<2 then return end
    indexSync.lastPoll=now
    indexSync.pending=false
    local name=detect()
    if not name then return end
    -- capture() verifies both the full animal list and the game's progress
    -- counter before replacing a collection snapshot.
    local changed=capture(name,'Live Index Sync')
    if changed then
        indexLookup[name]=nil
        indexCacheRef[name]=nil
    end
end
local oldMasteryWidget=pg:FindFirstChild('CRBFMasteryAnywhereV1'); if oldMasteryWidget then oldMasteryWidget:Destroy() end
local gui=new('ScreenGui',pg,{Name='CRBFHubV12',ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling}); local main=round(new('Frame',gui,{Size=UDim2.fromOffset(700,550),Position=UDim2.new(.5,-350,.5,-275),BackgroundColor3=theme.bg,BorderSizePixel=0,Active=true}),12); border(main); local head=new('Frame',main,{Size=UDim2.new(1,0,0,58),BackgroundColor3=theme.side,BorderSizePixel=0,Active=true}); text(head,'CRBF HUB',18,{Size=UDim2.new(1,-120,0,28),Position=UDim2.fromOffset(18,5),Font=Enum.Font.GothamBold}); text(head,'V23  /  CLEAN NAV  /  K TO HIDE',11,{Size=UDim2.new(1,-120,0,20),Position=UDim2.fromOffset(18,31),TextColor3=theme.muted});
-- Solid opaque hub: prevent game objects from bleeding through UI.
new('UIStroke',main,{Color=theme.blue,Thickness=1.5,Transparency=.25})
new('Frame',head,{Size=UDim2.new(1,0,0,3),Position=UDim2.new(0,0,1,-3),BorderSizePixel=0,BackgroundColor3=theme.blue})
local uiScaler=new('UIScale',main,{Scale=math.clamp((cfg.uiScale or 100)/100,.7,1.2)}); main.BackgroundTransparency=0; main.ClipsDescendants=false
-- Cyan accent retained for all navigation and UI components
local function btn(parent,title,fn,props) props=props or {}; props.Size=props.Size or UDim2.new(1,0,0,36); props.BackgroundColor3=props.BackgroundColor3 or theme.card; props.Text=title; props.TextColor3=props.TextColor3 or theme.white; props.Font=Enum.Font.GothamBold; props.TextSize=props.TextSize or 15; props.BorderSizePixel=0; local b=round(new('TextButton',parent,props),5); new('UIStroke',b,{Color=color('#07121D'),Thickness=2}); if fn then b.MouseButton1Click:Connect(function() if live then fn(b) end end) end; return b end
-- Chilli-inspired layout: external navigation flanking a full-width content window.
local sidebar=new('ScrollingFrame',main,{Name='LeftNavigation',CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ClipsDescendants=true,Size=UDim2.new(0,160,1,-104),Position=UDim2.fromOffset(-172,58),BackgroundTransparency=1,BorderSizePixel=0})
new('UIPadding',sidebar,{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,3),PaddingRight=UDim.new(0,3)})
new('UIListLayout',sidebar,{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder})
local body=new('Frame',main,{Size=UDim2.new(1,-16,1,-114),Position=UDim2.fromOffset(8,58),BackgroundTransparency=1})
local foot=new('Frame',main,{Size=UDim2.new(1,0,0,46),Position=UDim2.new(0,0,1,-46),BackgroundColor3=theme.side,BorderSizePixel=0})
local rightbar=new('ScrollingFrame',main,{Name='RightNavigation',Size=UDim2.new(0,160,1,-104),Position=UDim2.new(1,12,0,58),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true})
new('UIPadding',rightbar,{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,3),PaddingRight=UDim.new(0,3)})
new('UIListLayout',rightbar,{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder})
local floating=btn(gui,'',nil,{Name='CRBFLauncher',Size=UDim2.fromOffset(72,72),Position=UDim2.new(1,-90,0,22),BackgroundColor3=color('#081724'),Visible=false,Active=true,AutoButtonColor=false})
new('UIStroke',floating,{Color=Color3.fromRGB(0,0,0),Thickness=4})
local floatInset=new('Frame',floating,{Size=UDim2.new(1,-10,1,-10),Position=UDim2.fromOffset(5,5),BackgroundColor3=color('#0B3955'),BorderSizePixel=0})
new('UIGradient',floatInset,{Color=ColorSequence.new(color('#00D8F4'),color('#092C52')),Rotation=90})
new('UIStroke',floatInset,{Color=color('#56E8FF'),Thickness=1.5})
local diamond=new('TextLabel',floatInset,{Size=UDim2.new(1,0,0,42),Position=UDim2.fromOffset(0,1),BackgroundTransparency=1,Text='◆',Font=Enum.Font.GothamBlack,TextSize=39,TextColor3=color('#A9FAFF'),TextStrokeColor3=color('#003047'),TextStrokeTransparency=0})
new('TextLabel',floatInset,{Size=UDim2.new(1,0,0,17),Position=UDim2.new(0,0,1,-18),BackgroundTransparency=1,Text='CRBF',Font=Enum.Font.GothamBlack,TextSize=13,TextColor3=Color3.new(1,1,1),TextStrokeTransparency=0})
-- Original Mastery GUI shortcut, styled as an independent square game-menu icon.
-- Square Mastery shortcut. Uses the game's own mastery icon if a suitable ImageLabel exists.
local masteryButton=Instance.new('TextButton')
masteryButton.Name='MasteryQuickMenu'
masteryButton.Size=UDim2.fromOffset(82,82)
masteryButton.Position=UDim2.new(1,-94,.5,160)
masteryButton.BackgroundColor3=Color3.fromRGB(156,0,226)
masteryButton.BorderSizePixel=0
masteryButton.Text='✦'
masteryButton.TextColor3=Color3.fromRGB(246,170,255)
masteryButton.TextStrokeColor3=Color3.fromRGB(22,0,35)
masteryButton.TextStrokeTransparency=0
masteryButton.TextSize=54
masteryButton.Font=Enum.Font.GothamBlack
masteryButton.AutoButtonColor=false
masteryButton.Active=true
masteryButton.ZIndex=20
masteryButton.Parent=gui
local outerStroke=Instance.new('UIStroke',masteryButton)
outerStroke.Color=Color3.fromRGB(15,0,22)
outerStroke.Thickness=4
local inset=Instance.new('Frame',masteryButton)
inset.Name='Inset';inset.Size=UDim2.new(1,-9,1,-9);inset.Position=UDim2.fromOffset(4,4)
inset.BackgroundTransparency=1;inset.BorderSizePixel=0;inset.ZIndex=20
local insetStroke=Instance.new('UIStroke',inset)
insetStroke.Color=Color3.fromRGB(80,0,105);insetStroke.Thickness=2
local masteryGradient=Instance.new('UIGradient',masteryButton)
masteryGradient.Color=ColorSequence.new({
 ColorSequenceKeypoint.new(0,Color3.fromRGB(240,68,255)),
 ColorSequenceKeypoint.new(.48,Color3.fromRGB(175,0,231)),
 ColorSequenceKeypoint.new(1,Color3.fromRGB(93,0,148))
})
masteryGradient.Rotation=90
-- Reuse the game's own artwork if the Mastery top bar exposes a suitable star image.
task.defer(function()
 local mg=pg:FindFirstChild('MainGUI');local frames=mg and mg:FindFirstChild('Frames')
 local m=frames and frames:FindFirstChild('Mastery')
 local top=m and m:FindFirstChild('TopBar')
 if not top then return end
 for _,d in ipairs(top:GetDescendants()) do
  if d:IsA('ImageLabel') and d.Image~='' and
   (d.Name:lower():find('icon') or d.Name:lower():find('mastery') or d.Name:lower():find('star')) then
   local art=Instance.new('ImageLabel')
   art.Name='GameMasteryIcon';art.BackgroundTransparency=1;art.Image=d.Image
   art.ImageRectOffset=d.ImageRectOffset;art.ImageRectSize=d.ImageRectSize
   art.ScaleType=Enum.ScaleType.Fit;art.Size=UDim2.new(1,-10,1,-10)
   art.Position=UDim2.fromOffset(5,5);art.ZIndex=22;art.Parent=masteryButton
   masteryButton.Text='';break
  end
 end
end)
local function openOriginalMastery()
    local mainGui=pg:FindFirstChild('MainGUI')
    local frames=mainGui and mainGui:FindFirstChild('Frames')
    local mastery=frames and frames:FindFirstChild('Mastery')
    if not mastery or not mastery:IsA('GuiObject') then return end
    if mastery.Visible then mastery.Visible=false;return end
    local list=mastery:FindFirstChild('MasteryList')
    local info=mastery:FindFirstChild('MasteryInfo')
    local back=mastery:FindFirstChild('Back')
    if list and list:IsA('GuiObject') then list.Visible=true end
    if info and info:IsA('GuiObject') then info.Visible=false end
    if back and back:IsA('GuiObject') then back.Visible=false end
    mastery.Visible=true
end
-- Bind the original game's red X to the same close behaviour as the floating shortcut.
-- Do not destroy the game GUI: only hide its Mastery frame.
local masteryCloseConnections={}
local function bindMasteryClose()
    local mainGui=pg:FindFirstChild('MainGUI')
    local frames=mainGui and mainGui:FindFirstChild('Frames')
    local mastery=frames and frames:FindFirstChild('Mastery')
    local top=mastery and mastery:FindFirstChild('TopBar')
    if not top then return end
    for _,node in ipairs(top:GetDescendants()) do
        if node:IsA('GuiButton') then
            local n=node.Name:lower()
            local likelyClose=n=='x' or n=='close' or n=='closebutton' or n=='exit' or n=='exitbutton'
            -- Some game UIs use an unnamed TextButton with an X label.
            if not likelyClose and node:IsA('TextButton') then
                local label=(node.Text or ''):gsub('%s+',''):lower()
                likelyClose=label=='x' or label=='×'
            end
            if likelyClose and not masteryCloseConnections[node] then
                local connection=node.Activated:Connect(function()
                    -- Defer until the game's own click handler finishes.
                    task.defer(function()
                        if live and mastery and mastery.Parent then mastery.Visible=false end
                    end)
                end)
                masteryCloseConnections[node]=connection
                table.insert(con,connection)
            end
        end
    end
end
bindMasteryClose()
task.defer(bindMasteryClose)
_G.CRBFOpenMasteryMenu=openOriginalMastery
masteryButton.Activated:Connect(openOriginalMastery)
-- Draggable square button; tap toggles the actual in-game Mastery GUI.
local masteryDragging=false
local masteryStart,masteryOrigin,masteryInput
masteryButton.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        masteryDragging=true;masteryStart=input.Position;masteryOrigin=masteryButton.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then masteryDragging=false end
        end)
    end
end)
masteryButton.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then masteryInput=input end
end)
listen(U.InputChanged,function(input)
    if masteryDragging and input==masteryInput and masteryStart and masteryOrigin then
        local d=input.Position-masteryStart
        masteryButton.Position=UDim2.new(masteryOrigin.X.Scale,masteryOrigin.X.Offset+d.X,masteryOrigin.Y.Scale,masteryOrigin.Y.Offset+d.Y)
    end
end)
task.spawn(function()
    while live and masteryButton.Parent do
        masteryButton.Visible=cfg.masteryShortcut~=false
        task.wait(.25)
    end
end)

local function startEggPredictor()
-- CRBF LIVE ANIMAL TRACKER V1 | standalone, read-only
-- Uses replicated Workspace.Plots.Base_*.PlacedAnimals models.
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
-- RunService was not used by this panel.
local localPlayer = Players.LocalPlayer
local pg = localPlayer:WaitForChild('PlayerGui')
if _G.CRBFAnimalTrackerV1 and _G.CRBFAnimalTrackerV1.close then pcall(_G.CRBFAnimalTrackerV1.close) end
local state = {alive=true,connections={},highlights={},selected=nil,sort='Income high',query='',onlyOthers=false,collapsed=false,items={}}
_G.CRBFAnimalTrackerV1 = state
local function bind(signal,fn) local c=signal:Connect(fn); table.insert(state.connections,c); return c end
local function ui(class,props,parent)
 local o=Instance.new(class)
 for k,v in pairs(props or {}) do o[k]=v end
 o.Parent=parent;return o
end
local C={bg=Color3.fromRGB(18,18,22),card=Color3.fromRGB(32,31,37),line=Color3.fromRGB(66,52,57),red=Color3.fromRGB(178,49,65),txt=Color3.fromRGB(245,240,241),muted=Color3.fromRGB(174,164,169)}
local function corner(x,r) ui('UICorner',{CornerRadius=UDim.new(0,r or 7)},x) end
local function stroke(x) ui('UIStroke',{Color=C.line,Thickness=1},x) end
local gui=ui('ScreenGui',{Name='CRBF_EggPredictor',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=180},pg)
local main=ui('Frame',{Size=UDim2.fromOffset(332,510),Position=UDim2.new(1,-347,.5,-255),BackgroundColor3=C.bg,BorderSizePixel=0,Active=true},gui);corner(main,10);stroke(main)
local title=ui('TextLabel',{Size=UDim2.new(1,-88,0,39),Position=UDim2.fromOffset(13,3),BackgroundTransparency=1,Text='CRBF  |  PLACED ANIMALS',TextColor3=C.txt,TextSize=16,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},main)
local function button(parent,text,pos,size,fn)
 local b=ui('TextButton',{Text=text,Position=pos,Size=size,BackgroundColor3=C.card,TextColor3=C.txt,TextSize=12,Font=Enum.Font.GothamSemibold,BorderSizePixel=0,AutoButtonColor=true},parent);corner(b,6);bind(b.MouseButton1Click,fn);return b
end
local body=ui('Frame',{Position=UDim2.fromOffset(10,46),Size=UDim2.new(1,-20,1,-56),BackgroundTransparency=1},main)
local count=ui('TextLabel',{Position=UDim2.fromOffset(2,0),Size=UDim2.new(1,-4,0,23),BackgroundTransparency=1,Text='Scanning plots...',TextColor3=C.muted,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},body)
local search=ui('TextBox',{Position=UDim2.fromOffset(0,27),Size=UDim2.new(1,0,0,32),BackgroundColor3=C.card,BorderSizePixel=0,PlaceholderText='Search animal, rarity, mutation, owner...',Text='',TextColor3=C.txt,PlaceholderColor3=C.muted,TextSize=12,Font=Enum.Font.Gotham,ClearTextOnFocus=false},body);corner(search,6)
local sortBtn,otherBtn
local sortModes={'Income high','Income low','Weight high','Rarity','Newest'}
sortBtn=button(body,'SORT: Income high',UDim2.new(0,0,0,65),UDim2.new(.59,-3,0,31),function()
 local n=table.find(sortModes,state.sort) or 1;state.sort=sortModes[n%#sortModes+1];sortBtn.Text='SORT: '..state.sort;state.dirty=true
end)
otherBtn=button(body,'ALL PLOTS',UDim2.new(.59,3,0,65),UDim2.new(.41,-3,0,31),function()
 state.onlyOthers=not state.onlyOthers;otherBtn.Text=state.onlyOthers and 'OTHER PLOTS' or 'ALL PLOTS';otherBtn.BackgroundColor3=state.onlyOthers and C.red or C.card;state.dirty=true
end)
local list=ui('ScrollingFrame',{Position=UDim2.fromOffset(0,104),Size=UDim2.new(1,0,1,-139),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=C.red,CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},body)
ui('UIListLayout',{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},list)
ui('TextLabel',{Position=UDim2.new(0,0,1,-29),Size=UDim2.new(1,0,0,27),BackgroundTransparency=1,Text='TRACK highlights only; no movement or stealing',TextColor3=C.muted,TextSize=10,Font=Enum.Font.Gotham},body)
local function clearHighlight()
 for _,h in ipairs(state.highlights) do pcall(function()h:Destroy()end) end
 state.highlights={}
end
local function track(model)
 clearHighlight()
 if state.selected==model then state.selected=nil;state.dirty=true;return end
 state.selected=model
 if model and model.Parent then
  local h=ui('Highlight',{Name='CRBF_TrackedAnimal',Adornee=model,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,FillColor=C.red,OutlineColor=Color3.fromRGB(255,255,255),FillTransparency=.72,OutlineTransparency=0},gui)
  table.insert(state.highlights,h)
 end
 state.dirty=true
end
local function close()
 if not state.alive then return end
 state.alive=false
 clearHighlight()
 for _,c in ipairs(state.connections) do pcall(function()c:Disconnect()end) end
 pcall(function()gui:Destroy()end)
 if _G.CRBFAnimalTrackerV1==state then _G.CRBFAnimalTrackerV1=nil end
end
state.close=close
button(main,'−',UDim2.new(1,-72,0,8),UDim2.fromOffset(28,28),function()
 state.collapsed=not state.collapsed;body.Visible=not state.collapsed;main.Size=state.collapsed and UDim2.fromOffset(332,44) or UDim2.fromOffset(332,510)
end)
button(main,'×',UDim2.new(1,-39,0,8),UDim2.fromOffset(28,28),close)
local drag=false;local dragStart;local startPos
bind(title.InputBegan,function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;dragStart=input.Position;startPos=main.Position end
end)
bind(UIS.InputEnded,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
bind(UIS.InputChanged,function(input)
 if drag and input.UserInputType==Enum.UserInputType.MouseMovement then
  local d=input.Position-dragStart;main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
 end
end)
local function fmt(v)
 v=tonumber(v) or 0
 local suffix={{1e33,'Dc'},{1e30,'No'},{1e27,'Oc'},{1e24,'Sp'},{1e21,'Sx'},{1e18,'Qi'},{1e15,'Qa'},{1e12,'T'},{1e9,'B'},{1e6,'M'},{1e3,'K'}}
 for _,p in ipairs(suffix) do if math.abs(v)>=p[1] then return string.format('%.2f%s',v/p[1],p[2]) end end
 return string.format('%.0f',v)
end
local function mutation(model)
 for _,key in ipairs({'Mutation','Variant','AuraMutation'}) do
  local v=model:GetAttribute(key);if v~=nil and tostring(v)~='' then return tostring(v) end
 end
 local root=model:FindFirstChild('RootPart')
 local att=root and root:FindFirstChild('AnimalOverheadAttachment')
 local over=att and att:FindFirstChild('AnimalOverhead')
 local label=over and over:FindFirstChild('Mutation')
 if label and label:IsA('TextLabel') and label.Text~='' then return label.Text end
 return 'Normal'
end
local function ownerName(id)
 id=tonumber(id)
 if not id then return 'Unknown' end
 local p=Players:GetPlayerByUserId(id)
 return p and p.DisplayName or ('User '..tostring(id))
end
local rarityOrder={Common=1,Uncommon=2,Rare=3,Epic=4,Legendary=5,Mythic=6,Divine=7,Secret=8,Omega=9,Ethereal=10,Spectral=11,Void=12}
local seenAt=setmetatable({},{__mode='k'})
local function snapshot()
 local result={};local plots=workspace:FindFirstChild('Plots')
 if not plots then return result end
 for _,plot in ipairs(plots:GetChildren()) do
  local folder=plot:FindFirstChild('PlacedAnimals')
  if folder then
   for _,model in ipairs(folder:GetChildren()) do
    if model:IsA('Model') then
     if not seenAt[model] then seenAt[model]=os.clock() end
     local id=model:GetAttribute('OwnerUserId') or plot:GetAttribute('OwnerUserId')
     local item={model=model,name=tostring(model:GetAttribute('AnimalName') or model.Name),rarity=tostring(model:GetAttribute('Rarity') or 'Unknown'),mutation=mutation(model),income=tonumber(model:GetAttribute('CashPerSecond')) or 0,weight=tonumber(model:GetAttribute('WeightKg')) or 0,owner=ownerName(id),ownerId=tonumber(id),plot=plot.Name,created=seenAt[model]}
     table.insert(result,item)
    end
   end
  end
 end
 return result
end
local function render()
 if not state.alive then return end
 local all=snapshot();local filtered={};local query=state.query:lower()
 for _,a in ipairs(all) do
  local matches=query=='' or (a.name..' '..a.rarity..' '..a.mutation..' '..a.owner..' '..a.plot):lower():find(query,1,true)
  if matches and (not state.onlyOthers or a.ownerId~=localPlayer.UserId) then table.insert(filtered,a) end
 end
 table.sort(filtered,function(a,b)
  if state.sort=='Income low' then return a.income<b.income end
  if state.sort=='Weight high' then return a.weight>b.weight end
  if state.sort=='Rarity' then return (rarityOrder[a.rarity] or 0)>(rarityOrder[b.rarity] or 0) end
  if state.sort=='Newest' then return a.created>b.created end
  return a.income>b.income
 end)
 for _,c in ipairs(list:GetChildren()) do if c:IsA('GuiObject') then c:Destroy() end end
 count.Text=string.format('%d visible  •  %d total animals  •  %d plots',#filtered,#all,(function()local n=0;local plots=workspace:FindFirstChild('Plots');if plots then for _,p in ipairs(plots:GetChildren()) do if p:FindFirstChild('PlacedAnimals') then n=n+1 end end end;return n end)())
 for i,a in ipairs(filtered) do
  local card=ui('Frame',{Size=UDim2.new(1,-6,0,94),BackgroundColor3=C.card,BorderSizePixel=0,LayoutOrder=i},list);corner(card,7)
  ui('TextLabel',{Position=UDim2.fromOffset(9,6),Size=UDim2.new(1,-94,0,21),BackgroundTransparency=1,Text=a.name,TextColor3=C.txt,TextSize=14,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},card)
  ui('TextLabel',{Position=UDim2.fromOffset(9,29),Size=UDim2.new(1,-15,0,16),BackgroundTransparency=1,Text='💰 $'..fmt(a.income)..'/s   •   ⚖ '..fmt(a.weight)..' kg',TextColor3=Color3.fromRGB(228,204,176),TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},card)
  ui('TextLabel',{Position=UDim2.fromOffset(9,48),Size=UDim2.new(1,-15,0,16),BackgroundTransparency=1,Text=a.rarity..'  •  '..a.mutation,TextColor3=Color3.fromRGB(222,141,151),TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},card)
  ui('TextLabel',{Position=UDim2.fromOffset(9,68),Size=UDim2.new(1,-96,0,17),BackgroundTransparency=1,Text=a.owner..'  |  '..a.plot,TextColor3=C.muted,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},card)
  local b=button(card,state.selected==a.model and 'UNTRACK' or 'TRACK',UDim2.new(1,-82,0,7),UDim2.fromOffset(74,23),function()track(a.model)end)
  if state.selected==a.model then b.BackgroundColor3=C.red end
 end
 if state.selected and not state.selected:IsDescendantOf(workspace) then clearHighlight();state.selected=nil end
end
bind(search:GetPropertyChangedSignal('Text'),function()state.query=search.Text;state.dirty=true end)
-- Polling handles both new plots and new animals without a large DescendantAdded listener.
-- The short interval also refreshes income/weight/mutation if attributes change.
task.spawn(function()
 while state.alive do
  local ok,err=xpcall(render,debug.traceback)
  if not ok then count.Text='Tracker error (see console)';warn('[CRBF Tracker] '..tostring(err)) end
  for _=1,10 do if not state.alive then break end;task.wait(.2) end
 end
end)
print('[CRBF] Egg Predictor loaded. Read-only; updates approximately every 2 seconds.')

return state
end
local eggPredictor=nil
local function eggPredictorActive() return eggPredictor and eggPredictor.alive end
local function setEggPredictor(on)
 if on then
  if not eggPredictorActive() then eggPredictor=startEggPredictor() end
 else
  if eggPredictorActive() then eggPredictor.close() end
  eggPredictor=nil
 end
end

-- V12.5: Filters and larger rarity/mutation labels; Chilli-style portrait cards, value-first sorting and honest income fallback.
-- LIVE SPAWN TRACKER: reads only Workspace.AnimalPickups, never PlacedAnimals.
-- A pickup is listed while replicated under AnimalPickups and removed when it leaves.
local spawnTracker=nil
local function spawnTrackerActive() return spawnTracker and spawnTracker.alive end
local function startSpawnTracker()
 local Players=game:GetService('Players'); local player=Players.LocalPlayer
 local state={alive=true,connections={},highlights={},query='',sort='Newest',tracked=nil,filterMode='All',raritySelected={},mutationSelected={},billboard=nil}
 local function connect(signal,callback) local c=signal:Connect(callback);table.insert(state.connections,c);return c end
 local function make(class,parent,properties)
  local obj=Instance.new(class)
  for k,v in pairs(properties or {}) do obj[k]=v end
  obj.Parent=parent;return obj
 end
 local function roundIt(obj) make('UICorner',obj,{CornerRadius=UDim.new(0,7)}) end
 local palette={bg=Color3.fromRGB(19,17,22),card=Color3.fromRGB(37,32,40),red=Color3.fromRGB(160,45,63),white=Color3.fromRGB(245,240,242),muted=Color3.fromRGB(184,170,178)}
 local screen=make('ScreenGui',pg,{Name='CRBF_LiveSpawnTracker',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=182})
 local panel=make('Frame',screen,{Size=UDim2.fromOffset(380,565),Position=UDim2.new(1,-730,.5,-282),BackgroundColor3=palette.bg,BorderSizePixel=0,Active=true});roundIt(panel)
 make('UIStroke',panel,{Color=palette.red,Thickness=1})
 local head=make('Frame',panel,{Size=UDim2.new(1,0,0,42),BackgroundColor3=palette.red,BorderSizePixel=0});roundIt(head)
 make('TextLabel',head,{Size=UDim2.new(1,-70,1,0),Position=UDim2.fromOffset(12,0),BackgroundTransparency=1,Text='CRBF  |  LIVE SPAWNS',TextColor3=palette.white,TextSize=15,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 local function button(parent,label,size,position,callback)
  local b=make('TextButton',parent,{Text=label,Size=size,Position=position,BackgroundColor3=palette.card,TextColor3=palette.white,TextSize=12,Font=Enum.Font.GothamSemibold,BorderSizePixel=0});roundIt(b);connect(b.MouseButton1Click,callback);return b
 end
 local function closeTracker()
  if not state.alive then return end
  state.alive=false
  for _,c in ipairs(state.connections) do pcall(function() c:Disconnect() end) end
  for _,h in pairs(state.highlights) do pcall(function() h:Destroy() end) end
  if state.billboard then pcall(function() state.billboard:Destroy() end) end
  screen:Destroy()
 end
 state.close=closeTracker
 button(head,'X',UDim2.fromOffset(29,28),UDim2.new(1,-35,0,7),closeTracker)
 local status=make('TextLabel',panel,{Position=UDim2.fromOffset(12,49),Size=UDim2.new(1,-24,0,22),BackgroundTransparency=1,Text='Waiting for AnimalPickups...',TextColor3=palette.muted,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left})
 local query=make('TextBox',panel,{Position=UDim2.fromOffset(12,77),Size=UDim2.new(1,-24,0,32),BackgroundColor3=palette.card,TextColor3=palette.white,PlaceholderColor3=palette.muted,PlaceholderText='Search spawned animals...',Text='',TextSize=12,Font=Enum.Font.Gotham,ClearTextOnFocus=false,BorderSizePixel=0});roundIt(query)
 local sortModes={'Income high','Newest','Income low','Weight high','Rarity'};local sortIndex=1;state.sort='Income high'
 local pending=true -- shared by the sort callback and refresh loop
 button(panel,'SORT: Income high',UDim2.new(1,-24,0,30),UDim2.fromOffset(12,115),function() sortIndex=sortIndex%#sortModes+1;state.sort=sortModes[sortIndex];pending=true end)
 local filterModes={'All','Mutated only','No mutation','Selected rarities','Selected mutations','Rarity + mutation'}
 local filterButton=button(panel,'FILTER: All  ▼',UDim2.new(1,-24,0,30),UDim2.fromOffset(12,151),function() end)
 local filterBox=make('Frame',panel,{Position=UDim2.fromOffset(12,184),Size=UDim2.new(1,-24,0,0),BackgroundColor3=palette.card,BorderSizePixel=0,Visible=false,ZIndex=15});roundIt(filterBox)
 local filterList=make('ScrollingFrame',filterBox,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ScrollBarThickness=4,CanvasSize=UDim2.new(),ZIndex=16})
 make('UIListLayout',filterList,{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder})
 local filterOpen=false
 local function hideFilter() filterOpen=false;filterBox.Visible=false end
 local function filterOption(label,callback,selected,rarityName)
  local btn=make('TextButton',filterList,{Size=UDim2.new(1,-6,0,29),BackgroundColor3=selected and Color3.fromRGB(91,38,54) or Color3.fromRGB(42,36,44),TextColor3=palette.white,Text=label,TextSize=12,Font=Enum.Font.GothamSemibold,BorderSizePixel=0,ZIndex=17});roundIt(btn)
  if rarityName then
   btn.TextColor3=rarityTint(rarityName)
   local swatch=make('Frame',btn,{Position=UDim2.fromOffset(5,8),Size=UDim2.fromOffset(12,12),BackgroundColor3=rarityTint(rarityName),BorderSizePixel=0,ZIndex=18});roundIt(swatch)
   rarityGradient(swatch,rarityName)
   btn.Text='     '..label
  end
  connect(btn.MouseButton1Click,callback)
 end
 local rebuildFilter
 rebuildFilter=function()
  for _,v in ipairs(filterList:GetChildren()) do if v:IsA('GuiObject') then v:Destroy() end end
  for _,mode in ipairs(filterModes) do filterOption((state.filterMode==mode and '✓  ' or '    ')..mode,function() state.filterMode=mode;pending=true;filterButton.Text='FILTER: '..mode..'  ▼';rebuildFilter();hideFilter() end,state.filterMode==mode) end
  local rarities={'Common','Uncommon','Rare','Epic','Legendary','Mythic','Divine','Cosmic','Secret','Celestial','Inferno','Void','Omega','Spectral','Ethereal','Primordial','Exclusive'}
  filterOption('──── RARITIES (multi-select) ────',function() end,false)
  for _,r in ipairs(rarities) do filterOption((state.raritySelected[r] and '☑  ' or '☐  ')..r,function() state.raritySelected[r]=not state.raritySelected[r];pending=true;rebuildFilter() end,state.raritySelected[r],r) end
  local mutations={'Gold','Diamond','Lightning','Frozen','Angelic','Hacker','Time','Void','Normal','Limited'}
  filterOption('──── MUTATIONS (multi-select) ────',function() end,false)
  for _,m in ipairs(mutations) do filterOption((state.mutationSelected[m] and '☑  ' or '☐  ')..m,function() state.mutationSelected[m]=not state.mutationSelected[m];pending=true;rebuildFilter() end,state.mutationSelected[m]) end
  filterOption('CLEAR SELECTIONS',function() state.raritySelected={};state.mutationSelected={};rebuildFilter() end,false)
  filterList.CanvasSize=UDim2.fromOffset(0,#filterModes*32+(#rarities+#mutations+3)*32)
 end
 connect(filterButton.MouseButton1Click,function() filterOpen=not filterOpen;filterBox.Visible=filterOpen;if filterOpen then filterBox.Size=UDim2.new(1,-24,0,265);rebuildFilter() end end)
 local scroll=make('ScrollingFrame',panel,{Position=UDim2.fromOffset(12,190),Size=UDim2.new(1,-24,1,-230),BackgroundTransparency=1,ScrollBarThickness=4,ScrollBarImageColor3=palette.red,BorderSizePixel=0,CanvasSize=UDim2.new()})
 local layout=make('UIListLayout',scroll,{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder})
 connect(layout:GetPropertyChangedSignal('AbsoluteContentSize'),function() scroll.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+8) end)
 make('TextLabel',panel,{Position=UDim2.new(0,12,1,-34),Size=UDim2.new(1,-24,0,25),BackgroundTransparency=1,Text='Shows only currently replicated pickup animals',TextColor3=palette.muted,TextSize=10,Font=Enum.Font.Gotham})
 local dragging=false;local startPos;local origin
 connect(head.InputBegan,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;startPos=input.Position;origin=panel.Position end end)
 connect(game:GetService('UserInputService').InputChanged,function(input)
  if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then local d=input.Position-startPos;panel.Position=UDim2.new(origin.X.Scale,origin.X.Offset+d.X,origin.Y.Scale,origin.Y.Offset+d.Y) end
 end)
 connect(game:GetService('UserInputService').InputEnded,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
 local folder=nil;local arrivals={};local serial=0;local cards={}
 local portraitCache={};local portraitMissAt={};local rarityColorCache={};local lastSignature=nil;local folderConnections={}
 local function disconnectFolder() for _,c in ipairs(folderConnections) do c:Disconnect() end;table.clear(folderConnections) end
 local function requestRefresh() pending=true end
 local function attr(m,k) return m:GetAttribute(k) end
 local function mutation(m)
  -- Verified from V3: the pickup overhead has a Mutation TextLabel whose
  -- Text can say "Gold" while Visible=false. Hidden labels are NOT mutations.
  for _,key in ipairs({'Mutation','MutationType','AuraMutation'}) do
   local v=m:GetAttribute(key)
   if v~=nil and tostring(v)~='' then
    local value=tostring(v):match('^%s*(.-)%s*$')
    if value:lower()=='none' or value:lower()=='normal' then return 'None' end
    return value
   end
  end
  local overhead=m:FindFirstChild('AnimalOverhead',true)
  if overhead then
   for _,label in ipairs(overhead:GetDescendants()) do
    if label:IsA('TextLabel') and label.Name=='Mutation' and label.Visible then
     local value=tostring(label.Text):gsub('^%s*[Mm]utation%s*:%s*',''):match('^%s*(.-)%s*$')
     if value~='' and value:lower()~='normal' and value:lower()~='none' then return value end
    end
   end
  end
  return 'None'
 end
 local function abbreviate(n)
  n=tonumber(n)
  if not n then return '?' end
  local suffix={'','K','M','B','T','Qa','Qi','Sx','Sp','Oc','No','Dc','Ud'};local i=1
  while math.abs(n)>=1000 and i<#suffix do n=n/1000;i=i+1 end
  return string.format('%.2f%s',n,suffix[i])
 end
 local function clearHighlight()
  for model,h in pairs(state.highlights) do h:Destroy();state.highlights[model]=nil end
  if state.billboard then state.billboard:Destroy();state.billboard=nil end
  state.billboardLabels=nil
  state.tracked=nil
 end
 local function incomeFromModel(model)
  local n=tonumber(attr(model,'CashPerSecond') or attr(model,'IncomePerSecond') or attr(model,'Income') or attr(model,'MoneyPerSecond'))
  if n then return n end
  local scales={K=1e3,M=1e6,B=1e9,T=1e12,Qa=1e15,Qi=1e18,Sx=1e21,Sp=1e24,Oc=1e27,No=1e30,Dc=1e33,Ud=1e36}
  for _,obj in ipairs(model:GetDescendants()) do
   if obj:IsA('TextLabel') and (obj.Text:find('/s',1,true) or obj.Name:lower():find('income') or obj.Name:lower():find('cash')) then
    local raw=obj.Text:gsub(',',''):gsub('%$','')
    local number,suffix=raw:match('([%d%.]+)%s*([%a]*)%s*/s')
    if number then return tonumber(number)*(scales[suffix] or 1) end
   end
  end
  return nil
 end
 local function toggleTrack(model)
  if state.tracked==model then clearHighlight();return end
  clearHighlight()
  if model and model.Parent then
   local h=make('Highlight',model,{Name='CRBF_SpawnTrack',Adornee=model,FillColor=Color3.fromRGB(255,66,92),OutlineColor=Color3.fromRGB(255,255,255),FillTransparency=.65,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop})
   state.highlights[model]=h;state.tracked=model
   -- Billboard is attached to the actual pickup, not to the camera.
   local anchor=model:IsA('BasePart') and model or model.PrimaryPart or model:FindFirstChildWhichIsA('BasePart',true)
   if anchor then
    local bb=make('BillboardGui',screen,{Name='CRBF_TrackedAnimalStats',Adornee=anchor,AlwaysOnTop=true,MaxDistance=0,Size=UDim2.fromOffset(265,115),StudsOffsetWorldSpace=Vector3.new(0,math.max(4,(model:IsA('Model') and model:GetExtentsSize().Y or anchor.Size.Y)/2+2),0),LightInfluence=0})
    local bg=make('Frame',bb,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(22,16,23),BackgroundTransparency=.10,BorderSizePixel=0});roundIt(bg)
    make('UIStroke',bg,{Color=Color3.fromRGB(255,78,104),Thickness=2})
    local name=tostring(attr(model,'AnimalName') or model.Name)
    local rarity=tostring(attr(model,'Rarity') or 'Unknown')
    local mut=mutation(model)
    local income=incomeFromModel(model)
    local weight=tonumber(attr(model,'WeightKg') or attr(model,'Weight'))
    local mult=tonumber(attr(model,'MutationMultiplier') or attr(model,'Multiplier') or attr(model,'SizeMult'))
    local lines={name,'$'..(income and abbreviate(income) or '?')..'/s  •  '..(weight and abbreviate(weight) or '?')..' kg',rarity..'  •  '..mut..(mult and ('  •  x'..string.format('%.2f',mult)) or '')}
    state.billboardLabels={}
    for i,t in ipairs(lines) do state.billboardLabels[i]=make('TextLabel',bg,{Position=UDim2.fromOffset(9,6+(i-1)*35),Size=UDim2.new(1,-18,0,31),BackgroundTransparency=1,Text=t,TextScaled=true,TextColor3=i==2 and Color3.fromRGB(116,255,115) or (i==3 and Color3.fromRGB(112,198,255) or Color3.new(1,1,1)),Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center}) end
    state.billboard=bb
   end
  end
 end
 local function isPickup(obj)
  return obj:IsA('Model') or obj:IsA('BasePart')
 end
 local function rescan()
  if not state.alive then return end
  local f=workspace:FindFirstChild('AnimalPickups')
  if f~=folder then
   disconnectFolder();folder=f;pending=true
   if folder then
    table.insert(folderConnections,folder.ChildAdded:Connect(requestRefresh))
    table.insert(folderConnections,folder.ChildRemoved:Connect(requestRefresh))
   end
  end
  local current={};local entries={}
  if folder then
   for _,m in ipairs(folder:GetChildren()) do
    if isPickup(m) then
     current[m]=true
     if not arrivals[m] then serial=serial+1;arrivals[m]=serial end
     local name=tostring(attr(m,'AnimalName') or m.Name)
     local rarity=tostring(attr(m,'Rarity') or 'Unknown')
     local ownerId=tonumber(attr(m,'OwnerUserId'))
     local owner=ownerId and Players:GetPlayerByUserId(ownerId)
     local who=owner and owner.DisplayName or (ownerId and ('User '..ownerId) or 'Unassigned')
     local income=incomeFromModel(m)
     local weight=tonumber(attr(m,'WeightKg') or attr(m,'Weight')) or 0
     local mut=mutation(m)
     local entry={model=m,name=name,rarity=rarity,owner=who,income=income,weight=weight,mutation=mut,order=arrivals[m],mult=tonumber(attr(m,'MutationMultiplier') or attr(m,'Multiplier') or attr(m,'SizeMult'))}
     local q=state.query:lower()
     local mutated=(mut~='None' and mut~='Normal' and mut~='')
     local rarityMatch=state.raritySelected[rarity]==true
     local mutMatch=state.mutationSelected[mut]==true
     local filterPass=state.filterMode=='All' or (state.filterMode=='Mutated only' and mutated) or (state.filterMode=='No mutation' and not mutated) or (state.filterMode=='Selected rarities' and rarityMatch) or (state.filterMode=='Selected mutations' and mutMatch) or (state.filterMode=='Rarity + mutation' and rarityMatch and mutMatch)
     if filterPass and (q=='' or (name..' '..rarity..' '..who..' '..mut):lower():find(q,1,true)) then entries[#entries+1]=entry end
    end
   end
  end
  for m in pairs(arrivals) do if not current[m] then arrivals[m]=nil;pending=true;if state.tracked==m then clearHighlight() end end end
  table.sort(entries,function(a,b)
   if a.model==state.tracked then return true end
   if b.model==state.tracked then return false end
   if state.sort=='Income high' then if (a.income or -1)~=(b.income or -1) then return (a.income or -1)>(b.income or -1) end
   elseif state.sort=='Income low' then if (a.income or -1)~=(b.income or -1) then return (a.income or -1)<(b.income or -1) end
   elseif state.sort=='Weight high' then if a.weight~=b.weight then return a.weight>b.weight end
   elseif state.sort=='Rarity' then if a.rarity~=b.rarity then return a.rarity<b.rarity end end
   return a.order>b.order
  end)
  if state.tracked and state.billboardLabels then
   for _,e in ipairs(entries) do
    if e.model==state.tracked then
     state.billboardLabels[1].Text=e.name
     state.billboardLabels[2].Text='$'..(e.income and abbreviate(e.income) or '?')..'/s  •  '..abbreviate(e.weight)..' kg'
     state.billboardLabels[3].Text=e.rarity..'  •  '..e.mutation..(e.mult and ('  •  x'..string.format('%.2f',e.mult)) or '')
     break
    end
   end
  end
  status.Text=string.format('%d live pickups  |  %d matching%s',folder and #folder:GetChildren() or 0,#entries,state.tracked and '  |  1 PINNED' or '')
  local signature={state.sort,state.query,state.filterMode,tostring(state.tracked)}
  for _,e in ipairs(entries) do signature[#signature+1]=table.concat({tostring(e.model),e.name,e.rarity,e.mutation,tostring(e.income),tostring(e.weight),tostring(e.mult)},':') end
  local stamp=table.concat(signature,'|')
  if stamp==lastSignature and not pending then return end
  lastSignature=stamp
  for _,card in ipairs(cards) do card:Destroy() end;table.clear(cards)
  if not folder then status.Text='AnimalPickups not found (waiting...)' end
  if #entries==0 then
   local msg=make('TextLabel',scroll,{Size=UDim2.new(1,-6,0,72),BackgroundTransparency=1,Text=folder and 'No live pickup animals right now.\nHatch an egg to test.' or 'Waiting for AnimalPickups folder...',TextWrapped=true,TextColor3=palette.muted,TextSize=12,Font=Enum.Font.Gotham});cards[#cards+1]=msg
  end
  -- Resolve portraits from the actual Index UI when exposed as ImageLabels.
  -- Never invent asset IDs; if an entry is a ViewportFrame, show a fallback icon.
  local function portraitFor(name)
   local gui=player:FindFirstChild('PlayerGui')
   if not gui then return nil end
   local main=gui:FindFirstChild('MainGUI')
   local frames=main and main:FindFirstChild('Frames')
   if not frames then return nil end
   -- Prefer an exact species entry's AnimalDisplay. Do not choose the
   -- largest descendant image: that often picks a blurred/locked backdrop.
   local function fromEntry(entry)
    if not entry then return nil end
    local inner=entry:FindFirstChild('Inner')
    for _,parent in ipairs({inner,entry}) do
     if parent then
      local img=parent:FindFirstChild('AnimalDisplay')
      if img and (img:IsA('ImageLabel') or img:IsA('ImageButton')) and img.Image~='' then
       return {kind='image',id=img.Image}
      end
     end
    end
    return nil
   end
   local index=frames:FindFirstChild('Index')
   if index then
    for _,entry in ipairs(index:GetDescendants()) do
     if entry.Name:lower()==name:lower() and entry:IsA('GuiObject') then
      local result=fromEntry(entry)
      if result then return result end
     end
    end
   end
   -- The Merge Machine has real portraits for some Index-locked species.
   local merge=frames:FindFirstChild('MergeMachine')
   if merge then
    for _,label in ipairs(merge:GetDescendants()) do
     if (label:IsA('TextLabel') or label:IsA('TextButton')) and label.Name=='Name' and label.Text:lower()==name:lower() then
      local entry=label.Parent
      for _=1,2 do
       local result=fromEntry(entry)
       if result then return result end
       entry=entry and entry.Parent
      end
     end
    end
   end
   return nil
  end
  local function showPortrait(parent,info,name)
   if info and info.kind=='image' then
    make('ImageLabel',parent,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Image=info.id,ScaleType=Enum.ScaleType.Fit})
    return
   end
   if info and info.kind=='viewport' and info.source and info.source.Parent then
    local ok,clone=pcall(function() return info.source:Clone() end)
    if ok and clone then
     clone.Size=UDim2.fromScale(1,1);clone.Position=UDim2.new();clone.Visible=true
     clone.Parent=parent
     if info.source.CurrentCamera then
      local cam=info.source.CurrentCamera:Clone();cam.Parent=clone;clone.CurrentCamera=cam
     end
     return
    end
   end
   make('TextLabel',parent,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text=name:sub(1,2):upper(),TextColor3=palette.white,TextSize=25,Font=Enum.Font.GothamBold})
  end
  local function incomeFromVisual(model)
   -- Pickups can expose income as a UI label instead of a model attribute.
   for _,obj in ipairs(model:GetDescendants()) do
    if obj:IsA('TextLabel') and (obj.Name:lower():find('cash') or obj.Name:lower():find('income') or obj.Text:find('/s',1,true)) then
     local raw=obj.Text:gsub(',',''):gsub('%$','')
     local num,suffix=raw:match('([%d%.]+)%s*([%a]*)%s*/s')
     if num then
      local scales={K=1e3,M=1e6,B=1e9,T=1e12,Qa=1e15,Qi=1e18,Sx=1e21,Sp=1e24,Oc=1e27,No=1e30,Dc=1e33,Ud=1e36}
      return tonumber(num)*(scales[suffix] or 1)
     end
    end
   end
   return nil
  end
  for i,e in ipairs(entries) do
   local row=make('Frame',scroll,{Size=UDim2.new(1,-6,0,126),BackgroundColor3=e.model==state.tracked and Color3.fromRGB(94,37,52) or palette.card,BorderSizePixel=0,LayoutOrder=i});roundIt(row);cards[#cards+1]=row
   make('UIStroke',row,{Color=e.model==state.tracked and rarityTint(e.rarity) or rarityTint(e.rarity):Lerp(Color3.fromRGB(40,36,44),.5),Thickness=e.model==state.tracked and 2 or 1})
   local accent=make('Frame',row,{Position=UDim2.fromOffset(0,6),Size=UDim2.fromOffset(3,110),BackgroundColor3=rarityTint(e.rarity),BorderSizePixel=0});rarityGradient(accent,e.rarity)
   local portrait=make('Frame',row,{Position=UDim2.fromOffset(6,9),Size=UDim2.fromOffset(86,104),BackgroundColor3=Color3.fromRGB(52,46,54),BorderSizePixel=0});roundIt(portrait)
   local pic=portraitCache[e.name]
   if pic==nil and (not portraitMissAt[e.name] or os.clock()-portraitMissAt[e.name]>20) then
    pic=portraitFor(e.name)
    if pic then portraitCache[e.name]=pic else portraitMissAt[e.name]=os.clock() end
   end
   showPortrait(portrait,pic,e.name)
   local rarityColors=setmetatable({},{__index=function(_,rarity) return rarityTint(rarity) end})
   make('TextLabel',row,{Position=UDim2.fromOffset(100,7),Size=UDim2.new(1,-190,0,24),BackgroundTransparency=1,Text=e.name,TextColor3=rarityColors[e.rarity] or palette.white,TextSize=15,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
   local income=e.income or incomeFromVisual(e.model)
   make('TextLabel',row,{Position=UDim2.fromOffset(100,33),Size=UDim2.new(1,-110,0,23),BackgroundTransparency=1,Text=income and ('$'..abbreviate(income)..'/s') or 'Income unavailable',TextColor3=Color3.fromRGB(112,255,80),TextSize=15,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
   local mult=e.mult and ('x'..string.format('%.2f',e.mult)..'  •  ') or ''
   make('TextLabel',row,{Position=UDim2.fromOffset(100,56),Size=UDim2.new(1,-110,0,19),BackgroundTransparency=1,Text=mult..abbreviate(e.weight)..' kg',TextColor3=Color3.fromRGB(83,193,255),TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
   local rarityColor=rarityColors[e.rarity] or palette.white
   -- Prefer the exact color of the rarity text in the in-game Index when available.
   local function indexRarityColor()
    if rarityColorCache[e.name]~=nil then return rarityColorCache[e.name] or nil end
    local gui=player:FindFirstChild('PlayerGui');if not gui then return nil end
    for _,v in ipairs(gui:GetDescendants()) do
     if v:IsA('TextLabel') and v.Text==e.rarity and v.TextColor3~=Color3.new(1,1,1) then
      local par=v.Parent
      for depth=1,5 do
       if not par then break end
       if par.Name:lower():find(e.name:lower(),1,true) then rarityColorCache[e.name]=v.TextColor3;return v.TextColor3 end
       par=par.Parent
      end
     end
    end
    rarityColorCache[e.name]=false
    return nil
   end
   rarityColor=indexRarityColor() or rarityColor
   local rarityLabel=make('TextLabel',row,{Position=UDim2.fromOffset(100,80),Size=UDim2.new(1,-110,0,22),BackgroundTransparency=1,Text=e.rarity,TextColor3=rarityColor,TextSize=16,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
   rarityGradient(rarityLabel,e.rarity)
   make('TextLabel',row,{Position=UDim2.fromOffset(100,101),Size=UDim2.new(1,-110,0,20),BackgroundTransparency=1,Text=(e.mutation=='None' and 'Mutation: None' or 'Mutation: '..e.mutation),TextColor3=Color3.fromRGB(255,178,91),TextSize=14,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
   local b=button(row,state.tracked==e.model and 'UNPIN' or 'TRACK',UDim2.fromOffset(70,30),UDim2.new(1,-77,0,10),function() toggleTrack(e.model);pending=true end)
   b.BackgroundColor3=Color3.fromRGB(38,145,66)
  end
  pending=false
 end
 connect(query:GetPropertyChangedSignal('Text'),function() state.query=query.Text;pending=true end)
 -- Event-driven updates; reconcile periodically for attribute changes and folder recreation.
 -- Do not destroy/recreate every card on every tick: repaint only when the data signature changes.
 task.spawn(function()
  local lastCheck=0
  while state.alive do
   if pending or os.clock()-lastCheck>=5 then
    lastCheck=os.clock()
    local ok,err=pcall(rescan)
    if not ok then warn('[CRBF Live Spawns]',err) end
   end
   task.wait(.3)
  end
 end)
 local originalClose=state.close
 state.close=function() disconnectFolder();originalClose() end
 return state
end
local function setSpawnTracker(on)
 if on then if not spawnTrackerActive() then spawnTracker=startSpawnTracker() end
 else if spawnTrackerActive() then spawnTracker.close() end;spawnTracker=nil end
end

local pageNames={'ESP','Dashboard','Farm','Animal ESP','Player ESP','Money','Animals','Mutations','Trackers','Placed Animals','Live Spawns','Zone Eggs','Egg Predictor','Menus','Settings'}; local tab='Dashboard'; local mode='EXPANDED'; local nav={}; local showTab
local function page(name) local p=new('ScrollingFrame',body,{Name=name,Size=UDim2.new(1,-28,1,-24),Position=UDim2.fromOffset(14,12),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=theme.blue,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=false}); new('UIPadding',p,{PaddingBottom=UDim.new(0,18)}); new('UIListLayout',p,{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder}); return p end
for _,name in ipairs(pageNames) do pages[name]=page(name) end
local function clear(p) for _,x in ipairs(p:GetChildren()) do if x:IsA('GuiObject') then x:Destroy() end end end
local function line(p,s,size,height,c) return text(p,s,size or 14,{Size=UDim2.new(1,0,0,height or 28),TextColor3=c or theme.white,TextWrapped=true}) end
local collapsedSections={}
-- Chilli-style compact centre-panel component library.
local chilli={base=color('#101827'),surface=color('#151E2F'),deep=color('#0C1220'),edge=color('#38BDF8'),text=color('#F1F5F9'),sub=color('#94A3B8'),active=color('#34B4E6')}
local function chunkyBorder(obj,accent,thickness)
    local stroke=Instance.new('UIStroke')
    stroke.Color=accent or chilli.edge
    stroke.Thickness=thickness or 1
    stroke.Transparency=.52
    stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    stroke.Parent=obj
    return stroke
end
local function gradientFill(obj,top,bottom)
    local grad=Instance.new('UIGradient')
    grad.Color=ColorSequence.new(top,bottom)
    grad.Rotation=35
    grad.Parent=obj
end
local function chilliCard(parent,height)
    local card=round(new('Frame',parent,{Size=UDim2.new(1,-4,0,height),BackgroundColor3=chilli.surface,BorderSizePixel=0}),10)
    gradientFill(card,chilli.deep,color('#15324B'))
    chunkyBorder(card,chilli.edge)
    return card
end
local collapsedSections={}
local function section(p,s)
    local row=chilliCard(p,39)
    row:SetAttribute('CRBFSectionHeading',true)
    local heading=btn(row,'',nil,{Size=UDim2.new(1,-14,1,-4),Position=UDim2.fromOffset(7,2),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextSize=16,Font=Enum.Font.GothamBold,TextColor3=chilli.text})
    local arrow=text(row,'▼',13,{Size=UDim2.fromOffset(24,28),Position=UDim2.new(1,-33,0,5),TextColor3=chilli.active,Font=Enum.Font.GothamBold})
    local key=(p.Name or 'Page')..'/'..s
    local collapsed=collapsedSections[key]==true
    local function members()
        local items={}; local found=false
        for _,item in ipairs(p:GetChildren()) do
            if item==row then found=true
            elseif found and item:IsA('GuiObject') then
                if item:GetAttribute('CRBFSectionHeading') then break end
                items[#items+1]=item
            end
        end
        return items
    end
    local function refresh()
        heading.Text='  '..string.upper(s)
        arrow.Text=collapsed and '▶' or '▼'
        for _,item in ipairs(members()) do item.Visible=not collapsed end
    end
    heading.MouseButton1Click:Connect(function()
        collapsed=not collapsed;collapsedSections[key]=collapsed;refresh()
    end)
    task.defer(function() if row.Parent then refresh() end end)
    return row
end
local function action(p,s,fn,c)
    local card=chilliCard(p,39)
    local b=btn(card,s,function(...)
        if fn then fn(...) end
    end,{Size=UDim2.new(1,-12,1,-10),Position=UDim2.fromOffset(6,5),BackgroundColor3=c or color('#175073'),TextColor3=chilli.text,TextSize=14,Font=Enum.Font.GothamBold})
    round(b,8)
    gradientFill(b,c or color('#1B668B'),c or color('#17334C'))
    chunkyBorder(b,chilli.active)
    return card
end
local function toggle(p,s,key)
    local row=chilliCard(p,42)
    text(row,s,14,{Size=UDim2.new(1,-94,1,0),Position=UDim2.fromOffset(13,0),Font=Enum.Font.GothamMedium,TextColor3=chilli.text})
    local hit=btn(row,'',nil,{Size=UDim2.fromOffset(58,30),Position=UDim2.new(1,-71,.5,-15),BackgroundTransparency=1})
    local track=round(new('Frame',hit,{Size=UDim2.fromOffset(44,22),Position=UDim2.fromOffset(7,4),BorderSizePixel=0}),11)
    local knob=round(new('Frame',track,{Size=UDim2.fromOffset(18,18),Position=UDim2.fromOffset(2,2),BackgroundColor3=chilli.text,BorderSizePixel=0}),9)
    local function refresh()
        local on=not not cfg[key]
        game:GetService('TweenService'):Create(track,TweenInfo.new(.17),{BackgroundColor3=on and color('#1DBA9A') or color('#3A475B')}):Play()
        game:GetService('TweenService'):Create(knob,TweenInfo.new(.17),{Position=on and UDim2.fromOffset(24,2) or UDim2.fromOffset(2,2)}):Play()
    end
    refresh()
    hit.MouseButton1Click:Connect(function() cfg[key]=not cfg[key];settingsDirty=true;refresh() end)
    return row
end
local function slider(p,s,min,max,get,set)
    local row=chilliCard(p,60)
    local caption=text(row,'',14,{Size=UDim2.new(1,-26,0,27),Position=UDim2.fromOffset(13,3),Font=Enum.Font.GothamMedium,TextColor3=chilli.text})
    local track=round(new('Frame',row,{Size=UDim2.new(1,-34,0,7),Position=UDim2.fromOffset(17,40),BackgroundColor3=color('#28364A'),BorderSizePixel=0}),4)
    local fill=round(new('Frame',track,{BackgroundColor3=chilli.active,BorderSizePixel=0}),4)
    local knob=round(new('Frame',track,{Size=UDim2.fromOffset(16,16),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=chilli.text,BorderSizePixel=0}),8)
    chunkyBorder(knob,chilli.active)
    local function display()
        local v=get();local t=max>min and math.clamp((v-min)/(max-min),0,1) or 0
        caption.Text=s..'     '..tostring(v)
        fill.Size=UDim2.fromScale(t,1);knob.Position=UDim2.fromScale(t,.5)
    end
    display()
    local moving=false
    local function at(x)
        if track.AbsoluteSize.X==0 then return end
        set(math.floor(math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(max-min)+min+.5))
        settingsDirty=true;display()
    end
    local hit=new('TextButton',row,{Position=UDim2.new(0,13,0,30),Size=UDim2.new(1,-26,0,27),BackgroundTransparency=1,Text=''})
    local c1=hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then moving=true;at(i.Position.X) end end)
    local c2=U.InputChanged:Connect(function(i) if moving and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then at(i.Position.X) end end)
    local c3=U.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then moving=false end end)
    row.Destroying:Once(function() c1:Disconnect();c2:Disconnect();c3:Disconnect() end)
    return row
end
local function _filters(p,names,selected,colors) local box=new('Frame',p,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1}); new('UIGridLayout',box,{CellSize=UDim2.new(.5,-5,0,37),CellPadding=UDim2.fromOffset(10,7)}); for _,name in ipairs(names) do local b=btn(box,'',nil,{TextColor3=color(colors[name])}); local function refresh() b.Text=(selected[name] and '✓ ' or '○ ')..name; b.BackgroundColor3=selected[name] and Color3.fromRGB(21,105,113) or theme.card end; refresh(); b.MouseButton1Click:Connect(function() selected[name]=not selected[name]; settingsDirty=true; refresh() end) end end
local function bar(p,name,a,b,c)
    local row=round(new('Frame',p,{Size=UDim2.new(1,0,0,73),BackgroundColor3=theme.panel,BorderSizePixel=0}),12)
    border(row,c or theme.border)
    new('Frame',row,{Size=UDim2.fromOffset(4,48),Position=UDim2.fromOffset(8,11),BackgroundColor3=c or theme.blue,BorderSizePixel=0})
    text(row,string.upper(name),14,{Size=UDim2.new(.62,-20,0,24),Position=UDim2.fromOffset(24,11),Font=Enum.Font.GothamBold})
    text(row,string.format('%.1f%%',b>0 and a/b*100 or 0),13,{Size=UDim2.new(.32,0,0,23),Position=UDim2.new(.66,0,0,11),TextXAlignment=Enum.TextXAlignment.Right,TextColor3=c or theme.blue,Font=Enum.Font.GothamBold})
    text(row,a..' / '..b..'  UNLOCKED',10,{Size=UDim2.new(1,-42,0,17),Position=UDim2.fromOffset(24,35),TextColor3=theme.muted})
    local track=round(new('Frame',row,{Size=UDim2.new(1,-48,0,9),Position=UDim2.fromOffset(24,56),BackgroundColor3=theme.card,BorderSizePixel=0}),4)
    round(new('Frame',track,{Size=UDim2.fromScale(b>0 and math.clamp(a/b,0,1) or 0,1),BackgroundColor3=c or theme.blue,BorderSizePixel=0}),4)
    return row
end

-- Mastery tracker: read replicated data or visible UI; never fabricate progress.
local masteryNames={'Swinging','Power','Breaking','Running','Wealth','Stealing','Bonking','Growing'}
local masteryData={}; local masterySource={}; local masteryRate={}; local masteryLast={}
local function masteryTextNumber(v)
    if type(v)=='number' then return v end
    if type(v)~='string' then return nil end
    local t=v:gsub(',',''):gsub('%s','')
    return tonumber(t)
end
local function findMasteryRoot()
    local direct={me:FindFirstChild('Mastery',true),me:FindFirstChild('Masteries',true),me:FindFirstChild('MasteryData',true),me:FindFirstChild('Data',true),me:FindFirstChild('PlayerData',true)}
    for _,v in ipairs(direct) do if v then return v end end
    return nil
end
local function parseMasteryNode(node,name)
    if not node then return nil end
    local out={}
    local function readKey(keys)
        for _,key in ipairs(keys) do
            local a=node:GetAttribute(key)
            if a~=nil then local n=masteryTextNumber(a); if n then return n end end
            local child=node:FindFirstChild(key)
            if child and child:IsA('ValueBase') then local n=masteryTextNumber(child.Value); if n then return n end end
        end
        return nil
    end
    out.level=readKey({'Level','Lvl','MasteryLevel'})
    out.xp=readKey({'XP','Exp','Experience','CurrentXP','CurrentExp'})
    out.required=readKey({'RequiredXP','MaxXP','XPRequired','NextLevelXP','XPToNextLevel','MaxExp'})
    if out.level or out.xp then return out end
    return nil
end
local function scanMasteryData()
    local root=findMasteryRoot()
    if not root then return end
    for _,name in ipairs(masteryNames) do
        local node=root:FindFirstChild(name,true)
        local info=parseMasteryNode(node,name)
        if not info then
            local playerNode=me:FindFirstChild(name,true)
            if playerNode and playerNode~=node then info=parseMasteryNode(playerNode,name) end
        end
        if info then
            local prev=masteryData[name] or {}
            for k,v in pairs(prev) do if info[k]==nil then info[k]=v end end
            masteryData[name]=info; masterySource[name]='Replicated data'
        end
    end
end
local function scanMasteryGUI()
    -- Visible menu fallback. Only parse values when explicitly associated with a category.
    local candidates={}
    for _,d in ipairs(pg:GetDescendants()) do
        if d:IsA('GuiObject') and d.Name:lower():find('mastery') then candidates[#candidates+1]=d end
    end
    for _,panel in ipairs(candidates) do
        local visiblePanel=true; local cursor=panel
        while cursor and cursor~=pg do if cursor:IsA('GuiObject') and not cursor.Visible then visiblePanel=false; break end; cursor=cursor.Parent end
        if visiblePanel then
            local labels={}
            for _,d in ipairs(panel:GetDescendants()) do if d:IsA('TextLabel') then labels[#labels+1]=d.Text end end
            local combined=table.concat(labels,' | ')
            for _,name in ipairs(masteryNames) do
                local lower=combined:lower()
                if lower:find(name:lower()..' mastery',1,true) then
                    local xp,maxxp=combined:match('([%d,]+)%s*/%s*([%d,]+)%s*[Xx][Pp]')
                    local level=combined:match('[Ll]evel%s*(%d+)')
                    if level or xp then
                        local entry=masteryData[name] or {}
                        if level then entry.level=tonumber(level) end
                        if xp then entry.xp=masteryTextNumber(xp); entry.required=masteryTextNumber(maxxp) end
                        if masterySource[name]~='Replicated data' then masteryData[name]=entry; masterySource[name]='Visible mastery menu' end
                    end
                end
            end
        end
    end
end
local function updateMasteryRates()
    local now=os.clock()
    for _,name in ipairs(masteryNames) do
        local d=masteryData[name]
        if d and d.xp~=nil and d.level~=nil then
            local prev=masteryLast[name]
            if prev and prev.level==d.level and d.xp>prev.xp and now-prev.time>=.5 then
                local observed=(d.xp-prev.xp)/(now-prev.time)*60
                masteryRate[name]=masteryRate[name] and (masteryRate[name]*.6+observed*.4) or observed
            end
            if not prev or d.xp~=prev.xp or d.level~=prev.level then masteryLast[name]={xp=d.xp,level=d.level,time=now} end
        end
    end
end
-- Mastery status is rendered from live data; no separate status variable needed.
local selectedZone='ALL'; local indexZoneOpen=nil; local selectedRarity='ALL'; local missing=false; local search=''
local render={}
local function dropdown(p,title,options,chosen,onPick)
    local wrap=round(new('Frame',p,{Size=UDim2.new(1,-4,0,45),BackgroundColor3=chilli.surface,BorderSizePixel=0,ClipsDescendants=true}),10)
    chunkyBorder(wrap)
    gradientFill(wrap,chilli.deep,color('#15324B'))
    local trigger=btn(wrap,title..'   /   '..tostring(chosen)..'     ▼',nil,{Size=UDim2.new(1,-12,0,40),Position=UDim2.fromOffset(6,2),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextSize=15,Font=Enum.Font.GothamBold})
    local menu=new('ScrollingFrame',wrap,{Position=UDim2.fromOffset(7,45),Size=UDim2.new(1,-14,0,0),BackgroundColor3=theme.side,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=theme.blue,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y})
    new('UIListLayout',menu,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
    local expanded=false
    local function setOpen(v)
        expanded=v
        local height=math.min(#options*39+8,225)
        wrap.Size=UDim2.new(1,0,0,v and height+48 or 45)
        menu.Size=UDim2.new(1,-14,0,v and height or 0)
        trigger.Text=title..'   /   '..tostring(chosen)..(v and '     ▲' or '     ▼')
    end
    trigger.MouseButton1Click:Connect(function() setOpen(not expanded) end)
    for i,value in ipairs(options) do
        local opt=btn(menu,(value==chosen and '◆  ' or '    ')..value,function()
            chosen=value; setOpen(false); onPick(value)
        end,{Size=UDim2.new(1,-7,0,35),LayoutOrder=i,BackgroundColor3=title=='RARITY' and rc[value] and rarityTint(value):Lerp(theme.panel,.73) or (value==chosen and Color3.fromRGB(21,105,113) or theme.card),TextXAlignment=Enum.TextXAlignment.Left,TextColor3=theme.white,Font=Enum.Font.GothamBold})
        if title=='RARITY' and rc[value] then local sw=new('Frame',opt,{Position=UDim2.new(1,-20,0,11),Size=UDim2.fromOffset(12,12),BackgroundColor3=rarityTint(value),BorderSizePixel=0});rarityGradient(sw,value) end
    end
end
local function multiPicker(p,title,items,selected,colors)
    local count=0
    for _,item in ipairs(items) do if selected[item] then count+=1 end end
    local wrap=round(new('Frame',p,{Size=UDim2.new(1,-4,0,46),BackgroundColor3=chilli.surface,BorderSizePixel=0,ClipsDescendants=true}),10)
    chunkyBorder(wrap)
    gradientFill(wrap,chilli.deep,color('#15324B'))
    local trigger=btn(wrap,title..'   ('..count..' selected)   ▾',nil,{Size=UDim2.new(1,-12,0,40),Position=UDim2.fromOffset(6,3),BackgroundColor3=theme.card,TextXAlignment=Enum.TextXAlignment.Left})
    local list=new('ScrollingFrame',wrap,{Position=UDim2.fromOffset(6,48),Size=UDim2.new(1,-12,0,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()})
    new('UIListLayout',list,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
    local open=false
    local function refresh()
        local n=0
        for _,item in ipairs(items) do if selected[item] then n+=1 end end
        trigger.Text=title..'   ('..n..' selected)   '..(open and '▴' or '▾')
    end
    local function setOpen(v)
        open=v
        local h=math.min(#items*38+8,235)
        wrap.Size=UDim2.new(1,0,0,v and h+50 or 46)
        list.Size=UDim2.new(1,-12,0,v and h or 0)
        refresh()
    end
    trigger.MouseButton1Click:Connect(function() setOpen(not open) end)
    for i,item in ipairs(items) do
        local b=btn(list,'',nil,{Size=UDim2.new(1,-8,0,34),LayoutOrder=i,TextXAlignment=Enum.TextXAlignment.Left})
        local function paint()
            b.Text=(selected[item] and '  ☑  ' or '  □  ')..item
            local tint=colors and colors[item] and color(colors[item])
            b.BackgroundColor3=tint and tint:Lerp(theme.panel,selected[item] and .63 or .78) or (selected[item] and Color3.fromRGB(79,37,51) or theme.card)
            b.TextColor3=tint or theme.white
            if tint and not b:FindFirstChild('RarityEdge') then
                new('Frame',b,{Name='RarityEdge',Size=UDim2.new(0,5,1,-6),Position=UDim2.fromOffset(2,3),BackgroundColor3=tint,BorderSizePixel=0})
                border(b,tint)
            end
        end
        paint()
        b.MouseButton1Click:Connect(function() selected[item]=not selected[item]; settingsDirty=true; paint(); refresh() end)
    end
end
local moneyModes={'Rarity Only','Rarity + Money','Rarity + Index Missing','Rarity + Money + Index Missing','Money Only','Money + Index Missing','Index Missing Only','All Animals'}
render.Money=function()
    local p=pages.Money; clear(p)
    section(p,'MONEY FILTERS')
    line(p,'Filter animal ESP by displayed income per second. Animals with unknown income do not pass money filters.',12,60,theme.muted)

    section(p,'MINIMUM INCOME / SECOND')
    local row=round(new('Frame',p,{Size=UDim2.new(1,0,0,66),BackgroundColor3=theme.panel,BorderSizePixel=0}),9)
    text(row,'Minimum $/s',13,{Size=UDim2.new(.4,0,1,0),Position=UDim2.fromOffset(14,0)})
    local box=round(new('TextBox',row,{Size=UDim2.new(.46,0,0,38),Position=UDim2.new(.52,0,.5,-19),BackgroundColor3=theme.card,TextColor3=theme.white,Text=cfg.minimumIncomeText,PlaceholderText='e.g. 20B, 1.5T, 10Qi',Font=Enum.Font.Gotham,TextSize=14,ClearTextOnFocus=false,BorderSizePixel=0}),8)
    box.FocusLost:Connect(function() if parseIncome(box.Text) then cfg.minimumIncomeText=box.Text; settingsDirty=true else box.Text=cfg.minimumIncomeText end end)
    toggle(p,'Show animal income on ESP cards','showAnimalIncome')
    line(p,'Income is read from replicated animal attributes or visible $/s labels when available. Unknown values are never guessed.',11,65,theme.muted)
end
local function collectionView(name)
    local p=pages[tab]; clear(p)
    section(p,'COLLECTION / '..name)
    action(p,'←  RETURN TO COLLECTIONS',function() render[tab]() end)
    local d=cache[name]
    if not d then line(p,'No saved collection data available.',12,35,theme.muted); return end
    local st=stats(d.Entries)
    local a,b=name=='Limited' and st.EventCollected or st.RegularCollected,name=='Limited' and st.EventTotal or st.RegularTotal
    bar(p,name,a,b,color(mc[name] or rc.Primordial))
    local rs={'ALL'}
    for _,e in ipairs(d.Entries) do
        if not table.find(rs,e.Rarity) then rs[#rs+1]=e.Rarity end
    end
    local rarityRank={}
    for i,r in ipairs(rarities) do rarityRank[r]=i end
    table.sort(rs,function(a,b)
        if a=='ALL' then return true end
        if b=='ALL' then return false end
        return (rarityRank[a] or 999)<(rarityRank[b] or 999)
    end)
    section(p,'CHOOSE A ZONE')
    line(p,'Select one of the 12 zones below to open its animal index. Only the selected zone is shown.',11,40,theme.muted)
    local zoneGrid=new('Frame',p,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
    new('UIGridLayout',zoneGrid,{CellSize=UDim2.new(.25,-7,0,42),CellPadding=UDim2.fromOffset(8,8),SortOrder=Enum.SortOrder.LayoutOrder})
    for zi=1,12 do
        local zn='Zone'..zi
        local active=indexZoneOpen==zn
        btn(zoneGrid,(active and '▾  ' or '▸  ')..'ZONE '..zi,function()
            if active then indexZoneOpen=nil else indexZoneOpen=zn end
            selectedZone=indexZoneOpen or 'ALL'
            collectionView(name)
        end,{LayoutOrder=zi,BackgroundColor3=active and theme.blue or theme.card,TextSize=11})
    end
    if not indexZoneOpen then
        line(p,'SELECT A ZONE ABOVE TO VIEW ITS ANIMALS',12,48,theme.muted)
        return
    end
    section(p,indexZoneOpen..'  /  ANIMAL INDEX')
    action(p,'←  CLOSE '..string.upper(indexZoneOpen),function() indexZoneOpen=nil; selectedZone='ALL'; collectionView(name) end)
    dropdown(p,'RARITY',rs,selectedRarity,function(v) selectedRarity=v; collectionView(name) end)
    action(p,missing and '●  SHOWING MISSING ONLY' or '○  SHOWING ALL ANIMALS',function() missing=not missing; collectionView(name) end,missing and theme.blue or theme.card)
    local input=round(new('TextBox',p,{Size=UDim2.new(1,0,0,43),BackgroundColor3=theme.panel,TextColor3=theme.white,PlaceholderText='⌕   Search by animal name...',PlaceholderColor3=theme.muted,Text=search,ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=12,BorderSizePixel=0}),9)
    border(input,theme.border)
    local summary=line(p,'',12,26,theme.blue)
    local results=new('Frame',p,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
    new('UIListLayout',results,{Padding=UDim.new(0,7)})
    local function redraw()
        clear(results); local count=0; local last
        local sortedEntries={}
        for _,e in ipairs(d.Entries) do sortedEntries[#sortedEntries+1]=e end
        table.sort(sortedEntries,function(x,y)
            local xr,yr=rarityRank[x.Rarity] or 999,rarityRank[y.Rarity] or 999
            if xr~=yr then return xr<yr end
            return tostring(x.Name):lower()<tostring(y.Name):lower()
        end)
        for _,e in ipairs(sortedEntries) do
            if (name~='Limited' or not e.Zone:match('[Zz]one%d+')) and (selectedZone=='ALL' or selectedZone==e.Zone) and (selectedRarity=='ALL' or selectedRarity==e.Rarity) and (not missing or e.Status=='MISSING') and (search=='' or e.Name:lower():find(search:lower(),1,true) or e.InternalName:lower():find(search:lower(),1,true)) then
                if last~=e.Zone then last=e.Zone; section(results,e.Zone) end
                local tint=rarityTint(e.Rarity); local row=round(new('Frame',results,{Size=UDim2.new(1,0,0,65),BackgroundColor3=theme.panel,BorderSizePixel=0}),10)
                border(row,tint)
                new('Frame',row,{Size=UDim2.fromOffset(4,42),Position=UDim2.fromOffset(9,12),BackgroundColor3=tint,BorderSizePixel=0})
                text(row,e.Name,13,{Size=UDim2.new(1,-140,0,27),Position=UDim2.fromOffset(22,8),Font=Enum.Font.GothamBold})
                text(row,string.upper(e.Rarity)..'   •   '..string.upper(e.Zone),10,{Size=UDim2.new(1,-145,0,20),Position=UDim2.fromOffset(22,34),TextColor3=tint,Font=Enum.Font.GothamBold})
                local done=tostring(e.Status)=='COLLECTED'
                text(row,done and '✓  OWNED' or '×  MISSING',11,{Size=UDim2.fromOffset(106,26),Position=UDim2.new(1,-116,.5,-13),TextColor3=done and theme.green or theme.red,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right})
                count+=1
            end
        end
        summary.Text='RESULTS   '..count..' MATCHES    •    '..a..' / '..b..' COLLECTED'
        if count==0 then line(results,'No animals match these filters.',12,35,theme.muted) end
    end
    input:GetPropertyChangedSignal('Text'):Connect(function() search=input.Text; redraw() end)
    redraw()
end

render.Dashboard=function() local p=pages.Dashboard; clear(p); section(p,'Dashboard'); line(p,'ESP + index tracker • Custom shortcuts in Settings.',12,45,theme.muted); local detected=detect(); line(p,'Index: '..tostring(detected or 'Unknown')..'   |   Progress: '..progressText(),12,36); line(p,'ESP: Animals '..((cfg.rarity or cfg.mutation) and 'ON' or 'OFF')..'   Players '..(cfg.players and 'ON' or 'OFF'),12,30); section(p,'Collection progress'); for _,name in ipairs(collections) do local d=cache[name]; if d then local s=stats(d.Entries); bar(p,name,name=='Limited' and s.EventCollected or s.RegularCollected,name=='Limited' and s.EventTotal or s.RegularTotal,color(mc[name])) else line(p,name..': Not cached',12,22,theme.muted) end end; section(p,'Storage'); line(p,'Imported: '..imported..'\nSave verification: '..tostring(verified),11,54,theme.muted) end
render['Animal ESP']=function()
    local p=pages['Animal ESP']; clear(p)
    section(p,'ANIMAL ESP DISPLAY')
    line(p,'Choose what appears on animal labels. Use FARM for overall filters and selection rules.',12,49,theme.muted)
    toggle(p,'Show rarity information','rarity')
    toggle(p,'Show mutation information','mutation')
    toggle(p,'Show income on labels','showAnimalIncome')
    slider(p,'Text size',10,30,function() return cfg.animalSize end,function(v) cfg.animalSize=v end)
    slider(p,'Card transparency %',0,100,function() return math.floor(cfg.animalBG*100) end,function(v) cfg.animalBG=v/100 end)
    slider(p,'Maximum distance',100,5000,function() return cfg.animalRange end,function(v) cfg.animalRange=v end)
    section(p,'INDEX DISPLAY')
    toggle(p,'Show collection status on animal labels','showIndexStatus')
    toggle(p,'Highlight animals missing from index','prioritiseMissing')
    line(p,'For filtering to missing animals only, use Farm > Index filter.',11,45,theme.muted)
end
render.Farm=function()
    local p=pages.Farm; clear(p)
    section(p,'OVERALL ANIMAL ESP FILTERS')
    line(p,'All animal selection rules are controlled here. Pick a mode, then choose which rarities and mutations qualify.',12,57,theme.muted)
    dropdown(p,'FILTER MODE',moneyModes,cfg.moneyMode,function(v) cfg.moneyMode=v; settingsDirty=true; render.Farm() end)
    section(p,'RARITY SELECTION')
    multiPicker(p,'RARITIES',rarities,cfg.selectedR,rc)
    section(p,'MUTATION SELECTION')
    multiPicker(p,'MUTATIONS',mutations,cfg.selectedM,mc)
    section(p,'INDEX FILTER')
    dropdown(p,'INDEX FILTER',{'Show all animals','Missing index animals only'},cfg.missingIndexOnly and 'Missing index animals only' or 'Show all animals',function(v)
        cfg.missingIndexOnly=v=='Missing index animals only'; settingsDirty=true; render.Farm()
    end)
    line(p,'Index status is based on saved collection data. If your index has not been scanned, missing status may be unknown.',11,59,theme.muted)
    section(p,'QUICK ACTIONS')
    action(p,'SELECT ALL RARITIES + MUTATIONS',function()
        for _,r in ipairs(rarities) do cfg.selectedR[r]=true end
        for _,m in ipairs(mutations) do cfg.selectedM[m]=true end
        settingsDirty=true; render.Farm()
    end)
    action(p,'CLEAR RARITIES + MUTATIONS',function()
        cfg.selectedR={}; cfg.selectedM={}; settingsDirty=true; render.Farm()
    end)
end

local playerPalette={
    {'Red','#FF5050'},{'Orange','#FF963C'},{'Yellow','#FFE05A'},{'Green','#45E18B'},
    {'Cyan','#29C7FF'},{'Blue','#548CFF'},{'Purple','#A16BFF'},{'Pink','#FF72BD'},
    {'White','#F1F5FF'},{'Gold','#FFCD23'},{'Black','#292F42'},{'Mint','#73FFBE'}
}
local function colorControl(p,title,key)
    section(p,title)
    local chosen=validHex(cfg[key]) or '#FF5050'
    local row=round(new('Frame',p,{Size=UDim2.new(1,0,0,52),BackgroundColor3=theme.panel,BorderSizePixel=0}),8)
    local swatch=round(new('Frame',row,{Size=UDim2.fromOffset(34,34),Position=UDim2.fromOffset(10,9),BackgroundColor3=color(chosen),BorderSizePixel=0}),7)
    local box=round(new('TextBox',row,{Size=UDim2.new(1,-65,0,34),Position=UDim2.fromOffset(54,9),BackgroundColor3=theme.card,TextColor3=theme.white,Text=chosen,PlaceholderText='#FF5050',ClearTextOnFocus=false,Font=Enum.Font.GothamBold,TextSize=13,BorderSizePixel=0}),7)
    box.FocusLost:Connect(function()
        local hex=validHex(box.Text)
        if hex then cfg[key]=hex; settingsDirty=true; swatch.BackgroundColor3=color(hex) end
        box.Text=cfg[key]
    end)
    local grid=new('Frame',p,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
    new('UIGridLayout',grid,{CellSize=UDim2.new(.25,-7,0,39),CellPadding=UDim2.fromOffset(8,7),SortOrder=Enum.SortOrder.LayoutOrder})
    for i,item in ipairs(playerPalette) do
        local b=btn(grid,item[1],nil,{LayoutOrder=i,BackgroundColor3=color(item[2]),TextColor3=(item[1]=='White' or item[1]=='Yellow' or item[1]=='Gold' or item[1]=='Mint') and theme.bg or theme.white,TextSize=11})
        b.MouseButton1Click:Connect(function()
            cfg[key]=item[2]; settingsDirty=true; swatch.BackgroundColor3=color(item[2]); box.Text=item[2]
        end)
    end
end
render['Player ESP']=function()
    local p=pages['Player ESP']; clear(p)
    section(p,'PLAYER ESP')
    dropdown(p,'ESP STYLE',{'Compact','Bubble Name','Detailed','Outline Only'},cfg.playerStyle,function(v) cfg.playerStyle=v; settingsDirty=true; render['Player ESP']() end)
    toggle(p,'Outline around character','playerOutline')
    toggle(p,'Body fill highlight','playerFill')
    toggle(p,'Outline visible through walls','playerThroughWalls')
    slider(p,'Head-side card offset',0,8,function() return cfg.playerHeadSide end,function(v) cfg.playerHeadSide=v end)
    section(p,'BUBBLE NAME SETTINGS')
    slider(p,'Bubble font size',16,40,function() return cfg.playerBubbleSize end,function(v) cfg.playerBubbleSize=v end)
    toggle(p,'Bubble background','playerBubbleBackground')
    toggle(p,'Bubble distance','playerBubbleDistance')
    toggle(p,'Enable Player ESP','players')
    section(p,'CARD APPEARANCE')
    toggle(p,'Auto-resize cards to visible information','playerAutoResize')
    slider(p,'Card width (pixels)',140,400,function() return cfg.playerCardWidth end,function(v) cfg.playerCardWidth=v end)
    slider(p,'Overall card scale %',50,150,function() return cfg.playerCardScale end,function(v) cfg.playerCardScale=v end)
    slider(p,'Text size',10,30,function() return cfg.playerSize end,function(v) cfg.playerSize=v end)
    slider(p,'Card transparency %',0,100,function() return math.floor(cfg.playerBG*100) end,function(v) cfg.playerBG=v/100 end)
    slider(p,'Highlight transparency %',0,100,function() return math.floor(cfg.trans*100) end,function(v) cfg.trans=v/100 end)
    colorControl(p,'CARD & HIGHLIGHT COLOUR','playerColorHex')
    local separateRow=round(new('Frame',p,{Size=UDim2.new(1,0,0,47),BackgroundColor3=theme.panel,BorderSizePixel=0}),8)
    text(separateRow,'Separate player highlight colour',12,{Size=UDim2.new(1,-100,1,0),Position=UDim2.fromOffset(14,0)})
    btn(separateRow,cfg.playerSeparateColors and 'ON' or 'OFF',function() cfg.playerSeparateColors=not cfg.playerSeparateColors; settingsDirty=true; render['Player ESP']() end,{Size=UDim2.fromOffset(68,28),Position=UDim2.new(1,-80,.5,-14),BackgroundColor3=cfg.playerSeparateColors and theme.blue or theme.card})
    if cfg.playerSeparateColors then colorControl(p,'HIGHLIGHT COLOUR','playerHighlightHex') end
    section(p,'INFORMATION')
    for _,pair in ipairs({{'Username','username'},{'Distance','distance'},{'Health','health'},{'Speed','speed'},{'Money','money'}}) do
        toggle(p,'Show '..pair[1],pair[2])
    end
    section(p,'DISTANCE')
    slider(p,'Maximum distance (studs)',100,10000,function() return cfg.playerRange end,function(v) cfg.playerRange=v end)
    toggle(p,'Unlimited player ESP range','unlimitedPlayerRange')
end

render.Animals=function()
    local p=pages.Animals; clear(p)
    section(p,'CHOOSE A COLLECTION')
    line(p,'Select a collection to open its zone index. Active collections are listed first.',12,46,theme.muted)
    local grid=new('Frame',p,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
    new('UIGridLayout',grid,{CellSize=UDim2.new(.5,-6,0,102),CellPadding=UDim2.fromOffset(10,10),SortOrder=Enum.SortOrder.LayoutOrder})
    local function collectionCard(name,order)
        local d=cache[name]; local st=d and stats(d.Entries)
        local a=st and (name=='Limited' and st.EventCollected or st.RegularCollected) or 0
        local b=st and (name=='Limited' and st.EventTotal or st.RegularTotal) or (name=='Limited' and 15 or 120)
        local c=color(mc[name] or (name=='Normal' and '#29C7FF' or '#A16BFF'))
        local tile=round(new('Frame',grid,{LayoutOrder=order,BackgroundColor3=theme.panel,BorderSizePixel=0}),9)
        border(tile,c)
        new('Frame',tile,{Position=UDim2.fromOffset(0,0),Size=UDim2.new(0,5,1,0),BackgroundColor3=c,BorderSizePixel=0})
        text(tile,name:upper(),14,{Position=UDim2.fromOffset(16,10),Size=UDim2.new(1,-28,0,24),Font=Enum.Font.GothamBold,TextColor3=theme.white})
        text(tile,string.format('%d / %d  •  %.1f%%',a,b,b>0 and a/b*100 or 0),11,{Position=UDim2.fromOffset(16,39),Size=UDim2.new(1,-28,0,20),TextColor3=theme.muted})
        local track=round(new('Frame',tile,{Position=UDim2.new(0,16,1,-21),Size=UDim2.new(1,-32,0,7),BackgroundColor3=theme.card,BorderSizePixel=0}),4)
        round(new('Frame',track,{Size=UDim2.new(b>0 and math.clamp(a/b,0,1) or 0,0,1,0),BackgroundColor3=c,BorderSizePixel=0}),4)
        btn(tile,'',function() indexZoneOpen=nil; selectedZone='ALL'; collectionView(name) end,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,TextTransparency=1})
    end
    local n=0
    for _,name in ipairs(collections) do
        if name~='Limited' then n=n+1; collectionCard(name,n) end
    end
    section(p,'LEGACY COLLECTIONS')
    line(p,'Past limited-time collections remain available to view.',11,34,theme.muted)
    n=n+1; collectionCard('Limited',n)
    section(p,'INDEX ACTIONS')
    action(p,'CAPTURE CURRENT INDEX',function() local name=detect(); if name then capture(name,'Manual') end; render.Animals() end,theme.blue)
end
render.Mutations=function()
    local p=pages.Mutations; clear(p)
    section(p,'MUTATION COLLECTIONS')
    line(p,'Choose a mutation card to open its saved index.',12,36,theme.muted)
    for _,name in ipairs(mutations) do
        local d=cache[name]; local st=d and stats(d.Entries)
        local card=bar(p,name,st and st.RegularCollected or 0,st and st.RegularTotal or 120,color(mc[name]))
        btn(card,'',function() collectionView(name) end,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,TextTransparency=1})
    end
end

local mainTab='Farm'; local espSub='Animal ESP'; local indexSub='Animals'; local panic=false; local panicBackup=nil; local awaitingKey=nil
local function subnav(p,names,active)
    local row=new('Frame',p,{Size=UDim2.new(1,0,0,40),BackgroundTransparency=1})
    new('UIListLayout',row,{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})
    for i,name in ipairs(names) do
        btn(row,name,function()
            if mainTab=='ESP' then espSub=name else indexSub=name end
            showTab(name)
        end,{Size=UDim2.new(1/#names,-(8*(#names-1))/#names,0,36),LayoutOrder=i,BackgroundColor3=name==active and theme.blue or theme.card})
    end
end
local oldAnimalRender=render['Animal ESP']; local oldPlayerRender=render['Player ESP']; local oldAnimalsRender=render.Animals; local oldMutationsRender=render.Mutations
render['Animal ESP']=function() oldAnimalRender() end
render['Player ESP']=function()
    oldPlayerRender()
    local page=pages['Player ESP']
    section(page,'DISTANCE CONTROL')
    line(page,'Set a precise range below, or enable Unlimited Range above. Unlimited removes the hub distance cutoff, but cannot reveal characters Roblox has not loaded.',11,64,theme.muted)
    local rangeRow=round(new('Frame',page,{Size=UDim2.new(1,0,0,64),BackgroundColor3=theme.panel,BorderSizePixel=0}),8)
    text(rangeRow,'Custom range (studs)',12,{Size=UDim2.new(.58,0,1,0),Position=UDim2.fromOffset(14,0)})
    local rangeBox=new('TextBox',rangeRow,{Size=UDim2.new(.32,0,0,36),Position=UDim2.new(.66,0,.5,-18),BackgroundColor3=theme.card,TextColor3=theme.white,Text=tostring(cfg.playerRange),PlaceholderText='100–10000',ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=13,BorderSizePixel=0})
    round(rangeBox,7)
    rangeBox.FocusLost:Connect(function()
        local n=tonumber(rangeBox.Text)
        if n then cfg.playerRange=math.floor(math.clamp(n,100,10000)); settingsDirty=true end
        rangeBox.Text=tostring(cfg.playerRange)
    end)
    section(page,'PLAYER SELECTION')
    line(page,'Select exactly who you want highlighted. New players are enabled by default. Players beyond your selected range are hidden unless Unlimited Range is enabled.',11,62,theme.muted)
    action(page,'SELECT ALL PLAYERS',function()
        for _,target in ipairs(P:GetPlayers()) do if target~=me then cfg.playerSelection[tostring(target.UserId)]=true end end
        settingsDirty=true; render['Player ESP']()
    end,theme.blue)
    action(page,'DESELECT ALL PLAYERS',function()
        for _,target in ipairs(P:GetPlayers()) do if target~=me then cfg.playerSelection[tostring(target.UserId)]=false end end
        settingsDirty=true; render['Player ESP']()
    end)
    local targets={}
    for _,target in ipairs(P:GetPlayers()) do if target~=me then targets[#targets+1]=target end end
    table.sort(targets,function(a,b) return a.DisplayName:lower()<b.DisplayName:lower() end)
    if #targets==0 then line(page,'No other players are currently in this server.',12,40,theme.muted) end
    for _,target in ipairs(targets) do
        local id=tostring(target.UserId)
        local char=target.Character
        local root=char and char:FindFirstChild('HumanoidRootPart')
        local hum=char and char:FindFirstChildOfClass('Humanoid')
        local dist=root and distance(root) or nil
        local status=not root and 'CHARACTER LOADING' or (not hum or hum.Health<=0) and 'NOT ALIVE' or (not cfg.unlimitedPlayerRange and dist>cfg.playerRange and 'OUT OF RANGE' or (cfg.playerSelection[id]==false and 'DISABLED' or 'IN RANGE'))
        local enabled=cfg.playerSelection[id]~=false
        local row=round(new('Frame',page,{Size=UDim2.new(1,0,0,70),BackgroundColor3=theme.panel,BorderSizePixel=0}),9)
        border(row,enabled and theme.blue or theme.border)
        text(row,target.DisplayName,13,{Size=UDim2.new(1,-112,0,25),Position=UDim2.fromOffset(13,7),Font=Enum.Font.GothamBold})
        text(row,'@'..target.Name..'  •  '..status..(dist and ('  •  '..dist..' studs') or ''),10,{Size=UDim2.new(1,-112,0,24),Position=UDim2.fromOffset(13,34),TextColor3=theme.muted})
        btn(row,enabled and 'ON' or 'OFF',function()
            cfg.playerSelection[id]=not enabled; settingsDirty=true; render['Player ESP']()
        end,{Size=UDim2.fromOffset(77,34),Position=UDim2.new(1,-91,.5,-17),BackgroundColor3=enabled and theme.blue or theme.card})
        local override=cfg.playerOverrides[id] or {}
        dropdown(page,target.DisplayName..' STYLE',{'Default','Compact','Bubble Name','Detailed','Outline Only'},override.style or 'Default',function(v)
            cfg.playerOverrides[id]=cfg.playerOverrides[id] or {}; cfg.playerOverrides[id].style=v; settingsDirty=true; render['Player ESP']()
        end)
        dropdown(page,target.DisplayName..' OUTLINE',{'Default','On','Off'},override.outline or 'Default',function(v)
            cfg.playerOverrides[id]=cfg.playerOverrides[id] or {}; cfg.playerOverrides[id].outline=v; settingsDirty=true; render['Player ESP']()
        end)
    end
    action(page,'REFRESH PLAYER LIST',function() render['Player ESP']() end,theme.card)
end
render.Animals=function() oldAnimalsRender(); subnav(pages.Animals,{'Animals','Mutations'},'Animals') end
render.Mutations=function() oldMutationsRender(); subnav(pages.Mutations,{'Animals','Mutations'},'Mutations') end
local function panicToggle()
    if not panic then
        save()
        panicBackup={rarity=cfg.rarity,mutation=cfg.mutation,players=cfg.players}
        panic=true; cfg.rarity=false; cfg.mutation=false; cfg.players=false
        for m in pairs(objects) do erase(m) end
        mode='HIDDEN'; main.Visible=false; floating.Visible=false
    else
        panic=false
        if panicBackup then
            cfg.rarity=panicBackup.rarity; cfg.mutation=panicBackup.mutation; cfg.players=panicBackup.players
        end
        panicBackup=nil; mode='EXPANDED'; main.Visible=true
        floating.Visible=false
        showTab(mainTab=='Farm' and 'Farm' or (mainTab=='ESP' and espSub or (mainTab=='Money' and 'Money' or (mainTab=='Players' and 'Player ESP' or (mainTab=='Index' and indexSub or (mainTab=='Trackers' and 'Trackers' or 'Settings'))))))
    end
end
local function keyPicker(p,title,key)
    action(p,title..': '..tostring(cfg[key]),function(b)
        awaitingKey={key=key,button=b,title=title}
        b.Text='PRESS ANY KEY (ESC TO CANCEL)'
    end,theme.blue)
end
-- Game GUI launcher: discovers local menus without assuming their internal button callbacks.
local menuHints={
 {'Shops',{'shop','store','merchant','market','purchase'}},
 {'Upgrades',{'upgrade','boost','rebirth','enchant'}},
 {'Machines',{'fuse','fusion','merge','machine','craft','combine'}},
 {'Other',{'inventory','index','mastery','reward','quest','trade','pet','egg','spin','daily'}}
}
local function classifyMenu(name)
 local lower=name:lower()
 for _,entry in ipairs(menuHints) do
  for _,hint in ipairs(entry[2]) do if lower:find(hint,1,true) then return entry[1] end end
 end
 return nil
end
local function discoverGameMenus()
 local results={}
 local mainGui=pg:FindFirstChild('MainGUI')
 if not mainGui then return results end
 local frames=mainGui:FindFirstChild('Frames')
 if not frames then return results end
 for _,child in ipairs(frames:GetChildren()) do
  if child:IsA('GuiObject') then
   local category=classifyMenu(child.Name)
   if category then results[#results+1]={name=child.Name,category=category,object=child} end
  end
 end
 table.sort(results,function(a,b)
  if a.category~=b.category then return a.category<b.category end
  return a.name:lower()<b.name:lower()
 end)
 return results
end
local function toggleGameMenu(entry)
 local target=entry.object
 if not target or not target.Parent then return false end
 if entry.name=='Mastery' then openOriginalMastery();return true end
 local desired=not target.Visible
 if desired then
  for _,sibling in ipairs(target.Parent:GetChildren()) do
   if sibling~=target and sibling:IsA('GuiObject') and sibling.Visible and classifyMenu(sibling.Name) then
    sibling.Visible=false
   end
  end
 end
 target.Visible=desired
 return true
end
render.Menus=function()
 local p=pages.Menus;clear(p)
 line(p,'GAME MENUS',22,35,theme.white)
 line(p,'Quick access to the game’s replicated menus. Only menus currently found in MainGUI are shown. Some machines may need their normal game interaction to initialise.',12,66,theme.muted)
 action(p,'REFRESH AVAILABLE MENUS',function() render.Menus() end,theme.blue)
 local entries=discoverGameMenus()
 if #entries==0 then
  line(p,'No matching in-game menu frames detected. Open a shop or machine normally, then refresh.',12,70,theme.muted)
  return
 end
 local category=''
 for _,entry in ipairs(entries) do
  if entry.category~=category then
   category=entry.category
   line(p,string.upper(category),16,30,theme.blue)
  end
  action(p,entry.name..(entry.object.Visible and '  [OPEN]' or '  [CLOSED]'),function()
   toggleGameMenu(entry)
   if p.Parent then render.Menus() end
  end,theme.card)
 end
end
local function selectorCard(p,title,description,target,tint)
    local card=new('Frame',p,{Size=UDim2.new(1,-10,0,83),BackgroundColor3=color('#101E2C'),BorderSizePixel=0})
    round(card,7);new('UIStroke',card,{Color=tint or theme.blue,Thickness=1.5,Transparency=.25})
    text(card,title,16,{Size=UDim2.new(1,-125,0,30),Position=UDim2.fromOffset(13,8),Font=Enum.Font.GothamBold})
    text(card,description,11,{Size=UDim2.new(1,-125,0,34),Position=UDim2.fromOffset(13,37),TextColor3=theme.muted,TextWrapped=true})
    btn(card,'OPEN  ›',function() showTab(target) end,{Size=UDim2.fromOffset(103,40),Position=UDim2.new(1,-115,.5,-20),BackgroundColor3=color('#145879'),TextSize=13})
end
render.ESP=function()
    local p=pages.ESP;clear(p)
    line(p,'ESP',23,38,theme.white)
    line(p,'Select which ESP you want to configure.',12,48,theme.muted)
    selectorCard(p,'ANIMAL ESP','Animal labels, rarity, mutations and visibility.','Animal ESP',theme.blue)
    selectorCard(p,'PLAYER ESP','Player highlighting, names and card appearance.','Player ESP',theme.blue)
end
render.Trackers=function()
    local p=pages.Trackers;clear(p)
    line(p,'TRACKERS',23,38,theme.white)
    line(p,'Select a tracker to open its original controls.',12,48,theme.muted)
    selectorCard(p,'PLACED ANIMALS','Track animals placed on player plots.','Placed Animals',theme.blue)
    selectorCard(p,'LIVE SPAWNS','Monitor new animal spawns and events.','Live Spawns',theme.blue)
    selectorCard(p,'EGG PREDICTOR','Prediction status and available evidence.','Egg Predictor',theme.blue)
end
render['Placed Animals']=function()
 local p=pages['Placed Animals'];clear(p)
 section(p,'PLACED ANIMAL TRACKER')
 line(p,'Shows already-hatched animals equipped on player plots. Live data from PlacedAnimals.',12,65,theme.muted)
 action(p,eggPredictorActive() and 'TRACKER: ON — DISABLE' or 'TRACKER: OFF — ENABLE',function() setEggPredictor(not eggPredictorActive());render['Placed Animals']() end,eggPredictorActive() and theme.red or theme.card)
 action(p,'OPEN PLACED ANIMALS PANEL',function() setEggPredictor(true);local g=pg:FindFirstChild('CRBF_EggPredictor');if g then g.Enabled=true end;render['Placed Animals']() end,theme.card)
end
render['Live Spawns']=function()
 local p=pages['Live Spawns'];clear(p)
 section(p,'LIVE SPAWN TRACKER')
 line(p,'Monitors Workspace.AnimalPickups only. New replicated pickups appear; removed pickups disappear. Does not list equipped plot animals.',12,83,theme.muted)
 action(p,spawnTrackerActive() and 'LIVE SPAWNS: ON — DISABLE' or 'LIVE SPAWNS: OFF — ENABLE',function() setSpawnTracker(not spawnTrackerActive());render['Live Spawns']() end,spawnTrackerActive() and theme.red or theme.card)
 action(p,'OPEN LIVE SPAWNS PANEL',function() setSpawnTracker(true);local g=pg:FindFirstChild('CRBF_LiveSpawnTracker');if g then g.Enabled=true end;render['Live Spawns']() end,theme.card)
 line(p,'Tracks client-visible pickups. If an egg hatch does not create a model in AnimalPickups, a further hatch-event diagnostic is needed.',11,75,theme.muted)
end

-- CRBF V13: Zone egg ESP. Only actual zone egg models, never nests/plot eggs.
-- Read-only client display; no hatch-result predictions or server interaction.
local ZE={enabled=false,labels=true,zone='ALL',rarity='ALL',sort='LUCK',items={},visuals={},folders={},connections={},lastScan=0,selected=nil}
local zoneEggStop
local zSuffix={K=1e3,M=1e6,B=1e9,T=1e12,Qa=1e15,Qi=1e18,Sx=1e21,Sp=1e24,Oc=1e27,No=1e30,Dc=1e33,Ud=1e36}
local function zNumber(s)
 if type(s)~='string' then return 0 end
 local a,b=s:match('x?([%d%.]+)(%a*)');return (tonumber(a) or 0)*(zSuffix[b] or 1)
end
local function zUi(m,name)
 for _,d in ipairs(m:GetDescendants()) do
  if d:IsA('TextLabel') and d.Name==name and d.Visible and d.Text~='' then return d.Text end
 end
 return nil
end
local function zRoot(m)
 return m.PrimaryPart or m:FindFirstChild('Egg',true) or m:FindFirstChildWhichIsA('BasePart',true)
end
local function zValid(m)
 return m:IsA('Model') and m.Name:lower():find('egg',1,true)~=nil and m.Name:lower():find('nest',1,true)==nil and m.Parent and m.Parent.Name=='Eggs' and m.Parent.Parent and m.Parent.Parent.Name:match('^Zone%d+$') and m.Parent.Parent.Parent and m.Parent.Parent.Parent.Name=='ZoneBuilds'
end
local function zClear(m)
 local v=ZE.visuals[m];if v then for _,o in ipairs(v) do pcall(function()o:Destroy()end) end;ZE.visuals[m]=nil end
end
local function zStopVisuals() for m in pairs(ZE.visuals) do zClear(m) end end
local function zDistance(pos)
 local c=me.Character;local r=c and c:FindFirstChild('HumanoidRootPart')
 return r and (r.Position-pos).Magnitude or 1e10
end
local function zCollect()
 local build=workspace:FindFirstChild('Build');local zones=build and build:FindFirstChild('ZoneBuilds');local all={}
 if not zones then return all end
 for _,zone in ipairs(zones:GetChildren()) do
  if zone.Name:match('^Zone%d+$') and (ZE.zone=='ALL' or ZE.zone==zone.Name) then
   local folder=zone:FindFirstChild('Eggs')
   if folder then for _,m in ipairs(folder:GetChildren()) do
    if zValid(m) then
     local ok,pos=pcall(function()return m:GetPivot().Position end)
     if ok then
      local rarity=zUi(m,'Rarity') or '?'
      if ZE.rarity=='ALL' or rarity==ZE.rarity then
       local luck=zUi(m,'LuckMulti') or '?';local hp=zUi(m,'HpAmount') or '?'
       local mutation=zUi(m,'Mutation')
       local tagged=false
       pcall(function()tagged=game:GetService('CollectionService'):HasTag(m,'LuckyEgg') end)
       all[#all+1]={m=m,zone=zone.Name,name=m.Name:gsub('^%d+:%s*',''),rarity=rarity,luck=luck,luckValue=zNumber(luck),hp=hp,mutation=mutation,tagged=tagged,pos=pos,dist=zDistance(pos)}
      end
     end
    end
   end end
  end
 end
 table.sort(all,function(a,b)
  if ZE.sort=='LUCK' then if a.luckValue~=b.luckValue then return a.luckValue>b.luckValue end end
  return a.dist<b.dist
 end)
 return all
end
local function zDraw(all)
 if not ZE.enabled then zStopVisuals();return end
 local keep={};local count=0
 -- Highlight up to 70 eggs; overhead labels for nearest 24 to avoid UI overload.
 local nearest={};for _,v in ipairs(all) do nearest[#nearest+1]=v end
 table.sort(nearest,function(a,b)return a.dist<b.dist end)
 for i,v in ipairs(nearest) do
  if i>70 then break end
  local m=v.m;local root=zRoot(m)
  if root and root:IsA('BasePart') then
   keep[m]=true;count=count+1
   local existing=ZE.visuals[m]
   if not existing then
    local hl=Instance.new('Highlight');hl.Name='CRBF_ZoneEgg_Highlight';hl.Adornee=m;hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;hl.FillTransparency=.84;hl.OutlineTransparency=.05;hl.Parent=m
    local bg=Instance.new('BillboardGui');bg.Name='CRBF_ZoneEgg_Card';bg.Adornee=root;bg.AlwaysOnTop=true;bg.Size=UDim2.fromOffset(210,68);bg.StudsOffset=Vector3.new(0,4,0);bg.MaxDistance=1500;bg.Parent=pg
    local fr=Instance.new('Frame');fr.Size=UDim2.fromScale(1,1);fr.BackgroundColor3=theme.bg;fr.BackgroundTransparency=.13;fr.Parent=bg;round(fr,7);border(fr,theme.border)
    local title=text(fr,'',12,{Size=UDim2.new(1,-10,0,21),Position=UDim2.fromOffset(6,3),Font=Enum.Font.GothamBold,TextTruncate=Enum.TextTruncate.AtEnd})
    local detail=text(fr,'',11,{Size=UDim2.new(1,-10,0,39),Position=UDim2.fromOffset(6,24),TextWrapped=true,TextColor3=theme.green})
    existing={hl,bg,title,detail};ZE.visuals[m]=existing
   end
   existing[1].OutlineColor=rc[v.rarity] and color(rc[v.rarity]) or theme.red
   existing[3].Text=v.name..'  ['..v.zone..']'
   existing[3].TextColor3=existing[1].OutlineColor
   existing[4].Text=v.luck..'\n'..v.rarity..(v.tagged and '  LUCKY' or '')
   existing[2].Enabled=ZE.labels and i<=24
  end
 end
 for m in pairs(ZE.visuals) do if not keep[m] then zClear(m) end end
end
local function zRefresh()
 if not live then return end
 ZE.items=zCollect();zDraw(ZE.items)
end
local function zCycleZone()
 local zones={'ALL'};local b=workspace:FindFirstChild('Build');local folder=b and b:FindFirstChild('ZoneBuilds')
 if folder then for _,v in ipairs(folder:GetChildren()) do if v.Name:match('^Zone%d+$') then zones[#zones+1]=v.Name end end end
 table.sort(zones,function(a,b)if a=='ALL' then return true elseif b=='ALL' then return false end;return (tonumber(a:match('%d+')) or 0)<(tonumber(b:match('%d+')) or 0) end)
 for i,v in ipairs(zones) do if v==ZE.zone then ZE.zone=zones[i%#zones+1];return end end
 ZE.zone='ALL'
end
render['Zone Eggs']=function()
 local p=pages['Zone Eggs'];clear(p)
 section(p,'ZONE EGG ESP  |  V13')
 line(p,'Live zone eggs only. Plots and nests excluded. No unverified hatch predictions.',11,55,theme.muted)
 action(p,ZE.enabled and 'EGG ESP: ON — DISABLE' or 'EGG ESP: OFF — ENABLE',function()ZE.enabled=not ZE.enabled;zRefresh();render['Zone Eggs']()end,ZE.enabled and theme.red or theme.card)
 action(p,'ZONE: '..ZE.zone..'  (CHANGE)',function()zCycleZone();zRefresh();render['Zone Eggs']()end,theme.card)
 action(p,'RARITY: '..ZE.rarity..'  (CHANGE)',function()
  local opts={'ALL'};for _,r in ipairs(rarities) do opts[#opts+1]=r end
  for i,r in ipairs(opts) do if ZE.rarity==r then ZE.rarity=opts[i%#opts+1];break end end
  zRefresh();render['Zone Eggs']()
 end,theme.card)
 action(p,'SORT: '..ZE.sort..'  (TOGGLE)',function()ZE.sort=ZE.sort=='LUCK' and 'DISTANCE' or 'LUCK';zRefresh();render['Zone Eggs']()end,theme.card)
 action(p,'OVERHEAD LABELS: '..(ZE.labels and 'ON' or 'OFF'),function()ZE.labels=not ZE.labels;zRefresh();render['Zone Eggs']()end,theme.card)
 action(p,'REFRESH EGGS',function()zRefresh();render['Zone Eggs']()end,theme.card)
 section(p,'VISIBLE EGGS  |  '..#ZE.items..' MATCHES')
 line(p,'Luck is the game-displayed multiplier, NOT a verified chance of a rare hatch. Showing up to 40 eggs.',11,49,theme.muted)
 for i,v in ipairs(ZE.items) do
  if i>40 then break end
  local mark=v.tagged and ' [LUCKY TAG]' or ''
  line(p,v.zone..'  '..v.name..mark..'  •  '..v.rarity..'\n'..v.luck..'  |  '..math.floor(v.dist)..' studs  |  '..v.hp,11,53,rc[v.rarity] and color(rc[v.rarity]) or theme.white)
 end
 if #ZE.items==0 then line(p,'No eggs found for these filters. Try ALL zones and ALL rarities.',12,50,theme.muted) end
end
zoneEggStop=function()zStopVisuals()end
-- Refresh ESP every 2.5 seconds; refresh the list only while its page is open.
task.spawn(function()
 while live do
  if ZE.enabled or tab=='Zone Eggs' then
   local ok,err=pcall(zRefresh)
   if not ok then warn('[CRBF Zone Eggs]',err) end
   if tab=='Zone Eggs' and mode=='EXPANDED' and not panic then pcall(render['Zone Eggs']) end
  end
  task.wait(2.5)
 end
end)

render['Egg Predictor']=function()
 local p=pages['Egg Predictor'];clear(p)
 section(p,'EGG PREDICTOR')
 line(p,'Prediction of unopened egg contents is not yet verified. Existing plot animals are now correctly labelled Placed Animals.',12,85,theme.muted)
 line(p,'We need evidence of an egg-to-animal mapping before predicting contents. No made-up predictions will be shown.',12,70,theme.muted)
end
render.Settings=function()
    local p=pages.Settings; clear(p)
    section(p,'Settings')
    section(p,'INTERFACE & CONVENIENCE')
    toggle(p,'Auto-close Invite Friends popup','autoCloseInvites')
    line(p,'Experimental: dismisses detected Roblox invite dialogs with Escape. OFF by default; may not work if CoreGui is inaccessible.',11,62,theme.muted)
    section(p,'ANTI-AFK / IDLE')
    toggle(p,'Enable anti-idle input','antiAFK')
    line(p,'Uses VirtualUser on Roblox idle events when supported. Cannot guarantee against server or game-specific AFK kicks.',11,65,theme.muted)
    section(p,'FLOATING BUTTONS')
    toggle(p,'Show floating Mastery button','masteryShortcut')
    action(p,'SAVE + VERIFY',function() save() end,theme.blue)
    line(p,'Customise your shortcuts. Keys are saved automatically.',12,48,theme.muted)
    section(p,'Keyboard shortcuts')
    keyPicker(p,'Hide / Show Hub','hideKey')
    keyPicker(p,'PANIC — Disable everything','panicKey')
    line(p,'Panic instantly removes ESP and hides the hub. Press the panic key again to restore your previous ESP settings.',12,72,theme.muted)
    section(p,'Emergency controls')
    action(p,panic and 'RESTORE ALL FEATURES' or 'PANIC NOW',panicToggle,theme.red)
    action(p,'RESET SHORTCUTS',function() cfg.hideKey='K'; cfg.panicKey='P'; settingsDirty=true; render.Settings() end)
    section(p,'APPEARANCE')
    slider(p,'Interface scale %',70,120,function() return cfg.uiScale or 100 end,function(v) cfg.uiScale=v; if uiScaler then uiScaler.Scale=v/100 end end)
    slider(p,'Panel transparency %',0,60,function() return cfg.uiOpacity or 10 end,function(v) cfg.uiOpacity=v; main.BackgroundTransparency=0 end)
    section(p,'NEON ACCENT RGB')
    for _,spec in ipairs({{'Red','accentR'}, {'Green','accentG'}, {'Blue','accentB'}}) do
        slider(p,spec[1],0,255,function() return cfg[spec[2]] end,function(v) cfg[spec[2]]=v; theme.blue=Color3.fromRGB(cfg.accentR or 38,cfg.accentG or 214,cfg.accentB or 245) end)
    end
    section(p,'Storage')
    line(p,'Your existing index cache and ESP preferences are retained. Saving does not overwrite the previous version files.',12,68,theme.muted)
end
local persistentBack
local childParent={['Animal ESP']='ESP',['Player ESP']='ESP',['Placed Animals']='Trackers',['Live Spawns']='Trackers',['Egg Predictor']='Trackers'}
showTab=function(name)
    if not pages[name] or not render[name] then return end
    tab=name
    if name=='Farm' then mainTab='Farm'
    elseif name=='ESP' or name=='Animal ESP' or name=='Player ESP' then mainTab='ESP'
    elseif name=='Money' then mainTab='Money'
    elseif name=='Animals' or name=='Mutations' then mainTab='Index';indexSub=name
    elseif name=='Trackers' or childParent[name]=='Trackers' then mainTab='Trackers'
    elseif name=='Menus' or name=='Settings' then mainTab='Settings' end
    for n,p in pairs(pages) do p.Visible=mode=='EXPANDED' and n==name end
    local active=childParent[name] or name
    if active=='Animals' then active='Animals' end
    for n,b in pairs(nav) do b.BackgroundColor3=n==active and color('#177EA8') or color('#214D6C') end
    render[name]()
    -- Persistent back control is attached to body, not the scrolling page.
    if persistentBack then
        local parent=childParent[name]
        persistentBack.Visible=parent~=nil
        if parent then persistentBack.Text='‹  BACK TO '..string.upper(parent) end
    end
    pages[name].CanvasPosition=Vector2.new(0,0)
end
-- Fixed-position navigation bar, always visible while child settings scroll.
persistentBack=btn(body,'‹  BACK',function() local parent=childParent[tab]; if parent then showTab(parent) end end,{Name='PersistentBack',Size=UDim2.new(1,-28,0,37),Position=UDim2.fromOffset(14,8),BackgroundColor3=color('#18415C'),TextSize=13,Visible=false,ZIndex=25})
for child in pairs(childParent) do
    local page=pages[child]
    page.Position=UDim2.fromOffset(14,51)
    page.Size=UDim2.new(1,-28,1,-64)
end
-- No tiny footer search box: navigation is now organised into clear category landing pages.
for i,item in ipairs({{'Farm','FARM'},{'ESP','ESP'},{'Money','MONEY'},{'Animals','INDEX'},{'Trackers','TRACKERS'}}) do
    local name,label=item[1],item[2]
    nav[name]=btn(sidebar,label,function() showTab(name) end,{Size=UDim2.new(1,0,0,48),LayoutOrder=i,BackgroundColor3=color('#214D6C'),TextXAlignment=Enum.TextXAlignment.Center,TextSize=14}); border(nav[name],theme.border); new('UIGradient',nav[name],{Color=ColorSequence.new(color('#37BCE3'),color('#173F65')),Rotation=90})
end
-- Right-hand quick navigation inspired by Chilli Hub's split menu.
for i,item in ipairs({{'Dashboard','DASHBOARD'},{'Mutations','MUTATIONS'},{'Menus','GAME MENUS'},{'Settings','SETTINGS'}}) do
    local quick=btn(rightbar,item[2],function() showTab(item[1]) end,{Size=UDim2.new(1,0,0,48),LayoutOrder=i,BackgroundColor3=color('#214D6C'),TextSize=14}); border(quick,theme.border); new('UIGradient',quick,{Color=ColorSequence.new(color('#37BCE3'),color('#173F65')),Rotation=90})
end
local function setMode(v) mode=v; main.Visible=v=='EXPANDED'; floating.Visible=v=='MINIMIZED'; for n,p in pairs(pages) do p.Visible=v=='EXPANDED' and n==tab end end
btn(head,'−',function() setMode('MINIMIZED') end,{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-78,0,14)}); local close=btn(head,'X',nil,{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-40,0,14),BackgroundColor3=theme.red});
local function drag(handle,target) local moving=false; local moved=false; local start; local origin; listen(handle.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then moving=true; moved=false; start=i.Position; origin=target.Position end end); listen(U.InputChanged,function(i) if moving and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-start; if d.Magnitude>5 then moved=true end; target.Position=UDim2.new(origin.X.Scale,origin.X.Offset+d.X,origin.Y.Scale,origin.Y.Offset+d.Y) end end); listen(U.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then moving=false end end); return function() return moved end end
 drag(head,main); local wasMoved=drag(floating,floating); floating.MouseButton1Click:Connect(function() if not wasMoved() and not panic then setMode('EXPANDED') end end)
listen(U.InputBegan,function(i,processed)
    if not live or i.UserInputType~=Enum.UserInputType.Keyboard then return end
    if awaitingKey then
        local selected=i.KeyCode.Name
        if selected~='Escape' and selected~='Unknown' then
            if selected~=cfg[awaitingKey.key=='hideKey' and 'panicKey' or 'hideKey'] then
                cfg[awaitingKey.key]=selected; settingsDirty=true
            end
        end
        awaitingKey=nil; render.Settings(); return
    end
    if processed or U:GetFocusedTextBox() then return end
    if i.KeyCode.Name==cfg.panicKey then panicToggle(); return end
    if panic then return end
    if i.KeyCode.Name==cfg.hideKey then setMode(mode=='HIDDEN' and 'EXPANDED' or 'HIDDEN') end
end)
-- Minimal footer; resizing uses the lower-right grip instead of a large button.
local grip=btn(main,'◢',nil,{Name='ResizeGrip',Size=UDim2.fromOffset(28,26),Position=UDim2.new(1,-30,1,-28),BackgroundColor3=theme.side,TextColor3=theme.blue,TextSize=20,AutoButtonColor=false})
local resizing=false;local resizeStart;local resizeSize
listen(grip.InputBegan,function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 then resizing=true;resizeStart=input.Position;resizeSize=main.AbsoluteSize end
end)
listen(U.InputChanged,function(input)
 if resizing and input.UserInputType==Enum.UserInputType.MouseMovement then
  local d=input.Position-resizeStart
  main.Size=UDim2.fromOffset(math.clamp(resizeSize.X+d.X,590,1080),math.clamp(resizeSize.Y+d.Y,420,800))
 end
end)
listen(U.InputEnded,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then resizing=false end end)
-- Experimental invite-dialog watcher: only sends Escape after identifying a visible
-- CoreGui dialog with an Invite Friends heading. Never closes unrelated dialogs.
local inviteLast=0
local function visibleInviteDialog()
    local ok,core=pcall(function() return game:GetService('CoreGui') end)
    if not ok or not core then return false end
    local scanned=0
    local okScan,result=pcall(function()
        for _,node in ipairs(core:GetDescendants()) do
            scanned=scanned+1; if scanned>12000 then break end
            if node:IsA('TextLabel') and node.Text=='Invite Friends' then
                local ancestor=node.Parent
                while ancestor and ancestor~=core do
                    if ancestor:IsA('GuiObject') and not ancestor.Visible then break end
                    if ancestor:IsA('ScreenGui') and not ancestor.Enabled then break end
                    ancestor=ancestor.Parent
                end
                if ancestor==core then return true end
            end
        end
        return false
    end)
    return okScan and result or false
end

task.spawn(function()
    while live do
        task.wait(.45)
        if cfg.autoCloseInvites and os.clock()-inviteLast>2 and visibleInviteDialog() then
            inviteLast=os.clock()
            pcall(function()
                local vim=game:GetService('VirtualInputManager')
                vim:SendKeyEvent(true,Enum.KeyCode.Escape,false,game)
                task.wait(.06)
                vim:SendKeyEvent(false,Enum.KeyCode.Escape,false,game)
            end)
        end
    end
end)


-- V24: compact Player ESP controls inspired by Chilli's selection grids.
-- Gameplay callbacks and saved configuration keys remain unchanged.
function v24Title(parent,title,subtitle)
    local box=new('Frame',parent,{Size=UDim2.new(1,0,0,subtitle and 76 or 36),BackgroundColor3=color('#112638'),BorderSizePixel=0})
    round(box,7);new('UIStroke',box,{Color=theme.blue,Thickness=1,Transparency=.55})
    text(box,title,19,{Size=UDim2.new(1,-18,0,30),Position=UDim2.fromOffset(10,5),Font=Enum.Font.GothamBold})
    if subtitle then text(box,subtitle,13,{Size=UDim2.new(1,-20,0,34),Position=UDim2.fromOffset(10,37),TextColor3=color('#D0E7F4'),TextWrapped=true}) end
end
function v24Label(parent,s)
    local r=new('Frame',parent,{Size=UDim2.new(1,0,0,25),BackgroundTransparency=1})
    text(r,s,13,{Size=UDim2.new(1,-8,1,0),Position=UDim2.fromOffset(4,0),Font=Enum.Font.GothamBold})
end
function v24Grid(parent,items,cols,handler)
    local rows=math.ceil(#items/cols)
    local h=rows*37+math.max(0,rows-1)*6
    local holder=new('Frame',parent,{Size=UDim2.new(1,0,0,h),BackgroundTransparency=1})
    new('UIGridLayout',holder,{CellSize=UDim2.new(1/cols,-(6*(cols-1))/cols,0,37),CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder})
    for i,item in ipairs(items) do
        local label,key,selected=item[1],item[2],item[3]
        local b=btn(holder,label,nil,{LayoutOrder=i,TextSize=12,Font=Enum.Font.GothamBold,BackgroundColor3=selected and color('#176B77') or color('#182B3E'),TextColor3=theme.white})
        border(b,selected and theme.blue or theme.border)
        b.MouseButton1Click:Connect(function() handler(key) end)
    end
end
function v24Switch(parent,label,key)
    local r=new('Frame',parent,{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1})
    text(r,label,12,{Size=UDim2.new(1,-80,1,0),Position=UDim2.fromOffset(5,0)})
    local b=btn(r,cfg[key] and 'ON' or 'OFF',nil,{Size=UDim2.fromOffset(60,27),Position=UDim2.new(1,-66,0,3),TextSize=12,BackgroundColor3=cfg[key] and color('#12A98C') or color('#36465C')})
    b.MouseButton1Click:Connect(function()
        cfg[key]=not cfg[key];settingsDirty=true
        b.Text=cfg[key] and 'ON' or 'OFF';b.BackgroundColor3=cfg[key] and color('#12A98C') or color('#36465C')
    end)
end
function v24Slider(parent,label,minv,maxv,get,set)
    local r=new('Frame',parent,{Size=UDim2.new(1,0,0,53),BackgroundTransparency=1})
    text(r,label,12,{Size=UDim2.new(.65,0,0,22),Position=UDim2.fromOffset(5,0)})
    local value=new('TextBox',r,{Size=UDim2.fromOffset(67,24),Position=UDim2.new(1,-72,0,0),BackgroundColor3=color('#21374A'),TextColor3=theme.white,Font=Enum.Font.GothamBold,TextSize=12,ClearTextOnFocus=false,BorderSizePixel=0})
    round(value,5)
    local track=round(new('Frame',r,{Size=UDim2.new(1,-24,0,7),Position=UDim2.fromOffset(12,37),BackgroundColor3=color('#334358'),BorderSizePixel=0}),4)
    local fill=round(new('Frame',track,{BackgroundColor3=theme.blue,BorderSizePixel=0}),4)
    local dot=round(new('Frame',track,{Size=UDim2.fromOffset(14,14),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=theme.white,BorderSizePixel=0}),7)
    local function update(v)
        v=math.floor(math.clamp(v,minv,maxv)+.5);set(v);settingsDirty=true
        value.Text=tostring(v)
        local ratio=(v-minv)/(maxv-minv)
        fill.Size=UDim2.fromScale(ratio,1);dot.Position=UDim2.fromScale(ratio,.5)
    end
    update(get())
    value.FocusLost:Connect(function() update(tonumber(value.Text) or get()) end)
    local hit=new('TextButton',r,{Size=UDim2.new(1,-12,0,25),Position=UDim2.fromOffset(6,27),BackgroundTransparency=1,Text=''})
    local moving=false
    local function at(x)
        if track.AbsoluteSize.X>0 then update(minv+(maxv-minv)*math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)) end
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then moving=true;at(i.Position.X) end
    end)
    local c1=U.InputChanged:Connect(function(i)
        if moving and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then at(i.Position.X) end
    end)
    local c2=U.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then moving=false end
    end)
    r.Destroying:Once(function() c1:Disconnect();c2:Disconnect() end)
end
function v24SliderPair(parent,items)
    local row=new('Frame',parent,{Size=UDim2.new(1,0,0,57),BackgroundTransparency=1})
    for i,item in ipairs(items) do
        local half=new('Frame',row,{Size=UDim2.new(.5,-5,1,0),Position=UDim2.new((i-1)*.5,(i-1)*10,0,0),BackgroundTransparency=1})
        v24Slider(half,item[1],item[2],item[3],item[4],item[5])
    end
end
local v24Colors={'#FF5050','#FF963C','#FFE05A','#45E18B','#29C7FF','#548CFF','#A16BFF','#FF72BD','#F1F5FF','#FFCD23','#292F42','#73FFBE'}
function v24ColorsRow(parent,key)
    local row=new('Frame',parent,{Size=UDim2.new(1,0,0,69),BackgroundTransparency=1})
    local grid=new('Frame',row,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1})
    new('UIGridLayout',grid,{CellSize=UDim2.fromOffset(31,29),CellPadding=UDim2.fromOffset(7,5),SortOrder=Enum.SortOrder.LayoutOrder})
    local buttons={}
    local function refresh()
        for _,entry in ipairs(buttons) do entry.stroke.Color=(cfg[key]==entry.hex) and theme.white or theme.border;entry.stroke.Thickness=(cfg[key]==entry.hex) and 3 or 1 end
    end
    for i,hex in ipairs(v24Colors) do
        local b=btn(grid,'',nil,{LayoutOrder=i,Size=UDim2.fromOffset(31,29),BackgroundColor3=color(hex),Text=''})
        local stroke=new('UIStroke',b,{Color=theme.border,Thickness=1})
        buttons[#buttons+1]={hex=hex,stroke=stroke}
        b.MouseButton1Click:Connect(function() cfg[key]=hex;settingsDirty=true;refresh() end)
    end
    refresh()
end
render['Player ESP']=function()
    local p=pages['Player ESP'];clear(p)
    v24Title(p,'PLAYER ESP','Choose a display style and the information you want to see.')
    v24Switch(p,'Enable Player ESP','players')
    v24Label(p,'DISPLAY STYLE')
    local styles={'Compact','Bubble Name','Detailed','Outline Only'}
    local styleItems={}
    for _,style in ipairs(styles) do styleItems[#styleItems+1]={style,style,cfg.playerStyle==style} end
    v24Grid(p,styleItems,2,function(style) cfg.playerStyle=style;settingsDirty=true;render['Player ESP']() end)
    v24Label(p,'PLAYER INFORMATION')
    local info={{'Username','username'},{'Distance','distance'},{'Health','health'},{'Speed','speed'},{'Money','money'}}
    local selected={}
    for _,item in ipairs(info) do selected[#selected+1]={item[1],item[2],cfg[item[2]]} end
    v24Grid(p,selected,3,function(key) cfg[key]=not cfg[key];settingsDirty=true;render['Player ESP']() end)
    v24Label(p,'HIGHLIGHT')
    v24Grid(p,{{'Outline','playerOutline',cfg.playerOutline},{'Body fill','playerFill',cfg.playerFill},{'Through walls','playerThroughWalls',cfg.playerThroughWalls}},3,function(key)
        cfg[key]=not cfg[key];settingsDirty=true;render['Player ESP']()
    end)
    v24Label(p,'APPEARANCE')
    if cfg.playerStyle=='Bubble Name' then
        v24SliderPair(p,{{'Font size',16,40,function() return cfg.playerBubbleSize end,function(v) cfg.playerBubbleSize=v end},{'Text size',10,30,function() return cfg.playerSize end,function(v) cfg.playerSize=v end}})
        v24Grid(p,{{'Background','playerBubbleBackground',cfg.playerBubbleBackground},{'Show distance','playerBubbleDistance',cfg.playerBubbleDistance}},2,function(key)
            cfg[key]=not cfg[key];settingsDirty=true;render['Player ESP']()
        end)
    else
        v24SliderPair(p,{{'Card width',140,400,function() return cfg.playerCardWidth end,function(v) cfg.playerCardWidth=v end},{'Card scale %',50,150,function() return cfg.playerCardScale end,function(v) cfg.playerCardScale=v end}})
        v24SliderPair(p,{{'Text size',10,30,function() return cfg.playerSize end,function(v) cfg.playerSize=v end},{'Card opacity %',0,100,function() return math.floor((1-cfg.playerBG)*100) end,function(v) cfg.playerBG=1-v/100 end}})
    end
    v24Label(p,'ESP COLOUR')
    v24ColorsRow(p,'playerColorHex')
    v24Label(p,'RANGE & ADVANCED')
    v24SliderPair(p,{{'Max distance',100,10000,function() return cfg.playerRange end,function(v) cfg.playerRange=v end},{'Fill opacity %',0,100,function() return math.floor((1-cfg.trans)*100) end,function(v) cfg.trans=1-v/100 end}})
    v24Switch(p,'Unlimited range','unlimitedPlayerRange')
    v24Switch(p,'Auto-resize cards','playerAutoResize')
    v24Switch(p,'Separate highlight colour','playerSeparateColors')
    if cfg.playerSeparateColors then v24ColorsRow(p,'playerHighlightHex') end
    v24SliderPair(p,{{'Card offset',0,8,function() return cfg.playerHeadSide end,function(v) cfg.playerHeadSide=v end},{'Bubble font',16,40,function() return cfg.playerBubbleSize end,function(v) cfg.playerBubbleSize=v end}})
    v24Label(p,'PLAYER SELECTION')
    local targets={}
    for _,target in ipairs(P:GetPlayers()) do if target~=me then targets[#targets+1]=target end end
    table.sort(targets,function(a,b) return a.DisplayName:lower()<b.DisplayName:lower() end)
    if #targets==0 then line(p,'No other players in this server.',11,31,theme.muted) else
        local items={}
        for _,target in ipairs(targets) do
            local id=tostring(target.UserId)
            items[#items+1]={target.DisplayName,id,cfg.playerSelection[id]~=false}
        end
        v24Grid(p,items,2,function(id)
            cfg.playerSelection[id]=not (cfg.playerSelection[id]~=false)
            settingsDirty=true;render['Player ESP']()
        end)
    end
end


-- V25: Shared compact component system across main pages.
function v25Action(p,label,callback)
    v24Grid(p,{{label,label,false}},1,function() callback() end)
end
function v25Select(p,title,description,entries)
    v24Title(p,title,description)
    local items={}
    for _,entry in ipairs(entries) do items[#items+1]={entry[1],entry[1],false} end
    v24Grid(p,items,2,function(label)
        for _,entry in ipairs(entries) do if entry[1]==label then entry[2]() return end end
    end)
end
render['Animal ESP']=function()
    local p=pages['Animal ESP'];clear(p)
    v24Title(p,'ANIMAL ESP','Select animal label information, appearance and collection highlights.')
    v24Label(p,'DISPLAY INFORMATION')
    v24Grid(p,{{'Rarity','rarity',cfg.rarity},{'Mutation','mutation',cfg.mutation},{'Income','showAnimalIncome',cfg.showAnimalIncome},{'Index status','showIndexStatus',cfg.showIndexStatus}},2,function(key)
        cfg[key]=not cfg[key];settingsDirty=true;render['Animal ESP']()
    end)
    v24Label(p,'COLLECTION HIGHLIGHTS')
    v24Grid(p,{{'Highlight missing','prioritiseMissing',cfg.prioritiseMissing}},2,function(key)
        cfg[key]=not cfg[key];settingsDirty=true;render['Animal ESP']()
    end)
    v24Label(p,'APPEARANCE & RANGE')
    v24SliderPair(p,{{'Text size',10,30,function()return cfg.animalSize end,function(v)cfg.animalSize=v end},{'Card opacity %',0,100,function()return math.floor((1-cfg.animalBG)*100) end,function(v)cfg.animalBG=1-v/100 end}})
    v24SliderPair(p,{{'Max distance',100,5000,function()return cfg.animalRange end,function(v)cfg.animalRange=v end}})
end
render['Placed Animals']=function()
    local p=pages['Placed Animals'];clear(p)
    v24Title(p,'PLACED ANIMALS','View animals currently equipped on player plots.')
    v24Label(p,'TRACKER CONTROLS')
    v24Grid(p,{{eggPredictorActive() and 'DISABLE TRACKER' or 'ENABLE TRACKER','toggle',eggPredictorActive()},{'OPEN TRACKER PANEL','open',false}},2,function(key)
        if key=='toggle' then setEggPredictor(not eggPredictorActive()) else setEggPredictor(true);local g=pg:FindFirstChild('CRBF_EggPredictor');if g then g.Enabled=true end end
        render['Placed Animals']()
    end)
end
render['Live Spawns']=function()
    local p=pages['Live Spawns'];clear(p)
    v24Title(p,'LIVE SPAWNS','Track client-visible animal pickups as they appear in the world.')
    v24Label(p,'TRACKER CONTROLS')
    v24Grid(p,{{spawnTrackerActive() and 'DISABLE TRACKER' or 'ENABLE TRACKER','toggle',spawnTrackerActive()},{'OPEN SPAWN PANEL','open',false}},2,function(key)
        if key=='toggle' then setSpawnTracker(not spawnTrackerActive()) else setSpawnTracker(true);local g=pg:FindFirstChild('CRBF_LiveSpawnTracker');if g then g.Enabled=true end end
        render['Live Spawns']()
    end)
end
render['Egg Predictor']=function()
    local p=pages['Egg Predictor'];clear(p)
    v24Title(p,'EGG PREDICTOR','Prediction requires verified egg-to-animal data. No fabricated results.')
    v24Label(p,'STATUS')
    line(p,'No verified prediction source available yet.',13,38,color('#D0E7F4'))
end
render.Trackers=function()
    local p=pages.Trackers;clear(p)
    v25Select(p,'TRACKERS','Choose a tracker to view or configure.',{{'PLACED ANIMALS',function()showTab('Placed Animals')end},{'LIVE SPAWNS',function()showTab('Live Spawns')end},{'EGG PREDICTOR',function()showTab('Egg Predictor')end}})
end
render.ESP=function()
    local p=pages.ESP;clear(p)
    v25Select(p,'ESP','Select the type of ESP you want to configure.',{{'ANIMAL ESP',function()showTab('Animal ESP')end},{'PLAYER ESP',function()showTab('Player ESP')end}})
end
-- Explicit paths verified by the GUI inspector and launcher test.
local menuSpecs={
    {'MERGE PETS','MainGUI','Frames','MergeMachine'},
    {'FUSE MACHINE','SciFi UI',nil,'SciFiTradeInMain'},
    {'GEMS SHOP','DiamondShop','Frames','GemShop'},
    {'PICKAXE SHOP','MainGUI','Frames','Pickaxes'},
    {'TRAILS SHOP','MainGUI','Frames','Trails'},
    {'MASTERY','MainGUI','Frames','Mastery'}
}
local menuCloseBound={}
function v25MenuTarget(spec)
    local root=pg:FindFirstChild(spec[2]);if not root then return nil end
    if spec[3] then root=root:FindFirstChild(spec[3]);if not root then return nil end end
    return root:FindFirstChild(spec[4])
end
function v25BindClose(spec,target)
    if not target or menuCloseBound[target] then return end
    local top=target:FindFirstChild('TopBar')
    local closeButton=top and top:FindFirstChild('Close',true)
    if closeButton and closeButton:IsA('GuiButton') then
        local connection=closeButton.Activated:Connect(function()
            task.defer(function() if live and target.Parent then target.Visible=false end end)
        end)
        menuCloseBound[target]=connection
        table.insert(con,connection)
    end
end
function v25ToggleMenu(spec)
    local target=v25MenuTarget(spec)
    if not target or not target:IsA('GuiObject') then return false end
    v25BindClose(spec,target)
    if spec[1]=='MASTERY' then openOriginalMastery() else target.Visible=not target.Visible end
    return true
end
render.Menus=function()
    local p=pages.Menus;clear(p)
    v24Title(p,'GAME MENUS','Open the original in-game shops and machines from anywhere.')
    v24Label(p,'MACHINES')
    v24Grid(p,{{'MERGE PETS',1,false},{'FUSE MACHINE',2,false}},2,function(i)v25ToggleMenu(menuSpecs[i])end)
    v24Label(p,'SHOPS')
    v24Grid(p,{{'GEMS SHOP',3,false},{'PICKAXE SHOP',4,false},{'TRAILS SHOP',5,false}},2,function(i)v25ToggleMenu(menuSpecs[i])end)
    v24Label(p,'OTHER')
    v24Grid(p,{{'MASTERY',6,false}},2,function(i)v25ToggleMenu(menuSpecs[i])end)
end
-- Hook close buttons even if the menu is opened from elsewhere.
for _,spec in ipairs(menuSpecs) do v25BindClose(spec,v25MenuTarget(spec)) end
-- Original Settings renderer retained in render table; no extra local binding needed
render.Settings=function()
    local p=pages.Settings;clear(p)
    v24Title(p,'SETTINGS','Quick controls, floating shortcuts and hub preferences.')
    v24Label(p,'CONVENIENCE')
    v24Switch(p,'Auto-close invite popup','autoCloseInvites')
    v24Switch(p,'Anti-idle','antiAFK')
    v24Label(p,'FLOATING SHORTCUTS')
    v24Switch(p,'Show Mastery shortcut','masteryShortcut')
    v24Label(p,'INTERFACE')
    v24SliderPair(p,{{'Hub scale %',70,120,function()return cfg.uiScale or 100 end,function(v)cfg.uiScale=v;if uiScaler then uiScaler.Scale=v/100 end end},{'Panel opacity %',0,60,function()return cfg.uiOpacity or 10 end,function(v)cfg.uiOpacity=v end}})
    v24Label(p,'ACTIONS')
    v24Grid(p,{{'SAVE + VERIFY','save',false},{panic and 'RESTORE FEATURES' or 'PANIC NOW','panic',false}},2,function(k)
        if k=='save' then save() else panicToggle() end
    end)
    v24Label(p,'KEYBOARD SHORTCUTS')
    keyPicker(p,'Hide / Show Hub','hideKey')
    keyPicker(p,'Emergency toggle','panicKey')
end
-- Lightweight visual refresh of pages with established gameplay logic.
render._crbfOriginalFarm=render.Farm
render.Farm=function()
    render._crbfOriginalFarm()
    local p=pages.Farm
    for _,child in ipairs(p:GetChildren()) do
        if child:IsA('GuiObject') and child:GetAttribute('CRBFSectionHeading') then child.Visible=false;child.Size=UDim2.fromOffset(0,0) end
    end
    local title=new('Frame',p,{Size=UDim2.new(1,0,0,76),BackgroundColor3=color('#112638'),BorderSizePixel=0,LayoutOrder=-900})
    round(title,7);new('UIStroke',title,{Color=theme.blue,Thickness=1,Transparency=.55})
    text(title,'FARM FILTERS',19,{Size=UDim2.new(1,-20,0,30),Position=UDim2.fromOffset(10,5),Font=Enum.Font.GothamBold})
    text(title,'Choose animal filters, rarities and mutations.',13,{Size=UDim2.new(1,-20,0,34),Position=UDim2.fromOffset(10,37),TextColor3=color('#D0E7F4')})
end

local function stop() if not live then return end; live=false; if _G.CRBFAnimalTrackerV1 and type(_G.CRBFAnimalTrackerV1.close)=='function' then pcall(_G.CRBFAnimalTrackerV1.close) end; indexSyncDisconnect(); if zoneEggStop then zoneEggStop() end; setEggPredictor(false);setSpawnTracker(false); if panic and panicBackup then cfg.rarity=panicBackup.rarity; cfg.mutation=panicBackup.mutation; cfg.players=panicBackup.players end; save(); for _,c in ipairs(con) do c:Disconnect() end; for m in pairs(objects) do erase(m) end; gui:Destroy(); if _G.CRBFOpenMasteryMenu==openOriginalMastery then _G.CRBFOpenMasteryMenu=nil end end
close.MouseButton1Click:Connect(stop)
showTab('Dashboard')
listen(P.PlayerAdded,function()
    if tab=='Player ESP' and live then task.defer(function() if live and tab=='Player ESP' then render['Player ESP']() end end) end
end)
listen(P.PlayerRemoving,function(target)
    if target.Character then erase(target.Character) end
    if tab=='Player ESP' and live then task.defer(function() if live and tab=='Player ESP' then render['Player ESP']() end end) end
end)
task.spawn(function() while live do local ok,err=pcall(animalESP); if not ok then warn('[EggHub Animal ESP]',err) end; task.wait(.3) end end)
task.spawn(function() while live do local ok,err=pcall(playerESP); if not ok then warn('[EggHub Player ESP]',err) end; task.wait(.3) end end)
task.spawn(function()
 while live do
  local ok,err=pcall(indexSyncTick)
  if not ok then warn('[CRBF Live Index Sync]',err) end
  task.wait(.25)
 end
 indexSyncDisconnect()
end)
task.spawn(function() while live do if dirty or settingsDirty then save() end; task.wait(3) end end)
local virtualUser=game:GetService('VirtualUser')
listen(me.Idled,function()
    if not live or not cfg.antiAFK then return end
    pcall(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new(0,0))
    end)
end)
task.spawn(function()
    while live do
        if cfg.masteryPolling then
            pcall(function() scanMasteryData(); scanMasteryGUI(); updateMasteryRates() end)
            if tab=='Trackers' and mode=='EXPANDED' and not panic then -- Trackers page controls do not require continuous rebuilding.
            end
        end
        task.wait(math.clamp(cfg.masteryInterval or 2,1,15))
    end
end)
_G.CRBFHubV12={Stop=stop,Save=save,Capture=capture,ScanEntries=scan,DetectCollection=detect,DetectMutation=selectedMutation,FormatMoney=money,GetCaches=function() return cache end,GetESPSettings=function() return cfg end,Hide=function() setMode('HIDDEN') end,Show=function() setMode('EXPANDED') end,Minimize=function() setMode('MINIMIZED') end}
print('CRBF HUB V22 MENUS ready | Hide: '..cfg.hideKey..' | Panic: '..cfg.panicKey..' | cache: '..imported)
