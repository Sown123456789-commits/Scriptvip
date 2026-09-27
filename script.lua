-- ==============================================================================
-- CHILLI HUB - ULTRA ZERO-LAG & NOSTALGIC SUNSET ENGINE V10.4 (EN/VI)
-- Tối ưu hóa:
-- 1. Cập nhật 100% tiếng sự kiện mới: Dr Scramble Event, Auto Hunt Drone, Vault.
-- 2. Tách Module Tối Ưu (Hoàng hôn + Chống lag) thành nút Bật/Tắt riêng (Mặc định: Tắt).
-- 3. SỬA LỖI TRIỆT ĐỂ: Chống lag không còn chạy ngầm khi nút Tối Ưu bị Tắt.
-- 4. Vòng xoay 2 ngôn ngữ (Anh/Việt) và Nút bấm Frosted Slate (Top-Center).
-- ==============================================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ==================== 1. NẠP CHILLI HUB GỐC (ƯU TIÊN SỐ 1) ====================
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/Chilli-Hub-Script/refs/heads/main/StealAnEgg"))()
    end)
end)

-- ==================== 2. MODULE TỐI ƯU ĐỒ HỌA & CHỐNG LAG (TÁCH RIÊNG) ====================
-- Nguyên tắc: Khi Tắt, KHÔNG có bất kỳ vòng lặp hay sự kiện nào chạy ngầm.
local GraphicsOptimizer = {}
GraphicsOptimizer.Active = false
GraphicsOptimizer.Connections = {}
GraphicsOptimizer.OriginalLighting = {}
GraphicsOptimizer.OriginalMaterials = {} -- Lưu Material gốc của các part

-- Lưu trạng thái Lighting gốc
local function saveLighting()
    GraphicsOptimizer.OriginalLighting = {
        GlobalShadows = Lighting.GlobalShadows,
        TimeOfDay = Lighting.TimeOfDay,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ColorShift_Bottom = Lighting.ColorShift_Bottom,
        ColorShift_Top = Lighting.ColorShift_Top,
        FogEnd = Lighting.FogEnd,
    }
end

-- Khôi phục Lighting gốc
local function restoreLighting()
    if next(GraphicsOptimizer.OriginalLighting) then
        for k, v in pairs(GraphicsOptimizer.OriginalLighting) do
            pcall(function() Lighting[k] = v end)
        end
    end
    for _, v in ipairs(Lighting:GetChildren()) do
        if v.Name == "Chilli_CC" or v.Name == "Chilli_Bloom" then
            v:Destroy()
        end
    end
end

-- Áp dụng Shader Hoàng Hôn
local function applySunsetShader()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.TimeOfDay = "17:15:00"
        Lighting.Ambient = Color3.fromRGB(110, 100, 90)
        Lighting.OutdoorAmbient = Color3.fromRGB(160, 130, 100)
        Lighting.Brightness = 1.0
        Lighting.ColorShift_Bottom = Color3.fromRGB(130, 110, 90)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 235, 210)
        Lighting.FogEnd = 9e9

        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") then
                v:Destroy()
            end
        end

        local cc = Instance.new("ColorCorrectionEffect", Lighting)
        cc.Name = "Chilli_CC"
        cc.Saturation = 0.15
        cc.Contrast = 0.05
        cc.TintColor = Color3.fromRGB(255, 250, 240)

        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Name = "Chilli_Bloom"
        bloom.Intensity = 0.35
        bloom.Size = 14
        bloom.Threshold = 1.2
    end)
end

-- Hàm xử lý một BasePart (dùng chung cho cả quét ban đầu và DescendantAdded)
local function processPart(obj)
    if not GraphicsOptimizer.Active then return end
    if not obj or not obj.Parent then return end
    
    if obj:IsA("BasePart") then
        -- Lưu Material gốc trước khi đổi (chỉ lưu 1 lần)
        if not GraphicsOptimizer.OriginalMaterials[obj] then
            GraphicsOptimizer.OriginalMaterials[obj] = {
                Material = obj.Material,
                CastShadow = obj.CastShadow
            }
        end
        
        obj.CastShadow = false
        local name = obj.Name:lower()
        local pName = (obj.Parent and obj.Parent.Name:lower()) or ""
        if name:find("egg") or pName:find("egg") then
            obj.Material = Enum.Material.Neon
        else
            obj.Material = Enum.Material.SmoothPlastic
        end
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        if not GraphicsOptimizer.OriginalMaterials[obj] then
            GraphicsOptimizer.OriginalMaterials[obj] = { Transparency = obj.Transparency }
        end
        obj.Transparency = 1
    end
end

-- Khôi phục Material gốc cho tất cả các part đã lưu
local function restoreMaterials()
    for obj, data in pairs(GraphicsOptimizer.OriginalMaterials) do
        if obj and obj.Parent then
            pcall(function()
                if data.Material then obj.Material = data.Material end
                if data.CastShadow ~= nil then obj.CastShadow = data.CastShadow end
                if data.Transparency ~= nil then obj.Transparency = data.Transparency end
            end)
        end
    end
    GraphicsOptimizer.OriginalMaterials = {}
end

-- Quét map chuyển SmoothPlastic & Neon (Chỉ chạy khi Active == true)
local function processGraphics(parent)
    if not GraphicsOptimizer.Active then return end
    local children = parent:GetChildren()
    for i, obj in ipairs(children) do
        if not GraphicsOptimizer.Active then break end
        processPart(obj)
        if i % 50 == 0 then
            RunService.RenderStepped:Wait()
        end
        processGraphics(obj)
    end
end

-- Khởi động Module
function GraphicsOptimizer:Start()
    if self.Active then return end
    self.Active = true
    
    -- 1. Lưu và áp dụng shader
    saveLighting()
    applySunsetShader()

    -- 2. Quét map lần đầu
    task.spawn(function()
        pcall(function() processGraphics(workspace) end)
    end)

    -- 3. Lắng nghe các object mới thêm vào map
    local conn = workspace.DescendantAdded:Connect(function(obj)
        if not self.Active then return end
        task.defer(function()
            if not self.Active then return end
            processPart(obj)
        end)
    end)
    table.insert(self.Connections, conn)
end

-- Tắt Module
function GraphicsOptimizer:Stop()
    if not self.Active then return end
    self.Active = false
    
    -- Ngắt kết nối sự kiện
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
    
    -- Khôi phục đồ họa gốc
    restoreLighting()
    restoreMaterials()
end

