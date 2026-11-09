-- CRBF HUB V11.1 DIAGNOSTIC BUILD
local SOURCE = [==[
-- CRBF HUB V11.1 | Optimised standalone release
-- ESP + index tracker only. K hides the hub, not overlays.
local P=game:GetService('Players'); local U=game:GetService('UserInputService'); local H=game:GetService('HttpService')
local me=P.LocalPlayer; local pg=me:WaitForChild('PlayerGui')
for _,key in ipairs({'EggFarmingHubV103','EggFarmingHubV104','EggFarmingHubV105','EggFarmingHubV106','EggFarmingHubV107','EggFarmingHubV108','EggFarmingHubV109','EggFarmingHubV110','CRBFHubV111'}) do local old=_G[key]; if type(old)=='table' and type(old.Stop)=='function' then pcall(old.Stop) end end
for _,name in ipairs({'EggFarmingHubV103','EggFarmingHubV104','EggFarmingHubV105','EggFarmingHubV106','EggFarmingHubV107','EggFarmingHubV108','EggFarmingHubV109','EggFarmingHubV110','CRBFHubV111'}) do local g=pg:FindFirstChild(name); if g then g:Destroy() end end
local live=true; local con={}; local objects={}; local pages={}; local cache={}; local dirty=false; local settingsDirty=false
local rarities={'Common','Uncommon','Rare','Epic','Legendary','Mythic','Divine','Cosmic','Celestial','Secret','Void','Inferno','Omega','Spectral','Ethereal','Primordial'}
local mutations={'Gold','Diamond','Lightning','Frozen','Angelic','Hacker','Time','Void'}
local collections={'Normal','Limited','Gold','Diamond','Lightning','Frozen','Angelic','Hacker','Time','Void'}
local rc={Common='#B4B4B4',Uncommon='#4BDC5F',Rare='#3791FF',Epic='#AF4BFF',Legendary='#FFAF23',Mythic='#FF4169',Divine='#FFF578',Cosmic='#8741FF',Celestial='#5FF0FF',Secret='#FF2D41',Void='#5F239B',Inferno='#FF550F',Omega='#FF2DC3',Spectral='#73FFBE',Ethereal='#AFDCFF',Primordial='#FFD787'}
local mc={Gold='#FFCD23',Diamond='#55EBFF',Lightning='#FFFF4B',Frozen='#64AFFF',Angelic='#FFFFE1',Hacker='#23FF55',Time='#FF64CD',Void='#9137E6'}
local function color(hex) return Color3.fromHex(hex or '#FFFFFF') end
local theme={bg=color('#090D1B'),side=color('#10162B'),panel=color('#151D36'),card=color('#202A48'),border=color('#35507B'),blue=color('#29C7FF'),purple=color('#A16BFF'),white=color('#F1F5FF'),muted=color('#9BAAC1'),green=color('#4CDC91'),red=color('#F55B6E')}
local cfg={playerStyle='Compact',playerOutline=true,playerFill=false,playerThroughWalls=true,playerHeadSide=3,playerBubbleSize=25,playerBubbleBackground=true,playerBubbleDistance=false,playerOverrides={},moneyMode='Rarity Only',minimumIncomeText='20B',showAnimalIncome=true,playerSelection={},rarity=false,mutation=false,players=false,animalSize=15,playerSize=17,playerCardWidth=290,playerCardScale=100,playerAutoResize=true,playerColorHex='#FF5050',playerSeparateColors=false,playerHighlightHex='#FF5050',trans=.65,animalBG=.18,playerBG=.15,animalRange=1500,playerRange=1500,unlimitedPlayerRange=false,showIndexStatus=true,missingIndexOnly=false,prioritiseMissing=true,rgb={255,80,80},username=true,distance=true,health=true,speed=true,money=true,selectedR={},selectedM={},hideKey='K',panicKey='P',uiScale=100,uiOpacity=10,accentR=41,accentG=199,accentB=255,antiAFK=false,masteryPolling=true,masteryInterval=2}
local folder='EggFarmingHub'; local cf=folder..'/CollectionCacheV111.json'; local sf=folder..'/SettingsV111.json'; local fileOK=type(readfile)=='function' and type(writefile)=='function' and type(isfile)=='function'
local function listen(sig,fn) local c=sig:Connect(fn); con[#con+1]=c; return c end
local function folderReady() if type(makefolder)=='function' then pcall(makefolder,folder) end end
local function read(path) if not fileOK then return end; local ok,res=pcall(function() if isfile(path) then return H:JSONDecode(readfile(path)) end end); if ok and type(res)=='table' and res.PlaceId==game.PlaceId and res.UserId==me.UserId then return res end end
local function write(path,data) if not fileOK then return false end; folderReady(); data.PlaceId=game.PlaceId; data.UserId=me.UserId; local ok=pcall(function() writefile(path,H:JSONEncode(data)) end); return ok end
local imported='None'; local verified=false
local function load() local s=read(sf) or read(folder..'/SettingsV110.json') or read(folder..'/SettingsV109.json') or read(folder..'/SettingsV108.json') or read(folder..'/SettingsV107.json') or read(folder..'/SettingsV106.json') or read(folder..'/SettingsV105.json') or read(folder..'/SettingsV104.json') or read(folder..'/SettingsV103.json') or read(folder..'/SettingsV102.json') or read(folder..'/SettingsV101.json'); if s then local source=s.Settings or s; for k,v in pairs(source) do if cfg[k]~=nil and type(v)==type(cfg[k]) then cfg[k]=v end end; if s.RarityESP~=nil then cfg.rarity=s.RarityESP end; if s.MutationESP~=nil then cfg.mutation=s.MutationESP end; if s.PlayerESP~=nil then cfg.players=s.PlayerESP end; cfg.selectedR=s.RaritySelected or cfg.selectedR; cfg.selectedM=s.MutationSelected or cfg.selectedM; cfg.rgb=s.PlayerRGB and {s.PlayerRGB.R or 255,s.PlayerRGB.G or 80,s.PlayerRGB.B or 80} or cfg.rgb end
for _,f in ipairs({cf,folder..'/CollectionCacheV110.json',folder..'/CollectionCacheV109.json',folder..'/CollectionCacheV108.json',folder..'/CollectionCacheV107.json',folder..'/CollectionCacheV106.json',folder..'/CollectionCacheV105.json',folder..'/CollectionCacheV104.json',folder..'/CollectionCacheV103.json',folder..'/CollectionCacheV102.json',folder..'/CollectionCacheV101.json',folder..'/CollectionCacheV100.json',folder..'/CollectionCacheV99.json',folder..'/CollectionCacheV98.json',folder..'/CollectionCacheV97.json',folder..'/CollectionCacheV96.json',folder..'/CollectionCacheV95.json'}) do local d=read(f); if d and type(d.Caches)=='table' then cache=d.Caches; imported=f; dirty=f~=cf; break end end end
print('[CRBF] Loading settings/cache')
load()
print('[CRBF] Settings/cache loaded')
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
local function playerMoney(p) for _,host in ipairs({p:FindFirstChild('leaderstats'),p}) do if host then for _,name in ipairs({'Money','Cash','Coins','Currency','Gold','Balance','Dollars'}) do local v=host:FindFirstChild(name); if v and (v:IsA('IntValue') or v:IsA('NumberValue')) then return v.Value end; local a=host:GetAttribute(name); if type(a)=='number' then return a end end end end end
local function mutationOf(m) for _,key in ipairs({'Mutation','MutationType'}) do local value=m:GetAttribute(key); if type(value)=='string' then for _,name in ipairs(mutations) do if value:match('^%s*(.-)%s*$'):lower()==name:lower() then return name end end end end end
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
local c=color((mut and cfg.mutation and cfg.selectedM[mut]) and mc[mut] or rc[r]); d[1].FillColor=c; d[1].OutlineColor=c; d.card.stroke.Color=c; d.bar.BackgroundColor3=c; d.card.frame.BackgroundTransparency=cfg.animalBG; d.title.Text=tostring(m:GetAttribute('AnimalName') or m.Name); d.title.TextSize=cfg.animalSize; d.rarity.Text=r:upper(); d.rarity.TextColor3=color(rc[r]); d.rarity.TextSize=math.max(10,cfg.animalSize-4); d.mutation.Text=mut and ('★ '..mut:upper()) or ''; d.mutation.TextColor3=color(mc[mut]); d.dist.Text=distance(root)..' STUDS'; d.income.Visible=cfg.showAnimalIncome; d.income.Text=income and (money(income)..'/s') or 'INCOME UNKNOWN'; d.indexStatus.Visible=cfg.showIndexStatus; d.indexStatus.Text=indexStatus=='NEEDED' and ('● NEEDED / '..indexCollection:upper()..' INDEX') or indexStatus=='COLLECTED' and ('✓ COLLECTED / '..indexCollection:upper()) or ('? UNKNOWN / '..indexCollection:upper()..' INDEX'); d.indexStatus.TextColor3=indexStatus=='NEEDED' and theme.red or indexStatus=='COLLECTED' and theme.green or theme.muted; local urgent=cfg.prioritiseMissing and indexStatus=='NEEDED'; if urgent then d.card.stroke.Color=theme.red; d.card.stroke.Thickness=2.5; d.bar.BackgroundColor3=theme.red else d.card.stroke.Thickness=1.3 end; local scale=math.clamp(1-distance(root)/3000,.65,1); d[2].Size=UDim2.fromOffset(math.floor(260*scale),math.floor((85+(cfg.showIndexStatus and 23 or 0)+(cfg.showAnimalIncome and 21 or 0))*scale)) else erase(m) end end end end
for m,d in pairs(objects) do if d.kind=='animal' and not seen[m] then erase(m) end end end
local function validHex(v)
    if type(v)~='string' then return nil end
    local h=v:gsub('%s',''):gsub('^#',''):upper()
    if #h==6 and h:match('^[0-9A-F]+$') then return '#'..h end
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
print('[CRBF] Building GUI')
local gui=new('ScreenGui',pg,{Name='CRBFHubV111',ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling}); local main=round(new('Frame',gui,{Size=UDim2.fromOffset(780,580),Position=UDim2.new(.5,-390,.5,-290),BackgroundColor3=theme.bg,BorderSizePixel=0,Active=true}),12); border(main); local head=new('Frame',main,{Size=UDim2.new(1,0,0,58),BackgroundColor3=theme.side,BorderSizePixel=0,Active=true}); text(head,'CRBF HUB',18,{Size=UDim2.new(1,-120,0,28),Position=UDim2.fromOffset(18,5),Font=Enum.Font.GothamBold}); text(head,'V11.1  /  NEON EDITION  /  K TO HIDE',10,{Size=UDim2.new(1,-120,0,20),Position=UDim2.fromOffset(18,31),TextColor3=theme.muted});
new('UIGradient',main,{Rotation=125,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,color('#111C39')),ColorSequenceKeypoint.new(.55,color('#090D1B')),ColorSequenceKeypoint.new(1,color('#1B1237'))})})
new('UIStroke',main,{Color=theme.blue,Thickness=1.5,Transparency=.25})
new('Frame',head,{Size=UDim2.new(1,0,0,3),Position=UDim2.new(0,0,1,-3),BorderSizePixel=0,BackgroundColor3=theme.blue})
local uiScaler=new('UIScale',main,{Scale=math.clamp((cfg.uiScale or 100)/100,.7,1.2)}); main.BackgroundTransparency=(cfg.uiOpacity or 10)/100
theme.blue=Color3.fromRGB(cfg.accentR or 41,cfg.accentG or 199,cfg.accentB or 255)
local function btn(parent,title,fn,props) props=props or {}; props.Size=props.Size or UDim2.new(1,0,0,36); props.BackgroundColor3=props.BackgroundColor3 or theme.card; props.Text=title; props.TextColor3=props.TextColor3 or theme.white; props.Font=Enum.Font.GothamBold; props.TextSize=props.TextSize or 12; props.BorderSizePixel=0; local b=round(new('TextButton',parent,props),7); if fn then b.MouseButton1Click:Connect(function() if live then fn(b) end end) end; return b end
local sidebar=new('Frame',main,{Size=UDim2.new(0,170,1,-104),Position=UDim2.fromOffset(0,58),BackgroundColor3=theme.side,BorderSizePixel=0}); new('UIPadding',sidebar,{PaddingTop=UDim.new(0,14),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)}); new('UIListLayout',sidebar,{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder}); local body=new('Frame',main,{Size=UDim2.new(1,-170,1,-104),Position=UDim2.fromOffset(170,58),BackgroundTransparency=1}); local foot=new('Frame',main,{Size=UDim2.new(1,0,0,46),Position=UDim2.new(0,0,1,-46),BackgroundColor3=theme.side,BorderSizePixel=0}); local floating=round(btn(gui,'EGG',nil,{Size=UDim2.fromOffset(58,58),Position=UDim2.new(0,24,.5,-29),BackgroundColor3=theme.blue,Visible=false,Active=true,TextSize=14}),29); border(floating,theme.white)
local pageNames={'Dashboard','Animal ESP','Player ESP','Money','Animals','Mutations','Mastery','Settings'}; local tab='Dashboard'; local mode='EXPANDED'; local nav={}; local showTab
local function page(name) local p=new('ScrollingFrame',body,{Name=name,Size=UDim2.new(1,-28,1,-24),Position=UDim2.fromOffset(14,12),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=theme.blue,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=false}); new('UIPadding',p,{PaddingBottom=UDim.new(0,18)}); new('UIListLayout',p,{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder}); return p end
for _,name in ipairs(pageNames) do pages[name]=page(name) end
local function clear(p) for _,x in ipairs(p:GetChildren()) do if x:IsA('GuiObject') then x:Destroy() end end end
local function line(p,s,size,height,c) return text(p,s,size or 12,{Size=UDim2.new(1,0,0,height or 28),TextColor3=c or theme.white,TextWrapped=true}) end
local collapsedSections={}
local function section(p,s)
    local row=new('Frame',p,{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1})
    row:SetAttribute('CRBFSection',true)
    local marker=new('Frame',row,{Size=UDim2.fromOffset(3,19),Position=UDim2.fromOffset(0,8),BackgroundColor3=theme.blue,BorderSizePixel=0})
    local label=text(row,string.upper(s),13,{Size=UDim2.new(1,-52,1,0),Position=UDim2.fromOffset(13,0),Font=Enum.Font.GothamBold,TextColor3=theme.white})
    local key=p.Name..'/'..s
    local arrow=btn(row,collapsedSections[key] and '▶' or '▼',nil,{Size=UDim2.fromOffset(34,29),Position=UDim2.new(1,-37,0,2),BackgroundColor3=theme.card,TextSize=15})
    local function apply()
        local children=p:GetChildren(); local active=false
        for _,child in ipairs(children) do
            if child==row then active=true
            elseif active and child:IsA('GuiObject') and child:GetAttribute('CRBFSection') then break
            elseif active and child:IsA('GuiObject') then child.Visible=not collapsedSections[key] end
        end
        arrow.Text=collapsedSections[key] and '▶' or '▼'
    end
    arrow.MouseButton1Click:Connect(function() collapsedSections[key]=not collapsedSections[key]; apply() end)
    task.defer(function() if row.Parent then apply() end end)
    return row
