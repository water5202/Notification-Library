local a = game:GetService("TweenService");
local b = game:GetService("Players");

local d = Instance.new("ScreenGui");
d.Name = "WaterNotify";
d.Parent = game:GetService("CoreGui");

local e = {};
local f = 10;
local g = 80;
local h = 250;

function Notify(TITLE, TEXT, DURATION);
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

    local bs = Instance.new("LocalScript")
    bs.Name = ""
    bs.Parent = m
    bs.Source = [[
    local Lighting          = game:GetService("Lighting")
local camera			= workspace.CurrentCamera

local BLUR_SIZE         = Vector2.new(10, 10)
local PART_SIZE         = 0.01
local PART_TRANSPARENCY = 1 - 1e-7
local START_INTENSITY	= 0.25

script.Parent:SetAttribute("BlurIntensity", START_INTENSITY)

local BLUR_OBJ          = Instance.new("DepthOfFieldEffect")
BLUR_OBJ.FarIntensity   = 0
BLUR_OBJ.NearIntensity  = script.Parent:GetAttribute("BlurIntensity")
BLUR_OBJ.FocusDistance  = 0.25
BLUR_OBJ.InFocusRadius  = 0
BLUR_OBJ.Parent         = Lighting

local PartsList         = {}
local BlursList         = {}
local BlurObjects       = {}
local BlurredGui        = {}

BlurredGui.__index      = BlurredGui

function rayPlaneIntersect(planePos, planeNormal, rayOrigin, rayDirection)
	local n = planeNormal
	local d = rayDirection
	local v = rayOrigin - planePos

	local num = n.x*v.x + n.y*v.y + n.z*v.z
	local den = n.x*d.x + n.y*d.y + n.z*d.z
	local a = -num / den

	return rayOrigin + a * rayDirection, a
end

function rebuildPartsList()
	PartsList = {}
	BlursList = {}
	for blurObj, part in pairs(BlurObjects) do
		table.insert(PartsList, part)
		table.insert(BlursList, blurObj)
	end
end

function BlurredGui.new(frame, shape)
	local blurPart        = Instance.new("Part")
	blurPart.Size         = Vector3.new(1, 1, 1) * 0.01
	blurPart.Anchored     = true
	blurPart.CanCollide   = false
	blurPart.CanTouch     = false
	blurPart.Material     = Enum.Material.Glass
	blurPart.Transparency = PART_TRANSPARENCY
	blurPart.Parent       = workspace.CurrentCamera

	local mesh
	if (shape == "Rectangle") then
		mesh        = Instance.new("BlockMesh")
		mesh.Parent = blurPart
	elseif (shape == "Oval") then
		mesh          = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent   = blurPart
	end
	
	local ignoreInset = false
	local currentObj  = frame
	
	while true do
		currentObj = currentObj.Parent

		if (currentObj and currentObj:IsA("ScreenGui")) then
			ignoreInset = currentObj.IgnoreGuiInset
			break
		elseif (currentObj == nil) then
			break
		end
	end

	local new = setmetatable({
		Frame          = frame;
		Part           = blurPart;
		Mesh           = mesh;
		IgnoreGuiInset = ignoreInset;
	}, BlurredGui)

	BlurObjects[new] = blurPart
	rebuildPartsList()

	game:GetService("RunService"):BindToRenderStep("...", Enum.RenderPriority.Camera.Value + 1, function()
		blurPart.CFrame = camera.CFrame * CFrame.new(0,0,0)
		BlurredGui.updateAll()
	end)
	return new
end

function updateGui(blurObj)
	if (not blurObj.Frame.Visible) then
		blurObj.Part.Transparency = 1
		return
	end
	
	local camera = workspace.CurrentCamera
	local frame  = blurObj.Frame
	local part   = blurObj.Part
	local mesh   = blurObj.Mesh
	
	part.Transparency = PART_TRANSPARENCY
	
	local corner0 = frame.AbsolutePosition + BLUR_SIZE
	local corner1 = corner0 + frame.AbsoluteSize - BLUR_SIZE*2
	local ray0, ray1

	if (blurObj.IgnoreGuiInset) then
		ray0 = camera:ViewportPointToRay(corner0.X, corner0.Y, 1)
		ray1 = camera:ViewportPointToRay(corner1.X, corner1.Y, 1)
	else
		ray0 = camera:ScreenPointToRay(corner0.X, corner0.Y, 1)
		ray1 = camera:ScreenPointToRay(corner1.X, corner1.Y, 1)
	end

	local planeOrigin = camera.CFrame.Position + camera.CFrame.LookVector * (0.05 - camera.NearPlaneZ)
	local planeNormal = camera.CFrame.LookVector
	local pos0 = rayPlaneIntersect(planeOrigin, planeNormal, ray0.Origin, ray0.Direction)
	local pos1 = rayPlaneIntersect(planeOrigin, planeNormal, ray1.Origin, ray1.Direction)

	local pos0 = camera.CFrame:PointToObjectSpace(pos0)
	local pos1 = camera.CFrame:PointToObjectSpace(pos1)

	local size   = pos1 - pos0
	local center = (pos0 + pos1)/2

	mesh.Offset = center
	mesh.Scale  = size / PART_SIZE
end

function BlurredGui.updateAll()
	BLUR_OBJ.NearIntensity = tonumber(script.Parent:GetAttribute("BlurIntensity"))
	
	for i = 1, #BlursList do
		updateGui(BlursList[i])
	end

	local cframes = table.create(#BlursList, workspace.CurrentCamera.CFrame)
	workspace:BulkMoveTo(PartsList, cframes, Enum.BulkMoveMode.FireCFrameChanged)

	BLUR_OBJ.FocusDistance = 0.25 - camera.NearPlaneZ
end

function BlurredGui:Destroy()
	self.Part:Destroy()
	BlurObjects[self] = nil
	rebuildPartsList()
end

BlurredGui.new(script.Parent, "Rectangle")

BlurredGui.updateAll()
return BlurredGui
]]
     
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
    WNotify = Notify
}