-- ==================== 3. HỆ THỐNG DỊCH THUẬT SONG NGỮ (EN/VI) ====================
local currentLanguage = "VI"
local translationLock = false
local FastCache = {}

local function safeReplace(str, findStr, replaceStr)
    local startIdx, endIdx = str:find(findStr, 1, true)
    if startIdx then
        return str:sub(1, startIdx - 1) .. replaceStr .. str:sub(endIdx + 1)
    end
    return str
end

local MAP_VI = {
    -- Các Tab Chính
    ["Farm"] = "Cày Cuốc",
    ["Player"] = "Người Chơi",
    ["Egg Finder"] = "Máy Dò Trứng",
    ["Predictor"] = "Soi Trứng",
    ["Progress"] = "Tiến Độ",
    ["Server"] = "Máy Chủ",
    ["Misc"] = "Linh Tinh",
    ["Creator"] = "Tác Giả",
    ["Discord"] = "Discord",
    ["Quick & Keys"] = "Phím Tắt",
    ["Settings"] = "Cài Đặt",
    ["Config"] = "Cấu Hình",
    
    -- === DR SCRAMBLE EVENT (SỰ KIỆN MỚI) ===
    ["Dr Scramble Event"] = "Sự Kiện Dr Scramble",
    ["Auto Hunt Drones"] = "Tự Động Săn Drone",
    ["Kill drones during outbreaks for Samples and Drone Parts"] = "Tiêu diệt drone khi bùng phát để lấy Mẫu Vật và Phụ Tùng",
    ["Hunt Priority"] = "Ưu Tiên Săn",
    ["Most HP First"] = "Nhiều Máu Nhất Trước",
    ["Drone Types"] = "Loại Drone",
    ["Hunt Travel Method"] = "Cách Thức Di Chuyển",
    ["Teleport only to drones within 50 studs, farther ones are tweened"] = "Dịch chuyển nếu dưới 50 studs, xa hơn sẽ dùng Tween bay tới",
    ["Hunt Tween Speed"] = "Tốc Độ Bay (Tween) Săn",
    ["Only Until Vault Parts Found"] = "Dừng Khi Đủ Phụ Tùng Hầm",
    ["Auto Collect Lost Parts"] = "Tự Nhặt Phụ Tùng Rơi",
    ["Collect the 2 Lost Parts for the vault"] = "Thu thập đủ 2 Phụ Tùng Rơi để mở hầm",
    ["Auto Open Vault"] = "Tự Động Mở Hầm Chứa",
    ["Open the vault when all 5 parts are found"] = "Tự mở khóa hầm khi đã thu thập đủ 5 phụ tùng",
    ["Auto Buy Scramble Shop"] = "Tự Động Mua Shop Scramble",
    ["Buy the picked items with Samples"] = "Dùng Mẫu Vật để mua các món đồ đã chọn",
    ["Scramble Shop Items"] = "Vật Phẩm Cửa Hàng Scramble",
    ["Keep Samples"] = "Giữ Lại Mẫu Vật (Không mua hết)",
    ["Go To Secret Cave"] = "Đi Đến Hang Động Bí Ẩn (Secret)",
    
    -- Cập nhật từ Ảnh Dr Scramble Mech & Scrambled Mutation
    ["Dr Scramble Mech"] = "Mech Dr Scramble",
    ["Dr Scramble Mech (New)"] = "Mech Dr Scramble (Mới)",
    ["Next Mech portal in"] = "Cổng Mech tiếp theo sau",
    ["Auto Mech Boss"] = "Tự Động Đánh Boss Mech",
    ["Mech Tốc Độ Bay (Tween)"] = "Mech Tốc Độ Bay (Tween)",
    ["Main Weapon Hold"] = "Giữ Vũ Khí Chính",
    ["Scrambler Hold"] = "Giữ Máy Gây Nhiễu",
    ["Swap Two Weapons"] = "Đổi Hai Vũ Khí",
    ["Dodge Attacks"] = "Né Đòn Tấn Công",
    ["Anti Guard"] = "Chống Vệ Sĩ",
    ["Ball And Core Phase"] = "Giai Đoạn Bóng & Lõi",
    ["Leave After Fight"] = "Rời Đi Sau Khi Đánh",
    ["Auto Use Scrambled Mutation"] = "Tự Động Dùng Đột Biến Scrambled",
    ["Idle"] = "Đang Chờ",
    ["Turn it on to start applying Scrambled"] = "Bật lên để bắt đầu áp dụng Scrambled",
    ["Charges"] = "Lượt Sạc",
    ["Eggs"] = "Trứng",
    ["Tries"] = "Lần Thử",
    ["Applied"] = "Đã Áp Dụng",
    ["Mutation Độ Hiếm Tối Thiểu"] = "Độ Hiếm Đột Biến Tối Thiểu",
    ["Only eggs of this rarity and above are used"] = "Chỉ dùng trứng từ độ hiếm này trở lên",
    ["Min Mutation Giá Trị"] = "Giá Trị Đột Biến Tối Thiểu",
    ["Bỏ qua trứng rẻ hơn mức này (0 = Tắt)"] = "Bỏ qua trứng rẻ hơn mức này (0 = Tắt)",
    ["Mutation Priority"] = "Ưu Tiên Đột Biến",
    ["Giá Trị Cao Nhất"] = "Giá Trị Cao Nhất",
    ["Which egg gets the consumable first"] = "Trứng nào nhận vật phẩm tiêu hao trước",
    ["Mutation Target Eggs"] = "Trứng Mục Tiêu Đột Biến",
    ["Only use the consumable on these eggs (empty = all)"] = "Chỉ dùng vật phẩm này lên những trứng này (Trống = Tất cả)",
    ["Auto Buy Scrambled"] = "Tự Động Mua Scrambled",
    ["Buy another Scrambled from the event shop when you run out"] = "Tự mua thêm Scrambled từ shop sự kiện khi hết",
    ["Any"] = "Bất Kỳ",
    ["All"] = "Tất Cả",
    ["Tắt"] = "Tắt",

    -- Các menu điều hướng
    ["Farm Tab > Auto Steal"] = "Tab Cày Cuốc > Tự Động Cướp",
    ["Farm Tab > Auto Place Egg"] = "Tab Cày Cuốc > Tự Đặt Trứng",
    ["Farm Tab > Auto Treadmill"] = "Tab Cày Cuốc > Tự Chạy Máy Tập",
    ["Farm Tab > Auto Hatch & Equip"] = "Tab Cày Cuốc > Tự Ấp & Thay Thú",
    ["Farm Tab > Auto Sell"] = "Tab Cày Cuốc > Tự Động Bán",
    ["Farm Tab > Auto Fuse Machine"] = "Tab Cày Cuốc > Tự Máy Ghép",
    ["Farm Tab > Auto Favorite"] = "Tab Cày Cuốc > Tự Khóa Thú",
    ["Farm Tab > Auto Rift & Boss"] = "Tab Cày Cuốc > Tự Động Rift & Boss",
    ["Player Tab > ESP"] = "Tab Người Chơi > Xuyên Tường (ESP)",
    ["Player Tab > Movement"] = "Tab Người Chơi > Di Chuyển",
    ["Player Tab > Character"] = "Tab Người Chơi > Nhân Vật",
    ["Egg Finder Tab > Egg Finder"] = "Tab Tìm Trứng > Máy Dò Trứng",
    ["Predictor Tab > Discord Webhook"] = "Tab Dự Đoán > Webhook Discord",
    ["Predictor Tab > Egg Predictor"] = "Tab Dự Đoán > Soi Trứng",
    ["Predictor Tab > Fuse Predictor"] = "Tab Dự Đoán > Soi Tỷ Lệ Ghép",
    ["Progress Tab > Auto Progression"] = "Tab Tiến Độ > Tự Động Thăng Tiến",
    ["Server Tab > Server"] = "Tab Máy Chủ > Máy Chủ",
    ["Misc Tab > Performance"] = "Tab Linh Tinh > Hiệu Năng",
    ["Misc Tab > Utility"] = "Tab Linh Tinh > Tiện Ích",
    ["Discord Tab > Creator Event"] = "Tab Discord > Sự Kiện Tác Giả",
    ["Discord Tab > Community"] = "Tab Discord > Cộng Đồng",
    ["Quick & Keys Tab > Quick Access"] = "Tab Phím Tắt > Truy Cập Nhanh",
    ["Quick & Keys Tab > Quick Bar & Keybinds"] = "Tab Phím Tắt > Thanh Nhanh & Gán Phím",
    ["Settings Tab > Interface"] = "Tab Cài Đặt > Giao Diện",
    ["Settings Tab > Defaults"] = "Tab Cài Đặt > Mặc Định",
    ["Config Tab > Config"] = "Tab Cấu Hình > Cấu Hình",
    ["Config Tab > Profiles"] = "Tab Cấu Hình > Hồ Sơ",
    ["Config Tab > Import/Export"] = "Tab Cấu Hình > Nhập/Xuất",

    -- Các tính năng
    ["Auto Steal"] = "Tự Động Cướp",
    ["Target Areas"] = "Khu Vực Mục Tiêu",
    ["Min Rarity"] = "Độ Hiếm Tối Thiểu",
    ["Steal eggs of the chosen rarity and every rarity above it"] = "Cướp trứng từ độ hiếm đã chọn trở lên",
    ["Min Value To Steal"] = "Giá Trị Cướp Tối Thiểu",
    ["Skip eggs worth less than this (0 = off)"] = "Bỏ qua trứng rẻ hơn mức này (0 = Tắt)",
    ["Target Specific Eggs"] = "Nhắm Trứng Cụ Thể",
    ["Only steal these eggs (empty = all)"] = "Chỉ cướp những trứng này (Trống = Tất cả)",
    ["Prioritize Rift Recipe Eggs"] = "Ưu Tiên Trứng Rift",
    ["Steal eggs the Rift recipe needs first"] = "Cướp trứng cần cho Rift trước",
    ["Steal Priority"] = "Ưu Tiên Cướp",
    ["Highest Value"] = "Giá Trị Cao Nhất",
    ["Tween Speed"] = "Tốc Độ Bay (Tween)",
    ["Anti Guard V1"] = "Chống Vệ Sĩ V1",
    ["Not recommended to use with Auto Steal"] = "Không khuyên dùng cùng Tự Động Cướp",
    ["Auto Place Egg"] = "Tự Động Đặt Trứng",
    ["Place Egg Rule"] = "Quy Tắc Đặt Trứng",
    ["Place Egg Priority"] = "Ưu Tiên Đặt Trứng",
    ["Biggest Size"] = "Kích Thước Lớn Nhất",
    ["Always"] = "Luôn Luôn",
    ["Auto Treadmill"] = "Tự Chạy Máy Tập",
    ["Stay On Treadmill"] = "Giữ Trên Máy Tập",
    ["Re-mount the belt whenever the ride drops"] = "Tự trèo lên lại nếu bị rớt",
    ["Auto Hatch & Equip"] = "Tự Ấp & Thay Thú",
    ["Auto Hatch"] = "Tự Động Ấp",
    ["Auto Equip Best"] = "Tự Mặc Đồ Xịn Nhất",
    ["Equip Best when a better pet appears"] = "Tự đổi thú xịn hơn khi có",
    ["Auto Sell"] = "Tự Động Bán",
    ["Auto Sell Pet"] = "Tự Động Bán Thú",
    ["Sell Pets Now"] = "Bán Thú Ngay",
    ["Sell Pet Rule"] = "Quy Tắc Bán Thú",
    ["Which checks must pass to sell"] = "Điều kiện cần thỏa mãn để bán",
    ["Rarity Only"] = "Chỉ Xét Độ Hiếm",
    ["Pet Max Rarity"] = "Độ Hiếm Thú Tối Đa",
    ["Sell pets at or below this rarity"] = "Bán thú từ độ hiếm này trở xuống",
    ["Pet Value Threshold"] = "Ngưỡng Giá Trị Thú",
    ["Sell pets worth less than this (0 = off)"] = "Bán thú rẻ hơn mức này (0 = Tắt)",
    ["Keep Mutated Pets"] = "Giữ Thú Đột Biến",
    ["Never sell mutated pets"] = "Tuyệt đối không bán thú đột biến",
    ["Blacklist Sell Pets"] = "Danh Sách Đen (Không Bán)",
    ["These pets are never sold"] = "Những thú này sẽ không bao giờ bị bán",
    ["Auto Sell Egg"] = "Tự Động Bán Trứng",
    ["Sell bag eggs matching the rules below"] = "Bán trứng trong túi theo luật dưới đây",
    ["Sell Eggs Now"] = "Bán Trứng Ngay",
    ["Sell matching eggs once"] = "Bán trứng đúng điều kiện một lần",
    ["Sell Egg Rule"] = "Quy Tắc Bán Trứng",
    ["Egg Max Rarity"] = "Độ Hiếm Trứng Tối Đa",
    ["Sell eggs at or below this rarity"] = "Bán trứng từ độ hiếm này trở xuống",
    ["Egg Value Threshold"] = "Ngưỡng Giá Trị Trứng",
    ["Sell eggs worth less than this (0 = off)"] = "Bán trứng rẻ hơn mức này (0 = Tắt)",
    ["Keep Mutated Eggs"] = "Giữ Trứng Đột Biến",
    ["Never sell mutated eggs"] = "Tuyệt đối không bán trứng đột biến",
    ["Blacklist Sell Eggs"] = "Danh Sách Đen Trứng",
    ["These eggs are never sold"] = "Những trứng này sẽ không bao giờ bị bán",
    ["Auto Fuse Machine"] = "Tự Động Máy Ghép",
    ["Fuse 3 same pets into an egg, nonstop"] = "Liên tục ghép 3 thú giống nhau",
    ["Fuse Priority Mode"] = "Chế Độ Ưu Tiên Ghép",
    ["Lowest Rarity First"] = "Độ Hiếm Thấp Trộn Trước",
    ["Pets To Use"] = "Thú Cưng Sử Dụng",
    ["Lowest To Highest"] = "Từ Thấp Đến Cao",
    ["Max Rarity to Fuse"] = "Độ Hiếm Ghép Tối Đa",
    ["Specific Species to Fuse"] = "Chỉ Ghép Loài Thú Này",
    ["Only fuse these species (empty = all)"] = "Chỉ ghép những loài này (Trống = Tất cả)",
    ["Skip Mutated Pets"] = "Bỏ Qua Thú Đột Biến",
    ["Eject Incomplete Slots"] = "Đẩy Ra Ô Chưa Đủ",
    ["Take out pets that can't make a set"] = "Lấy ra thú không đủ bộ 3 con",
    ["Auto Favorite"] = "Tự Động Khóa Thú",
    ["Auto Favorite Pet"] = "Tự Động Khóa Thú",
    ["Favorite pets matching the rules below"] = "Khóa thú thỏa mãn luật bên dưới",
    ["Favorite Pets Now"] = "Khóa Thú Ngay",
    ["Favorite matching pets once"] = "Khóa thú đúng điều kiện 1 lần",
    ["Favorite Rule"] = "Quy Tắc Khóa",
    ["Pass any check or all checks"] = "Thỏa 1 điều kiện hoặc tất cả",
    ["Match All"] = "Khớp Tất Cả",
    ["Favorite Min Rarity"] = "Độ Hiếm Khóa Min",
    ["Favorite pets of the chosen rarity and every rarity above it"] = "Khóa thú từ độ hiếm này trở lên",
    ["Favorite Mutations"] = "Khóa Thú Đột Biến",
    ["Mutation check (empty = skip)"] = "Kiểm tra đột biến (Trống = Bỏ qua)",
    ["Favorite Min Value"] = "Giá Trị Khóa Min",
    ["Value check (0 = skip)"] = "Kiểm tra giá trị (0 = Bỏ qua)",
    ["Always Favorite Species"] = "Luôn Khóa Loài Này",
    ["Always favorite these species"] = "Luôn khóa những loài thú này",
    ["Auto Favorite Equipped"] = "Tự Khóa Thú Đang Dùng",
    ["Keep equipped pets favorited"] = "Giữ thú đang trang bị ở trạng thái khóa",
    ["Auto Unfavorite Equipped"] = "Tự Mở Khóa Thú Đang Dùng",
    ["Unfavorite equipped pets not in the rules"] = "Mở khóa nếu không đúng luật",
    ["Favorite Equipped Now"] = "Khóa Thú Đang Dùng Ngay",
    ["Favorite all equipped pets once"] = "Khóa tất cả thú đang dùng",
    ["Unfavorite Equipped Now"] = "Mở Khóa Thú Đang Dùng Ngay",
    ["Unfavorite all equipped pets once"] = "Mở khóa tất cả thú đang dùng",
    ["Auto Rift & Boss"] = "Tự Động Rift & Boss",
    ["Auto Rift Sacrifice"] = "Tự Động Hiến Tế Rift",
    ["Trade the 3 required pets into the Rift machine"] = "Tự nạp 3 thú yêu cầu vào máy Rift",
    ["Auto Reroll Rift Recipe"] = "Tự Động Đổi Công Thức Rift",
    ["Reroll the recipe when a pet is missing and free rerolls remain"] = "Đổi công thức nếu thiếu thú và còn lượt free",
    ["Auto Claim Boss Mastery"] = "Tự Nhận Thưởng Boss",
    ["Claim milestone rewards as soon as the kill count allows"] = "Nhận mốc thưởng ngay khi đủ điểm hạ gục",
    ["Auto Fight Boss"] = "Tự Động Đánh Boss",
    ["Auto Progression"] = "Tự Động Thăng Tiến",
    ["Auto Buy Trail"] = "Tự Động Mua Vệt Sáng",
    ["Automatically buy available trails when affordable"] = "Tự động mua vệt sáng khi đủ tiền",
    ["Auto Upgrade Base"] = "Tự Động Nâng Cấp Căn Cứ",
    ["Automatically upgrade base when money is available"] = "Tự động nâng cấp căn cứ khi có tiền",
    ["Auto Upgrade Treadmill"] = "Tự Động Nâng Cấp Máy Tập",
    ["Automatically upgrade treadmill when money is available"] = "Tự động nâng cấp máy tập khi có tiền",
    ["Auto Claim"] = "Tự Động Nhận Thưởng",
    ["Claim offline money & index rewards"] = "Nhận tiền offline & thưởng danh mục",
    ["ESP"] = "Xuyên Tường (ESP)",
    ["ESP Eggs"] = "Hiển Thị Trứng",
    ["ESP Fixed Size"] = "Cố Định Kích Cỡ ESP",
    ["ESP Own Base Eggs"] = "Hiển Thị Trứng Căn Cứ Mình",
    ["Also show the eggs placed in your own base"] = "Hiện cả trứng đã đặt trong căn cứ của bạn",
    ["ESP Min Rarity"] = "Độ Hiếm Tối Thiểu ESP",
    ["Show eggs of the chosen rarity and every rarity above it"] = "Hiện trứng từ độ hiếm này trở lên",
    ["ESP Show Info"] = "Hiện Thông Tin ESP",
    ["ESP Min Value"] = "Giá Trị ESP Tối Thiểu",
    ["ESP Egg Size"] = "Kích Cỡ Trứng ESP",
    ["ESP Guards"] = "Hiển Thị Vệ Sĩ",
    ["ESP Guard Size"] = "Kích Cỡ Vệ Sĩ ESP",
    ["ESP Players"] = "Hiển Thị Người Chơi",
    ["ESP Player Info"] = "Thông Tin Người Chơi ESP",
    ["ESP Player Size"] = "Kích Cỡ Người Chơi ESP",
    ["Movement"] = "Di Chuyển",
    ["Speed Boost"] = "Tăng Tốc Di Chuyển",
    ["Boost Speed"] = "Tốc Độ Tăng Cường",
    ["Infinite Jump"] = "Nhảy Vô Hạn",
    ["Character"] = "Nhân Vật",
    ["Anti Ragdoll"] = "Chống Ngã (Ragdoll)",
    ["Anti Trap"] = "Chống Bẫy",
    ["Traps from other players cannot catch you"] = "Bẫy của người khác không bắt được bạn",
    ["Instant Steal"] = "Cướp Tức Thì",
    ["IDLE"] = "ĐANG CHỜ LỆNH",
    ["Turn on Egg Finder to start hunting"] = "Bật Máy Dò Trứng để bắt đầu săn",
    ["Keep hopping servers until a matching egg is found"] = "Đổi server liên tục tới khi thấy trứng đúng luật",
    ["Link To Auto Steal Filters"] = "Dùng Chung Bộ Lọc Tự Động Cướp",
    ["Share one set of filters with Auto Steal, both sides stay in step"] = "Đồng bộ hóa bộ lọc với tab Tự Động Cướp",
    ["Min Value To Find"] = "Giá Trị Trứng Tối Thiểu",
    ["Hop Only When Rarity Appears"] = "Chỉ Đổi Server Khi Thấy Độ Hiếm Này",
    ["Wait for the chosen rarity to appear, then hop until night"] = "Chờ độ hiếm xuất hiện, sau đó đổi server liên tục",
    ["Rarity That Must Appear"] = "Độ Hiếm Bắt Buộc Xuất Hiện",
    ["Hop starts when this rarity or higher appears"] = "Đổi server khi độ hiếm này xuất hiện",
    ["Hop Delay"] = "Độ Trễ Đổi Server",
    ["Egg Predictor"] = "Soi Trứng (Predictor)",
    ["Sort By"] = "Sắp Xếp Theo",
    ["Value"] = "Giá Trị",
    ["Preview Card"] = "Xem Thẻ Trước",
    ["Search eggs..."] = "Tìm kiếm trứng...",
    ["Tap an egg below to preview it"] = "Chạm vào trứng bên dưới để xem chi tiết",
    ["In inventory"] = "Trong túi",
    ["Hold egg"] = "Đang giữ",
    ["Fuse Predictor"] = "Soi Tỷ Lệ Ghép (Fuse)",
    ["Machine is empty"] = "Máy đang trống",
    ["Load 3 pets of the same species to see the result odds"] = "Cho 3 thú cùng loài vào để xem tỷ lệ kết quả",
    ["Search"] = "Tìm Kiếm",
    ["Auto Load Script"] = "Tự Động Nạp Script",
    ["Server Hop Mode"] = "Chế Độ Đổi Server",
    ["Least Players"] = "Ít Người Chơi Nhất",
    ["Server Hop"] = "Đổi Server Ngay",
    ["Job ID"] = "ID Máy Chủ (Job ID)",
    ["Paste a server Job ID..."] = "Dán ID máy chủ vào đây...",
    ["Join Job ID"] = "Vào Bằng ID",
    ["Copy Current Job ID"] = "Chép ID Máy Chủ Hiện Tại",
    ["Rejoin Server"] = "Vào Lại Máy Chủ Này",
    ["Join"] = "Vào",
    ["Copy"] = "Chép",
    ["Rejoin"] = "Vào Lại",
    ["Hop"] = "Chuyển",
    ["Performance"] = "Hiệu Năng",
    ["FPS Cap"] = "Giới Hạn FPS",
    ["Optimizer"] = "Tối Ưu Hóa Tối Đa",
    ["Strip shadows, textures and effects for the highest FPS"] = "Tắt bóng, kết cấu và hiệu ứng để đạt FPS cao nhất",
    ["FPS and Ping"] = "Hiện FPS & Ping",
    ["FPS and Ping Size"] = "Cỡ Chữ FPS & Ping",
    ["Utility"] = "Tiện Ích",
    ["Anti AFK"] = "Chống Treo Máy (AFK)",
    ["Creator Event"] = "Sự Kiện Của Tác Giả",
    ["INVITE LINK"] = "LIÊN KẾT MỜI",
    ["Copy Link"] = "Sao Chép Link",
    ["WHAT YOU GET"] = "BẠN NHẬN ĐƯỢC GÌ",
    ["New Scripts & Updates"] = "Script & Cập Nhật Mới",
    ["Patch notes and new game scripts are posted there first."] = "Chi tiết cập nhật và script game mới được đăng ở đây đầu tiên.",
    ["Giveaways"] = "Tặng Quà (Giveaways)",
    ["Member giveaways and events are announced in the server."] = "Sự kiện và phát quà cho thành viên được thông báo trong server.",
    ["Support"] = "Hỗ Trợ",
    ["Ask for help, report bugs and get answers from the team."] = "Hỏi đáp, báo lỗi và nhận hỗ trợ từ nhóm phát triển.",
    ["Suggestions"] = "Đóng Góp Ý Kiến",
    ["Request features and vote on what gets added next."] = "Yêu cầu tính năng và bình chọn cập nhật tiếp theo.",
    ["Paste the copied link into your browser or the Discord app to join."] = "Dán link vừa chép vào trình duyệt hoặc app Discord để tham gia.",
    ["Copy Discord Link"] = "Chép Link Discord",
    ["Click"] = "Bấm",
    ["Quick Access"] = "Truy Cập Nhanh",
    ["Show Quick Bars"] = "Hiện Thanh Phím Tắt",
    ["Floating quick bars; drag a header to move one"] = "Thanh phím tắt nổi; kéo tiêu đề để di chuyển",
    ["Visible Quick Bars"] = "Các Thanh Đang Hiện",
    ["Quick Bar Size"] = "Kích Cỡ Thanh Phím Tắt",
    ["Quick Bar & Keybinds"] = "Thanh Phím Tắt & Gán Nút",
    ["Reset Quick Access"] = "Đặt Lại Truy Cập Nhanh",
    ["Restore default items, bars and positions"] = "Khôi phục lại vị trí thanh mặc định",
    ["Reset Keybinds"] = "Đặt Lại Nút Gán",
    ["Restore the defaults set in code"] = "Khôi phục lại nút gán mặc định",
    ["Reset"] = "Đặt Lại",
    ["Interface"] = "Giao Diện",
    ["UI Size"] = "Kích Cỡ Giao Diện",
    ["Scales the main window; the corner grip does the same by hand"] = "Đổi cỡ cửa sổ; kéo góc dưới cùng bên phải để đổi thủ công",
    ["Notifications"] = "Bật Thông Báo",
    ["Show notification cards; turning this off hides every notify"] = "Hiện thẻ thông báo; tắt mục này sẽ ẩn toàn bộ",
    ["Open On Launch"] = "Mở Khi Khởi Chạy",
    ["Open the UI automatically when the script starts"] = "Tự động hiện bảng menu khi script bắt đầu",
    ["Defaults"] = "Mặc Định",
    ["Reset to Defaults"] = "Đặt Lại Về Mặc Định",
    ["Reset every feature to its built-in default"] = "Khôi phục mọi tính năng về mặc định gốc",
    ["Turn Off All Toggles"] = "Tắt Tất Cả Công Tắc",
    ["Switch off every enabled toggle in the feature tabs"] = "Tắt mọi công tắc đang bật trong các tab",
    ["Turn Off"] = "Tắt Ngay",
    ["Auto Save Config"] = "Tự Động Lưu Cấu Hình",
    ["Auto Load Config"] = "Tự Động Nạp Cấu Hình",
    ["New Config Name"] = "Tên Cấu Hình Mới",
    ["Create New Config"] = "Tạo Cấu Hình Mới",
    ["Save Config"] = "Lưu Cấu Hình Hiện Tại",
    ["Import Config Text"] = "Nhập Mã Văn Bản Cấu Hình",
    ["Destination"] = "Nơi Nhận Thông Báo",
    ["Webhook URL"] = "Đường Dẫn Webhook",
    ["Notify Egg Finder Match"] = "Báo Khi Máy Dò Khớp Trứng",
    ["Post the egg Egg Finder stops hopping for"] = "Gửi cảnh báo quả trứng mà Máy Dò vừa tìm được",
    ["Notify Stolen Eggs"] = "Báo Khi Cướp Được Trứng",
    ["Post every egg you bring home"] = "Gửi thông báo mỗi khi bạn cướp thành công mang về nhà",
    ["None"] = "Không Chọn",
    ["Off"] = "Tắt",
    ["Filter features..."] = "Lọc tính năng...",
    ["Favorite"] = "Khóa Lại",
    ["Unfavorite"] = "Mở Khóa",
    ["Sell"] = "Bán",
    ["Mythic"] = "Thần Thoại (Mythic)",
    ["Secret"] = "Bí Ẩn (Secret)",
    ["Divine"] = "Thánh Thần (Divine)",
    ["Eternal"] = "Vĩnh Cửu (Eternal)",
    ["Cosmic"] = "Vũ Trụ (Cosmic)",
    ["Legendary"] = "Huyền Thoại (Legendary)",
    ["Window Minimized - Click bubble to restore"] = "Cửa sổ đã thu nhỏ - Bấm bong bóng để mở lại",
    ["Let's Chat!"] = "Trò Chuyện Nào!",
    ["Connecting to Global Script Chat..."] = "Đang kết nối chat thế giới...",
    ["Send"] = "Gửi",
    ["Live"] = "Trực Tiếp",
    ["Spoof anti cheat success!"] = "Đã vượt qua Anti-Cheat thành công!",
    ["Fetching..."] = "Đang Tải Dữ Liệu...",
    ["Loaded"] = "Đã Nạp Xong"
}

