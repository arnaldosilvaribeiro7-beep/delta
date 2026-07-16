-- [[ SENSI HUB - VERSÃO TURBO (COM EVENT COLLECTOR) ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Prevenir duplicações
if PlayerGui:FindFirstChild("SensiHub_Landscape") then
    PlayerGui.SensiHub_Landscape:Destroy()
end

-- Estados Globais
_G.AutoFarmFruits = false
_G.AutoFarmMobs = false
_G.AutoChest = false
_G.FastAttack = false
_G.FruitESP = false
_G.AutoEventCollector = false  -- NOVO: coletor de eventos (ventos)

-- Criar Interface (mantive a mesma estrutura bonita)
local SensiHub = Instance.new("ScreenGui")
SensiHub.Name = "SensiHub_Landscape"
SensiHub.Parent = PlayerGui
SensiHub.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 640, 0, 90)  -- Aumentei um pouco para caber mais botões
MainFrame.Position = UDim2.new(0.5, -320, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(240, 244, 248)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = SensiHub

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(10, 80, 160)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- Barra de Título Lateral
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(0, 110, 1, 0)
TitleFrame.BackgroundColor3 = Color3.fromRGB(10, 80, 160)
TitleFrame.BorderSizePixel = 0
TitleFrame.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.6, 0)
Title.BackgroundTransparency = 1
Title.Text = "SENSI HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = TitleFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0.4, 0)
Subtitle.Position = UDim2.new(0, 0, 0.6, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Turbo Edition"
Subtitle.TextColor3 = Color3.fromRGB(200, 220, 255)
Subtitle.TextSize = 10
Subtitle.Font = Enum.Font.SourceSansItalic
Subtitle.Parent = TitleFrame

-- Container Horizontal de Botões (mais largo)
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -120, 1, 0)
Container.Position = UDim2.new(0, 120, 0, 0)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.FillDirection = Enum.FillDirection.Horizontal
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 5)
Layout.VerticalAlignment = Enum.VerticalAlignment.Center

-- Sistema de Arrasto (igual)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Funções auxiliares (SecureTeleport, EquipMelee - iguais)
local function SecureTeleport(targetCFrame)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = targetCFrame
    end
end

local function EquipMelee()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer.Backpack
    if character and backpack then
        local tool = character:FindFirstChildOfClass("Tool")
        if not tool or (tool.ToolTip ~= "Melee" and tool.Name ~= "Combat") then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") and (item.ToolTip == "Melee" or item.Name == "Combat") then
                    character.Humanoid:EquipTool(item)
                    break
                end
            end
        end
    end
end

-- Verifica se um baú está realmente disponível (não foi aberto)
local function IsChestAvailable(chestPart)
    -- Se o baú tiver um atributo "Opened" ou "Destroyed" ou se estiver transparente, não está disponível
    if chestPart:FindFirstChild("Open") or chestPart:FindFirstChild("Opened") then
        return false
    end
    if chestPart.Transparency > 0.5 then
        return false
    end
    -- Verifica se há algum filho chamado "Chest" que indique que já foi aberto (depende do jogo)
    for _, child in pairs(chestPart:GetChildren()) do
        if child:IsA("BoolValue") and (child.Name == "Opened" or child.Name == "Used") then
            return false
        end
    end
    return true
end

-- Criador de Botões (igual ao original)
local function CreateButton(text, order, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 68, 0, 70)
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextColor3 = Color3.fromRGB(10, 80, 160)
    Button.TextSize = 9
    Button.Font = Enum.Font.SourceSansBold
    Button.Text = text .. "\n[OFF]"
    Button.BorderSizePixel = 0
    Button.TextWrapped = true
    Button.LayoutOrder = order
    Button.Parent = Container

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(200, 210, 225)
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = Button

    local active = false
    Button.MouseButton1Click:Connect(function()
        active = not active
        if active then
            Button.BackgroundColor3 = Color3.fromRGB(10, 80, 160)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonStroke.Color = Color3.fromRGB(10, 80, 160)
            Button.Text = text .. "\n[ON]"
        else
            Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextColor3 = Color3.fromRGB(10, 80, 160)
            ButtonStroke.Color = Color3.fromRGB(200, 210, 225)
            Button.Text = text .. "\n[OFF]"
        end
        callback(active)
    end)
    return Button
