-- // UI Library
local UI = {}
UI.__index = UI

UI.Version = "1.0.1"
UI.ReleaseDate = "Sun Mar 15 2026"

-- remove old ui
if _G.UI then
	_G.UI:Destroy()
	_G.UI = nil
end

local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

-- theme
UI.bg = Color3.fromRGB(30,30,30)
UI.fg = Color3.fromRGB(45,45,45)
UI.tx = Color3.fromRGB(255,255,255)
UI.stroke = Color3.fromRGB(70,70,70)

-- main container
UI.Main = Instance.new("ScreenGui")
UI.Main.Name = "UILibrary"
UI.Main.Parent = CoreGui
_G.UI = UI.Main

--------------------------------------------------
-- helper: round
--------------------------------------------------

function UI:Round(gui, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = gui
end

--------------------------------------------------
-- helper: stroke
--------------------------------------------------

function UI:Stroke(gui)
	local s = Instance.new("UIStroke")
	s.Color = self.stroke
	s.Thickness = 1
	s.Parent = gui
end

--------------------------------------------------
-- drag
--------------------------------------------------

function UI:MakeDraggable(gui)
	local dragging = false
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		gui.Position = UDim2.new(
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
			startPos = gui.Position

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

--------------------------------------------------
-- window
--------------------------------------------------

function UI:Window(title, size)

	local Frame = Instance.new("Frame")
	Frame.Size = size or UDim2.new(.4,0,.4,0)
	Frame.Position = UDim2.new(.3,0,.3,0)
	Frame.BackgroundColor3 = self.bg
	Frame.Parent = self.Main

	self:Round(Frame,10)
	self:Stroke(Frame)
	self:MakeDraggable(Frame)

	-- title bar
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1,0,0,32)
	Title.BackgroundColor3 = self.fg
	Title.Text = title or "Window"
	Title.TextColor3 = self.tx
	Title.TextSize = 16
	Title.Font = Enum.Font.GothamBold
	Title.Parent = Frame

	self:Round(Title,10)
	self:Stroke(Title)

	-- container
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1,-10,1,-42)
	Container.Position = UDim2.new(0,5,0,37)
	Container.BackgroundTransparency = 1
	Container.Parent = Frame

	-- auto layout
	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0,6)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = Container

	local Window = {}
	Window.Container = Container

	--------------------------------------------------
	-- label
	--------------------------------------------------

	function Window:Label(text)

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1,0,0,25)
		Label.BackgroundTransparency = 1
		Label.Text = text or "Label"
		Label.TextColor3 = UI.tx
		Label.TextSize = 14
		Label.Font = Enum.Font.Gotham
		Label.Parent = Container

		return Label
	end

	--------------------------------------------------
	-- button
	--------------------------------------------------

	function Window:Button(text, callback)

		local Button = Instance.new("TextButton")
		Button.Size = UDim2.new(1,0,0,30)
		Button.BackgroundColor3 = UI.fg
		Button.Text = text or "Button"
		Button.TextColor3 = UI.tx
		Button.TextSize = 14
		Button.Font = Enum.Font.Gotham
		Button.Parent = Container

		UI:Round(Button,8)
		UI:Stroke(Button)

		Button.MouseButton1Click:Connect(function()
			if callback then
				callback()
			end
		end)

		return Button
	end

	return Window
end

return UI