-- Mẫu Regex xử lý chuỗi động đa ngôn ngữ (Chỉ EN/VI)
local DYNAMIC_PATTERNS = {
    -- Regex đếm ngược thời gian Mech Portal
    { 
        pattern = "^Next Mech portal in (.-)$", 
        format = function(lang, timeStr) 
            if lang == "VI" then return "Cổng Mech tiếp theo sau " .. timeStr end 
            return "Next Mech portal in " .. timeStr 
        end 
    },
    -- Regex đếm số lượng Mẫu Vật & Phụ Tùng sự kiện Dr Scramble
    { 
        pattern = "^Samples (%d+) %- Lost (%d+)/(%d+) Drone (.-) %- Outbreak in (.-)$", 
        format = function(lang, s, l1, l2, d, t) 
            if lang == "VI" then return "Mẫu vật " .. s .. " - Đã rơi " .. l1 .. "/" .. l2 .. " - Drone " .. d .. " - Bùng phát sau " .. t end 
            return "Samples " .. s .. " - Lost " .. l1 .. "/" .. l2 .. " - Drone " .. d .. " - Outbreak in " .. t 
        end 
    },
    { 
        pattern = "^Lost Parts on map (%d+)/(%d+) %- Collected (%d+)/(%d+)$", 
        format = function(lang, m1, m2, c1, c2) 
            if lang == "VI" then return "Phụ Tùng Rơi trên map " .. m1 .. "/" .. m2 .. " - Đã nhặt " .. c1 .. "/" .. c2 end 
            return "Lost Parts on map " .. m1 .. "/" .. m2 .. " - Collected " .. c1 .. "/" .. c2 
        end 
    },
    { 
        pattern = "^(%d+) selected$", 
        format = function(lang, count) 
            if lang == "VI" then return "Đã chọn " .. count end 
            return count .. " selected" 
        end 
    },
    { 
        pattern = "^IN INVENTORY %((%d+)%)$", 
        format = function(lang, count) 
            if lang == "VI" then return "TRONG TÚI ĐỒ (" .. count .. ")" end 
            return "IN INVENTORY (" .. count .. ")" 
        end 
    },
    { 
        pattern = "^Eggs placed (%d+)%/(%d+) %- (%d+)%/(%d+) pets equipped, (%d+) in bag$", 
        format = function(lang, e1, e2, p1, p2, b1) 
            if lang == "VI" then return "Đã đặt " .. e1 .. "/" .. e2 .. " trứng - " .. p1 .. "/" .. p2 .. " thú trang bị, " .. b1 .. " trong túi" end 
            return "Eggs placed " .. e1 .. "/" .. e2 .. " - " .. p1 .. "/" .. p2 .. " pets equipped, " .. b1 .. " in bag" 
        end 
    },
    { 
        pattern = "^Pet matches %- (%d+) pets for %$(.-)$", 
        format = function(lang, count, val) 
            if lang == "VI" then return "Thú khớp lệnh - " .. count .. " thú, tổng giá $" .. val end 
            return "Pet matches - " .. count .. " pets for $" .. val 
        end 
    },
    { 
        pattern = "^Egg matches %- (%d+) eggs for %$(.-)$", 
        format = function(lang, count, val) 
            if lang == "VI" then return "Trứng khớp lệnh - " .. count .. " trứng, tổng giá $" .. val end 
            return "Egg matches - " .. count .. " eggs for $" .. val 
        end 
    },
    { 
        pattern = "^Next fuse %- (%d+) (.-) for %$(.-)$", 
        format = function(lang, count, name, val) 
            if lang == "VI" then return "Ghép tiếp theo - " .. count .. " " .. name .. " tốn $" .. val end 
            return "Next fuse - " .. count .. " " .. name .. " for $" .. val 
        end 
    },
    { 
        pattern = "^Favorite matches %- (%d+) pets, (%d+) to mark %| (%d+) favorited$", 
        format = function(lang, mCount, mark, fav) 
            if lang == "VI" then return "Khớp khóa thú - " .. mCount .. " con, " .. mark .. " cần khóa | " .. fav .. " đã khóa" end 
            return "Favorite matches - " .. mCount .. " pets, " .. mark .. " to mark | " .. fav .. " favorited" 
        end 
    },
    { 
        pattern = "^Riftborn %- needs (.-) %- pity (%d+)%/(%d+) %- free rerolls (%d+) %- rotates in (.-) %- boss portal (.-)$", 
        format = function(lang, needs, pity1, pity2, reroll, timeStr, status) 
            if lang == "VI" then return "Riftborn - Cần: " .. needs .. " - Bảo hiểm: " .. pity1 .. "/" .. pity2 .. " - Quay free: " .. reroll .. " - Đổi sau " .. timeStr .. " - Cổng Boss: " .. (status == "closed" and "Đóng" or "Mở") end 
            return "Riftborn - needs " .. needs .. " - pity " .. pity1 .. "/" .. pity2 .. " - free rerolls " .. reroll .. " - rotates in " .. timeStr .. " - boss portal " .. status 
        end 
    },
    { 
        pattern = "^(%d+) eggs %- (%d+) ready %- (%d+) growing %- (%d+) in bag %- Total (.-)$", 
        format = function(lang, e1, r1, g1, b1, t1) 
            if lang == "VI" then return e1 .. " trứng - " .. r1 .. " xong - " .. g1 .. " đang lớn - " .. b1 .. " trong túi - Tổng " .. t1 end 
            return e1 .. " eggs - " .. r1 .. " ready - " .. g1 .. " growing - " .. b1 .. " in bag - Total " .. t1 
        end 
    },
    { 
        pattern = "^Players (%d+)%/(%d+)$", 
        format = function(lang, p1, p2) 
            if lang == "VI" then return "Người chơi: " .. p1 .. "/" .. p2 end 
            return "Players " .. p1 .. "/" .. p2 
        end 
    }
}