end

-- Tabelas para rastrear objetos de ESP e itens coletados
local activeBillboards = {}
local collectedObjects = {}  -- Evitar coletar o mesmo item duas vezes

-- =================================================================
-- 1. PEGAR FRUTAS (melhorado com detecção de novos itens)
-- =================================================================
CreateButton("Pegar Frutas", 1, function(state)
    _G.AutoFarmFruits = state
    if state then
        -- Conecta o detetor de novos objetos para capturar frutas que spawnarem
        local function onChildAdded(child)
            if _G.AutoFarmFruits and child:IsA("Tool") and (string.find(child.Name, "Fruit") or string.find(child.Name, "Fruta")) and child:FindFirstChild("Handle") then
                task.wait(0.2)
                if child:FindFirstChild("Handle") then
                    SecureTeleport(child.Handle.CFrame)
                end
            end
        end
        Workspace.ChildAdded:Connect(onChildAdded)
    end
    task.spawn(function()
        while _G.AutoFarmFruits do
            task.wait(0.5)
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("Tool") and (string.find(obj.Name, "Fruit") or string.find(obj.Name, "Fruta")) and obj:FindFirstChild("Handle") then
                    SecureTeleport(obj.Handle.CFrame)
                    task.wait(0.3)
                end
            end
        end
    end)
end)

