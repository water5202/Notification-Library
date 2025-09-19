local a = game:GetService("TweenService");
local b = game:GetService("Players");

local d = Instance.new("ScreenGui");
d.Name = "WaterNotify";
d.Parent = game:GetService("CoreGui");

local e = {};
local f = 10;
local g = 80;
local h = 250;

function Notify(TITLE, TEXT, DURATION)
    local m = Instance.new("Frame");
    m.Size = UDim2.new(0, h, 0, g);
    m.AnchorPoint = Vector2.new(1, 1);
    m.Position = UDim2.new(1, h + 20, 1, -10);
    m.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
    m.BackgroundTransparency = 0.1
    m.Parent = d;

    local n = Instance.new("UICorner");
    n.Parent = m;

    local o = Instance.new("TextLabel");
    o.Text = TITLE;
    o.Font = Enum.Font.Nunito;
    o.TextSize = 18;
    o.TextColor3 = Color3.fromRGB(255, 255, 255);
    o.TextXAlignment = Enum.TextXAlignment.Left;
    o.BackgroundTransparency = 1;
    o.Size = UDim2.new(1, -30, 0, 25);
    o.Position = UDim2.new(0, 10, 0, 5);
    o.Parent = m;

    local p = Instance.new("TextLabel");
    p.Text = TEXT;
    p.Font = Enum.Font.Nunito;
    p.TextSize = 16;
    p.TextColor3 = Color3.fromRGB(200, 200, 200);
    p.TextXAlignment = Enum.TextXAlignment.Left;
    p.BackgroundTransparency = 1;
    p.Size = UDim2.new(1, -30, 0, 20);
    p.Position = UDim2.new(0, 10, 0, 30);
    p.Parent = m;

    local q = Instance.new("TextLabel");
    q.Text = "(" .. string.format("%.1f", DURATION) .. ")";
    q.Font = Enum.Font.Nunito;
    q.TextSize = 16;
    q.TextColor3 = Color3.fromRGB(255, 255, 255);
    q.BackgroundTransparency = 1;
    q.Size = UDim2.new(0, 40, 1, 0);
    q.Position = UDim2.new(1, -50, 0, 0);
    q.Parent = m;
	
    table.insert(e, m);
    local r = #e;
    local s = -((g + f) * r);
    m.Position = UDim2.new(1, h + 20, 1, s);
    local t = {Position = UDim2.new(1, -10, 1, s)};
    a:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), t):Play();

    task.spawn(function()
        local u = tick();
        while tick() - u < DURATION do;
            local v = DURATION - (tick() - u);
            q.Text = "(" .. string.format("%.1f", v) .. ")";
            task.wait(0.1);
        end;
        local w = a:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, h + 20, m.Position.Y.Scale, m.Position.Y.Offset)
        })
        w:Play();
        w.Completed:Wait();
        for x, y in ipairs(e) do
            if y == m then;
                table.remove(e, x);
                break;
            end;
        end;
        m:Destroy();
    end);
end;

return {
    WNotify = Notify;
}