local SortedVI = {}
for en, vi in pairs(MAP_VI) do
    table.insert(SortedVI, {en = en, out = vi, len = #en})
end
table.sort(SortedVI, function(a, b) return a.len > b.len end)

local function translateText(raw)
    local cacheKey = currentLanguage .. "|" .. raw
    if FastCache[cacheKey] then return FastCache[cacheKey] end

    local trimmed = raw:gsub("^%s*(.-)%s*$", "%1")
    local exactMatch = nil

    if currentLanguage == "VI" then
        exactMatch = MAP_VI[trimmed]
    end

    if exactMatch then
        local res = safeReplace(raw, trimmed, exactMatch)
        FastCache[cacheKey] = res
        return res
    end

    for _, item in ipairs(DYNAMIC_PATTERNS) do
        local matches = {trimmed:match(item.pattern)}
        if #matches > 0 then
            local res = item.format(currentLanguage, unpack(matches))
            FastCache[cacheKey] = res
            return res
        end
    end

    local result = raw
    local matched = false

    if currentLanguage == "VI" then
        for _, item in ipairs(SortedVI) do
            if result:find(item.en, 1, true) then
                result = safeReplace(result, item.en, item.out)
                matched = true
            end
        end
    end

    FastCache[cacheKey] = matched and result or raw
    return FastCache[cacheKey]
end

local TrackedElements = {}

local function applyTranslation(inst)
    if not (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then return end
    if inst:FindFirstAncestor("Chilli_TopUI_Slate") then return end

    local original = inst:GetAttribute("OriginalRawText")
    if not original then
        original = inst.Text
        inst:SetAttribute("OriginalRawText", original)
    end

    if currentLanguage == "EN" then
        if inst.Text ~= original then
            translationLock = true
            inst.Text = original
            translationLock = false
        end
    else
        local mappedText = translateText(original)
        if inst.Text ~= mappedText then
            translationLock = true
            inst.Text = mappedText
            translationLock = false
        end
    end
end

local function hookElement(inst)
    if not (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then return end
    if inst:GetAttribute("HasTranslateHook") then return end
    inst:SetAttribute("HasTranslateHook", true)

    table.insert(TrackedElements, inst)
    task.defer(function() applyTranslation(inst) end)

    inst:GetPropertyChangedSignal("Text"):Connect(function()
        if not translationLock then
            local current = inst.Text
            local isKnown = false
            if currentLanguage ~= "EN" then
                for _, item in ipairs(SortedVI) do
                    if current:find(item.out, 1, true) then
                        isKnown = true
                        break
                    end
                end
            else
                isKnown = (current == inst:GetAttribute("OriginalRawText"))
            end

            if not isKnown then
                inst:SetAttribute("OriginalRawText", current)
            end
            applyTranslation(inst)
        end
    end)
end

local function updateAllActive()
    for i = #TrackedElements, 1, -1 do
        local el = TrackedElements[i]
        if el and el.Parent then
            applyTranslation(el)
        else
            table.remove(TrackedElements, i)
        end
    end
end

-- ==================== 4. NÚT ĐỔI NGÔN NGỮ & CÔNG TẮC TỐI ƯU (TOP-CENTER) ====================
local function createTopUI()
    local parentTarget = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    local old = parentTarget:FindFirstChild("Chilli_TopUI_Slate")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Chilli_TopUI_Slate"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 2147483647
    ScreenGui.Parent = parentTarget

    -- Container chính (chứa cả 2 nút)
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 280, 0, 28)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0, 15)
    MainFrame.BackgroundTransparency = 1

    -- === Nút đổi ngôn ngữ ===
    local LangBtnFrame = Instance.new("Frame", MainFrame)
    LangBtnFrame.Size = UDim2.new(0, 130, 1, 0)
    LangBtnFrame.Position = UDim2.new(0, 0, 0, 0)
    LangBtnFrame.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
    LangBtnFrame.BackgroundTransparency = 0.2
    LangBtnFrame.BorderSizePixel = 0
    Instance.new("UICorner", LangBtnFrame).CornerRadius = UDim.new(1, 0)

    local LangStroke = Instance.new("UIStroke", LangBtnFrame)
    LangStroke.Color = Color3.fromRGB(160, 45, 45)
    LangStroke.Thickness = 1.0

    local LangIcon = Instance.new("TextLabel", LangBtnFrame)
    LangIcon.Size = UDim2.new(0, 22, 1, 0)
    LangIcon.Position = UDim2.new(0, 8, 0, 0)
    LangIcon.BackgroundTransparency = 1
    LangIcon.Text = "🌐"
    LangIcon.TextSize = 14

    local LangLabel = Instance.new("TextLabel", LangBtnFrame)
    LangLabel.Size = UDim2.new(1, -36, 1, 0)
    LangLabel.Position = UDim2.new(0, 30, 0, 0)
    LangLabel.BackgroundTransparency = 1
    LangLabel.Text = "Tiếng Việt"
    LangLabel.Font = Enum.Font.GothamMedium
    LangLabel.TextSize = 11
    LangLabel.TextColor3 = Color3.fromRGB(240, 130, 130)
    LangLabel.TextXAlignment = Enum.TextXAlignment.Left

    local LangClickBtn = Instance.new("TextButton", LangBtnFrame)
    LangClickBtn.Size = UDim2.new(1, 0, 1, 0)
    LangClickBtn.BackgroundTransparency = 1
    LangClickBtn.Text = ""

    -- === Nút Bật/Tắt Tối Ưu Đồ Họa ===
    local OptBtnFrame = Instance.new("Frame", MainFrame)
    OptBtnFrame.Size = UDim2.new(0, 130, 1, 0)
    OptBtnFrame.Position = UDim2.new(0, 145, 0, 0) -- Cách nút ngôn ngữ 15px
    OptBtnFrame.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
    OptBtnFrame.BackgroundTransparency = 0.2
    OptBtnFrame.BorderSizePixel = 0
    Instance.new("UICorner", OptBtnFrame).CornerRadius = UDim.new(1, 0)

    local OptStroke = Instance.new("UIStroke", OptBtnFrame)
    OptStroke.Color = Color3.fromRGB(75, 45, 45) -- Màu xám tối (Tắt)
    OptStroke.Thickness = 1.0

    local OptIcon = Instance.new("TextLabel", OptBtnFrame)
    OptIcon.Size = UDim2.new(0, 22, 1, 0)
    OptIcon.Position = UDim2.new(0, 8, 0, 0)
    OptIcon.BackgroundTransparency = 1
    OptIcon.Text = "⚡"
    OptIcon.TextSize = 14

    local OptLabel = Instance.new("TextLabel", OptBtnFrame)
    OptLabel.Size = UDim2.new(1, -36, 1, 0)
    OptLabel.Position = UDim2.new(0, 30, 0, 0)
    OptLabel.BackgroundTransparency = 1
    OptLabel.Text = "Tối Ưu: Tắt"
    OptLabel.Font = Enum.Font.GothamMedium
    OptLabel.TextSize = 11
    OptLabel.TextColor3 = Color3.fromRGB(150, 150, 150) -- Màu xám (Tắt)
    OptLabel.TextXAlignment = Enum.TextXAlignment.Left

    local OptClickBtn = Instance.new("TextButton", OptBtnFrame)
    OptClickBtn.Size = UDim2.new(1, 0, 1, 0)
    OptClickBtn.BackgroundTransparency = 1
    OptClickBtn.Text = ""

    -- === Kéo thả MainFrame ===
    local dragging, dragStart, startPos = false, nil, nil
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- === Logic nút đổi ngôn ngữ ===
    LangClickBtn.MouseButton1Click:Connect(function()
        if currentLanguage == "VI" then
            currentLanguage = "EN"
            LangLabel.Text = "English"
            TweenService:Create(LangLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(215, 180, 180)}):Play()
            TweenService:Create(LangStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(75, 45, 45)}):Play()
        else
            currentLanguage = "VI"
            LangLabel.Text = "Tiếng Việt"
            TweenService:Create(LangLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(240, 130, 130)}):Play()
            TweenService:Create(LangStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(160, 45, 45)}):Play()
        end
        updateAllActive()
    end)

    -- === Logic nút Bật/Tắt Tối Ưu ===
    OptClickBtn.MouseButton1Click:Connect(function()
        if GraphicsOptimizer.Active then
            GraphicsOptimizer:Stop()
            OptLabel.Text = "Tối Ưu: Tắt"
            TweenService:Create(OptLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            TweenService:Create(OptStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(75, 45, 45)}):Play()
        else
            GraphicsOptimizer:Start()
            OptLabel.Text = "Tối Ưu: Bật"
            TweenService:Create(OptLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(130, 240, 130)}):Play()
            TweenService:Create(OptStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(45, 160, 45)}):Play()
        end
    end)
end

-- ==================== 5. BỘ QUÉT ZERO-LAG ĐƯỢC DEFER SAU CÙNG ====================
task.delay(4.5, function()
    createTopUI()
    
    local searchRoots = { gethui and gethui(), CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }

    local function scanUIChunked(parent)
        local children = parent:GetChildren()
        for i, desc in ipairs(children) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                hookElement(desc)
            end
            if i % 20 == 0 then
                RunService.RenderStepped:Wait()
            end
            scanUIChunked(desc)
        end
    end

    for _, root in ipairs(searchRoots) do
        if root then
            pcall(function() scanUIChunked(root) end)
        end
    end

    for _, root in ipairs(searchRoots) do
        if root then
            root.DescendantAdded:Connect(function(desc)
                task.defer(function()
                    if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                        hookElement(desc)
                    end
                end)
            end)
        end
    end
end)