-- =================================================================
-- 2. AUTO FARM MOBS (igual ao original, funciona bem)
-- =================================================================
CreateButton("Farm Mobs", 2, function(state)
    _G.AutoFarmMobs = state
    task.spawn(function()
        local currentTarget = nil
        local lastShift = os.time()
        local shiftDirection = true

        task.spawn(function()
            while _G.AutoFarmMobs do
                if _G.FastAttack then task.wait(0.05) else task.wait(0.15) end
                if currentTarget and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 then
                    EquipMelee()
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                end
            end
        end)

        while _G.AutoFarmMobs do
            task.wait(0.05)
            if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
                currentTarget = nil
                local enemies = Workspace:FindFirstChild("Enemies") or Workspace
                for _, enemy in pairs(enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                        currentTarget = enemy
                        break
                    end
                end
            end
            if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                if os.time() - lastShift >= 1 then
                    shiftDirection = not shiftDirection
                    lastShift = os.time()
                end
                local positionOffset = shiftDirection and 3.5 or -3.5
                SecureTeleport(currentTarget.HumanoidRootPart.CFrame * CFrame.new(0, 1.5, positionOffset))
            end
        end
    end)
end)

-- =================================================================
-- 3. FAST ATTACK (igual)
-- =================================================================
CreateButton("Fast Attack", 3, function(state)
    _G.FastAttack = state
end)

-- =================================================================
-- 4. FRUIT ESP (igual ao original, mas com mais eficiência)
-- =================================================================
CreateButton("Fruit ESP", 4, function(state)
    _G.FruitESP = state
    if not state then
        for _, billboard in pairs(activeBillboards) do
            if billboard then billboard:Destroy() end
        end
        activeBillboards = {}
    else
        task.spawn(function()
            while _G.FruitESP do
                task.wait(1)
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj:IsA("Tool") and (string.find(obj.Name, "Fruit") or string.find(obj.Name, "Fruta")) and obj:FindFirstChild("Handle") then
                        if not obj.Handle:FindFirstChild("FruitESP_Tag") then
                            local BillboardGui = Instance.new("BillboardGui")
                            BillboardGui.Name = "FruitESP_Tag"
                            BillboardGui.AlwaysOnTop = true
                            BillboardGui.Size = UDim2.new(0, 100, 0, 30)
                            BillboardGui.Adornee = obj.Handle
                            BillboardGui.Parent = obj.Handle
                            local TextLabel = Instance.new("TextLabel")
                            TextLabel.Size = UDim2.new(1, 0, 1, 0)
                            TextLabel.BackgroundTransparency = 1
                            TextLabel.TextColor3 = Color3.fromRGB(10, 80, 160)
                            TextLabel.TextSize = 10
                            TextLabel.Font = Enum.Font.SourceSansBold
                            TextLabel.Text = "[🍒 " .. obj.Name .. "]"
                            TextLabel.Parent = BillboardGui
                            table.insert(activeBillboards, BillboardGui)
                        end
                    end
                end
            end
        end)
    end
end)

-- =================================================================
-- 5. FARM DE BAÚS INTELIGENTE (SÓ TELEPORTA PARA BAÚS DISPONÍVEIS)
-- =================================================================
CreateButton("Farm Baús", 5, function(state)
    _G.AutoChest = state
    task.spawn(function()
        while _G.AutoChest do
            task.wait(0.5)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Part") and (string.find(obj.Name, "Chest") or string.find(obj.Name, "Chest1") or string.find(obj.Name, "Chest2") or string.find(obj.Name, "Chest3")) then
                    -- Verifica se o baú está disponível
                    if IsChestAvailable(obj) then
                        SecureTeleport(obj.CFrame + Vector3.new(0, 2, 0))
                        task.wait(0.4)
                        break  -- Vai para o primeiro baú disponível
                    end
                end
            end
        end
    end)
end)

-- =================================================================
-- 6. NOVO: COLETOR DE EVENTOS (VENTOS / DROPS RAROS)
-- =================================================================
CreateButton("Coletar Eventos", 6, function(state)
    _G.AutoEventCollector = state
    collectedObjects = {}  -- Limpa o histórico ao ativar/desativar
    
    if state then
        -- Escaneia objetos já existentes
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Tool") and (string.find(obj.Name, "Fruit") or string.find(obj.Name, "Drop") or string.find(obj.Name, "Event")) and obj:FindFirstChild("Handle") then
                if not collectedObjects[obj] then
                    collectedObjects[obj] = true
                    SecureTeleport(obj.Handle.CFrame)
                    task.wait(0.3)
                end
            end
        end
        
        -- Detecta novos objetos que spawnarem (eventos)
        local function onNewObject(child)
            if _G.AutoEventCollector then
                if child:IsA("Tool") and (string.find(child.Name, "Fruit") or string.find(child.Name, "Drop") or string.find(child.Name, "Event")) and child:FindFirstChild("Handle") then
                    if not collectedObjects[child] then
                        collectedObjects[child] = true
                        task.wait(0.2)  -- Espera um pouco para o objeto estabilizar
                        if child:FindFirstChild("Handle") then
                            SecureTeleport(child.Handle.CFrame)
                            -- Cria um ESP rápido para indicar que foi coletado
                            local esp = Instance.new("BillboardGui")
                            esp.Name = "EventESP"
                            esp.AlwaysOnTop = true
                            esp.Size = UDim2.new(0, 60, 0, 20)
                            esp.Adornee = child.Handle
                            esp.Parent = child.Handle
                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1,0,1,0)
                            label.BackgroundTransparency = 1
                            label.Text = "🚀 COLETADO"
                            label.TextColor3 = Color3.fromRGB(0,255,0)
                            label.TextSize = 12
                            label.Font = Enum.Font.SourceSansBold
                            label.Parent = esp
                            task.wait(2)
                            esp:Destroy()
                        end
                    end
                end
            end
        end
        
        Workspace.ChildAdded:Connect(onNewObject)
    end
end)

-- Instrução final (opcional)
print("Sensi Hub Turbo carregado! Aproveite os eventos!")
