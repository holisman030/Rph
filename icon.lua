-- Left icon ui
-- =========================
-- WAIT GUI
-- =========================
task.wait(0.3)

local GUI = Fluent.GUI
if not GUI then
    return warn("Fluent GUI not found")
end

-- =========================
-- FIND TITLE
-- =========================
local Title

for i = 1, 30 do
    for _, v in pairs(GUI:GetDescendants()) do
        if v:IsA("TextLabel") and string.find(string.lower(v.Text), "reaper") then
            Title = v
            break
        end
    end
    if Title then break end
    task.wait(0.1)
end

if not Title then
    return warn("Title not found")
end

-- =========================
-- GET TOPBAR
-- =========================
local TopBar = Title.Parent
if not TopBar then
    return warn("TopBar not found")
end

-- =========================
-- FIX LAYOUT (สำคัญ)
-- =========================
local Layout
for _, v in pairs(TopBar:GetChildren()) do
    if v:IsA("UIListLayout") then
        Layout = v
        break
    end
end

if Layout then
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding = UDim.new(0, 6)
end

-- =========================
-- CREATE LOGO (เข้า Layout)
-- =========================
local Logo = Instance.new("ImageLabel")
Logo.Name = "ReaperLogo"
Logo.Parent = TopBar

Logo.Image = "rbxassetid://131279093559313"
Logo.BackgroundTransparency = 1
Logo.Size = UDim2.new(0, 30, 0, 30) -- ปรับให้บาลานซ์กับฟอนต์
Logo.ScaleType = Enum.ScaleType.Fit

-- ให้อยู่ซ้ายสุด
Logo.LayoutOrder = -1

-- =========================
-- ALIGN CENTER (ละเอียด)
-- =========================
Logo.AnchorPoint = Vector2.new(0, 0.5)
Logo.Position = UDim2.new(0, 0, 0.5, 1) -- +1 ช่วยแก้ baseline ฟอนต์

-- =========================
-- OPTIONAL STYLE
-- =========================
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 0
Stroke.Transparency = 1
Stroke.Parent = Logo