end

local function action(p,s,fn,c)
    local b=btn(p,s,fn,{BackgroundColor3=c or theme.card,TextSize=12})
    border(b,theme.border)
    b.MouseEnter:Connect(function() if b.Parent then b.BackgroundColor3=theme.blue end end)
    b.MouseLeave:Connect(function() if b.Parent then b.BackgroundColor3=c or theme.card end end)
    return b
end
local function toggle(p,s,key) local row=round(new('Frame',p,{Size=UDim2.new(1,0,0,47),BackgroundColor3=theme.panel,BorderSizePixel=0}),8); text(row,s,12,{Size=UDim2.new(1,-100,1,0),Position=UDim2.fromOffset(14,0)}); local b=btn(row,'',nil,{Size=UDim2.fromOffset(68,28),Position=UDim2.new(1,-80,.5,-14)}); local function refresh() b.Text=cfg[key] and 'ON' or 'OFF'; b.BackgroundColor3=cfg[key] and theme.blue or theme.card end; refresh(); b.MouseButton1Click:Connect(function() cfg[key]=not cfg[key]; settingsDirty=true; refresh() end) end
local function slider(p,s,min,max,get,set) local row=round(new('Frame',p,{Size=UDim2.new(1,0,0,75),BackgroundColor3=theme.panel,BorderSizePixel=0}),8); local caption=text(row,'',12,{Size=UDim2.new(1,-28,0,26),Position=UDim2.fromOffset(14,6)}); local track=round(new('Frame',row,{Size=UDim2.new(1,-42,0,8),Position=UDim2.fromOffset(21,51),BackgroundColor3=theme.card,BorderSizePixel=0}),4); local fill=round(new('Frame',track,{BackgroundColor3=theme.blue,BorderSizePixel=0}),4); local knob=round(new('Frame',track,{Size=UDim2.fromOffset(16,16),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=theme.white,BorderSizePixel=0}),8); local function display() local v=get(); local t=(v-min)/(max-min); caption.Text=s..': '..v; fill.Size=UDim2.fromScale(t,1); knob.Position=UDim2.fromScale(t,.5) end; display(); local moving=false; local function at(x) if track.AbsoluteSize.X==0 then return end; set(math.floor(math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(max-min)+min+.5)); settingsDirty=true; display() end; local c1=track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then moving=true; at(i.Position.X) end end); local c2=U.InputChanged:Connect(function(i) if moving and i.UserInputType==Enum.UserInputType.MouseMovement then at(i.Position.X) end end); local c3=U.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then moving=false end end); row.Destroying:Once(function() c1:Disconnect(); c2:Disconnect(); c3:Disconnect() end) end
local function filters(p,names,selected,colors) local box=new('Frame',p,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1}); new('UIGridLayout',box,{CellSize=UDim2.new(.5,-5,0,37),CellPadding=UDim2.fromOffset(10,7)}); for _,name in ipairs(names) do local b=btn(box,'',nil,{TextColor3=color(colors[name])}); local function refresh() b.Text=(selected[name] and '✓ ' or '○ ')..name; b.BackgroundColor3=selected[name] and theme.blue or theme.card end; refresh(); b.MouseButton1Click:Connect(function() selected[name]=not selected[name]; settingsDirty=true; refresh() end) end end
local function bar(p,name,a,b,c)
    local row=round(new('Frame',p,{Size=UDim2.new(1,0,0,86),BackgroundColor3=theme.panel,BorderSizePixel=0}),12)
    border(row,c or theme.border)
    new('Frame',row,{Size=UDim2.fromOffset(4,57),Position=UDim2.fromOffset(10,14),BackgroundColor3=c or theme.blue,BorderSizePixel=0})
    text(row,string.upper(name),14,{Size=UDim2.new(.62,-20,0,24),Position=UDim2.fromOffset(24,11),Font=Enum.Font.GothamBold})
    text(row,string.format('%.1f%%',b>0 and a/b*100 or 0),13,{Size=UDim2.new(.32,0,0,23),Position=UDim2.new(.66,0,0,11),TextXAlignment=Enum.TextXAlignment.Right,TextColor3=c or theme.blue,Font=Enum.Font.GothamBold})
    text(row,a..' / '..b..'  UNLOCKED',10,{Size=UDim2.new(1,-42,0,17),Position=UDim2.fromOffset(24,35),TextColor3=theme.muted})
    local track=round(new('Frame',row,{Size=UDim2.new(1,-48,0,7),Position=UDim2.fromOffset(24,65),BackgroundColor3=theme.card,BorderSizePixel=0}),4)
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
    local direct={me:FindFirstChild('Mastery'),me:FindFirstChild('Masteries'),me:FindFirstChild('MasteryData'),me:FindFirstChild('Data')}
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
    end
    out.level=readKey({'Level','Lvl','MasteryLevel'})
    out.xp=readKey({'XP','Exp','Experience','CurrentXP','CurrentExp'})
    out.required=readKey({'RequiredXP','MaxXP','XPRequired','NextLevelXP','XPToNextLevel','MaxExp'})
    if out.level or out.xp then return out end
