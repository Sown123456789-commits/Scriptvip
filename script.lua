-- =========================================================================
-- 🌶️ KAI ROBLOX LOADER MENU V2.4 — UPDATE REQUIRED
-- Chỉ tập trung: thông báo update + nút copy link (KHÔNG chạy script chính) 
-- =========================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════
-- ⚙️ CẤU HÌNH
-- ═══════════════════════════════════════════════════════════════════
local CONFIG = {
    UpdateURL = "https://mod.game1s.xyz/2026/10/script-nhat-trung-chilli-hub-viet-hoa.html?m=1",
    AuthorName = "Kai Roblox",
    DiscordLink = "https://discord.gg/9gWma4JTpD",
    Version = "v2.4.0",
    RequiredVersion = "v2.4.0",
}

-- ═══════════════════════════════════════════════════════════════════
-- 📱 RESPONSIVE SCALE
-- ═══════════════════════════════════════════════════════════════════
local function GetResponsiveScale()
    local camera = workspace.CurrentCamera
    if not camera then return 0.7 end
    local vp = camera.ViewportSize
    local scaleW = (vp.X - 40) / 320
    local scaleH = (vp.Y - 40) / 400
    return math.clamp(math.min(scaleW, scaleH), 0.55, 1.0)
end

-- ═══════════════════════════════════════════════════════════════════
-- 🎯 PARENT TARGET
-- ═══════════════════════════════════════════════════════════════════
local parentTarget = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if parentTarget:FindFirstChild("KaiRoblox_Menu") then
    parentTarget.KaiRoblox_Menu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KaiRoblox_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 2147483647
pcall(function() ScreenGui.Parent = parentTarget end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ═══════ OVERLAY MỜ NỀN ═══════
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 1
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 1
Overlay.Parent = ScreenGui
TweenService:Create(Overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.55 }):Play()

-- ═══════ MAIN FRAME ═══════
local MainFrame = Instance.new("Frame")
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 8, 10)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)

local MainScale = Instance.new("UIScale", MainFrame)
MainScale.Scale = 0.5

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(239, 68, 68)

-- Hiệu ứng viền đỏ nhấp nháy (cảnh báo)
task.spawn(function()
    while MainStroke and MainStroke.Parent do
        local v = (math.sin(tick() * 3) + 1) / 2
        MainStroke.Color = Color3.new(
            (200 + v * 55) / 255,
            (40 + v * 40) / 255,
            (40 + v * 30) / 255
        )
        task.wait(0.05)
    end
end)

-- ═══════ HEADER ═══════
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(34, 12, 16)
Header.BorderSizePixel = 0
Header.ZIndex = 11
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 18)

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 18)
HeaderFix.Position = UDim2.new(0, 0, 1, -18)
HeaderFix.BackgroundColor3 = Color3.fromRGB(34, 12, 16)
HeaderFix.BorderSizePixel = 0
HeaderFix.ZIndex = 11
HeaderFix.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🌶️ KAI ROBLOX LOADER"
TitleLabel.TextColor3 = Color3.fromRGB(254, 226, 226)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 12
TitleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 18, 24)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(252, 165, 165)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 12
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 7)

-- ═══════ CẢNH BÁO UPDATE (TRUNG TÂM) ═══════
local WarnBox = Instance.new("Frame")
WarnBox.Size = UDim2.new(1, -32, 0, 76)
WarnBox.Position = UDim2.new(0, 16, 0, 50)
WarnBox.BackgroundColor3 = Color3.fromRGB(60, 20, 8)
WarnBox.ZIndex = 11
WarnBox.Parent = MainFrame
Instance.new("UICorner", WarnBox).CornerRadius = UDim.new(0, 12)

local WarnStroke = Instance.new("UIStroke", WarnBox)
WarnStroke.Color = Color3.fromRGB(251, 191, 36)
WarnStroke.Thickness = 1.4

local WarnIcon = Instance.new("TextLabel")
WarnIcon.Size = UDim2.new(0, 36, 0, 36)
WarnIcon.Position = UDim2.new(0, 12, 0, 12)
WarnIcon.BackgroundTransparency = 1
WarnIcon.Text = "⚠️"
WarnIcon.TextSize = 28
WarnIcon.ZIndex = 12
WarnIcon.Parent = WarnBox

