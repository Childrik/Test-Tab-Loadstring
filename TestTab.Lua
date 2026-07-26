-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local chatEvent = ReplicatedStorage:FindFirstChild("ChatEvent")
if not chatEvent then
    chatEvent = Instance.new("RemoteEvent")
    chatEvent.Name = "ChatEvent"
    chatEvent.Parent = ReplicatedStorage
end

local tagsEvent = ReplicatedStorage:FindFirstChild("TagsEvent")
if not tagsEvent then
    tagsEvent = Instance.new("RemoteEvent")
    tagsEvent.Name = "TagsEvent"
    tagsEvent.Parent = ReplicatedStorage
end

local playerColors = {}
local colorList = {
    Color3.new(1, 0.3, 0.3), Color3.new(0.3, 1, 0.3), Color3.new(0.3, 0.6, 1),
    Color3.new(1, 0.8, 0.3), Color3.new(1, 0.3, 0.8), Color3.new(0.3, 1, 1),
    Color3.new(1, 0.6, 0.3), Color3.new(0.6, 0.3, 1),
}
local colorIndex = 1

local function GetPlayerColor(playerName)
    if not playerColors[playerName] then
        playerColors[playerName] = colorList[colorIndex]
        colorIndex = colorIndex + 1
        if colorIndex > #colorList then colorIndex = 1 end
    end
    return playerColors[playerName]
end

local avatarCache = {}
local function GetPlayerAvatar(player)
    if not player then return "rbxassetid://0" end
    if avatarCache[player.UserId] then return avatarCache[player.UserId] end
    local success, url = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if success and url and url ~= "" then
        avatarCache[player.UserId] = url
        return url
    end
    return "rbxassetid://0"
end

local playerTags = {}
local defaultTag = "[Global]"
local presetTags = {
    ["antisocialForever2"] = {tag = "[Creator]", color = Color3.new(1, 0.9, 0.1)},
}

local function GetPlayerTag(playerName)
    if playerTags[playerName] then return playerTags[playerName] end
    if presetTags[playerName] then
        playerTags[playerName] = presetTags[playerName].tag
        return presetTags[playerName].tag
    end
    return defaultTag
end

local function GetTagColor(playerName)
    if presetTags[playerName] and presetTags[playerName].color then
        return presetTags[playerName].color
    end
    return Color3.new(0.6, 0.6, 1)
end

