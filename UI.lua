-- cobble hills UI (Sintonia RP - Weapon Grabber)
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
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
    Subtitle = "AIMBOT / ESP / ARMAS",
    Icon = "crosshair", Logo = true,
    Size = UDim2.fromOffset(460, 340),
    ToggleKey = Enum.KeyCode.Insert,
    Backdrop = "aurora",
})

-- ABA 1: VISUAIS (ESP)
local tabVisuals = Window:CreateTab({ Name = "VISUAIS", Icon = "eye" })
tabVisuals:SetColumns(2)

local secEsp = tabVisuals:CreateSection({ Name = "ESP" })
secEsp:Toggle({ Name = "Ativar ESP", Default = true, Callback = function(v) Config.ESP.Enabled = v end })
secEsp:Toggle({ Name = "Jogadores", Default = true, Callback = function(v) Config.ESP.Players = v end })
secEsp:Toggle({ Name = "Armas no Chão", Default = true, Callback = function(v) Config.ESP.Weapons = v end })
secEsp:Toggle({ Name = "Carros", Default = true, Callback = function(v) Config.ESP.Cars = v end })

-- ABA 2: AIMBOT
local tabAim = Window:CreateTab({ Name = "AIMBOT", Icon = "crosshair" })
tabAim:SetColumns(2)
local secA = tabAim:CreateSection({ Name = "Aimbot (Camera)" })
secA:Toggle({ Name = "Ativar Aimbot", Default = false, Callback = function(v) Config.Aim.Enabled = v end })
secA:Toggle({ Name = "Mostrar FOV", Default = true, Callback = function(v) Config.Aim.ShowFOV = v end })
secA:Slider({ Name = "FOV (px)", Min = 20, Max = 400, Default = 120, Callback = function(v) Config.Aim.FOV = v end })
secA:Slider({ Name = "Suavidade", Min = 0.1, Max = 1.0, Default = 0.55, Callback = function(v) Config.Aim.Smooth = v end })
secA:Paragraph({ Name = "Tecla", Text = "Segure E para mirar no jogador mais próximo." })

-- ABA 3: PLAYER E ARMAS
local tabPlayer = Window:CreateTab({ Name = "PLAYER", Icon = "user" })
tabPlayer:SetColumns(2)

local secMov = tabPlayer:CreateSection({ Name = "Movimento" })
secMov:Toggle({ Name = "WalkSpeed", Default = false, Callback = function(v) Config.Movement.SpeedEnabled = v end })
secMov:Slider({ Name = "Velocidade", Min = 16, Max = 200, Default = 50, Callback = function(v) Config.Movement.SpeedValue = v end })

local secArmas = tabPlayer:CreateSection({ Name = "Armas (Puxar)" })
secArmas:Paragraph({ Name = "Aviso", Text = "Puxa a arma mais próxima do chão pra sua mão." })
secArmas:Button({ Name = "Puxar Arma Próxima", Icon = "zap", Callback = function()
    local best = nil
    for tool, _ in pairs(getgenv().Cobble_CachedWeapons or {}) do best = tool.Name; break end
    if best and getgenv().Cobble_GrabWeapon then 
        getgenv().Cobble_GrabWeapon(best) 
    else 
        print("[cobble] Nenhuma arma encontrada perto.") 
    end
end })

-- ABA 4: CONFIG
local tabConfig = Window:CreateTab({ Name = "CONFIG", Icon = "wrench" })
tabConfig:SetColumns(1)
tabConfig:CreateSection({ Name = "Sessão" }):Button({ Name = "UNLOAD SCRIPT", Icon = "trash-2", Callback = function()
    if getgenv().Cobble_RP_Unload then getgenv().Cobble_RP_Unload() end
    Window:Destroy(); S:Destroy(); S.Cleanup()
end })

getgenv().Cobble_UI_Loaded = Window
