-- [[ todv2 ULTIMATE UI Library V9.2 - TOD999 Hub Custom Config ]] --
-- Author = "by .nongtitle"
 
local NovaUI = {}
 
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function ProtectGui(gui)
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
			gui.Parent = CoreGui
		elseif gethui then
			gui.Parent = gethui()
		else
			gui.Parent = CoreGui
		end
	end)
	if not gui.Parent then
		gui.Parent = PlayerGui
	end
end

function NovaUI:CreateWindow(config)
	--------------------------------------------------------------------
	-- [ระบบจัดการ Config: TOD999 Hub/NovaUI_Configs[PlaceId].json]
	--------------------------------------------------------------------
	local MainFolder = "TOD999 Hub"
	local ConfigFileName = MainFolder .. "/NovaUI_Configs" .. tostring(game.PlaceId) .. ".json"
 
	local function SaveConfigNow(data)
		pcall(function()
			if not writefile then return end
			if isfolder and not isfolder(MainFolder) and makefolder then 
				makefolder(MainFolder) 
			end
			local encoded = HttpService:JSONEncode(data)
			writefile(ConfigFileName, encoded)
		end)
	end
 
	local function LoadConfig()
		local loadedData = nil
		pcall(function()
			if isfile and readfile and isfile(ConfigFileName) then
				local content = readfile(ConfigFileName)
				if content and #content > 0 then
					loadedData = HttpService:JSONDecode(content)
				end
			end
		end)
		return loadedData or {}
	end

	local SavedSettings = LoadConfig()
	local isDataChanged = false

	task.spawn(function()
		while task.wait(1) do
			if isDataChanged then
				SaveConfigNow(SavedSettings)
				isDataChanged = false
			end
		end
	end)

	--------------------------------------------------------------------
	-- [ระบบ Auto-Flag]
	--------------------------------------------------------------------
	local flagCounts = {}
	local function getAutoFlag(name)
		local cleanName = string.gsub(name or "Element", "[%s%p]", "_")
		flagCounts[cleanName] = (flagCounts[cleanName] or 0) + 1
		if flagCounts[cleanName] > 1 then
			return cleanName .. "_" .. tostring(flagCounts[cleanName])
		end
		return cleanName
	end

	--------------------------------------------------------------------
	-- [สร้างหน้าต่างหลักของ UI]
	--------------------------------------------------------------------
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "NovaUI_V9_TOD999"
	ScreenGui.ResetOnSpawn = false
	ProtectGui(ScreenGui)

	--------------------------------------------------------------------
	-- [ระบบแสดง FPS & Ping Watermark (มุมซ้ายบน)]
	--------------------------------------------------------------------
	local StatsFrame = Instance.new("Frame")
	StatsFrame.Size = UDim2.new(0, 160, 0, 28)
	StatsFrame.Position = UDim2.new(0, 15, 0, 15)
	StatsFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	StatsFrame.BackgroundTransparency = 0.2
	StatsFrame.BorderSizePixel = 0
	StatsFrame.Parent = ScreenGui
	Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 6)
	local StatsStroke = Instance.new("UIStroke", StatsFrame)
	StatsStroke.Color = Color3.fromRGB(45, 45, 60)
	StatsStroke.Thickness = 1

	local StatsLabel = Instance.new("TextLabel")
	StatsLabel.Size = UDim2.new(1, 0, 1, 0)
	StatsLabel.BackgroundTransparency = 1
	StatsLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
	StatsLabel.Font = Enum.Font.GothamBold
	StatsLabel.TextSize = 11
	StatsLabel.Text = "FPS: -- | Ping: -- ms"
	StatsLabel.Parent = StatsFrame

	-- คำนวณ FPS และ Ping แบบเรียลไทม์
	local fps, lastTick = 0, tick()
	RunService.RenderStepped:Connect(function()
		local currentTick = tick()
		fps = math.floor(1 / (currentTick - lastTick))
		lastTick = currentTick
		
		local ping = 0
		pcall(function()
			ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
		end)
		
		StatsLabel.Text = string.Bool and "" or string.format("⚡ FPS: %d | 🏓 Ping: %d ms", fps, ping)
	end)
 
	local NotifContainer = Instance.new("Frame")
	NotifContainer.Name = "NotifContainer"
	NotifContainer.Size = UDim2.new(0, 260, 1, -20)
	NotifContainer.Position = UDim2.new(0.5, 0, 1, -20)
	NotifContainer.AnchorPoint = Vector2.new(0.5, 1)
	NotifContainer.BackgroundTransparency = 1
	NotifContainer.Parent = ScreenGui
 
	local NotifLayout = Instance.new("UIListLayout")
	NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	NotifLayout.Padding = UDim.new(0, 10)
	NotifLayout.Parent = NotifContainer
 
	local FloatButton = Instance.new("TextButton")
	FloatButton.Size = UDim2.new(0, 50, 0, 50)
	FloatButton.Position = config.ButtonPosition or UDim2.new(0, 20, 0.5, -25)
	FloatButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	FloatButton.Text = config.Icon or "🧑‍💻"
	FloatButton.TextSize = 22
	FloatButton.TextColor3 = Color3.new(1,1,1)
	FloatButton.BorderSizePixel = 0
	FloatButton.ZIndex = 10
	FloatButton.Parent = ScreenGui
 
	local FloatCorner = Instance.new("UICorner") FloatCorner.CornerRadius = UDim.new(0, 12) FloatCorner.Parent = FloatButton
	local FloatStroke = Instance.new("UIStroke") FloatStroke.Color = Color3.fromRGB(0, 162, 255) FloatStroke.Thickness = 1.5 FloatStroke.Parent = FloatButton
 
	local Main = Instance.new("Frame")
	local originalSize = config.Size or UDim2.new(0, 540, 0, 380)
	Main.Size = originalSize
	Main.Position = UDim2.new(0.5, -270, 0.5, -190)
	Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui
	Main.Visible = true
 
	local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 10) MainCorner.Parent = Main
	local MainStroke = Instance.new("UIStroke") MainStroke.Color = Color3.fromRGB(35, 35, 45) MainStroke.Parent = Main
 
	local function MakeSmartDraggable(guiObject, onClickCallback)
		local dragging = false
		local dragInput, dragStart, startPos
		local isMoved = false
 
		guiObject.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				isMoved = false
				dragStart = input.Position
				startPos = guiObject.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						if not isMoved and onClickCallback then onClickCallback() end
					end
				end)
			end
		end)
 
		guiObject.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
 
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
					isMoved = true
					TweenService:Create(guiObject, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
					}):Play()
				end
			end
		end)
	end
 
	MakeSmartDraggable(FloatButton, function()
		Main.Visible = not Main.Visible 
	end)
 
	local Title = Instance.new("TextButton")
	Title.Size = UDim2.new(1, 0, 0, 40)
	Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	Title.Text = "   " .. (config.Name or "TOD999 Hub")
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 15
	Title.AutoButtonColor = false
	Title.BorderSizePixel = 0
	Title.Parent = Main
	local TitleCorner = Instance.new("UICorner") TitleCorner.CornerRadius = UDim.new(0, 10) TitleCorner.Parent = Title
	local TitleFix = Instance.new("Frame") TitleFix.Size = UDim2.new(1, 0, 0, 10) TitleFix.Position = UDim2.new(0, 0, 1, -10) TitleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 35) TitleFix.BorderSizePixel = 0 TitleFix.Parent = Title
 
	local draggingMain, dragStartMain, startPosMain, dragInputMain
	Title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingMain = true dragStartMain = input.Position startPosMain = Main.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingMain = false end end)
		end
	end)
	Title.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputMain = input end end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInputMain and draggingMain then
			local delta = input.Position - dragStartMain
			TweenService:Create(Main, TweenInfo.new(0.1), {Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)}):Play()
		end
	end)
 
	local CloseButton = Instance.new("TextButton")
	CloseButton.Size = UDim2.new(0, 30, 0, 30)
	CloseButton.Position = UDim2.new(1, -35, 0, 5)
	CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	CloseButton.Text = "❌"
	CloseButton.TextSize = 12
	CloseButton.TextColor3 = Color3.new(1,1,1)
	CloseButton.Parent = Title
	Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)
 
	local MinimizeButton = Instance.new("TextButton")
	MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
	MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
	MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	MinimizeButton.Text = "➖"
	MinimizeButton.TextSize = 12
	MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	MinimizeButton.Font = Enum.Font.GothamBold
	MinimizeButton.Parent = Title
	Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)
 
	local isMinimized = false
	MinimizeButton.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		if isMinimized then
			MinimizeButton.Text = "➕"
			TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 40)}):Play()
		else
			MinimizeButton.Text = "➖"
			TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = originalSize}):Play()
		end
	end)
 
	local AlertFrame = Instance.new("Frame") AlertFrame.Size = UDim2.new(0, 320, 0, 150) AlertFrame.Position = UDim2.new(0.5, -160, 0.5, -75) AlertFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35) AlertFrame.Visible = false AlertFrame.ZIndex = 20 AlertFrame.Parent = ScreenGui
	Instance.new("UICorner", AlertFrame).CornerRadius = UDim.new(0, 8) local AlertStroke = Instance.new("UIStroke", AlertFrame) AlertStroke.Color = Color3.fromRGB(200, 50, 50) AlertStroke.Thickness = 1.5
	local AlertText = Instance.new("TextLabel") AlertText.Size = UDim2.new(1, 0, 0, 60) AlertText.BackgroundTransparency = 1 AlertText.Text = "คุณต้องการลบ UI หรือไม่?" AlertText.TextColor3 = Color3.new(1,1,1) AlertText.Font = Enum.Font.GothamBold AlertText.TextSize = 16 AlertText.ZIndex = 21 AlertText.Parent = AlertFrame
	local NoBtn = Instance.new("TextButton") NoBtn.Size = UDim2.new(0, 110, 0, 35) NoBtn.Position = UDim2.new(0, 35, 0, 85) NoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127) NoBtn.Text = "ไม่ลบ" NoBtn.Font = Enum.Font.GothamSemibold NoBtn.TextColor3 = Color3.new(1,1,1) NoBtn.ZIndex = 21 NoBtn.Parent = AlertFrame Instance.new("UICorner", NoBtn)
	local YesBtn = Instance.new("TextButton") YesBtn.Size = UDim2.new(0, 110, 0, 35) YesBtn.Position = UDim2.new(1, -145, 0, 85) YesBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) YesBtn.Text = "ลบเลย" YesBtn.Font = Enum.Font.GothamSemibold YesBtn.TextColor3 = Color3.new(1,1,1) YesBtn.ZIndex = 21 YesBtn.Parent = AlertFrame Instance.new("UICorner", YesBtn)
 
	CloseButton.MouseButton1Click:Connect(function() AlertFrame.Visible = true end)
	NoBtn.MouseButton1Click:Connect(function() AlertFrame.Visible = false end)
	YesBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
 
	local Footer = Instance.new("TextLabel")
	Footer.Size = UDim2.new(1, 0, 0, 20)
	Footer.Position = UDim2.new(0, 0, 1, -20)
	Footer.BackgroundTransparency = 1
	Footer.Text = "YouTube: Todv2Hud"
	Footer.TextColor3 = Color3.fromRGB(100, 100, 110)
	Footer.Font = Enum.Font.GothamBold
	Footer.TextSize = 11
	Footer.Parent = Main
 
	local TabHolder = Instance.new("Frame") TabHolder.Size = UDim2.new(0, 130, 1, -60) TabHolder.Position = UDim2.new(0, 0, 0, 40) TabHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 35) TabHolder.BorderSizePixel = 0 TabHolder.Parent = Main
	local TabHolderLayout = Instance.new("UIListLayout", TabHolder) TabHolderLayout.Padding = UDim.new(0, 4) TabHolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local TabPadding = Instance.new("UIPadding", TabHolder) TabPadding.PaddingLeft = UDim.new(0, 5) TabPadding.PaddingRight = UDim.new(0, 5) TabPadding.PaddingTop = UDim.new(0, 5)
 
	local ProfileCard = Instance.new("Frame")
	ProfileCard.Size = UDim2.new(1, 0, 0, 45)
	ProfileCard.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	ProfileCard.BorderSizePixel = 0
	ProfileCard.LayoutOrder = -1
	ProfileCard.Parent = TabHolder
	Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0, 6)
 
	local AvatarImg = Instance.new("ImageLabel")
	AvatarImg.Size = UDim2.new(0, 32, 0, 32)
	AvatarImg.Position = UDim2.new(0, 6, 0.5, -16)
	AvatarImg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
	AvatarImg.Parent = ProfileCard
	Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)
 
	local NameLabel = Instance.new("TextLabel")
	NameLabel.Size = UDim2.new(1, -42, 0, 16)
	NameLabel.Position = UDim2.new(0, 42, 0, 7)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Text = LocalPlayer.DisplayName
	NameLabel.TextColor3 = Color3.new(1, 1, 1)
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.TextSize = 11
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.Parent = ProfileCard
 
	local UserLabel = Instance.new("TextLabel")
	UserLabel.Size = UDim2.new(1, -42, 0, 14)
	UserLabel.Position = UDim2.new(0, 42, 0, 23)
	UserLabel.BackgroundTransparency = 1
	UserLabel.Text = "@" .. LocalPlayer.Name
	UserLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
	UserLabel.Font = Enum.Font.Gotham
	UserLabel.TextSize = 9
	UserLabel.TextXAlignment = Enum.TextXAlignment.Left
	UserLabel.Parent = ProfileCard
 
	local ProfileDiv = Instance.new("Frame")
	ProfileDiv.Size = UDim2.new(1, -6, 0, 1)
	ProfileDiv.Position = UDim2.new(0, 3, 1, -1)
	ProfileDiv.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	ProfileDiv.BorderSizePixel = 0
	ProfileDiv.Parent = ProfileCard
 
	local Pages = Instance.new("Frame") Pages.Size = UDim2.new(1, -130, 1, -60) Pages.Position = UDim2.new(0, 130, 0, 40) Pages.BackgroundTransparency = 1 Pages.Parent = Main
 