local function CreateChatUI()
    local oldGui = Player.PlayerGui:FindFirstChild("CustomChat")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomChat"
    screenGui.Parent = Player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    local chatWidth = 350
    local chatHeight = 400
    local chatX = 20
    local chatY = 15
    
    -- Кнопка чата
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(1, -60, 0, 15)
    toggleBtn.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    toggleBtn.Text = "💬"
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.TextSize = 26
    toggleBtn.Parent = screenGui
    toggleBtn.ZIndex = 10
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = toggleBtn
    
    -- Контейнер чата
    local chatContainer = Instance.new("Frame")
    chatContainer.Size = UDim2.new(0, chatWidth, 0, chatHeight)
    chatContainer.Position = UDim2.new(1, chatX + chatWidth + 20, 0, chatY)
    chatContainer.AnchorPoint = Vector2.new(1, 0)
    chatContainer.BackgroundColor3 = Color3.new(0.05, 0.05, 0.1)
    chatContainer.BackgroundTransparency = 0.3
    chatContainer.BorderSizePixel = 1
    chatContainer.BorderColor3 = Color3.new(0.2, 0.3, 0.5)
    chatContainer.ClipsDescendants = true
    chatContainer.Parent = screenGui
    chatContainer.ZIndex = 5
    local chatCorner = Instance.new("UICorner")
    chatCorner.CornerRadius = UDim.new(0, 10)
    chatCorner.Parent = chatContainer
    
    -- Заголовок
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.new(0.15, 0.2, 0.35)
    header.Parent = chatContainer
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Чат"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.SourceSansBold
    title.Parent = header
    
    -- Кнопка игроков
    local playersBtn = Instance.new("TextButton")
    playersBtn.Size = UDim2.new(0, 30, 0, 24)
    playersBtn.Position = UDim2.new(1, -36, 0.5, -12)
    playersBtn.BackgroundColor3 = Color3.new(0.3, 0.4, 0.7)
    playersBtn.Text = "👥"
    playersBtn.TextColor3 = Color3.new(1, 1, 1)
    playersBtn.TextSize = 14
    playersBtn.Parent = header
    playersBtn.Visible = (Player.Name == "antisocialForever2")
    local playersCorner = Instance.new("UICorner")
    playersCorner.CornerRadius = UDim.new(0, 5)
    playersCorner.Parent = playersBtn
    
    -- Список сообщений
    local messageList = Instance.new("ScrollingFrame")
    messageList.Size = UDim2.new(1, -10, 1, -75)
    messageList.Position = UDim2.new(0, 5, 0, 35)
    messageList.BackgroundTransparency = 1
    messageList.CanvasSize = UDim2.new(0, 0, 0, 0)
    messageList.ScrollBarThickness = 4
    messageList.ScrollBarImageColor3 = Color3.new(0.3, 0.3, 0.6)
    messageList.Parent = chatContainer
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 3)
    layout.Parent = messageList
    
    -- Поле ввода
    local inputPanel = Instance.new("Frame")
    inputPanel.Size = UDim2.new(1, -10, 0, 38)
    inputPanel.Position = UDim2.new(0, 5, 1, -43)
    inputPanel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.2)
    inputPanel.Parent = chatContainer
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 6)
    panelCorner.Parent = inputPanel
    
    local chatInput = Instance.new("TextBox")
    chatInput.Size = UDim2.new(1, -45, 1, -6)
    chatInput.Position = UDim2.new(0, 6, 0, 3)
    chatInput.BackgroundColor3 = Color3.new(0.05, 0.05, 0.12)
    chatInput.PlaceholderText = "Введите сообщение..."
    chatInput.PlaceholderColor3 = Color3.new(0.5, 0.5, 0.7)
    chatInput.Text = ""
    chatInput.TextColor3 = Color3.new(1, 1, 1)
    chatInput.TextSize = 13
    chatInput.ClearTextOnFocus = false
    chatInput.Font = Enum.Font.SourceSans
    chatInput.MultiLine = true
    chatInput.Parent = inputPanel
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 5)
    inputCorner.Parent = chatInput
    
    local sendBtn = Instance.new("TextButton")
    sendBtn.Size = UDim2.new(0, 32, 1, -6)
    sendBtn.Position = UDim2.new(1, -38, 0, 3)
    sendBtn.Text = "➤"
    sendBtn.TextColor3 = Color3.new(1, 1, 1)
    sendBtn.TextSize = 18
    sendBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    sendBtn.Parent = inputPanel
    sendBtn.ZIndex = 6
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 5)
    sendCorner.Parent = sendBtn
    
    -- Панель игроков
    local playersPanel = Instance.new("Frame")
    playersPanel.Size = UDim2.new(0, 280, 0, 300)
    playersPanel.Position = UDim2.new(0.5, -140, 0.5, -150)
    playersPanel.BackgroundColor3 = Color3.new(0.05, 0.05, 0.12)
    playersPanel.BackgroundTransparency = 0.3
    playersPanel.BorderSizePixel = 1
    playersPanel.BorderColor3 = Color3.new(0.2, 0.3, 0.5)
    playersPanel.ClipsDescendants = true
    playersPanel.Parent = screenGui
    playersPanel.Visible = false
    playersPanel.ZIndex = 20
    local panelCorner2 = Instance.new("UICorner")
    panelCorner2.CornerRadius = UDim.new(0, 10)
    panelCorner2.Parent = playersPanel
    
    local panelHeader = Instance.new("Frame")
    panelHeader.Size = UDim2.new(1, 0, 0, 30)
    panelHeader.BackgroundColor3 = Color3.new(0.15, 0.2, 0.35)
    panelHeader.Parent = playersPanel
    
    local panelTitle = Instance.new("TextLabel")
    panelTitle.Size = UDim2.new(1, -40, 1, 0)
    panelTitle.Position = UDim2.new(0, 10, 0, 0)
    panelTitle.BackgroundTransparency = 1
    panelTitle.Text = "Теги игроков"
    panelTitle.TextColor3 = Color3.new(1, 1, 1)
    panelTitle.TextSize = 13
    panelTitle.TextXAlignment = Enum.TextXAlignment.Left
    panelTitle.Font = Enum.Font.SourceSansBold
    panelTitle.Parent = panelHeader
    
    local closePanelBtn = Instance.new("TextButton")
    closePanelBtn.Size = UDim2.new(0, 28, 0, 28)
    closePanelBtn.Position = UDim2.new(1, -32, 0.5, -14)
    closePanelBtn.BackgroundTransparency = 1
    closePanelBtn.Text = "✕"
    closePanelBtn.TextColor3 = Color3.new(1, 1, 1)
    closePanelBtn.TextSize = 16
    closePanelBtn.Parent = panelHeader
    
    local addTagBtn = Instance.new("TextButton")
    addTagBtn.Size = UDim2.new(1, -20, 0, 28)
    addTagBtn.Position = UDim2.new(0, 10, 1, -35)
    addTagBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    addTagBtn.Text = "+ Добавить тег"
    addTagBtn.TextColor3 = Color3.new(1, 1, 1)
    addTagBtn.TextSize = 12
    addTagBtn.Parent = playersPanel
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 5)
    addCorner.Parent = addTagBtn
    
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(1, -10, 1, -75)
    playerList.Position = UDim2.new(0, 5, 0, 35)
    playerList.BackgroundTransparency = 1
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerList.ScrollBarThickness = 4
    playerList.ScrollBarImageColor3 = Color3.new(0.3, 0.3, 0.6)
    playerList.Parent = playersPanel
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = playerList
    
    local function UpdatePlayersList()
        for _, child in pairs(playerList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local canvasHeight = 0
        local allPlayers = {}
        for _, player in pairs(Players:GetPlayers()) do allPlayers[player.Name] = true end
        for name in pairs(presetTags) do allPlayers[name] = true end
        
        for playerName in pairs(allPlayers) do
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(1, -10, 0, 35)
            playerFrame.Position = UDim2.new(0, 5, 0, 0)
            playerFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.16)
            playerFrame.Parent = playerList
            local frameCorner = Instance.new("UICorner")
            frameCorner.CornerRadius = UDim.new(0, 5)
            frameCorner.Parent = playerFrame
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0, 85, 1, 0)
            nameLabel.Position = UDim2.new(0, 5, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = playerName
            nameLabel.TextColor3 = GetPlayerColor(playerName)
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.Parent = playerFrame
            
            local tagInput = Instance.new("TextBox")
            tagInput.Size = UDim2.new(0, 110, 1, -4)
            tagInput.Position = UDim2.new(0, 95, 0, 2)
            tagInput.BackgroundColor3 = Color3.new(0.05, 0.05, 0.12)
            tagInput.Text = GetPlayerTag(playerName)
            tagInput.TextColor3 = Color3.new(1, 1, 1)
            tagInput.TextSize = 11
            tagInput.ClearTextOnFocus = false
            tagInput.Parent = playerFrame
            local tagCorner = Instance.new("UICorner")
            tagCorner.CornerRadius = UDim.new(0, 4)
            tagCorner.Parent = tagInput
            
            local saveTagBtn = Instance.new("TextButton")
            saveTagBtn.Size = UDim2.new(0, 28, 1, -4)
            saveTagBtn.Position = UDim2.new(1, -33, 0, 2)
            saveTagBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
            saveTagBtn.Text = "✓"
            saveTagBtn.TextColor3 = Color3.new(1, 1, 1)
            saveTagBtn.TextSize = 14
            saveTagBtn.Parent = playerFrame
            local saveCorner = Instance.new("UICorner")
            saveCorner.CornerRadius = UDim.new(0, 4)
            saveCorner.Parent = saveTagBtn
            
            saveTagBtn.MouseButton1Click:Connect(function()
                local newTag = tagInput.Text
                if newTag ~= "" then
                    playerTags[playerName] = newTag
                    presetTags[playerName] = {tag = newTag, color = GetTagColor(playerName)}
                    tagsEvent:FireServer(playerName, newTag)
                end
            end)
            canvasHeight = canvasHeight + 38
        end
        playerList.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    end
    
    addTagBtn.MouseButton1Click:Connect(function()
        local dialog = Instance.new("Frame")
        dialog.Size = UDim2.new(0, 240, 0, 110)
        dialog.Position = UDim2.new(0.5, -120, 0.5, -55)
        dialog.BackgroundColor3 = Color3.new(0.05, 0.05, 0.12)
        dialog.Parent = playersPanel
        dialog.ZIndex = 25
        local dialogCorner = Instance.new("UICorner")
        dialogCorner.CornerRadius = UDim.new(0, 8)
        dialogCorner.Parent = dialog
        
        local nameInput = Instance.new("TextBox")
        nameInput.Size = UDim2.new(1, -20, 0, 28)
        nameInput.Position = UDim2.new(0, 10, 0, 8)
        nameInput.BackgroundColor3 = Color3.new(0.05, 0.05, 0.12)
        nameInput.PlaceholderText = "Имя игрока..."
        nameInput.TextColor3 = Color3.new(1, 1, 1)
        nameInput.TextSize = 13
        nameInput.Parent = dialog
        
        local tagInput2 = Instance.new("TextBox")
        tagInput2.Size = UDim2.new(1, -20, 0, 28)
        tagInput2.Position = UDim2.new(0, 10, 0, 40)
        tagInput2.BackgroundColor3 = Color3.new(0.05, 0.05, 0.12)
        tagInput2.PlaceholderText = "Тег (например [VIP])..."
        tagInput2.TextColor3 = Color3.new(1, 1, 1)
        tagInput2.TextSize = 13
        tagInput2.Parent = dialog
        
        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Size = UDim2.new(0, 75, 0, 28)
        confirmBtn.Position = UDim2.new(0.5, -80, 0, 74)
        confirmBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        confirmBtn.Text = "Добавить"
        confirmBtn.TextColor3 = Color3.new(1, 1, 1)
        confirmBtn.TextSize = 13
        confirmBtn.Parent = dialog
        local confCorner = Instance.new("UICorner")
        confCorner.CornerRadius = UDim.new(0, 5)
        confCorner.Parent = confirmBtn
        
        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0, 75, 0, 28)
        cancelBtn.Position = UDim2.new(0.5, 5, 0, 74)
        cancelBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
        cancelBtn.Text = "Отмена"
        cancelBtn.TextColor3 = Color3.new(1, 1, 1)
        cancelBtn.TextSize = 13
        cancelBtn.Parent = dialog
        local cancCorner = Instance.new("UICorner")
        cancCorner.CornerRadius = UDim.new(0, 5)
        cancCorner.Parent = cancelBtn
        
        confirmBtn.MouseButton1Click:Connect(function()
            local name = nameInput.Text
            local tag = tagInput2.Text
            if name ~= "" and tag ~= "" then
                presetTags[name] = {tag = tag, color = GetTagColor(name)}
                playerTags[name] = tag
                tagsEvent:FireServer(name, tag)
                dialog:Destroy()
                UpdatePlayersList()
            end
        end)
        cancelBtn.MouseButton1Click:Connect(function() dialog:Destroy() end)
    end)
    
    playersBtn.MouseButton1Click:Connect(function()
        playersPanel.Visible = not playersPanel.Visible
        if playersPanel.Visible then UpdatePlayersList() end
    end)
    closePanelBtn.MouseButton1Click:Connect(function() playersPanel.Visible = false end)
    Players.PlayerAdded:Connect(function()
        if playersPanel and playersPanel.Visible then UpdatePlayersList() end
    end)
    
    -- Перетаскивание
    local isDragging = false
    local dragStartPos = Vector2.new()
    local containerStartPos = Vector2.new()
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPos = input.Position
            containerStartPos = Vector2.new(chatX, chatY)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then isDragging = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStartPos
            chatX = containerStartPos.X + delta.X
            chatY = containerStartPos.Y + delta.Y
            chatContainer.Position = UDim2.new(1, chatX, 0, chatY)
        end
    end)
    
    -- Чат по умолчанию закрыт
    local isOpen = false
    
    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetPos
        if isOpen then
            targetPos = UDim2.new(1, chatX, 0, chatY)
        else
            targetPos = UDim2.new(1, chatX + chatWidth + 20, 0, chatY)
        end
        local tween = TweenService:Create(chatContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos})
        tween:Play()
    end)
    
    local function AddMessage(playerName, message)
        if message == "" or message == " " then return end
        local tag = GetPlayerTag(playerName)
        local player = Players:FindFirstChild(playerName)
        local avatarUrl = "rbxassetid://0"
        if player then avatarUrl = GetPlayerAvatar(player) end
        
        local msg = Instance.new("Frame")
        msg.Size = UDim2.new(1, -10, 0, 30)
        msg.Position = UDim2.new(0, 5, 0, 0)
        msg.BackgroundColor3 = Color3.new(0.08, 0.08, 0.16)
        msg.Parent = messageList
        local msgCorner = Instance.new("UICorner")
        msgCorner.CornerRadius = UDim.new(0, 5)
        msgCorner.Parent = msg
        
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 28, 0, 28)
        avatar.Position = UDim2.new(0, 4, 0.5, -14)
        avatar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
        avatar.Image = avatarUrl
        avatar.Parent = msg
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatar
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -45, 0, 14)
        nameLabel.Position = UDim2.new(0, 38, 0, 2)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = playerName .. " " .. tag
        nameLabel.TextColor3 = GetPlayerColor(playerName)
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = msg
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -45, 1, -16)
        textLabel.Position = UDim2.new(0, 38, 0, 16)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = message
        textLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        textLabel.TextSize = 11
        textLabel.TextXAliglocal function CreateChatUI()
    local oldGui = Player.PlayerGui:FindFirstChild("CustomChat")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomChat"
    screenGui.Parent = Player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    local chatWidth = 350
    local chatHeight = 400
    local chatX = 20
    local chatY = 15
    
    -- Кнопка чата
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(1, -60, 0, 15)
    toggleBtn.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    toggleBtn.Text = "💬"
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.TextSize = 26
    toggleBtn.Parent = screenGui
    toggleBtn.ZIndex = 10
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = toggleBtn
    
    -- Контейнер чата (прозрачный фон)
    local chatContainer = Instance.new("Frame")
    chatContainer.Size = UDim2.new(0, chatWidth, 0, chatHeight)
    chatContainer.Position = UDim2.new(1, chatX, 0, chatY)
    chatContainer.AnchorPoint = Vector2.new(1, 0)
    chatContainer.BackgroundTransparency = 1
    chatContainer.ClipsDescendants = true
    chatContainer.Parent = screenGui
    chatContainer.ZIndex = 5
    
    -- Только список сообщений (без фона)
    local messageList = Instance.new("ScrollingFrame")
    messageList.Size = UDim2.new(1, -10, 1, -50)
    messageList.Position = UDim2.new(0, 5, 0, 0)
    messageList.BackgroundTransparency = 1
    messageList.CanvasSize = UDim2.new(0, 0, 0, 0)
    messageList.ScrollBarThickness = 4
    messageList.ScrollBarImageColor3 = Color3.new(0.3, 0.3, 0.6)
    messageList.Parent = chatContainer
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = messageList
    
    -- Поле ввода (только оно с фоном)
    local inputPanel = Instance.new("Frame")
    inputPanel.Size = UDim2.new(1, -10, 0, 40)
    inputPanel.Position = UDim2.new(0, 5, 1, -45)
    inputPanel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.2)
    inputPanel.BackgroundTransparency = 0
    inputPanel.Parent = chatContainer
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 8)
    panelCorner.Parent = inputPanel
    
    local chatInput = Instance.new("TextBox")
    chatInput.Size = UDim2.new(1, -45, 1, -6)
    chatInput.Position = UDim2.new(0, 6, 0, 3)
    chatInput.BackgroundColor3 = Color3.new(0.05, 0.05, 0.12)
    chatInput.BackgroundTransparency = 0
    chatInput.PlaceholderText = "Введите сообщение..."
    chatInput.PlaceholderColor3 = Color3.new(0.5, 0.5, 0.7)
    chatInput.Text = ""
    chatInput.TextColor3 = Color3.new(1, 1, 1)
    chatInput.TextSize = 14
    chatInput.ClearTextOnFocus = false
    chatInput.Font = Enum.Font.SourceSans
    chatInput.MultiLine = true
    chatInput.Parent = inputPanel
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = chatInput
    
    local sendBtn = Instance.new("TextButton")
    sendBtn.Size = UDim2.new(0, 34, 1, -6)
    sendBtn.Position = UDim2.new(1, -40, 0, 3)
    sendBtn.Text = "➤"
    sendBtn.TextColor3 = Color3.new(1, 1, 1)
    sendBtn.TextSize = 20
    sendBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    sendBtn.BackgroundTransparency = 0
    sendBtn.Parent = inputPanel
    sendBtn.ZIndex = 6
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 6)
    sendCorner.Parent = sendBtn
    
    -- Кнопка игроков (без фона)
    local playersBtn = Instance.new("TextButton")
    playersBtn.Size = UDim2.new(0, 32, 0, 32)
    playersBtn.Position = UDim2.new(1, -42, 0, -35)
    playersBtn.BackgroundTransparency = 1
    playersBtn.Text = "👥"
    playersBtn.TextColor3 = Color3.new(1, 1, 1)
    playersBtn.TextSize = 18
    playersBtn.Parent = chatContainer
    playersBtn.Visible = (Player.Name == "antisocialForever2")
    
    -- Панель игроков (прозрачная)
    local playersPanel = Instance.new("Frame")
    playersPanel.Size = UDim2.new(0, 280, 0, 300)
    playersPanel.Position = UDim2.new(0.5, -140, 0.5, -150)
    playersPanel.BackgroundTransparency = 1
    playersPanel.ClipsDescendants = true
    playersPanel.Parent = screenGui
    playersPanel.Visible = false
    playersPanel.ZIndex = 20
    
    -- Заголовок панели (без фона)
    local panelHeader = Instance.new("Frame")
    panelHeader.Size = UDim2.new(1, 0, 0, 30)
    panelHeader.BackgroundTransparency = 1
    panelHeader.Parent = playersPanel
    
    local panelTitle = Instance.new("TextLabel")
    panelTitle.Size = UDim2.new(1, -40, 1, 0)
    panelTitle.Position = UDim2.new(0, 10, 0, 0)
    panelTitle.BackgroundTransparency = 1
    panelTitle.Text = "Теги игроков"
    panelTitle.TextColor3 = Color3.new(1, 1, 1)
    panelTitle.TextSize = 14
    panelTitle.TextXAlignment = Enum.TextXAlignment.Left
    panelTitle.Font = Enum.Font.SourceSansBold
    panelTitle.Parent = panelHeader
    
    local closePanelBtn = Instance.new("TextButton")
    closePanelBtn.Size = UDim2.new(0, 30, 0, 30)
    closePanelBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closePanelBtn.BackgroundTransparency = 1
    closePanelBtn.Text = "✕"
    closePanelBtn.TextColor3 = Color3.new(1, 1, 1)
    closePanelBtn.TextSize = 18
    closePanelBtn.Parent = panelHeader
    
    -- Список игроков (прозрачный)
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(1, -10, 1, -45)
    playerList.Position = UDim2.new(0, 5, 0, 35)
    playerList.BackgroundTransparency = 1
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerList.ScrollBarThickness = 4
    playerList.ScrollBarImageColor3 = Color3.new(0.3, 0.3, 0.6)
    playerList.Parent = playersPanel
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 3)
    listLayout.Parent = playerList
    
    -- Кнопка добавления тега (без фона)
    local addTagBtn = Instance.new("TextButton")
    addTagBtn.Size = UDim2.new(1, -20, 0, 30)
    addTagBtn.Position = UDim2.new(0, 10, 1, -38)
    addTagBtn.BackgroundTransparency = 1
    addTagBtn.Text = "+ Добавить тег"
    addTagBtn.TextColor3 = Color3.new(0.3, 0.8, 0.3)
    addTagBtn.TextSize = 13
    addTagBtn.Parent = playersPanel
    
    local function UpdatePlayersList()
        for _, child in pairs(playerList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local canvasHeight = 0
        local allPlayers = {}
        for _, player in pairs(Players:GetPlayers()) do allPlayers[player.Name] = true end
        for name in pairs(presetTags) do allPlayers[name] = true end
        
        for playerName in pairs(allPlayers) do
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(1, -10, 0, 35)
            playerFrame.Position = UDim2.new(0, 5, 0, 0)
            playerFrame.BackgroundTransparency = 1
            playerFrame.Parent = playerList
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0, 85, 1, 0)
            nameLabel.Position = UDim2.new(0, 5, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = playerName
            nameLabel.TextColor3 = GetPlayerColor(playerName)
            nameLabel.TextSize = 13
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.Parent = playerFrame
            
            local tagInput = Instance.new("TextBox")
            tagInput.Size = UDim2.new(0, 110, 1, -4)
            tagInput.Position = UDim2.new(0, 95, 0, 2)
            tagInput.BackgroundColor3 = Color3.new(0.05, 0.05, 0.12)
            tagInput.BackgroundTransparency = 0
            tagInput.Text = GetPlayerTag(playerName)
            tagInput.TextColor3 = Color3.new(1, 1, 1)
            tagInput.TextSize = 12
            tagInput.ClearTextOnFocus = false
            tagInput.Parent = playerFrame
            local tagCorner = Instance.new("UICorner")
            tagCorner.CornerRadius = UDim.new(0, 4)
            tagCorner.Parent = tagInput
            
            local saveTagBtn = Instance.new("TextButton")
            saveTagBtn.Size = UDim2.new(0, 30, 1, -4)
            saveTagBtn.Position = UDim2.new(1, -36, 0, 2)
            saveTagBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
            saveTagBtn.BackgroundTransparency = 0
            saveTagBtn.Text = "✓"
            saveTagBtn.TextColor3 = Color3.new(1, 1, 1)
            saveTagBtn.TextSize = 16
            saveTagBtn.Parent = playerFrame
            local saveCorner = Instance.new("UICorner")
            saveCorner.CornerRadius = UDim.new(0, 4)
            saveCorner.Parent = saveTagBtn
            
            saveTagBtn.MouseButton1Click:Connect(function()
                local newTag = tagInput.Text
                if newTag ~= "" then
                    playerTags[playerName] = newTag
                    presetTags[playerName] = {tag = newTag, color = GetTagColor(playerName)}
                    tagsEvent:FireServer(playerName, newTag)
                end
            end)
            canvasHeight = canvasHeight + 38
        end
        playerList.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    end
    
    addTagBtn.MouseButton1Click:Connect(function()
        local dialog = Instance.new("Frame")
        dialog.Size = UDim2.new(0, 240, 0, 110)
        dialog.Position = UDim2.new(0.5, -120, 0.5, -55)
        dialog.BackgroundColor3 = Color3.new(0.05, 0.05, 0.12)
        dialog.BackgroundTransparency = 0
        dialog.Parent = playersPanel
        dialog.ZIndex = 25
        local dialogCorner = Instance.new("UICorner")
        dialogCorner.CornerRadius = UDim.new(0, 8)
        dialogCorner.Parent = dialog
        
        local nameInput = Instance.new("TextBox")
        nameInput.Size = UDim2.new(1, -20, 0, 28)
        nameInput.Position = UDim2.new(0, 10, 0, 8)
        nameInput.BackgroundColor3 = Color3.new(0.05, 0.05, 0.12)
        nameInput.BackgroundTransparency = 0
        nameInput.PlaceholderText = "Имя игрока..."
        nameInput.TextColor3 = Color3.new(1, 1, 1)
        nameInput.TextSize = 13
        nameInput.Parent = dialog
        
        local tagInput2 = Instance.new("TextBox")
        tagInput2.Size = UDim2.new(1, -20, 0, 28)
        tagInput2.Position = UDim2.new(0, 10, 0, 40)
        tagInput2.BackgroundColor3 = Color3.new(0.05, 0.05, 0.12)
        tagInput2.BackgroundTransparency = 0
        tagInput2.PlaceholderText = "Тег (например [VIP])..."
        tagInput2.TextColor3 = Color3.new(1, 1, 1)
        tagInput2.TextSize = 13
        tagInput2.Parent = dialog
        
        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Size = UDim2.new(0, 75, 0, 28)
        confirmBtn.Position = UDim2.new(0.5, -80, 0, 74)
        confirmBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        confirmBtn.BackgroundTransparency = 0
        confirmBtn.Text = "Добавить"
        confirmBtn.TextColor3 = Color3.new(1, 1, 1)
        confirmBtn.TextSize = 13
        confirmBtn.Parent = dialog
        local confCorner = Instance.new("UICorner")
        confCorner.CornerRadius = UDim.new(0, 5)
        confCorner.Parent = confirmBtn
        
        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0, 75, 0, 28)
        cancelBtn.Position = UDim2.new(0.5, 5, 0, 74)
        cancelBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
        cancelBtn.BackgroundTransparency = 0
        cancelBtn.Text = "Отмена"
        cancelBtn.TextColor3 = Color3.new(1, 1, 1)
        cancelBtn.TextSize = 13
        cancelBtn.Parent = dialog
        local cancCorner = Instance.new("UICorner")
        cancCorner.CornerRadius = UDim.new(0, 5)
        cancCorner.Parent = cancelBtn
        
        confirmBtn.MouseButton1Click:Connect(function()
            local name = nameInput.Text
            local tag = tagInput2.Text
            if name ~= "" and tag ~= "" then
                presetTags[name] = {tag = tag, color = GetTagColor(name)}
                playerTags[name] = tag
                tagsEvent:FireServer(name, tag)
                dialog:Destroy()
                UpdatePlayersList()
            end
        end)
        cancelBtn.MouseButton1Click:Connect(function() dialog:Destroy() end)
    end)
    
    playersBtn.MouseButton1Click:Connect(function()
        playersPanel.Visible = not playersPanel.Visible
        if playersPanel.Visible then UpdatePlayersList() end
    end)
    closePanelBtn.MouseButton1Click:Connect(function() playersPanel.Visible = false end)
    Players.PlayerAdded:Connect(function()
        if playersPanel and playersPanel.Visible then UpdatePlayersList() end
    end)
    
    -- Перетаскивание
    local isDragging = false
    local dragStartPos = Vector2.new()
    local containerStartPos = Vector2.new()
    
    chatInput.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPos = input.Position
            containerStartPos = Vector2.new(chatX, chatY)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then isDragging = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStartPos
            chatX = containerStartPos.X + delta.X
            chatY = containerStartPos.Y + delta.Y
            chatContainer.Position = UDim2.new(1, chatX, 0, chatY)
        end
    end)
    
    local isOpen = true
    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetPos
        if isOpen then
            targetPos = UDim2.new(1, chatX, 0, chatY)
        else
            targetPos = UDim2.new(1, chatX + chatWidth + 10, 0, chatY)
        end
        local tween = TweenService:Create(chatContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos})
        tween:Play()
    end)
    
    -- Сообщения
    local function AddMessage(playerName, message)
        if message == "" or message == " " then return end
        local tag = GetPlayerTag(playerName)
        local player = Players:FindFirstChild(playerName)
        local avatarUrl = "rbxassetid://0"
        if player then avatarUrl = GetPlayerAvatar(player) end
        
        local msg = Instance.new("Frame")
        msg.Size = UDim2.new(1, -10, 0, 35)
        msg.Position = UDim2.new(0, 5, 0, 0)
        msg.BackgroundTransparency = 1
        msg.Parent = messageList
        
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 30, 0, 30)
        avatar.Position = UDim2.new(0, 4, 0.5, -15)
        avatar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
        avatar.BackgroundTransparency = 0
        avatar.Image = avatarUrl
        avatar.Parent = msg
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatar
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -45, 0, 16)
        nameLabel.Position = UDim2.new(0, 40, 0, 2)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = playerName .. " " .. tag
        nameLabel.TextColor3 = GetPlayerColor(playerName)
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = msg
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -45, 1, -20)
        textLabel.Position = UDim2.new(0, 40, 0, 18)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = message
        textLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        textLabel.TextSize = 11
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextWrapped = true
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.Parent = msg
        
        if playerName == Player.Name then
            nameLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
        end
        
        local textBounds = textLabel.TextBounds
        local lineCount = math.ceil(textBounds.Y / 14)
        local height = math.max(35, 20 + lineCount * 14)
        msg.Size = UDim2.new(1, -10, 0, height)
        textLabel.Size = UDim2.new(1, -45, 0, height - 20)
        textLabel.Position = UDim2.new(0, 40, 0, 18)
        
        messageList.CanvasSize = UDim2.new(0, 0, 0, messageList.CanvasSize.Y.Offset + height + 4)
        messageList.CanvasPosition = Vector2.new(0, messageList.CanvasSize.Y.Offset)
    end
    
    local function SendMessage()
        local text = chatInput.Text
        if text ~= "" and text ~= " " then
            chatEvent:FireServer(text)
            chatInput.Text = ""
        end
    end
    
    chatInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then SendMessage() end
    end)
    sendBtn.MouseButton1Click:
