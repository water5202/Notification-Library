local a = game:GetService("TweenService")
local d = Instance.new("ScreenGui")
d.Name = ""
d.Parent = game:GetService("CoreGui")
local e = {}
local f = 10
local g = 80
local h = 270

local function updpos()
    for i, m in ipairs(e) do
        local s = -((g + f) * i)
        local t = {Position = UDim2.new(1, -10, 1, s)}
        a:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), t):Play()
    end
end

local rng = Random.new()
local CHARSET =
    "abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ..
    "0123456789" ..
    " `~!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?"
    .. "�"

local function randString(len)
    local t = table.create(len)
    for i = 1, len do
        local idx = rng:NextInteger(1, #CHARSET)
        t[i] = CHARSET:sub(idx, idx)
    end
    return table.concat(t)
end

function Notify(TITLE, TEXT, DURATION)	
    local m = Instance.new("Frame")
    m.Name = randString(24)
    m.Size = UDim2.new(0, h, 0, g)
    m.AnchorPoint = Vector2.new(1, 1)
    m.Position = UDim2.new(1, h + 20, 1, -10)
    m.BackgroundColor3 = Color3.fromRGB(0,0,0)
    m.BackgroundTransparency = 0.5
    m.Parent = d

    local n = Instance.new("UICorner")
    n.Parent = m

    local o = Instance.new("TextLabel")
    o.Text = TITLE
    o.Font = Enum.Font.Nunito
    o.TextSize = 18
    o.TextColor3 = Color3.fromRGB(255, 255, 255)
    o.TextXAlignment = Enum.TextXAlignment.Left
    o.BackgroundTransparency = 1
    o.Size = UDim2.new(1, -30, 0, 25)
    o.Position = UDim2.new(0, 10, 0, 5)
    o.Parent = m

    local p = Instance.new("TextLabel")
    p.Text = TEXT
    p.Font = Enum.Font.Nunito
    p.TextSize = 16
    p.TextColor3 = Color3.fromRGB(200, 200, 200)
    p.TextXAlignment = Enum.TextXAlignment.Left
    p.BackgroundTransparency = 1
    p.Size = UDim2.new(1, -30, 0, 20)
    p.Position = UDim2.new(0, 10, 0, 30)
    p.Parent = m

    local q = Instance.new("TextLabel")
    q.Text = "(" .. string.format("%.1f", DURATION) .. ")"
    q.Font = Enum.Font.Nunito
    q.TextSize = 16
    q.TextColor3 = Color3.fromRGB(255, 255, 255)
    q.BackgroundTransparency = 1
    q.Size = UDim2.new(0, 40, 1, 0)
    q.Position = UDim2.new(1, -50, 0, 0)
    q.Parent = m

    table.insert(e, m)
	
    updpos()
    task.spawn(function()
        local u = tick()
        while tick() - u < DURATION do
            local v = DURATION - (tick() - u)
            q.Text = "(" .. string.format("%.1f", v) .. ")"
            task.wait(0.1)
        end

        local w = a:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, h + 20, m.Position.Y.Scale, m.Position.Y.Offset)
        })
        w:Play()
        w.Completed:Wait()

        for x, y in ipairs(e) do
            if y == m then
                table.remove(e, x)
                break
            end
        end

        updpos()
        m:Destroy()
    end)
end

return {
    WaterNotify = Notify
}