end
local function scanMasteryData()
    local root=findMasteryRoot()
    if not root then return end
    for _,name in ipairs(masteryNames) do
        local node=root:FindFirstChild(name,true)
        local info=parseMasteryNode(node,name)
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
        if d and d.xp and d.level then
            local prev=masteryLast[name]
            if prev and prev.level==d.level and d.xp>prev.xp and now-prev.time>=.5 then
                local observed=(d.xp-prev.xp)/(now-prev.time)*60
                masteryRate[name]=masteryRate[name] and (masteryRate[name]*.6+observed*.4) or observed
            end
            if not prev or d.xp~=prev.xp or d.level~=prev.level then masteryLast[name]={xp=d.xp,level=d.level,time=now} end
        end
    end
end
local masteryUIStatus='Waiting for mastery data'
local selectedZone='ALL'; local selectedRarity='ALL'; local missing=false; local search=''; local currentCollection=nil; local selectedCollection='Gold'
local render={}
local function dropdown(p,title,options,chosen,onPick)
    local wrap=round(new('Frame',p,{Size=UDim2.new(1,0,0,45),BackgroundColor3=theme.panel,BorderSizePixel=0,ClipsDescendants=true}),9)
    border(wrap,theme.border)
    local trigger=btn(wrap,title..'   /   '..tostring(chosen)..'     ▼',nil,{Size=UDim2.new(1,-12,0,40),Position=UDim2.fromOffset(6,2),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextSize=12})
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
        btn(menu,(value==chosen and '◆  ' or '    ')..value,function()
            chosen=value; setOpen(false); onPick(value)
        end,{Size=UDim2.new(1,-7,0,35),LayoutOrder=i,BackgroundColor3=value==chosen and theme.blue or theme.card,TextXAlignment=Enum.TextXAlignment.Left})
    end
