-- cobble hills UI (Sintonia RP)
local Players = game:GetService("Players")
local Config = getgenv().CobbleConfig
if not Config then return end

-- Puxa a biblioteca Slate
local SU = "https://raw.githubusercontent.com/PulseZax/Slate/refs/heads/main/.lua"
local ok, S = pcall(function() return loadstring(game:HttpGet(SU), "@Slate")() end)

if not ok or not S then
    warn("[cobble] Falha ao carregar a biblioteca Slate. Verifique sua internet.")
    return
end

-- Aplica o Tema Roxo (Veterano Style)
S.Theme.Preset("Violet")
S.Theme.Set({
    Background = Color3.fromRGB(12, 11, 20), Surface = Color3.fromRGB(22, 19, 34),
    SurfaceAlt = Color3.fromRGB(31, 26, 46), Elevated = Color3.fromRGB(39, 31, 57),
    Accent = Color3.fromRGB(157, 105, 255), ToggleOn = Color3.fromRGB(157, 105, 255),
    Text = Color3.fromRGB(245, 242, 255), Muted = Color3.fromRGB(163, 154, 185),
    Radius = 12, RowHeight = 42, HeaderHeight = 56,
})
pcall(function() S:SetFontFamily("Montserrat") end)

-- Cria a Janela
local Window = S:CreateWindow({
    Name = "COBBLE <font color='#9D69FF'>SINTONIA</font>",
    Subtitle = "RP EDITION  /  V1",
    Icon = "shield", Logo = true,
    Size = UDim2.fromOffset(460, 340),
    ToggleKey = Enum.KeyCode.Insert,
    Backdrop = "aurora",
})

-- Borda Roxa
pcall(function()
    local root = Window.root
    local stroke = root:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Color = Color3.fromRGB(157, 105, 255); stroke.Transparency = 0.55 end
end)

-- ==========================================
-- ABA 1: PLAYER
-- ==========================================
local tabPlayer = Window:CreateTab({ Name = "PLAYER", Icon = "user" })
tabPlayer:SetColumns(2)

local secMov = tabPlayer:CreateSection({ Name = "Movimento" })
secMov:Toggle({ Name = "WalkSpeed", Default = false, Callback = function(v) Config.Movement.SpeedEnabled = v end })
secMov:Slider({ Name = "Velocidade", Min = 16, Max = 200, Default = 50, Callback = function(v) Config.Movement.SpeedValue = v end })
secMov:Toggle({ Name = "Fly (Espaço/Shift)", Default = false, Callback = function(v) Config.Movement.FlyEnabled = v end })
secMov:Toggle({ Name = "Noclip", Default = false, Callback = function(v) Config.Movement.NoclipEnabled = v end })

local secInvis = tabPlayer:CreateSection({ Name = "Invisibilidade" })
secInvis:Toggle({ Name = "Invisível (Ghost)", Default = false, Callback = function(v) Config.Movement.InvisEnabled = v end })
secInvis:Paragraph({ Name = "Aviso", Text = "Use o Ghost se for farmar no chão ou usar TP." })

-- ==========================================
-- ABA 2: VISUAIS
-- ==========================================
local tabVisuals = Window:CreateTab({ Name = "VISUAIS", Icon = "eye" })
tabVisuals:SetColumns(2)

local secEsp = tabVisuals:CreateSection({ Name = "ESP" })
secEsp:Toggle({ Name = "Ativar ESP", Default = true, Callback = function(v) Config.ESP.Enabled = v end })
secEsp:Toggle({ Name = "Jogadores", Default = true, Callback = function(v) Config.ESP.Players = v end })
secEsp:Toggle({ Name = "Carros do Mapa", Default = true, Callback = function(v) Config.ESP.Cars = v end })
secEsp:Toggle({ Name = "Empregos (Lixo/Carga)", Default = true, Callback = function(v) Config.ESP.Prompts = v end })

-- ==========================================
-- ABA 3: FARM
-- ==========================================
local tabFarm = Window:CreateTab({ Name = "FARM", Icon = "sprout" })
tabFarm:SetColumns(2)

local secFarm = tabFarm:CreateSection({ Name = "Automação (Bypass AC)" })
secFarm:Toggle({ Name = "Auto Lixeiro", Default = false, Callback = function(v) Config.Farm.AutoTrash = v end })
secFarm:Toggle({ Name = "Auto Carga / Vender", Default = false, Callback = function(v) Config.Farm.AutoCargo = v end })
secFarm:Slider({ Name = "Raio de Ação (m)", Min = 5, Max = 50, Default = 15, Callback = function(v) Config.Farm.Radius = v end })

-- ==========================================
-- ABA 4: CONFIG
-- ==========================================
local tabConfig = Window:CreateTab({ Name = "CONFIG", Icon = "wrench" })
tabConfig:SetColumns(1)

local secSess = tabConfig:CreateSection({ Name = "Sessão" })
secSess:Button({ Name = "UNLOAD SCRIPT", Icon = "trash-2", Callback = function()
    if getgenv().Cobble_RP_Unload then getgenv().Cobble_RP_Unload() end
    Window:Destroy()
    S:Destroy()
    S.Cleanup()
end })

-- Launcher e Notificação
Window:CreateLauncher({ Name = "Cobble", Icon = "shield", Keybind = Enum.KeyCode.Insert })
S:Notify({ Title = "Cobble Hush", Description = "Menu carregado.", Icon = "crown", Tone = "Success", Duration = 5 })

getgenv().Cobble_UI_Loaded = Window
