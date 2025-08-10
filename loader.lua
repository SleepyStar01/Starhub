-- StarHub Loader
-- GitHub: https://github.com/username/StarHub

local REPO_URL = "https://raw.githubusercontent.com/username/StarHub/main/"

local function LoadModule(modulePath)
    local url = REPO_URL .. modulePath
    local success, content = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success then
        return nil, "Gagal load: " .. modulePath .. "\nError: " .. content
    end
    
    local fn, err = loadstring(content)
    if not fn then
        return nil, "Gagal compile: " .. modulePath .. "\nError: " .. err
    end
    
    return fn()
end

-- Load UI Library
local StarHub = LoadModule("hub/core.lua")
if not StarHub then
    warn(StarHub) -- Tampilkan error jika gagal
    return
end

-- ====================== KONFIGURASI STARHUB ======================
local Config = {
    HubName = "StarHub",
    HubVersion = "v0.0.1 Dev Build",
    GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    Scripts = {
        {
            Name = "AutoFarm",
            Description = "Farming otomatis untuk game ini",
            Icon = "rbxassetid://123456789", -- Ganti dengan icon
            Path = "hub/scripts/autofarm.lua",
            Tab = "Main"
        },
        {
            Name = "ESP",
            Description = "Lihat pemain melalui tembok",
            Icon = "rbxassetid://987654321",
            Path = "hub/scripts/esp.lua",
            Tab = "Visual"
        },
        {
            Name = "Aimbot",
            Description = "Auto-aim ke musuh terdekat",
            Icon = "rbxassetid://567891234",
            Path = "hub/scripts/aimbot.lua",
            Tab = "Combat"
        }
        -- Tambahkan script lain di sini
    }
}

-- ====================== BUAT STARHUB UI ======================
local Window = StarHub.CreateWindow(Config.HubName .. " - " .. Config.GameName)

-- Buat tab berdasarkan kategori script
local Tabs = {}
for _, scriptData in pairs(Config.Scripts) do
    if not Tabs[scriptData.Tab] then
        Tabs[scriptData.Tab] = Window:AddTab(scriptData.Tab)
    end
end

-- Tambahkan script ke UI
for _, scriptData in pairs(Config.Scripts) do
    local TargetTab = Tabs[scriptData.Tab]
    
    TargetTab:Button({
        Title = scriptData.Name,
        Description = scriptData.Description,
        Icon = scriptData.Icon,
        Callback = function()
            local Script, Err = LoadModule(scriptData.Path)
            if Script then
                Script()
                StarHub.Notify("✅ Sukses", scriptData.Name .. " diaktifkan!")
            else
                StarHub.Notify("❌ Error", Err)
            end
        end
    })
end

-- Notifikasi saat load selesai
StarHub.Notify(
    "🌟 StarHub Loaded",
    "Tekan [Right-CTRL] untuk buka/tutup menu!"
)