end
local moneyModes={'Rarity Only','Rarity + Money','Rarity + Index Missing','Rarity + Money + Index Missing','Money Only','Money + Index Missing','Index Missing Only','All Animals'}
render.Money=function()
    local p=pages.Money; clear(p)
    section(p,'MONEY FILTERS')
    line(p,'Filter animal ESP by displayed income per second. Animals with unknown income do not pass money filters.',12,60,theme.muted)
    dropdown(p,'ESP FILTER MODE',moneyModes,cfg.moneyMode,function(v) cfg.moneyMode=v; settingsDirty=true; render.Money() end)
    section(p,'MINIMUM INCOME / SECOND')
    local row=round(new('Frame',p,{Size=UDim2.new(1,0,0,66),BackgroundColor3=theme.panel,BorderSizePixel=0}),9)
    text(row,'Minimum $/s',13,{Size=UDim2.new(.4,0,1,0),Position=UDim2.fromOffset(14,0)})
    local box=round(new('TextBox',row,{Size=UDim2.new(.46,0,0,38),Position=UDim2.new(.52,0,.5,-19),BackgroundColor3=theme.card,TextColor3=theme.white,Text=cfg.minimumIncomeText,PlaceholderText='e.g. 20B, 1.5T, 10Qi',Font=Enum.Font.Gotham,TextSize=14,ClearTextOnFocus=false,BorderSizePixel=0}),8)
    box.FocusLost:Connect(function() if parseIncome(box.Text) then cfg.minimumIncomeText=box.Text; settingsDirty=true else box.Text=cfg.minimumIncomeText end end)
    toggle(p,'Show animal income on ESP cards','showAnimalIncome')
    line(p,'Income is read from replicated animal attributes or visible $/s labels when available. Unknown values are never guessed.',11,65,theme.muted)
