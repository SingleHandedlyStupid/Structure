local UI = {}
UI.__index = UI

-- destroy old UI
if _G.UI then
	_G.UI:Destroy()
end

local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

UI.bg = Color3.fromRGB(30,30,30)
UI.fg = Color3.fromRGB(45,45,45)
UI.accent = Color3.fromRGB(0,170,255)
UI.tx = Color3.new(1,1,1)

-- main gui
UI.Main = Instance.new("ScreenGui")
UI.Main.Name = "StructureUI"
UI.Main.Parent = CoreGui
_G.UI = UI.Main

------------------------------------------------
-- helpers
------------------------------------------------

function UI:Round(gui,r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,r or 6)
	c.Parent = gui
end

function UI:Stroke(gui)
	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(70,70,70)
	s.Thickness = 1
	s.Parent = gui
end

-- draggable only on specific frame
function UI:MakeDraggable(gui)
	local dragging = false
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		gui.Parent.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = gui.Parent.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)
end

------------------------------------------------
-- window
------------------------------------------------

function UI:Window(title)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(.45,0,.5,0)
	frame.Position = UDim2.new(.25,0,.25,0)
	frame.BackgroundColor3 = UI.bg
	frame.Parent = UI.Main

	self:Round(frame,10)
	self:Stroke(frame)

	-- title bar
	local titleBar = Instance.new("TextLabel")
	titleBar.Size = UDim2.new(1,0,0,32)
	titleBar.Text = title
	titleBar.BackgroundColor3 = UI.fg
	titleBar.TextColor3 = UI.tx
	titleBar.Font = Enum.Font.GothamBold
	titleBar.TextSize = 16
	titleBar.Parent = frame

	self:Round(titleBar,10)
	self:Stroke(titleBar)
	self:MakeDraggable(titleBar) -- only title bar draggable

	-- tab buttons
	local tabButtons = Instance.new("Frame")
	tabButtons.Size = UDim2.new(0,120,1,-32)
	tabButtons.Position = UDim2.new(0,0,0,32)
	tabButtons.BackgroundColor3 = UI.bg
	tabButtons.Parent = frame

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0,6)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabButtons

	-- pages container
	local pages = Instance.new("Frame")
	pages.Size = UDim2.new(1,-120,1,-32)
	pages.Position = UDim2.new(0,120,0,32)
	pages.BackgroundTransparency = 1
	pages.Parent = frame

	local window = {}
	window.TitleBar = titleBar

	function window:Tab(name)
		local tabButton = Instance.new("TextButton")
		tabButton.Size = UDim2.new(1,-10,0,30)
		tabButton.Text = name
		tabButton.BackgroundColor3 = UI.fg
		tabButton.TextColor3 = UI.tx
		tabButton.Parent = tabButtons

		UI:Round(tabButton,6)

		local page = Instance.new("Frame")
		page.Size = UDim2.new(1,0,1,0)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.Parent = pages

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0,6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = page

		tabButton.MouseButton1Click:Connect(function()
			for _,p in pairs(pages:GetChildren()) do
				if p:IsA("Frame") then
					p.Visible = false
				end
			end
			page.Visible = true
		end)

		local tab = {}

		function tab:Label(text)
			local l = Instance.new("TextLabel")
			l.Size = UDim2.new(1,0,0,24)
			l.BackgroundTransparency = 1
			l.Text = text
			l.TextColor3 = UI.tx
			l.Font = Enum.Font.Gotham
			l.TextSize = 14
			l.Parent = page
		end

		function tab:Button(text,callback)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1,0,0,30)
			b.BackgroundColor3 = UI.fg
			b.Text = text
			b.TextColor3 = UI.tx
			b.Font = Enum.Font.Gotham
			b.TextSize = 14
			b.Parent = page
			UI:Round(b,6)
			b.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)
		end

		function tab:Toggle(text,callback)
			local state = false
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1,0,0,30)
			b.BackgroundColor3 = UI.fg
			b.TextColor3 = UI.tx
			b.Font = Enum.Font.Gotham
			b.TextSize = 14
			b.Text = text.." : OFF"
			b.Parent = page
			UI:Round(b,6)
			b.MouseButton1Click:Connect(function()
				state = not state
				b.Text = text.." : "..(state and "ON" or "OFF")
				if callback then callback(state) end
			end)
		end

		function tab:Slider(text,min,max,callback)
			local value = min
			local frameS = Instance.new("Frame")
			frameS.Size = UDim2.new(1,0,0,40)
			frameS.BackgroundTransparency = 1
			frameS.Parent = page

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1,0,0,16)
			label.BackgroundTransparency = 1
			label.TextColor3 = UI.tx
			label.Font = Enum.Font.Gotham
			label.TextSize = 14
			label.Text = text.." : "..value
			label.Parent = frameS

			local bar = Instance.new("Frame")
			bar.Size = UDim2.new(1,0,0,10)
			bar.Position = UDim2.new(0,0,0,22)
			bar.BackgroundColor3 = UI.fg
			bar.Parent = frameS
			UI:Round(bar,6)

			local fill = Instance.new("Frame")
			fill.Size = UDim2.new(0,0,1,0)
			fill.BackgroundColor3 = UI.accent
			fill.Parent = bar
			UI:Round(fill,6)

			local dragging = false
			bar.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)
			UIS.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			UIS.InputChanged:Connect(function(i)
				if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
					local percent = math.clamp(
						(i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
						0,
						1
					)
					fill.Size = UDim2.new(percent,0,1,0)
					value = math.floor(min + (max-min)*percent)
					label.Text = text.." : "..value
					if callback then callback(value) end
				end
			end)
		end

		return tab
	end

	return window
end

return UI
