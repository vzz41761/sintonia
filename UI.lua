-- cobble hills UI (Sintonia RP v3)
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = getgenv().CobbleConfig
if not Config then return end

-- Puxa o Slate
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
    Subtitle = "ARMAS / CARROS / AIMBOT",
    Icon = "crosshair", Logo = true,
    Size = UDim2.fromOffset(460, 340),
    ToggleKey = Enum.KeyCode.Insert,
    Backdrop = "aurora",
})

-- ABA 1: AIMBOT
local tabAim = Window:CreateTab({ Name = "AIMBOT", Icon = "crosshair" })
tabAim:SetColumns(2)
local secA = tabAim:CreateSection({ Name = "Aimbot (Legit)" })
secA:Toggle({ Name = "Ativar Aimbot", Default = false, Callback = function(v) Config.Aim.Enabled = v end })
secA:Toggle({ Name = "Mostrar FOV", Default = true, Callback = function(v) Config.Aim.ShowFOV = v end })
secA:Slider({ Name = "FOV (px)", Min = 20, Max = 400, Default = 120, Callback = function(v) Config.Aim.FOV = v end })
secA:Slider({ Name = "Suavidade", Min = 0.1, Max = 1.0, Default = 0.55, Callback = function(v) Config.Aim.Smooth = v end })
secA:Paragraph({ Name = "Tecla", Text = "Aperte E (ou o botão do mouse) para mirar." })

-- ABA 2: SPAWNER
local tabSpawn = Window:CreateTab({ Name = "SPAWNER", Icon = "zap" })
tabSpawn:SetColumns(2)

-- Puxa as armas dinamicamente do ReplicatedStorage
local secWpn = tabSpawn:CreateSection({ Name = "Puxar Arma (Ghost)" })
local weaponsFound = {}
for _, obj in ipairs(RS:GetDescendants()) do
    if obj:IsA("Tool") then
        weaponsFound[obj.Name] = true
    end
end
for weaponName, _ in pairs(weaponsFound) do
    secWpn:Button({ Name = "Equipar: " .. weaponName, Callback = function() 
        if getgenv().Cobble_SpawnWeapon then getgenv().Cobble_SpawnWeapon(weaponName) end 
    end })
end

-- Spawn de Carros
local secCar = tabSpawn:CreateSection({ Name = "Spawnar Carro" })
local carros = {"Ferrari", "Porsche", "AUDI", "Lamborghini", "Nivus", "Hilux", "RAM", "SW4", "Tiggo 8 Pro 2023"} -- Lista baseada no mapa
for _, cName in ipairs(carros) do
    secCar:Button({ Name = "Spawn: " .. cName, Callback = function() 
        if getgenv().Cobble_SpawnCar then getgenv().Cobble_SpawnCar(cName) end 
    end })
end

-- ABA 3: VISUAIS
local tabVisuals = Window:CreateTab({ Name = "VISUAIS", Icon = "eye" })
tabVisuals:SetColumns(2)
local secEsp = tabVisuals:CreateSection({ Name = "ESP" })
secEsp:Toggle({ Name = "Ativar ESP", Default = true, Callback = function(v) Config.ESP.Enabled = v end })
secEsp:Toggle({ Name = "Jogadores", Default = true, Callback = function(v) Config.ESP.Players = v end })
secEsp:Toggle({ Name = "Carros", Default = true, Callback = function(v) Config.ESP.Cars = v end })
secEsp:Toggle({ Name = "Empregos", Default = true, Callback = function(v) Config.ESP.Prompts = v end })

-- ABA 4: PLAYER / FARM
local tabPlayer = Window:CreateTab({ Name = "PLAYER", Icon = "user" })
tabPlayer:SetColumns(2)
local secMov = tabPlayer:CreateSection({ Name = "Movimento" })
secMov:Toggle({ Name = "WalkSpeed", Default = false, Callback = function(v) Config.Movement.SpeedEnabled = v end })
secMov:Slider({ Name = "Velocidade", Min = 16, Max = 200, Default = 50, Callback = function(v) Config.Movement.SpeedValue = v end })
secMov:Toggle({ Name = "Fly", Default = false, Callback = function(v) Config.Movement.FlyEnabled = v end })
secMov:Toggle({ Name = "Noclip", Default = false, Callback = function(v) Config.Movement.NoclipEnabled = v end })

local secFarm = tabPlayer:CreateSection({ Name = "Auto Farm" })
secFarm:Toggle({ Name = "Auto Lixeiro", Default = false, Callback = function(v) Config.Farm.AutoTrash = v end })
secFarm:Toggle({ Name = "Auto Carga", Default = false, Callback = function(v) Config.Farm.AutoCargo = v end })

-- ABA 5: CONFIG
local tabConfig = Window:CreateTab({ Name = "CONFIG", Icon = "wrench" })
tabConfig:SetColumns(1)
tabConfig:CreateSection({ Name = "Sessão" }):Button({ Name = "UNLOAD SCRIPT", Icon = "trash-2", Callback = function()
    if getgenv().Cobble_RP_Unload then getgenv().Cobble_RP_Unload() end
    Window:Destroy(); S:Destroy(); S.Cleanup()
end })

-- Removemos o CreateLauncher que causava erro (a tecla Insert já faz o trabalho)
getgenv().Cobble_UI_Loaded = Window