local WarnTitle = Instance.new("TextLabel")
WarnTitle.Size = UDim2.new(1, -70, 0, 18)
WarnTitle.Position = UDim2.new(0, 56, 0, 12)
WarnTitle.BackgroundTransparency = 1
WarnTitle.Text = "ĐÃ CÓ BẢN UPDATE MỚI!"
WarnTitle.TextColor3 = Color3.fromRGB(254, 243, 199)
WarnTitle.TextSize = 12
WarnTitle.Font = Enum.Font.GothamBlack
WarnTitle.TextXAlignment = Enum.TextXAlignment.Left
WarnTitle.ZIndex = 12
WarnTitle.Parent = WarnBox

local WarnDesc = Instance.new("TextLabel")
WarnDesc.Size = UDim2.new(1, -70, 0, 32)
WarnDesc.Position = UDim2.new(0, 56, 0, 32)
WarnDesc.BackgroundTransparency = 1
WarnDesc.Text = "Bản cũ đã ngừng hoạt động.\nVui lòng lấy bản mới để tiếp tục dùng."
WarnDesc.TextColor3 = Color3.fromRGB(253, 186, 116)
WarnDesc.TextSize = 9
WarnDesc.Font = Enum.Font.GothamMedium
WarnDesc.TextXAlignment = Enum.TextXAlignment.Left
WarnDesc.TextYAlignment = Enum.TextYAlignment.Top
WarnDesc.TextWrapped = true
WarnDesc.ZIndex = 12
WarnDesc.Parent = WarnBox

-- ═══════ VERSION INFO ═══════
local VersionRow = Instance.new("Frame")
VersionRow.Size = UDim2.new(1, -32, 0, 34)
VersionRow.Position = UDim2.new(0, 16, 0, 136)
VersionRow.BackgroundColor3 = Color3.fromRGB(26, 12, 16)
VersionRow.ZIndex = 11
VersionRow.Parent = MainFrame
Instance.new("UICorner", VersionRow).CornerRadius = UDim.new(0, 10)

local VersionStroke = Instance.new("UIStroke", VersionRow)
VersionStroke.Color = Color3.fromRGB(80, 30, 36)
VersionStroke.Thickness = 1

local CurVerLabel = Instance.new("TextLabel")
CurVerLabel.Size = UDim2.new(0.5, -8, 1, 0)
CurVerLabel.Position = UDim2.new(0, 8, 0, 0)
CurVerLabel.BackgroundTransparency = 1
CurVerLabel.Text = "Hiện tại: " .. CONFIG.Version
CurVerLabel.TextColor3 = Color3.fromRGB(252, 165, 165)
CurVerLabel.TextSize = 9
CurVerLabel.Font = Enum.Font.GothamMedium
CurVerLabel.TextXAlignment = Enum.TextXAlignment.Left
CurVerLabel.ZIndex = 12
CurVerLabel.Parent = VersionRow

local NewVerLabel = Instance.new("TextLabel")
NewVerLabel.Size = UDim2.new(0.5, -8, 1, 0)
NewVerLabel.Position = UDim2.new(0.5, 0, 0, 0)
NewVerLabel.BackgroundTransparency = 1
NewVerLabel.Text = "Mới nhất: " .. CONFIG.RequiredVersion
NewVerLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
NewVerLabel.TextSize = 9
NewVerLabel.Font = Enum.Font.GothamBold
NewVerLabel.TextXAlignment = Enum.TextXAlignment.Right
NewVerLabel.ZIndex = 12
NewVerLabel.Parent = VersionRow

-- ═══════ NÚT LẤY BẢN MỚI (CHÍNH) ═══════
local GetNewBtn = Instance.new("TextButton")
GetNewBtn.Size = UDim2.new(1, -32, 0, 52)
GetNewBtn.Position = UDim2.new(0, 16, 0, 180)
GetNewBtn.BackgroundColor3 = Color3.fromRGB(180, 83, 9)
GetNewBtn.Text = "⬇  LẤY BẢN UPDATE MỚI"
GetNewBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetNewBtn.TextSize = 13
GetNewBtn.Font = Enum.Font.GothamBlack
GetNewBtn.AutoButtonColor = false
GetNewBtn.ZIndex = 12
GetNewBtn.Parent = MainFrame
Instance.new("UICorner", GetNewBtn).CornerRadius = UDim.new(0, 12)

local GetNewStroke = Instance.new("UIStroke", GetNewBtn)
GetNewStroke.Color = Color3.fromRGB(251, 191, 36)
GetNewStroke.Thickness = 1.8

-- Pulse cho nút chính
task.spawn(function()
    while GetNewStroke and GetNewStroke.Parent do
        local v = (math.sin(tick() * 4) + 1) / 2
        GetNewStroke.Transparency = 1 - (0.3 + v * 0.7)
        task.wait(0.05)
    end
end)

-- ═══════ DISCORD HỖ TRỢ ═══════
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Size = UDim2.new(1, -32, 0, 38)
DiscordBtn.Position = UDim2.new(0, 16, 0, 240)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 42)
DiscordBtn.Text = ""
DiscordBtn.AutoButtonColor = false
DiscordBtn.ZIndex = 11
DiscordBtn.Parent = MainFrame
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(0, 10)

local DiscordStroke = Instance.new("UIStroke", DiscordBtn)
DiscordStroke.Color = Color3.fromRGB(88, 101, 242)
DiscordStroke.Thickness = 1.2

local DiscordIcon = Instance.new("TextLabel")
DiscordIcon.Size = UDim2.new(0, 26, 1, 0)
DiscordIcon.Position = UDim2.new(0, 6, 0, 0)
DiscordIcon.BackgroundTransparency = 1
DiscordIcon.Text = "💬"
DiscordIcon.TextSize = 14
DiscordIcon.ZIndex = 12
DiscordIcon.Parent = DiscordBtn

local DiscordTxt = Instance.new("TextLabel")
DiscordTxt.Size = UDim2.new(1, -40, 1, 0)
DiscordTxt.Position = UDim2.new(0, 34, 0, 0)
DiscordTxt.BackgroundTransparency = 1
DiscordTxt.Text = "HỖ TRỢ · COPY LINK DISCORD"
DiscordTxt.TextColor3 = Color3.fromRGB(200, 210, 255)
DiscordTxt.TextSize = 10
DiscordTxt.Font = Enum.Font.GothamBold
DiscordTxt.TextXAlignment = Enum.TextXAlignment.Left
DiscordTxt.ZIndex = 12
DiscordTxt.Parent = DiscordBtn

-- ═══════ FOOTER ═══════
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -32, 0, 14)
Footer.Position = UDim2.new(0, 16, 1, -26)
Footer.BackgroundTransparency = 1
Footer.Text = "by " .. CONFIG.AuthorName .. " · Vui lòng cập nhật để tiếp tục"
Footer.TextColor3 = Color3.fromRGB(140, 90, 90)
Footer.TextSize = 8
Footer.Font = Enum.Font.GothamMedium
Footer.ZIndex = 12
Footer.Parent = MainFrame

-- ═══════ TOAST ═══════
local ToastGui = Instance.new("ScreenGui")
ToastGui.Name = "KaiRoblox_Toast"
ToastGui.ResetOnSpawn = false
ToastGui.DisplayOrder = 2147483646
pcall(function() ToastGui.Parent = parentTarget end)
if not ToastGui.Parent then ToastGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local function ShowToast(text, color)
    if ToastGui:FindFirstChild("Toast") then ToastGui.Toast:Destroy() end
    local Toast = Instance.new("Frame")
    Toast.Name = "Toast"
    Toast.AnchorPoint = Vector2.new(0.5, 0)
    Toast.Size = UDim2.new(0, 260, 0, 40)
    Toast.Position = UDim2.new(0.5, 0, 0, -60)
    Toast.BackgroundColor3 = Color3.fromRGB(24, 12, 16)
    Toast.ZIndex = 100
    Toast.Parent = ToastGui
    Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 10)

    local TStroke = Instance.new("UIStroke", Toast)
    TStroke.Color = color or Color3.fromRGB(74, 222, 128)
    TStroke.Thickness = 1.4

    local TLabel = Instance.new("TextLabel")
    TLabel.Size = UDim2.new(1, -16, 1, 0)
    TLabel.Position = UDim2.new(0, 8, 0, 0)
    TLabel.BackgroundTransparency = 1
    TLabel.Text = text
    TLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    TLabel.TextSize = 10
    TLabel.Font = Enum.Font.GothamBold
    TLabel.TextWrapped = true
    TLabel.ZIndex = 101
    TLabel.Parent = Toast

    TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, 0, 0, 20) }):Play()

    task.delay(2.5, function()
        if Toast and Toast.Parent then
            local t = TweenService:Create(Toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Position = UDim2.new(0.5, 0, 0, -60), BackgroundTransparency = 1 })
            t:Play()
            t.Completed:Connect(function() Toast:Destroy() end)
        end
    end)
end

-- ═══════ COPY HELPER ═══════
local function copyToClipboard(text)
    if setclipboard then pcall(setclipboard, text); return true end
    if toclipboard then pcall(toclipboard, text); return true end
    return false
end

