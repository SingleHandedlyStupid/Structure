local UI = {}
UI.__index = UI
UI.Version = "1.0.3"

-- Destroy previous UI
if _G.UI then
    _G.UI:Destroy()
end

local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
_G.UI = nil

-- ====== Default Theme ======
UI.Theme = {
    bg = Color3.fromRGB(30,30,30),
    fg = Color3.fromRGB(45,45,45),
    accent = Color3.fromRGB(0,170,255),
    tx = Color3.new(1,1,1)
}

-- ====== Main UI ======
UI.Main = Instance.new("ScreenGui")
UI.Main.Name = "StructureUI"
UI.Main.Parent = CoreGui
_G.UI = UI.Main

-- ====== Helpers ======
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

-- Dragging only on specified frame
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

-- ====== Window ======
function UI:Window(title)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(.45,0,.5,0)
    frame.Position = UDim2.new(.25,0,.25,0)
    frame.BackgroundColor3 = UI.Theme.bg
    frame.Parent = UI.Main
    self:Round(frame,10)
    self:Stroke(frame)

    -- Title bar
    local titleBar = Instance.new("TextLabel")
    titleBar.Size = UDim2.new(1,0,0,32)
    titleBar.Text = title
    titleBar.BackgroundColor3 = UI.Theme.fg
    titleBar.TextColor3 = UI.Theme.tx
    titleBar.Font = Enum.Font.GothamBold
    titleBar.TextSize = 16
    titleBar.Parent = frame
    self:Round(titleBar,10)
    self:Stroke(titleBar)
    self:MakeDraggable(titleBar)

    -- Tab buttons
    local tabButtons = Instance.new("Frame")
    tabButtons.Size = UDim2.new(0,120,1,-32)
    tabButtons.Position = UDim2.new(0,0,0,32)
    tabButtons.BackgroundColor3 = UI.Theme.bg
    tabButtons.Parent = frame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0,6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabButtons

    -- Pages container
    local pages = Instance.new("Frame")
    pages.Size = UDim2.new(1,-120,1,-32)
    pages.Position = UDim2.new(0,120,0,32)
    pages.BackgroundTransparency = 1
    pages.Parent = frame

    -- ====== Window object ======
    local window = {}
    window.TitleBar = titleBar
    window.Frame = frame

    -- ====== Theme API ======
    function window:SetTheme(theme)
        for k,v in pairs(theme) do
            UI.Theme[k] = v
        end
        frame.BackgroundColor3 = UI.Theme.bg
        titleBar.BackgroundColor3 = UI.Theme.fg
        titleBar.TextColor3 = UI.Theme.tx
    end

    -- ====== Toggle Window Visibility ======
    function window:BindToggle(key)
        UIS.InputBegan:Connect(function(input,gpe)
            if not gpe and input.KeyCode == key then
                frame.Visible = not frame.Visible
            end
        end)
    end

    -- ====== Notifications ======
    function UI:Notify(title,msg,duration)
        duration = duration or 3
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(0,250,0,60)
        notif.Position = UDim2.new(1,-260,1,-70)
        notif.BackgroundColor3 = UI.Theme.fg
        notif.Parent = UI.Main
        self:Round(notif,8)

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1,0,0,20)
        t.Text = title
        t.Font = Enum.Font.GothamBold
        t.TextColor3 = UI.Theme.tx
        t.BackgroundTransparency = 1
        t.Parent = notif

        local m = Instance.new("TextLabel")
        m.Size = UDim2.new(1,0,0,40)
        m.Position = UDim2.new(0,0,0,20)
        m.Text = msg
        m.TextColor3 = UI.Theme.tx
        m.TextWrapped = true
        m.BackgroundTransparency = 1
        m.Font = Enum.Font.Gotham
        m.TextSize = 14
        m.Parent = notif

        -- Tween fade in
        notif.Position = UDim2.new(1,0,1,0)
        TweenService:Create(notif,TweenInfo.new(0.3),{Position = UDim2.new(1,-260,1,-70)}):Play()

        delay(duration,function()
            TweenService:Create(notif,TweenInfo.new(0.3),{Position = UDim2.new(1,0,1,0)}):Play()
            task.delay(0.35,function()
                notif:Destroy()
            end)
        end)
    end

    -- ====== Tab ======
    function window:Tab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1,-10,0,30)
        tabButton.Text = name
        tabButton.BackgroundColor3 = UI.Theme.fg
        tabButton.TextColor3 = UI.Theme.tx
        tabButton.Parent = tabButtons
        self:Round(tabButton,6)

        -- Scrollable page
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1,0,1,0)
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollBarThickness = 4
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = pages

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0,6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page

        -- Activate page
        tabButton.MouseButton1Click:Connect(function()
            for _,p in pairs(pages:GetChildren()) do
                if p:IsA("ScrollingFrame") then
                    p.Visible = false
                end
            end
            page.Visible = true
        end)

        local tab = {}
        tab.Page = page

        -- ====== Label ======
        function tab:Label(text)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1,0,0,24)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextColor3 = UI.Theme.tx
            l.Font = Enum.Font.Gotham
            l.TextSize = 14
            l.Parent = page
        end

        -- ====== Button ======
        function tab:Button(text,callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,0,0,30)
            b.BackgroundColor3 = UI.Theme.fg
            b.Text = text
            b.TextColor3 = UI.Theme.tx
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            b.Parent = page
            UI:Round(b,6)
            -- Hover animation
            b.MouseEnter:Connect(function()
                TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3 = UI.Theme.accent}):Play()
            end)
            b.MouseLeave:Connect(function()
                TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3 = UI.Theme.fg}):Play()
            end)
            b.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end

        -- ====== Toggle ======
        function tab:Toggle(text,callback)
            local state = false
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,0,0,30)
            b.BackgroundColor3 = UI.Theme.fg
            b.TextColor3 = UI.Theme.tx
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

        -- ====== Slider ======
        function tab:Slider(text,min,max,callback)
            local value = min
            local frameS = Instance.new("Frame")
            frameS.Size = UDim2.new(1,0,0,40)
            frameS.BackgroundTransparency = 1
            frameS.Parent = page

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1,0,0,16)
            label.BackgroundTransparency = 1
            label.TextColor3 = UI.Theme.tx
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.Text = text.." : "..value
            label.Parent = frameS

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1,0,0,10)
            bar.Position = UDim2.new(0,0,0,22)
            bar.BackgroundColor3 = UI.Theme.fg
            bar.Parent = frameS
            UI:Round(bar,6)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0,0,1,0)
            fill.BackgroundColor3 = UI.Theme.accent
            fill.Parent = bar
            UI:Round(fill,6)

            local dragging = false
            bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UIS.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local percent = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    TweenService:Create(fill,TweenInfo.new(0.1),{Size=UDim2.new(percent,0,1,0)}):Play()
                    value = math.floor(min + (max-min)*percent)
                    label.Text = text.." : "..value
                    if callback then callback(value) end
                end
            end)
        end

        -- ====== Dropdown ======
        function tab:Dropdown(text,options,callback)
            local ddFrame = Instance.new("Frame")
            ddFrame.Size = UDim2.new(1,0,0,30)
            ddFrame.BackgroundColor3 = UI.Theme.fg
            ddFrame.Parent = page
            UI:Round(ddFrame,6)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1,-10,1,0)
            label.Position = UDim2.new(0,5,0,0)
            label.Text = text.." ▼"
            label.TextColor3 = UI.Theme.tx
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.Parent = ddFrame

            local open = false
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1,0,0,#options*30)
            container.Position = UDim2.new(0,0,0,30)
            container.BackgroundColor3 = UI.Theme.fg
            container.Visible = false
            container.Parent = ddFrame
            UI:Round(container,6)

            for i,opt in ipairs(options) do
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1,0,0,30)
                b.Position = UDim2.new(0,0,0,(i-1)*30)
                b.Text = opt
                b.BackgroundColor3 = UI.Theme.fg
                b.TextColor3 = UI.Theme.tx
                b.Font = Enum.Font.Gotham
                b.TextSize = 14
                b.Parent = container
                UI:Round(b,6)

                b.MouseButton1Click:Connect(function()
                    label.Text = text.." : "..opt
                    container.Visible = false
                    open = false
                    if callback then callback(opt) end
                end)
            end

            ddFrame.MouseButton1Click:Connect(function()
                open = not open
                container.Visible = open
            end)
        end

        return tab
    end

    return window
end

return UI
