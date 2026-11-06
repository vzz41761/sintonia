-- cobble hills UI (Sintonia RP - Money Maker v3)
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
    Subtitle = "MONEY MAKER V3",
    Icon = "dollar-sign", Logo = true,
    Size = UDim2.fromOffset(460, 340),
    ToggleKey = Enum.KeyCode.Insert,
    Backdrop = "aurora",
})

-- ABA 1: EMPREGOS
local tabMoney = Window:CreateTab({ Name = "EMPREGOS", Icon = "briefcase" })
tabMoney:SetColumns(2)

local secTeleport = tabMoney:CreateSection({ Name = "Ir Para Serviço" })
secTeleport:Button({ Name = "Ir para o Mercadinho", Icon = "map-pin", Callback = function()
    if getgenv().Cobble_GoToMercado then getgenv().Cobble_GoToMercado() end
end })

secTeleport:Button({ Name = "Listar Prompts Próximos", Icon = "list", Callback = function()
    if getgenv().Cobble_DumpPrompts then getgenv().Cobble_DumpPrompts() end
end })

local secJob = tabMoney:CreateSection({ Name = "Auto Farm" })
secJob:Toggle({ Name = "Auto Lixeiro", Default = false, Callback = function(v) 
    if v then getgenv().Cobble_StartFarm("Lixeiro") 
    elseif Config.Farm.ActiveJob == "Lixeiro" then getgenv().Cobble_StopFarm() end
end })

secJob:Toggle({ Name = "Auto Carga", Default = false, Callback = function(v) 
    if v then getgenv().Cobble_StartFarm("Carga") 
    elseif Config.Farm.ActiveJob == "Carga" then getgenv().Cobble_StopFarm() end
end })

-- ABA 2: VISUAIS
local tabVisuals = Window:CreateTab({ Name = "VISUAIS", Icon = "eye" })
tabVisuals:SetColumns(2)
local secEsp = tabVisuals:CreateSection({ Name = "ESP" })
secEsp:Toggle({ Name = "Ativar ESP", Default = true, Callback = function(v) Config.ESP.Enabled = v end })
secEsp:Toggle({ Name = "Jogadores", Default = true, Callback = function(v) Config.ESP.Players = v end })
secEsp:Toggle({ Name = "Serviços (Verde)", Default = true, Callback = function(v) Config.ESP.Jobs = v end })

-- ABA 3: AIMBOT
local tabAim = Window:CreateTab({ Name = "AIMBOT", Icon = "crosshair" })
tabAim:SetColumns(2)
local secA = tabAim:CreateSection({ Name = "Aimbot" })
secA:Toggle({ Name = "Ativar Aimbot", Default = false, Callback = function(v) Config.Aim.Enabled = v end })
secA:Slider({ Name = "Suavidade", Min = 0.1, Max = 1.0, Default = 0.55, Callback = function(v) Config.Aim.Smooth = v end })

-- ABA 4: CONFIG
local tabConfig = Window:CreateTab({ Name = "CONFIG", Icon = "wrench" })
tabConfig:SetColumns(1)
tabConfig:CreateSection({ Name = "Sessão" }):Button({ Name = "UNLOAD SCRIPT", Icon = "trash-2", Callback = function()
    if getgenv().Cobble_RP_Unload then getgenv().Cobble_RP_Unload() end
    Window:Destroy(); S:Destroy(); S.Cleanup()
end })

getgenv().Cobble_UI_Loaded = Window