local Window = {}

function Window:Notify(cfg)
		local titleText = cfg.Title or "TOD999 Hub"
		local contentText = cfg.Content or "Notification Content"
		local duration = cfg.Duration or 5
 
		local NotifFrame = Instance.new("Frame")
		NotifFrame.Size = UDim2.new(1, 0, 0, 0) 
		NotifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
		NotifFrame.BackgroundTransparency = 1
		NotifFrame.ClipsDescendants = true
		NotifFrame.Parent = NotifContainer
 
		Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)
		local NStroke = Instance.new("UIStroke", NotifFrame)
		NStroke.Color = Color3.fromRGB(0, 162, 255)
		NStroke.Thickness = 1.5
		NStroke.Transparency = 1
 
		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Size = UDim2.new(1, -20, 0, 25)
		TitleLabel.Position = UDim2.new(0, 10, 0, 5)
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Text = titleText
		TitleLabel.TextColor3 = Color3.new(1, 1, 1)
		TitleLabel.TextTransparency = 1
		TitleLabel.Font = Enum.Font.GothamBold
		TitleLabel.TextSize = 14
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.Parent = NotifFrame
 
		local ContentLabel = Instance.new("TextLabel")
		ContentLabel.Size = UDim2.new(1, -20, 0, 30)
		ContentLabel.Position = UDim2.new(0, 10, 0, 25)
		ContentLabel.BackgroundTransparency = 1
		ContentLabel.Text = contentText
		ContentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		ContentLabel.TextTransparency = 1
		ContentLabel.Font = Enum.Font.GothamSemibold
		ContentLabel.TextSize = 12
		ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
		ContentLabel.TextWrapped = true
		ContentLabel.Parent = NotifFrame
 
		local TweenIn = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		TweenService:Create(NotifFrame, TweenIn, {Size = UDim2.new(1, 0, 0, 65), BackgroundTransparency = 0}):Play()
		TweenService:Create(NStroke, TweenIn, {Transparency = 0}):Play()
		TweenService:Create(TitleLabel, TweenIn, {TextTransparency = 0}):Play()
		TweenService:Create(ContentLabel, TweenIn, {TextTransparency = 0}):Play()
 
		task.delay(duration, function()
			local TweenOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(NotifFrame, TweenOut, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}):Play()
			TweenService:Create(NStroke, TweenOut, {Transparency = 1}):Play()
			TweenService:Create(TitleLabel, TweenOut, {TextTransparency = 1}):Play()
			TweenService:Create(ContentLabel, TweenOut, {TextTransparency = 1}):Play()
			task.wait(0.3)
			NotifFrame:Destroy()
		end)
	end
 
	task.spawn(function()
		task.wait(0.6)
		Window:Notify({
			Title = "ยินดีต้อนรับ! 👋",
			Content = "โหลด Config จาก [TOD999 Hub] เรียบร้อย!",
			Duration = 4
		})
	end)

  function Window:CreateTab(name)
		local TabButton = Instance.new("TextButton") TabButton.Size = UDim2.new(1, 0, 0, 35) TabButton.Text = name TabButton.Font = Enum.Font.GothamBold TabButton.TextSize = 13 TabButton.BorderSizePixel = 0 TabButton.Parent = TabHolder
		Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
 
		local Page = Instance.new("ScrollingFrame") Page.Size = UDim2.new(1, 0, 1, 0) Page.CanvasSize = UDim2.new(0, 0, 0, 0) Page.ScrollBarThickness = 3 Page.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255) Page.BackgroundTransparency = 1 Page.BorderSizePixel = 0 Page.Visible = false Page.Parent = Pages
		local Layout = Instance.new("UIListLayout") Layout.Padding = UDim.new(0, 6) Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center Layout.Parent = Page
		Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 8)
 
		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
		end)
 
		local function updateTabVisuals()
			for _, v in ipairs(TabHolder:GetChildren()) do
				if v:IsA("TextButton") and v ~= ProfileCard then
					if v == TabButton then v.BackgroundColor3 = Color3.fromRGB(0, 162, 255) v.TextColor3 = Color3.fromRGB(18, 18, 24)
					else v.BackgroundColor3 = Color3.fromRGB(32, 32, 45) v.TextColor3 = Color3.fromRGB(200, 200, 200) end
				end
			end
		end
 
		TabButton.MouseButton1Click:Connect(function()
			for _, v in ipairs(Pages:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
			Page.Visible = true updateTabVisuals()
		end)
 
		local tabCount = 0
		for _, v in ipairs(TabHolder:GetChildren()) do if v:IsA("TextButton") and v ~= ProfileCard then tabCount = tabCount + 1 end end
 
		if tabCount == 1 then 
			Page.Visible = true 
			task.delay(0.1, updateTabVisuals)
		else 
			TabButton.BackgroundColor3 = Color3.fromRGB(32, 32, 45) 
			TabButton.TextColor3 = Color3.fromRGB(200, 200, 200) 
		end
 
		local Tab = {}
 
		function Tab:CreateLabel(cfg)
			local Label = Instance.new("TextLabel") Label.Size = UDim2.new(1, -16, 0, 25) Label.BackgroundTransparency = 1 Label.Text = cfg.Text or "Label" Label.TextColor3 = cfg.Color or Color3.fromRGB(220, 220, 220) Label.Font = Enum.Font.GothamSemibold Label.TextSize = 13 Label.TextXAlignment = Enum.TextXAlignment.Left Label.Parent = Page
			Instance.new("UIPadding", Label).PaddingLeft = UDim.new(0, 8)
			return {UpdateText = function(self, t) Label.Text = t end}
		end
 
		function Tab:CreateDivider()
			local Div = Instance.new("Frame") Div.Size = UDim2.new(1, -16, 0, 2) Div.BackgroundColor3 = Color3.fromRGB(40, 40, 52) Div.BorderSizePixel = 0 Div.Parent = Page
		end
 
		function Tab:CreateSection(name)
			local Sec = Instance.new("TextLabel") Sec.Size = UDim2.new(1, -16, 0, 30) Sec.BackgroundTransparency = 1 Sec.Text = "— " .. name .. " —" Sec.TextColor3 = Color3.fromRGB(0, 162, 255) Sec.Font = Enum.Font.GothamBold Sec.TextSize = 13 Sec.Parent = Page
		end
 
		function Tab:CreateButton(cfg)
			local Btn = Instance.new("TextButton") Btn.Size = UDim2.new(1, -16, 0, 36) Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38) Btn.TextColor3 = Color3.new(1,1,1) Btn.Font = Enum.Font.GothamSemibold Btn.TextSize = 13 Btn.Text = cfg.Name or "Button" Btn.Parent = Page Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6) Instance.new("UIStroke", Btn).Color = Color3.fromRGB(40, 40, 55)
			Btn.MouseButton1Click:Connect(function() if cfg.Callback then cfg.Callback() end end)
		end
 
		-- [ดีไซน์ Toggle ใหม่: แบบ WindUI Switch เดี่ยว]
		function Tab:CreateToggle(cfg)
			local flag = cfg.Flag or getAutoFlag(cfg.Name)
			local State = SavedSettings[flag] ~= nil and SavedSettings[flag] or (cfg.Default or false)
			
			local Tgl = Instance.new("TextButton")
			Tgl.Size = UDim2.new(1, -16, 0, 38)
			Tgl.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
			Tgl.Text = ""
			Tgl.AutoButtonColor = false
			Tgl.Parent = Page
			Instance.new("UICorner", Tgl).CornerRadius = UDim.new(0, 6)
			local TS = Instance.new("UIStroke", Tgl)
			TS.Color = Color3.fromRGB(40, 40, 55)
			
			local Lbl = Instance.new("TextLabel")
			Lbl.Size = UDim2.new(1, -60, 1, 0)
			Lbl.Position = UDim2.new(0, 12, 0, 0)
			Lbl.BackgroundTransparency = 1
			Lbl.Text = cfg.Name or "Toggle"
			Lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
			Lbl.Font = Enum.Font.GothamSemibold
			Lbl.TextSize = 13
			Lbl.TextXAlignment = Enum.TextXAlignment.Left
			Lbl.Parent = Tgl
			
			local SwitchBg = Instance.new("Frame")
			SwitchBg.Size = UDim2.new(0, 38, 0, 20)
			SwitchBg.Position = UDim2.new(1, -48, 0.5, -10)
			SwitchBg.BackgroundColor3 = State and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(45, 45, 60)
			SwitchBg.Parent = Tgl
			Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
			
			local SwitchKnob = Instance.new("Frame")
			SwitchKnob.Size = UDim2.new(0, 16, 0, 16)
			SwitchKnob.Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
			SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SwitchKnob.Parent = SwitchBg
			Instance.new("UICorner", SwitchKnob).CornerRadius = UDim.new(1, 0)
			
			if State and cfg.Callback then 
				task.spawn(function() pcall(function() cfg.Callback(true) end) end) 
			end

			Tgl.MouseButton1Click:Connect(function()
				State = not State 
				SavedSettings[flag] = State
				isDataChanged = true
				
				TweenService:Create(SwitchBg, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					BackgroundColor3 = State and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(45, 45, 60)
				}):Play()
				
				TweenService:Create(SwitchKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
				}):Play()
				
				if cfg.Callback then cfg.Callback(State) end
			end)
		end
 
		function Tab:CreateTextbox(cfg)
			local flag = cfg.Flag or getAutoFlag(cfg.Name)
			local defaultText = SavedSettings[flag] or cfg.Placeholder or "Type..."

			local Box = Instance.new("Frame") Box.Size = UDim2.new(1, -16, 0, 38) Box.BackgroundColor3 = Color3.fromRGB(28, 28, 38) Box.Parent = Page Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6) Instance.new("UIStroke", Box).Color = Color3.fromRGB(40, 40, 55)
			local Lbl = Instance.new("TextLabel") Lbl.Size = UDim2.new(0.5, 0, 1, 0) Lbl.Position = UDim2.new(0, 10, 0, 0) Lbl.BackgroundTransparency = 1 Lbl.Text = cfg.Name or "Textbox" Lbl.TextColor3 = Color3.new(1,1,1) Lbl.Font = Enum.Font.GothamSemibold Lbl.TextSize = 13 Lbl.TextXAlignment = Enum.TextXAlignment.Left Lbl.Parent = Box
			local TB = Instance.new("TextBox") TB.Size = UDim2.new(0.4, 0, 0, 26) TB.Position = UDim2.new(0.6, -10, 0.5, -13) TB.BackgroundColor3 = Color3.fromRGB(18, 18, 24) TB.Text = defaultText TB.TextColor3 = Color3.new(1,1,1) TB.Font = Enum.Font.Gotham TB.TextSize = 12 TB.Parent = Box Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 4)
			
			if SavedSettings[flag] and cfg.Callback then 
				task.spawn(function() pcall(function() cfg.Callback(defaultText) end) end) 
			end

			TB.FocusLost:Connect(function() 
				SavedSettings[flag] = TB.Text
				isDataChanged = true
				if cfg.Callback then cfg.Callback(TB.Text) end 
			end)
		end
 
		function Tab:CreateKeybind(cfg)
			local Bind = cfg.Default or Enum.KeyCode.E local Listening = false
			local Frame = Instance.new("Frame") Frame.Size = UDim2.new(1, -16, 0, 36) Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38) Frame.Parent = Page Instance.new("UICorner", Frame) Instance.new("UIStroke", Frame).Color = Color3.fromRGB(40, 40, 55)
			local Lbl = Instance.new("TextLabel") Lbl.Size = UDim2.new(0.5, 0, 1, 0) Lbl.Position = UDim2.new(0, 10, 0, 0) Lbl.BackgroundTransparency = 1 Lbl.Text = cfg.Name or "Keybind" Lbl.TextColor3 = Color3.new(1,1,1) Lbl.Font = Enum.Font.GothamSemibold Lbl.TextSize = 13 Lbl.TextXAlignment = Enum.TextXAlignment.Left Lbl.Parent = Frame
			local Btn = Instance.new("TextButton") Btn.Size = UDim2.new(0, 80, 0, 24) Btn.Position = UDim2.new(1, -90, 0.5, -12) Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55) Btn.Text = Bind.Name Btn.TextColor3 = Color3.fromRGB(0, 162, 255) Btn.Font = Enum.Font.GothamBold Btn.TextSize = 12 Btn.Parent = Frame Instance.new("UICorner", Btn)
			Btn.MouseButton1Click:Connect(function() Listening = true Btn.Text = "..." end)
			UserInputService.InputBegan:Connect(function(input)
				if Listening and input.UserInputType == Enum.UserInputType.Keyboard then Bind = input.KeyCode Btn.Text = Bind.Name Listening = false
				elseif not Listening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Bind then if cfg.Callback then cfg.Callback() end end
			end)
		end
 
		function Tab:CreateColorPicker(cfg)
			local Hue, Sat, Vib = 0, 1, 1
			local Open = false
			local IsRGB = false
 
			local PickerFrame = Instance.new("Frame") PickerFrame.Size = UDim2.new(1, -16, 0, 38) PickerFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38) PickerFrame.ClipsDescendants = true PickerFrame.Parent = Page
			Instance.new("UICorner", PickerFrame).CornerRadius = UDim.new(0, 6) local PS = Instance.new("UIStroke", PickerFrame) PS.Color = Color3.fromRGB(40, 40, 55)
 
			local Lbl = Instance.new("TextLabel") Lbl.Size = UDim2.new(0.4, 0, 0, 38) Lbl.Position = UDim2.new(0, 10, 0, 0) Lbl.BackgroundTransparency = 1 Lbl.Text = cfg.Name or "Color Picker" Lbl.TextColor3 = Color3.new(1,1,1) Lbl.Font = Enum.Font.GothamSemibold Lbl.TextSize = 13 Lbl.TextXAlignment = Enum.TextXAlignment.Left Lbl.Parent = PickerFrame
 
			local ColorShow = Instance.new("TextButton") ColorShow.Size = UDim2.new(0, 35, 0, 20) ColorShow.Position = UDim2.new(1, -45, 0, 9) ColorShow.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib) ColorShow.Text = "" ColorShow.Parent = PickerFrame Instance.new("UICorner", ColorShow).CornerRadius = UDim.new(0, 4)
 
			local HueSlider = Instance.new("TextButton") HueSlider.Size = UDim2.new(1, -110, 0, 15) HueSlider.Position = UDim2.new(0, 10, 0, 48) HueSlider.Text = "" HueSlider.AutoButtonColor = false HueSlider.Parent = PickerFrame Instance.new("UICorner", HueSlider)
			local Gradient = Instance.new("UIGradient") Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))}) Gradient.Parent = HueSlider
			local SliderBar = Instance.new("Frame") SliderBar.Size = UDim2.new(0, 4, 1, 4) SliderBar.Position = UDim2.new(0, 0, 0, -2) SliderBar.BackgroundColor3 = Color3.new(1, 1, 1) SliderBar.Parent = HueSlider Instance.new("UIStroke", SliderBar).Color = Color3.new(0,0,0)
 
			local RGBBtn = Instance.new("TextButton") RGBBtn.Size = UDim2.new(0, 75, 0, 24) RGBBtn.Position = UDim2.new(1, -85, 0, 44) RGBBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60) RGBBtn.Text = "RGB: OFF" RGBBtn.Font = Enum.Font.GothamBold RGBBtn.TextColor3 = Color3.fromRGB(200, 200, 200) RGBBtn.TextSize = 11 RGBBtn.Parent = PickerFrame Instance.new("UICorner", RGBBtn).CornerRadius = UDim.new(0, 4)
 
			local dragging = false
			local function updateColor(input)
				if IsRGB then return end
				local pos = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
				SliderBar.Position = UDim2.new(pos, -2, 0, -2)
				Hue = pos
				local FinalColor = Color3.fromHSV(Hue, Sat, Vib)
				ColorShow.BackgroundColor3 = FinalColor
				if cfg.Callback then cfg.Callback(FinalColor) end
			end
 
			task.spawn(function()
				local rainbowHue = 0
				while true do
					if IsRGB and ScreenGui.Parent then
						rainbowHue = rainbowHue + 0.005
						if rainbowHue > 1 then rainbowHue = 0 end
						local RainbowColor = Color3.fromHSV(rainbowHue, 1, 1)
						ColorShow.BackgroundColor3 = RainbowColor
						if cfg.Callback then cfg.Callback(RainbowColor) end
					else
						if not ScreenGui.Parent then break end
					end
					task.wait(0.03)
				end
			end)
 
			RGBBtn.MouseButton1Click:Connect(function()
				IsRGB = not IsRGB
				if IsRGB then
					RGBBtn.Text = "RGB: ON" RGBBtn.TextColor3 = Color3.fromRGB(0, 255, 127) RGBBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 45)
				else
					RGBBtn.Text = "RGB: OFF" RGBBtn.TextColor3 = Color3.fromRGB(200, 200, 200) RGBBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
					local FinalColor = Color3.fromHSV(Hue, Sat, Vib)
					ColorShow.BackgroundColor3 = FinalColor
					if cfg.Callback then cfg.Callback(FinalColor) end
				end
			end)
 
			HueSlider.InputBegan:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not IsRGB then dragging = true updateColor(input) end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateColor(input) end
			end)
 
			ColorShow.MouseButton1Click:Connect(function()
				Open = not Open
				TweenService:Create(PickerFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -16, 0, Open and 80 or 38)}):Play()
			end)
		end
 
		function Tab:CreateSlider(cfg)
			local flag = cfg.Flag or getAutoFlag(cfg.Name)
			local Min, Max = cfg.Min or 0, cfg.Max or 100
			local Value = SavedSettings[flag] ~= nil and SavedSettings[flag] or math.clamp(cfg.Default or Min, Min, Max)
			
			local SFrame = Instance.new("Frame") SFrame.Size = UDim2.new(1, -16, 0, 48) SFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38) SFrame.Parent = Page Instance.new("UICorner", SFrame)
			local SText = Instance.new("TextLabel") SText.Size = UDim2.new(1, -16, 0, 20) SText.Position = UDim2.new(0, 10, 0, 4) SText.BackgroundTransparency = 1 SText.Text = (cfg.Name or "Slider") .. " : " .. tostring(Value) SText.TextColor3 = Color3.new(1,1,1) SText.Font = Enum.Font.GothamSemibold SText.TextSize = 12 SText.Parent = SFrame
			local SBG = Instance.new("TextButton") SBG.Size = UDim2.new(1, -20, 0, 6) SBG.Position = UDim2.new(0, 10, 0, 30) SBG.BackgroundColor3 = Color3.fromRGB(18, 18, 24) SBG.Text = "" SBG.AutoButtonColor = false SBG.Parent = SFrame Instance.new("UICorner", SBG)
			local SFill = Instance.new("Frame") SFill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0) SFill.BackgroundColor3 = Color3.fromRGB(0, 162, 255) SFill.Parent = SBG Instance.new("UICorner", SFill)
			
			if SavedSettings[flag] and cfg.Callback then 
				task.spawn(function() pcall(function() cfg.Callback(Value) end) end) 
			end

			local dragging = false
			local function updateSlider(input)
				local pos = math.clamp((input.Position.X - SBG.AbsolutePosition.X) / SBG.AbsoluteSize.X, 0, 1)
				Value = math.floor(Min + ((Max - Min) * pos)) SFill.Size = UDim2.new(pos, 0, 1, 0) SText.Text = (cfg.Name or "Slider") .. " : " .. tostring(Value)
				
				SavedSettings[flag] = Value
				isDataChanged = true
				
				if cfg.Callback then cfg.Callback(Value) end
			end
			SBG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true updateSlider(input) end end)
			UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
			UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
		end
 
		function Tab:CreateDropdown(cfg)
			local Options = cfg.Options or {} 
			local flag = cfg.Flag or getAutoFlag(cfg.Name)
			local CurrentOption = SavedSettings[flag] or cfg.Default or "Select..." 
			local IsOpen = false

			local Container = Instance.new("Frame") Container.Size = UDim2.new(1, -16, 0, 36) Container.BackgroundTransparency = 1 Container.ClipsDescendants = true Container.Parent = Page
			local Btn = Instance.new("TextButton") Btn.Size = UDim2.new(1, 0, 0, 36) Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38) Btn.TextColor3 = Color3.new(1,1,1) Btn.Font = Enum.Font.GothamSemibold Btn.TextSize = 13 Btn.Text = (cfg.Name or "Dropdown") .. "  ▼  (" .. CurrentOption .. ")" Btn.Parent = Container Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
			local Frame = Instance.new("Frame") Frame.Size = UDim2.new(1, 0, 1, -36) Frame.Position = UDim2.new(0, 0, 0, 36) Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 30) Frame.Parent = Container Instance.new("UIListLayout", Frame)
			
			if SavedSettings[flag] and cfg.Callback then 
				task.spawn(function() pcall(function() cfg.Callback(CurrentOption) end) end) 
			end

			local function toggle()
				IsOpen = not IsOpen local target = IsOpen and (36 + (#Options * 30)) or 36
				TweenService:TextButton = nil
				TweenService:Create(Container, TweenInfo.new(0.2), {Size = UDim2.new(1, -16, 0, target)}):Play()
				Btn.Text = (cfg.Name or "Dropdown") .. (IsOpen and "  ▲  (" or "  ▼  (") .. CurrentOption .. ")"
			end
			Btn.MouseButton1Click:Connect(toggle)
			for _, option in ipairs(Options) do
				local OBtn = Instance.new("TextButton") OBtn.Size = UDim2.new(1, 0, 0, 30) OBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30) OBtn.TextColor3 = Color3.fromRGB(180, 180, 190) OBtn.Font = Enum.Font.Gotham OBtn.TextSize = 12 OBtn.Text = option OBtn.Parent = Frame
				OBtn.MouseButton1Click:Connect(function() 
					CurrentOption = option 
					toggle() 
					SavedSettings[flag] = option
					isDataChanged = true
					if cfg.Callback then cfg.Callback(option) end 
				end)
			end
		end
 
		return Tab
	end
 
	return Window
end
 
return NovaUI
  
