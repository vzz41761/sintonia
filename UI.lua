-- cobble hills UI (Sintonia RP - Money Maker)
local Players = game:GetService("Players")
local Config = getgenv().CobbleConfig
if not Config then return end

local SU = "https://raw.githubusercontent.com/PulseZax/Slate/refs/heads/main/.lua"
local ok, S = pcall(function() return loadstring(game:HttpGet(SU), "@Slate")() end)
if not ok or not S then return end

S.Theme.Preset("Violet")
S.Theme.Set({
    Background = Color3.fromRGB(12, 11, 20), Surface = Color3.fromRGB(22, 19, 34),
    SurfaceAlt = Color3.fromRGB(31, 26, 46), Elevated = Color3.fromRGB(39, 31, 57),
    Accent = Color3.fromRGB(157, 105, 255), ToggleOn = Color3.fromRGB(157, 105, 255),
    Text = Color3.fromRGB(245, 242, 255), Muted = Color3.fromRGB(163, 154, 185),
    Radius = 12, RowHeight = 42, HeaderHeight = 56,
})
pcall(function() S:SetFontFamily("Montserrat") end)

local Window = S:CreateWindow({
    Name = "COBBLE <font color='#9D69FF'>SINTONIA</font>",
    Subtitle = "MONEY MAKER",
    Icon = "dollar-sign", Logo = true,
    Size = UDim2.fromOffset(460, 340),
    ToggleKey = Enum.KeyCode.Insert,
    Backdrop = "aurora",
})

-- ABA 1: EMPREGOS & DINHEIRO
local tabMoney = Window:CreateTab({ Name = "EMPREGOS", Icon = "briefcase" })
tabMoney:SetColumns(2)

local secJob = tabMoney:CreateSection({ Name = "Auto Farm" })
secJob:Toggle({ Name = "Auto Lixeiro", Default = false, Callback = function(v) 
    Config.Farm.AutoLixeiro = v
    if v then getgenv().Cobble_StartFarm("Lixeiro") else getgenv().Cobble_StopFarm() end
end })
secJob:Toggle({ Name = "Auto Carga", Default = false, Callback = function(v) 
    Config.Farm.AutoCarga = v
    if v then getgenv().Cobble_StartFarm("Carga") else getgenv().Cobble_StopFarm() end
end })

local secTeleport = tabMoney:CreateSection({ Name = "Ir Para Serviço" })
secTeleport:Paragraph({ Name = "Aviso", Text = "O teleporte usa física de velocidade (seguro)." })
secTeleport:Button({ Name = "Ir para o Lixeiro", Icon = "map-pin", Callback = function()
    for prompt, info in pairs(getgenv().CobbleConfig and {} or {}) do end -- placeholder
    -- Puxa o job mais próximo do tipo Lixeiro
    local best = nil
    for prompt, info in pairs(_G.Cobble_CachedJobs or {}) do
        if info.Name:lower():find("lixeiro") then best = info.Pos; break end
    end
    if best and getgenv().Cobble_GlideTo then getgenv().Cobble_GlideTo(best) else print("Nenhum lixeiro encontrado.") end
end })
secTeleport:Button({ Name = "Ir para a Carga", Icon = "map-pin", Callback = function()
    local best = nil
    for prompt, info in pairs(_G.Cobble_CachedJobs or {}) do
        if info.Name:lower():find("carga") then best = info.Pos; break end
    end
    if best and getgenv().Cobble_GlideTo then getgenv().Cobble_GlideTo(best) else print("Nenhuma carga encontrada.") end
end })

-- ABA 2: VISUAIS
local tabVisuals = Window:CreateTab({ Name = "VISUAIS", Icon = "eye" })
tabVisuals:SetColumns(2)
local secEsp = tabVisuals:CreateSection({ Name = "ESP" })
secEsp:Toggle({ Name = "Ativar ESP", Default = true, Callback = function(v) Config.ESP.Enabled = v end })
secEsp:Toggle({ Name = "Jogadores", Default = true, Callback = function(v) Config.ESP.Players = v end })
secEsp:Toggle({ Name = "Empregos", Default = true, Callback = function(v) Config.ESP.Jobs = v end })

-- ABA 3: AIMBOT
local tabAim = Window:CreateTab({ Name = "AIMBOT", Icon = "crosshair" })
tabAim:SetColumns(2)
local secA = tabAim:CreateSection({ Name = "Aimbot" })
secA:Toggle({ Name = "Ativar Aimbot", Default = false, Callback = function(v) Config.Aim.Enabled = v end })
secA:Toggle({ Name = "Mostrar FOV", Default = true, Callback = function(v) Config.Aim.ShowFOV = v end })
secA:Slider({ Name = "FOV", Min = 20, Max = 400, Default = 120, Callback = function(v) Config.Aim.FOV = v end })
secA:Slider({ Name = "Suavidade", Min = 0.1, Max = 1.0, Default = 0.55, Callback = function(v) Config.Aim.Smooth = v end })

-- ABA 4: CONFIG
local tabConfig = Window:CreateTab({ Name = "CONFIG", Icon = "wrench" })
tabConfig:SetColumns(1)
tabConfig:CreateSection({ Name = "Sessão" }):Button({ Name = "UNLOAD SCRIPT", Icon = "trash-2", Callback = function()
    if getgenv().Cobble_RP_Unload then getgenv().Cobble_RP_Unload() end
    Window:Destroy(); S:Destroy(); S.Cleanup()
end })

getgenv().Cobble_UI_Loaded = Window