local function Bounce(btn)
    local os, op = btn.Size, btn.Position
    local ss = UDim2.new(os.X.Scale, os.X.Offset - 5, os.Y.Scale, os.Y.Offset - 3)
    local sp = UDim2.new(op.X.Scale, op.X.Offset + 2, op.Y.Scale, op.Y.Offset + 1.5)
    local t1 = TweenService:Create(btn, TweenInfo.new(0.08), { Size = ss, Position = sp })
    local t2 = TweenService:Create(btn, TweenInfo.new(0.16, Enum.EasingStyle.Back), { Size = os, Position = op })
    t1:Play(); t1.Completed:Connect(function() t2:Play() end)
end

-- ═══════════════════════════════════════════════════════════════════
-- 📱 APPLY SCALE + ENTRY ANIMATION
-- ═══════════════════════════════════════════════════════════════════
local targetScale = GetResponsiveScale()
MainScale.Scale = targetScale * 0.4

TweenService:Create(MainScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Scale = targetScale }):Play()

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local ns = GetResponsiveScale()
    if math.abs(ns - MainScale.Scale) > 0.02 then
        TweenService:Create(MainScale, TweenInfo.new(0.3), { Scale = ns }):Play()
    end
end)

-- ═══════ HIỆN TOAST CẢNH BÁO KHI MỞ ═══════
task.delay(0.5, function()
    ShowToast("⚠️ Bản cũ đã hết hạn — Lấy bản mới để tiếp tục!", Color3.fromRGB(251, 191, 36))
end)

-- ═══════════════════════════════════════════════════════════════════
-- 🎯 EVENTS
-- ═══════════════════════════════════════════════════════════════════

-- Đóng menu (vẫn cho phép nhưng cảnh báo)
local function CloseMenu()
    TweenService:Create(MainScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Scale = targetScale * 0.4 }):Play()
    TweenService:Create(Overlay, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
    task.wait(0.25)
    if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
    if ToastGui and ToastGui.Parent then ToastGui:Destroy() end
end

CloseBtn.MouseButton1Click:Connect(function()
    Bounce(CloseBtn)
    ShowToast("⚠️ Script sẽ không hoạt động nếu không update!", Color3.fromRGB(239, 68, 68))
    task.wait(1.2)
    CloseMenu()
end)

-- Nút chính: Lấy bản update
GetNewBtn.MouseButton1Click:Connect(function()
    Bounce(GetNewBtn)
    GetNewBtn.Text = "📋 ĐANG COPY LINK..."
    GetNewBtn.BackgroundColor3 = Color3.fromRGB(120, 53, 15)

    local ok = copyToClipboard(CONFIG.UpdateURL)

    if ok then
        GetNewBtn.Text = "✔ ĐÃ COPY — DÁN VÀO TRÌNH DUYỆT"
        GetNewBtn.BackgroundColor3 = Color3.fromRGB(22, 101, 52)
        GetNewStroke.Color = Color3.fromRGB(74, 222, 128)
        ShowToast("✔ Đã copy link! Mở trình duyệt để tải bản mới.", Color3.fromRGB(74, 222, 128))
    else
        GetNewBtn.Text = "✖ KHÔNG COPY ĐƯỢC"
        GetNewBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 30)
        GetNewStroke.Color = Color3.fromRGB(239, 68, 68)
        ShowToast("✖ Executor không hỗ trợ copy. Link: " .. CONFIG.UpdateURL, Color3.fromRGB(239, 68, 68))
    end

    task.delay(3, function()
        if GetNewBtn and GetNewBtn.Parent then
            GetNewBtn.Text = "⬇  LẤY BẢN UPDATE MỚI"
            GetNewBtn.BackgroundColor3 = Color3.fromRGB(180, 83, 9)
            GetNewStroke.Color = Color3.fromRGB(251, 191, 36)
        end
    end)
end)

-- Nút Discord
DiscordBtn.MouseButton1Click:Connect(function()
    Bounce(DiscordBtn)
    if copyToClipboard(CONFIG.DiscordLink) then
        ShowToast("✔ Đã copy link Discord!", Color3.fromRGB(88, 101, 242))
        DiscordTxt.Text = "✔ ĐÃ COPY!"
        task.delay(2, function()
            if DiscordTxt and DiscordTxt.Parent then
                DiscordTxt.Text = "HỖ TRỢ · COPY LINK DISCORD"
            end
        end)
    else
        ShowToast("✖ Không thể copy link!", Color3.fromRGB(239, 68, 68))
    end
end)

print("[KaiRoblox V2.4] ⚠️ UPDATE REQUIRED MODE")
print("  → Current: " .. CONFIG.Version .. " | Required: " .. CONFIG.RequiredVersion)
print("  → Update URL: " .. CONFIG.UpdateURL)
