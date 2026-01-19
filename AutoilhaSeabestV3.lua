-- ==========================================================
-- AUTO SEA BEST V4.1 | BY WERBERT_OFC
-- SERVER HOP ANTI-ERRO (ESPERA DE 9s)
-- ==========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local islandFolder = Workspace:WaitForChild("Island")

-- === CONFIGURAÇÕES ===
local configs = {
    ligado = true,
    autoHop = true,
    delayInicial = 25,
    posicaoInicial = Vector3.new(16619.78, -4.05, -6611.93),
    tempoScan = 10,
    scriptAtivo = true,
    buscandoAgora = false
}

-- === INTERFACE (UI) ===
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("SeaBestV7") then pGui.SeaBestV7:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SeaBestV7"
ScreenGui.Parent = pGui
ScreenGui.ResetOnSpawn = false

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -110, 0.4, -80)
MainFrame.Size = UDim2.new(0, 220, 0, 175)
MainFrame.Active = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Parent = MainFrame
Stroke.Color = Color3.fromRGB(0, 120, 255)
Stroke.Thickness = 2

-- Título
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Size = UDim2.new(1, -60, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "Auto Sea Best V4.1\nby: werbert_ofc"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Iniciando..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 11

-- Botões UI (X e -)
local function createTopBtn(text, xPos, color)
    local b = Instance.new("TextButton")
    b.Parent = MainFrame
    b.Size = UDim2.new(0, 22, 0, 22)
    b.Position = UDim2.new(1, xPos, 0, 5)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = b
    return b
end

local CloseBtn = createTopBtn("X", -27, Color3.fromRGB(200, 50, 50))
local MiniBtn = createTopBtn("-", -54, Color3.fromRGB(80, 80, 80))

-- Ícone Minimizado
local IconFrame = Instance.new("TextButton")
IconFrame.Parent = ScreenGui
IconFrame.Size = UDim2.new(0, 30, 0, 30)
IconFrame.Position = UDim2.new(0.9, 0, 0.2, 0)
IconFrame.BackgroundColor3 = Color3.new(0,0,0)
IconFrame.Visible = false
IconFrame.Text = "SK"
IconFrame.TextColor3 = Color3.new(1,1,1)
local ic = Instance.new("UICorner")
ic.CornerRadius = UDim.new(0, 6)
ic.Parent = IconFrame
local is = Instance.new("UIStroke")
is.Parent = IconFrame
is.Color = Color3.new(1,1,1)

-- === FUNÇÃO SERVER HOP COM ESPERA DE 9s ===
local function trocarDeServidor()
    if not configs.autoHop then return end
    
    local tentativaCount = 0
    local jobIdOriginal = game.JobId

    while configs.scriptAtivo do
        tentativaCount = tentativaCount + 1
        StatusLabel.Text = "Status: Hop (Tentativa " .. tentativaCount .. ")"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)

        local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(sfUrl)) end)

        if success and result and result.data then
            for _, server in pairs(result.data) do
                -- Filtro: Servidores com vaga (max - 1) e diferente do atual
                if server.playing < (server.maxPlayers - 1) and server.id ~= jobIdOriginal then
                    StatusLabel.Text = "Status: Conectando..."
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
                    
                    -- ESPERA DE 9 SEGUNDOS SOLICITADA
                    task.wait(9) 
                    
                    -- Se após 9 segundos game.JobId ainda for o mesmo, o teleporte falhou
                    if game.JobId == jobIdOriginal then
                        print("Falha ao entrar no server de 9s. Tentando o próximo...")
                    else
                        -- Se mudou o JobId, o script vai ser encerrado pelo teleporte de qualquer forma
                        return 
                    end
                end
            end
        end
        task.wait(1)
    end
end

-- === LÓGICA DE BUSCA ===
local function iniciarBusca()
    if configs.buscandoAgora then return end
    configs.buscandoAgora = true
    
    task.spawn(function()
        for i = configs.delayInicial, 1, -1 do
            if not configs.scriptAtivo or not configs.ligado then configs.buscandoAgora = false return end
            StatusLabel.Text = "Status: Carregando (" .. i .. "s)"
            task.wait(1)
        end
        
        StatusLabel.Text = "Status: Indo para Base..."
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(configs.posicaoInicial) end
        task.wait(2)
        
        local tempo = 0
        while configs.scriptAtivo and configs.ligado and tempo < configs.tempoScan do
            StatusLabel.Text = "Status: Buscando (" .. (configs.tempoScan - tempo) .. "s)"
            
            local target = islandFolder:FindFirstChild("SeaKing Island")
            if not target then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "SeaKing Island" then target = obj break end
                end
            end
            
            if target then
                StatusLabel.Text = "Status: ILHA ENCONTRADA!"
                StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                if hrp then hrp.CFrame = target:GetPivot() + Vector3.new(0, 50, 0) end
                configs.ligado = false
                local skBtn = MainFrame:FindFirstChild("SKToggle", true)
                if skBtn then skBtn.BackgroundColor3 = Color3.fromRGB(60,60,60) skBtn.Text = "Auto Sea Best: OFF" end
                configs.buscandoAgora = false
                return
            end
            tempo = tempo + 1
            task.wait(1)
        end
        
        if configs.scriptAtivo and configs.ligado and configs.autoHop then
            trocarDeServidor()
        end
        configs.buscandoAgora = false
    end)
end

-- === INTERAÇÕES UI ===
local function enableDrag(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = i.Position startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

enableDrag(MainFrame)
enableDrag(IconFrame)

MiniBtn.Activated:Connect(function() MainFrame.Visible = false IconFrame.Visible = true end)
IconFrame.Activated:Connect(function() IconFrame.Visible = false MainFrame.Visible = true end)
CloseBtn.Activated:Connect(function() configs.scriptAtivo = false ScreenGui:Destroy() end)

-- Toggles
local function createToggle(name, y, default, callback)
    local b = Instance.new("TextButton")
    b.Name = name:gsub(" ","") .. "Toggle"
    b.Parent = MainFrame
    b.Size = UDim2.new(1, -20, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = default and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 60)
    b.Text = name .. ": " .. (default and "ON" or "OFF")
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 12
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = b
    b.Activated:Connect(function()
        local s = not (b.BackgroundColor3.G * 255 > 100)
        b.BackgroundColor3 = s and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 60)
        b.Text = name .. ": " .. (s and "ON" or "OFF")
        callback(s)
    end)
end

createToggle("Auto Sea Best", 75, configs.ligado, function(s) 
    configs.ligado = s 
    if s then StatusLabel.TextColor3 = Color3.new(0.8,0.8,0.8) iniciarBusca() end 
end)
createToggle("Auto Server Hop", 115, configs.autoHop, function(s) configs.autoHop = s end)

if configs.ligado then iniciarBusca() end
