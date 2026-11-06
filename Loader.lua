-- cobble hills loader (Sintonia RP)
-- ⚠️ Certifique-se de que seu usuário do GitHub é "vzz41761". Se não for, mude abaixo!
local baseUrl = "https://raw.githubusercontent.com/vzz41761/sintonia/main/"

if getgenv().Cobble_RP_Unload then 
    pcall(getgenv().Cobble_RP_Unload) 
end

local function loadFile(name)
    local success, err = pcall(function()
        loadstring(game:HttpGet(baseUrl .. name, true))()
    end)
    if not success then
        warn("[cobble] Erro ao carregar " .. name .. ": " .. tostring(err))
    end
end

loadFile("Logic.lua")
task.wait(0.5)
loadFile("UI.lua")
