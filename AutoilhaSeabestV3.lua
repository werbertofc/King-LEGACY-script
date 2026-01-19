-- ==========================================================
-- KING LEGACY: SEA KING TRACKER PRO (v2.0)
-- FOCO: Forçar Renderização e Teleporte Preciso
-- ==========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local islandFolder = Workspace:WaitForChild("Island")
local ligado = true -- Já inicia buscando

-- === INTERFACE PEQUENA E ARRASTÁVEL ===
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("SK_Tracker") then pGui.SK_Tracker:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SK_Tracker"
ScreenGui.Parent = pGui
ScreenGui.ResetOnSpawn = false

local MainButton = Instance.new("TextButton")
MainButton.Name = "ToggleButton"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(80, 0, 200)
MainButton.Position = UDim2.new(0.1, 0, 0.5, 0)
MainButton.Size = UDim2.new(0, 55, 0, 55) -- Botão pequeno
MainButton.Font = Enum.Font.GothamBold
MainButton.Text = "SK: ON"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.TextSize = 12
MainButton.TextWrapped = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainButton

-- === FUNÇÃO DE TELEPORTE COM RENDERIZAÇÃO FORÇADA ===
local function teleportarComRender(ilha)
    if not ligado or not ilha then return end
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        local posAlvo = ilha:GetPivot().Position
        
        -- FORÇAR O MAPA A RENDERIZAR NA POSIÇÃO DA ILHA
        print("🔍 Forçando renderização da SeaKing Island...")
        player:RequestStreamAroundAsync(posAlvo)
        
        task.wait(0.3) -- Pequena pausa para o Delta processar a ilha
        
        -- Teleporta com uma altura de segurança para carregar o chão
        hrp.CFrame = CFrame.new(posAlvo + Vector3.new(0, 60, 0))
        
        -- AUTO-DESATIVAR
        ligado = false
        MainButton.Text = "SK: OFF"
        MainButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        print("🏝️ Chegamos! O teleporte foi desativado automaticamente.")
    end
end

-- === SCANNER DE ILHA (BUSCA CONSTANTE) ===
task.spawn(function()
    while true do
        if ligado then
            -- Procura na pasta Island
            local target = islandFolder:FindFirstChild("SeaKing Island")
            
            -- Caso o jogo mude o local da pasta em alguma atualização, ele tenta um Scan Geral
            if not target then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "SeaKing Island" then
                        target = obj
                        break
                    end
                end
            end

            if target then
                teleportarComRender(target)
            end
        end
        task.wait(1) -- Verifica a cada 1 segundo para não travar o celular
    end
end)

-- === SISTEMA DE ARRASTAR (MOBILE/DELTA) ===
local dragging, dragStart, startPos
MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MainButton.InputEnded:Connect(function() dragging = false end)

-- === BOTÃO DE CONTROLE MANUAL ===
MainButton.Activated:Connect(function()
    ligado = not ligado
    if ligado then
        MainButton.Text = "SK: ON"
        MainButton.BackgroundColor3 = Color3.fromRGB(80, 0, 200)
        print("📡 Buscando SeaKing Island...")
    else
        MainButton.Text = "SK: OFF"
        MainButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)

print("🚀 v2.0 Carregada: Scanner de Renderização Ativo!")