end
local function collectionView(name)
    currentCollection=name
    local p=pages[tab]; clear(p)
    section(p,'COLLECTION / '..name)
    action(p,'←  RETURN TO COLLECTIONS',function() currentCollection=nil; render[tab]() end)
    local d=cache[name]
    if not d then line(p,'No saved collection data available.',12,35,theme.muted); return end
    local st=stats(d.Entries)
    local a,b=name=='Limited' and st.EventCollected or st.RegularCollected,name=='Limited' and st.EventTotal or st.RegularTotal
    bar(p,name,a,b,color(mc[name] or rc.Primordial))
    local zs={'ALL'}; local rs={'ALL'}
    for _,e in ipairs(d.Entries) do
        if not table.find(zs,e.Zone) then zs[#zs+1]=e.Zone end
        if not table.find(rs,e.Rarity) then rs[#rs+1]=e.Rarity end
    end
    table.sort(zs,function(a,b) if a=='ALL' then return true elseif b=='ALL' then return false end; local x=tonumber(a:match('[Zz]one%s*(%d+)')); local y=tonumber(b:match('[Zz]one%s*(%d+)')); if x and y then return x<y elseif x then return true elseif y then return false end; return a<b end)
    table.sort(rs,function(a,b) return a=='ALL' or (b~='ALL' and a<b) end)
    section(p,'SMART FILTERS')
    dropdown(p,'ZONE',zs,selectedZone,function(v) selectedZone=v; collectionView(name) end)
    dropdown(p,'RARITY',rs,selectedRarity,function(v) selectedRarity=v; collectionView(name) end)
    action(p,missing and '●  SHOWING MISSING ONLY' or '○  SHOWING ALL ANIMALS',function() missing=not missing; collectionView(name) end,missing and theme.blue or theme.card)
    local input=round(new('TextBox',p,{Size=UDim2.new(1,0,0,43),BackgroundColor3=theme.panel,TextColor3=theme.white,PlaceholderText='⌕   Search by animal name...',PlaceholderColor3=theme.muted,Text=search,ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=12,BorderSizePixel=0}),9)
    border(input,theme.border)
    local summary=line(p,'',12,26,theme.blue)
    local results=new('Frame',p,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
    new('UIListLayout',results,{Padding=UDim.new(0,7)})
    local function redraw()
        clear(results); local count=0; local last
        for _,e in ipairs(d.Entries) do
            if (name~='Limited' or not e.Zone:match('[Zz]one%d+')) and (selectedZone=='ALL' or selectedZone==e.Zone) and (selectedRarity=='ALL' or selectedRarity==e.Rarity) and (not missing or e.Status=='MISSING') and (search=='' or e.Name:lower():find(search:lower(),1,true) or e.InternalName:lower():find(search:lower(),1,true)) then
                if last~=e.Zone then last=e.Zone; section(results,e.Zone) end
                local tint=color(rc[e.Rarity]); local row=round(new('Frame',results,{Size=UDim2.new(1,0,0,65),BackgroundColor3=theme.panel,BorderSizePixel=0}),10)
                border(row,theme.border)
                new('Frame',row,{Size=UDim2.fromOffset(4,42),Position=UDim2.fromOffset(9,12),BackgroundColor3=tint,BorderSizePixel=0})
                text(row,e.Name,13,{Size=UDim2.new(1,-140,0,27),Position=UDim2.fromOffset(22,8),Font=Enum.Font.GothamBold})
                text(row,string.upper(e.Rarity)..'   •   '..string.upper(e.Zone),10,{Size=UDim2.new(1,-145,0,20),Position=UDim2.fromOffset(22,34),TextColor3=tint,Font=Enum.Font.GothamBold})
                local done=e.Status=='COLLECTED'
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
render['Animal ESP']=function() local p=pages['Animal ESP']; clear(p); section(p,'Animal ESP'); section(p,'INDEX-AWARE CARDS'); toggle(p,'Show index collection status','showIndexStatus'); toggle(p,'Show only animals needed for index','missingIndexOnly'); toggle(p,'Highlight needed animals','prioritiseMissing'); line(p,'Checks the Normal index or the exact mutation index. UNKNOWN means no reliable match in saved data.',11,57,theme.muted); toggle(p,'Rarity ESP','rarity'); toggle(p,'Mutation ESP','mutation'); slider(p,'Text size',10,30,function() return cfg.animalSize end,function(v) cfg.animalSize=v end); slider(p,'Card transparency %',0,100,function() return math.floor(cfg.animalBG*100) end,function(v) cfg.animalBG=v/100 end); slider(p,'Maximum distance',100,5000,function() return cfg.animalRange end,function(v) cfg.animalRange=v end); section(p,'Rarity filters'); filters(p,rarities,cfg.selectedR,rc); action(p,'SELECT ALL RARITIES',function() for _,r in ipairs(rarities) do cfg.selectedR[r]=true end; settingsDirty=true; render['Animal ESP']() end,theme.blue); action(p,'CLEAR RARITIES',function() cfg.selectedR={} ; settingsDirty=true; render['Animal ESP']() end); section(p,'Mutation filters'); filters(p,mutations,cfg.selectedM,mc); action(p,'SELECT ALL MUTATIONS',function() for _,m in ipairs(mutations) do cfg.selectedM[m]=true end; settingsDirty=true; render['Animal ESP']() end,theme.blue); action(p,'CLEAR MUTATIONS',function() cfg.selectedM={}; settingsDirty=true; render['Animal ESP']() end) end
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
    section(p,'COLLECTION DASHBOARD')
    line(p,'Select a collection to inspect animals, progress and missing entries.',12,40,theme.muted)
    for _,name in ipairs(collections) do
        local d=cache[name]; local st=d and stats(d.Entries)
        local a=st and (name=='Limited' and st.EventCollected or st.RegularCollected) or 0
        local b=st and (name=='Limited' and st.EventTotal or st.RegularTotal) or (name=='Limited' and 15 or 120)
        local c=color(mc[name] or (name=='Normal' and '#29C7FF' or '#A16BFF'))
        local card=bar(p,name,a,b,c)
        local hit=btn(card,'',function() collectionView(name) end,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,TextTransparency=1})
    end
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

local mainTab='ESP'; local espSub='Animal ESP'; local indexSub='Animals'; local panic=false; local panicBackup=nil; local awaitingKey=nil
local function subnav(p,names,active)
    local row=new('Frame',p,{Size=UDim2.new(1,0,0,40),BackgroundTransparency=1})
    local grid=new('UIListLayout',row,{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})
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
        showTab(mainTab=='ESP' and espSub or (mainTab=='Money' and 'Money' or (mainTab=='Players' and 'Player ESP' or (mainTab=='Index' and indexSub or (mainTab=='Mastery' and 'Mastery' or 'Settings')))))
    end
end
local function keyPicker(p,title,key)
    action(p,title..': '..tostring(cfg[key]),function(b)
        awaitingKey={key=key,button=b,title=title}
        b.Text='PRESS ANY KEY (ESC TO CANCEL)'
    end,theme.blue)
end
render.Mastery=function()
    local p=pages.Mastery; clear(p)
    section(p,'LIVE MASTERY TRACKER')
    line(p,'LIVE requires XP replicated to your client. Menu-only XP is a snapshot, not live. XP/min and ETA use observed increases, never a guessed rate.',12,70,theme.muted)
    action(p,'REFRESH MASTERY DATA',function() scanMasteryData(); scanMasteryGUI(); updateMasteryRates(); render.Mastery() end,theme.blue)
    local source=findMasteryRoot()
    line(p,'Data source: '..(source and source:GetFullName() or 'No recognised replicated mastery folder found'),11,43,theme.muted)
    for _,name in ipairs(masteryNames) do
        local d=masteryData[name]
        section(p,name)
        if not d then
            line(p,'No verified data yet. Open this mastery in the game once, or locate its replicated data.',11,47,theme.muted)
        else
            local lvl=d.level and tostring(d.level) or '?'
            local xp=d.xp and tostring(math.floor(d.xp)) or '?'
            local maxxp=d.required and tostring(math.floor(d.required)) or '?'
            line(p,'LEVEL '..lvl..'    •    XP '..xp..' / '..maxxp,14,30,theme.white)
            if d.xp and d.required and d.required>0 then
                local pct=math.clamp(d.xp/d.required,0,1)
                local track=round(new('Frame',p,{Size=UDim2.new(1,0,0,12),BackgroundColor3=theme.card,BorderSizePixel=0}),6)
                round(new('Frame',track,{Size=UDim2.fromScale(pct,1),BackgroundColor3=theme.blue,BorderSizePixel=0}),6)
                local rate=masteryRate[name]
                local remain=math.max(0,d.required-d.xp)
                line(p,('%.1f%%  •  %s XP remaining  •  %s  •  ETA %s'):format(pct*100,tostring(math.floor(remain)),rate and string.format('%.1f XP/min',rate) or 'XP rate unknown',rate and rate>0 and string.format('%.1f min',remain/rate) or 'unknown'),11,48,theme.muted)
            end
            line(p,'Source: '..(masterySource[name] or 'Unknown')..(masterySource[name]=='Visible mastery menu' and ' (SNAPSHOT: not live)' or ''),10,30,theme.muted)
        end
    end
end
render.Settings=function()
    local p=pages.Settings; clear(p)
    section(p,'Settings')
    section(p,'ANTI-AFK / IDLE')
    toggle(p,'Enable anti-idle input','antiAFK')
    line(p,'Uses VirtualUser on Roblox idle events when supported. Cannot guarantee against server or game-specific AFK kicks.',11,65,theme.muted)
    toggle(p,'Track mastery automatically','masteryPolling')
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
    slider(p,'Panel transparency %',0,60,function() return cfg.uiOpacity or 10 end,function(v) cfg.uiOpacity=v; main.BackgroundTransparency=v/100 end)
    section(p,'NEON ACCENT RGB')
    for _,spec in ipairs({{'Red','accentR'}, {'Green','accentG'}, {'Blue','accentB'}}) do
        slider(p,spec[1],0,255,function() return cfg[spec[2]] end,function(v) cfg[spec[2]]=v; theme.blue=Color3.fromRGB(cfg.accentR,cfg.accentG,cfg.accentB) end)
    end
    section(p,'Storage')
    line(p,'Your existing index cache and ESP preferences are retained. Saving does not overwrite the previous version files.',12,68,theme.muted)
end
showTab=function(name)
    tab=name; currentCollection=nil
    if name=='Animal ESP' then mainTab='ESP'; espSub=name
    elseif name=='Player ESP' then mainTab='Players'
    elseif name=='Money' then mainTab='Money'
    elseif name=='Animals' or name=='Mutations' then mainTab='Index'; indexSub=name
    elseif name=='Mastery' then mainTab='Mastery'
    elseif name=='Settings' then mainTab='Settings' end
    for n,p in pairs(pages) do p.Visible=mode=='EXPANDED' and n==name end
    for n,b in pairs(nav) do b.BackgroundColor3=n==mainTab and theme.blue or theme.side end
    render[name]()
    pages[name].CanvasPosition=Vector2.new(0,0)
end
-- Search across hub controls; results navigate to the matching tab and expand its sections.
local searchBox=round(new('TextBox',sidebar,{Name='CRBFSearch',Size=UDim2.new(1,0,0,37),LayoutOrder=-10,BackgroundColor3=theme.card,TextColor3=theme.white,PlaceholderText='⌕ Search settings...',PlaceholderColor3=theme.muted,Text='',ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=12,BorderSizePixel=0}),8)
local searchResults=new('ScrollingFrame',sidebar,{Name='SearchResults',Size=UDim2.new(1,0,0,0),LayoutOrder=-9,BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,Visible=false,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y})
new('UIListLayout',searchResults,{Padding=UDim.new(0,4)})
local searchCatalog={
    {'Animal ESP','Rarity ESP'},{'Animal ESP','Mutation ESP'},{'Animal ESP','Show index collection status'},{'Animal ESP','Show only animals needed for index'},{'Animal ESP','Highlight needed animals'},{'Animal ESP','Text size'},{'Animal ESP','Maximum distance'},{'Animal ESP','Rarity filters'},{'Animal ESP','Mutation filters'},
    {'Money','ESP FILTER MODE'},{'Money','Minimum income'},{'Money','Show animal income'},
    {'Player ESP','ESP STYLE'},{'Player ESP','Outline around character'},{'Player ESP','Body fill highlight'},{'Player ESP','Outline visible through walls'},{'Player ESP','Head-side card offset'},{'Player ESP','Bubble font size'},{'Player ESP','Bubble background'},{'Player ESP','Bubble distance'},{'Player ESP','Enable Player ESP'},{'Player ESP','Auto-resize cards'},{'Player ESP','Card width'},{'Player ESP','Overall card scale'},{'Player ESP','Text size'},{'Player ESP','Card transparency'},{'Player ESP','Highlight transparency'},{'Player ESP','Player selection'},{'Player ESP','Show Username'},{'Player ESP','Show Distance'},{'Player ESP','Show Health'},{'Player ESP','Show Speed'},{'Player ESP','Show Money'},
    {'Mastery','LIVE MASTERY TRACKER'},{'Mastery','Running'},{'Mastery','XP rate'},{'Mastery','Refresh mastery'},
    {'Settings','Anti-AFK'},{'Settings','Track mastery automatically'},{'Settings','Keyboard shortcuts'},{'Settings','Appearance'},{'Settings','Storage'}
}
local function runSearch()
    for _,child in ipairs(searchResults:GetChildren()) do if child:IsA('GuiObject') then child:Destroy() end end
    local q=searchBox.Text:lower():gsub('^%s+',''):gsub('%s+$','')
    local active=q~=''
    searchResults.Visible=active
    for _,b in pairs(nav) do b.Visible=not active end
    if not active then searchResults.Size=UDim2.new(1,0,0,0); return end
    searchResults.Size=UDim2.new(1,0,1,-70)
    local count=0
    for _,entry in ipairs(searchCatalog) do
        if (entry[1]..' '..entry[2]):lower():find(q,1,true) then
            count+=1
            if count<=40 then
                btn(searchResults,entry[2]..'  ›',function()
                    for key in pairs(collapsedSections) do if key:sub(1,#entry[1]+1)==entry[1]..'/' then collapsedSections[key]=false end end
                    showTab(entry[1]); searchBox:ReleaseFocus()
                    local page=pages[entry[1]]
                    task.defer(function()
                        if not page or not page.Parent then return end
                        local target
                        for _,d in ipairs(page:GetDescendants()) do
                            if (d:IsA('TextLabel') or d:IsA('TextButton')) and d.Text:lower():find(entry[2]:lower(),1,true) then target=d; break end
                        end
                        if target then page.CanvasPosition=Vector2.new(0,math.max(0,target.AbsolutePosition.Y-page.AbsolutePosition.Y+page.CanvasPosition.Y-25)) end
                    end)
                end,{Size=UDim2.new(1,-4,0,35),BackgroundColor3=theme.card,TextSize=10,TextWrapped=true})
            end
        end
    end
    if count==0 then text(searchResults,'No matching controls',11,{Size=UDim2.new(1,0,0,32),TextColor3=theme.muted}) end
end
searchBox:GetPropertyChangedSignal('Text'):Connect(runSearch)
for i,name in ipairs({'ESP','Money','Players','Index','Mastery','Settings'}) do
    nav[name]=btn(sidebar,({'◎ ','＄ ','◉ ','▦ ','★ ','⚙ '})[i]..name,function()
        showTab(name=='ESP' and 'Animal ESP' or (name=='Money' and 'Money' or (name=='Players' and 'Player ESP' or (name=='Index' and indexSub or (name=='Mastery' and 'Mastery' or 'Settings')))))
    end,{Size=UDim2.new(1,0,0,44),LayoutOrder=i,BackgroundColor3=theme.side,TextXAlignment=Enum.TextXAlignment.Left})
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
local sizes={{650,480},{780,580},{920,660}}; local sizeIdx=2; btn(foot,'RESIZE',function() sizeIdx=sizeIdx%#sizes+1; local s=sizes[sizeIdx]; main.Size=UDim2.fromOffset(s[1],s[2]) end,{Size=UDim2.fromOffset(95,30),Position=UDim2.new(1,-238,0,8)}); local saveBtn=btn(foot,'SAVE + VERIFY',function(b) local ok=save(); b.Text=ok and 'VERIFIED!' or 'FAILED'; task.delay(2,function() if b.Parent then b.Text='SAVE + VERIFY' end end) end,{Size=UDim2.fromOffset(125,30),Position=UDim2.new(1,-135,0,8),BackgroundColor3=color('#256C50')}); text(foot,'● TRACKER ACTIVE',11,{Size=UDim2.new(.4,0,1,0),Position=UDim2.fromOffset(16,0),TextColor3=theme.green,Font=Enum.Font.GothamBold})
local function stop() if not live then return end; live=false; if panic and panicBackup then cfg.rarity=panicBackup.rarity; cfg.mutation=panicBackup.mutation; cfg.players=panicBackup.players end; save(); for _,c in ipairs(con) do c:Disconnect() end; for m in pairs(objects) do erase(m) end; gui:Destroy() end
close.MouseButton1Click:Connect(stop)
showTab('Player ESP')
main.Visible=true
gui.Enabled=true
print('[CRBF] UI created and visible')
listen(P.PlayerAdded,function()
    if tab=='Player ESP' and live then task.defer(function() if live and tab=='Player ESP' then render['Player ESP']() end end) end
end)
listen(P.PlayerRemoving,function(target)
    if target.Character then erase(target.Character) end
    if tab=='Player ESP' and live then task.defer(function() if live and tab=='Player ESP' then render['Player ESP']() end end) end
end)
task.spawn(function() while live do local ok,err=pcall(animalESP); if not ok then warn('[EggHub Animal ESP]',err) end; task.wait(.3) end end)
task.spawn(function() while live do local ok,err=pcall(playerESP); if not ok then warn('[EggHub Player ESP]',err) end; task.wait(.3) end end)
task.spawn(function() local prev,at=nil,0; while live do local name=detect(); if name~=prev then prev=name; at=os.clock() end; if not panic and name and os.clock()-at>.6 then local confirmed=detect(); if confirmed==name and capture(name,'Automatic') and currentCollection==name then collectionView(name) end end; task.wait(.5) end end)
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
        end
        task.wait(math.clamp(cfg.masteryInterval or 2,1,15))
    end
end)
_G.CRBFHubV111={Stop=stop,Save=save,Capture=capture,ScanEntries=scan,DetectCollection=detect,DetectMutation=selectedMutation,FormatMoney=money,GetCaches=function() return cache end,GetESPSettings=function() return cfg end,Hide=function() setMode('HIDDEN') end,Show=function() setMode('EXPANDED') end,Minimize=function() setMode('MINIMIZED') end}
print('CRBF HUB V11.1 ready | Hide: '..cfg.hideKey..' | Panic: '..cfg.panicKey..' | cache: '..imported)

]==]
local okCompile, compiled = pcall(loadstring, SOURCE)
local function alert(msg)
    warn('[CRBF HUB] '..tostring(msg))
    pcall(function() game:GetService('StarterGui'):SetCore('SendNotification',{Title='CRBF HUB',Text=tostring(msg):sub(1,190),Duration=12}) end)
end
if not okCompile or type(compiled)~='function' then
    alert('Compile error: '..tostring(compiled))
else
    local ok, err = xpcall(compiled, function(e) return tostring(e)..'\n'..debug.traceback() end)
    if not ok then
        alert('Runtime error: '..tostring(err))
        if type(writefile)=='function' then pcall(writefile,'CRBF_HUB_ERROR.txt',tostring(err)) end
    else
        alert('Script started. Press K if hidden.')
    end
end
