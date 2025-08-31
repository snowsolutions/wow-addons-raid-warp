-- =========================
-- Full raid data
-- =========================
local RAIDS = {
    -- Classic
    { name="Molten Core",               exp="Classic", tier="Medium",   patch="1.1",  tierSet="T1", tele=".tele molten" },
    { name="Onyxia’s Lair",             exp="Classic", tier="Easy",     patch="1.1",  tierSet="T2 (helm)", tele=".tele onyxia" },
    { name="Blackwing Lair",            exp="Classic", tier="Medium",   patch="1.6",  tierSet="T2", tele=".tele bwl" },
    { name="Ruins of Ahn’Qiraj (AQ20)", exp="Classic", tier="Easy",     patch="1.9",  tierSet="-", tele=".tele aq20" },
    { name="Temple of Ahn’Qiraj (AQ40)",exp="Classic", tier="Hard",     patch="1.9",  tierSet="T2.5", tele=".tele aq40" },
    { name="Naxxramas (Classic 40)",    exp="Classic", tier="Hard",     patch="1.11", tierSet="T3", tele=".tele naxx" },

    -- The Burning Crusade
    { name="Karazhan",                  exp="TBC",     tier="Easy",     patch="2.0",  tierSet="-", tele=".tele karazhan" },
    { name="Gruul’s Lair",              exp="TBC",     tier="Easy",     patch="2.0",  tierSet="T4 (shoulders)", tele=".tele gruul" },
    { name="Magtheridon’s Lair",        exp="TBC",     tier="Easy",     patch="2.0",  tierSet="T4 (chest)", tele=".tele magtheridon" },
    { name="Serpentshrine Cavern",      exp="TBC",     tier="Medium",   patch="2.1",  tierSet="T5", tele=".tele ssc" },
    { name="Tempest Keep: The Eye",     exp="TBC",     tier="Medium",   patch="2.1",  tierSet="T5", tele=".tele theeye" },
    { name="Battle for Mount Hyjal",    exp="TBC",     tier="Medium",   patch="2.1",  tierSet="T6", tele=".tele hyjal" },
    { name="Black Temple",              exp="TBC",     tier="Hard",     patch="2.1",  tierSet="T6", tele=".tele blacktemple" },
    { name="Sunwell Plateau",           exp="TBC",     tier="Extreme",  patch="2.4",  tierSet="T6.5", tele=".tele sunwell" },

    -- Wrath of the Lich King
    { name="Naxxramas (WotLK 10/25)",   exp="WotLK",   tier="Easy",     patch="3.0",  tierSet="T7", tele=".tele naxx" },
    { name="The Obsidian Sanctum",      exp="WotLK",   tier="Variable", patch="3.0",  tierSet="-", tele=".tele obsidian" },
    { name="The Eye of Eternity",       exp="WotLK",   tier="Medium",   patch="3.0",  tierSet="-", tele=".tele nexus" },
    { name="Ulduar",                    exp="WotLK",   tier="Hard–Extreme", patch="3.1", tierSet="T8", tele=".tele ulduar" },
    { name="Trial of the Crusader",     exp="WotLK",   tier="Hard",     patch="3.2",  tierSet="T9", tele=".tele toc" },
    { name="Icecrown Citadel",          exp="WotLK",   tier="Extreme",  patch="3.3",  tierSet="T10", tele=".tele icecrowncitadel" },
    { name="The Ruby Sanctum",          exp="WotLK",   tier="Extreme",  patch="3.3.5",tierSet="-", tele=".tele rubysanctum" },
}

-- =========================
-- SavedVariables
-- =========================
if not RaidWarpDB then RaidWarpDB = {} end

-- =========================
-- Main draggable button
-- =========================
local mainBtn = CreateFrame("Button", "RaidWarpBtn", UIParent, "UIPanelButtonTemplate")
mainBtn:SetSize(120, 25)
mainBtn:SetText("Raid Warp")
mainBtn:SetPoint("CENTER", UIParent, "CENTER", 0, 200)

mainBtn:SetMovable(true)
mainBtn:EnableMouse(true)
mainBtn:RegisterForDrag("LeftButton")
mainBtn:SetScript("OnDragStart", function(self) self:StartMoving() end)
mainBtn:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- =========================
-- Popup frame
-- =========================
local frame = CreateFrame("Frame", "RaidWarpFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
frame:SetSize(820, 500)
frame:SetPoint("CENTER")
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0,0,0,0.9)
frame:Hide()

frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- Close button
local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
closeBtn:SetSize(60, 20)
closeBtn:SetText("Close")
closeBtn:SetPoint("TOPRIGHT", -10, -10)
closeBtn:SetScript("OnClick", function() frame:Hide() end)

-- Reset button
local resetBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
resetBtn:SetSize(60, 20)
resetBtn:SetText("Reset")
resetBtn:SetPoint("TOPLEFT", 10, -10)
resetBtn:SetScript("OnClick", function()
    wipe(RaidWarpDB)
    RenderList()
end)

-- =========================
-- Scroll area
-- =========================
local scroll = CreateFrame("ScrollFrame", "RaidWarpScroll", frame, "UIPanelScrollFrameTemplate")
scroll:SetSize(780, 430)
scroll:SetPoint("TOPLEFT", 20, -40)

local content = CreateFrame("Frame", "RaidWarpContent", scroll)
content:SetSize(760, 1)
scroll:SetScrollChild(content)

-- =========================
-- Expansion row colors
-- =========================
local EXP_COLORS = {
    Classic = {0.6, 0.45, 0.2, 0.65},  -- vàng nâu, alpha 65%
    TBC     = {0.0, 0.6, 0.0, 0.65},  -- xanh lá đậm
    WotLK   = {0.0, 0.4, 0.8, 0.65},  -- xanh dương
}

-- =========================
-- Render list
-- =========================
function RenderList()
    for _, child in ipairs({content:GetChildren()}) do child:Hide() end

    local y = 0
    local rowHeight = 28

    -- header
    local header = CreateFrame("Frame", nil, content)
    header:SetSize(760, 25)
    header:SetPoint("TOPLEFT", 0, y)
    local h1 = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    h1:SetPoint("LEFT", 0, 0); h1:SetText("Raid Name")
    local h2 = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    h2:SetPoint("LEFT", 260, 0); h2:SetText("Expansion")
    local h3 = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    h3:SetPoint("LEFT", 360, 0); h3:SetText("Patch")
    local h4 = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    h4:SetPoint("LEFT", 430, 0); h4:SetText("Tier Set")
    local h5 = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    h5:SetPoint("LEFT", 520, 0); h5:SetText("Difficulty")
    y = y - rowHeight

    for _, raid in ipairs(RAIDS) do
        local row = CreateFrame("Frame", nil, content, BackdropTemplateMixin and "BackdropTemplate" or nil)
        row:SetSize(760, 25)
        row:SetPoint("TOPLEFT", 0, y)
        y = y - rowHeight

        -- row color by expansion
        local color = EXP_COLORS[raid.exp] or {0,0,0,0}
        row:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
        row:SetBackdropColor(unpack(color))

        local txt = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        txt:SetPoint("LEFT", 0, 0)
        txt:SetText(raid.name)

        local exp = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        exp:SetPoint("LEFT", 260, 0)
        exp:SetText(raid.exp)

        local patch = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        patch:SetPoint("LEFT", 360, 0)
        patch:SetText(raid.patch)

        local tierSet = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        tierSet:SetPoint("LEFT", 430, 0)
        tierSet:SetText(raid.tierSet)

        local tier = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        tier:SetPoint("LEFT", 520, 0)
        tier:SetText(raid.tier)

        -- Warp button
        local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btn:SetSize(60, 20)
        btn:SetText("Warp")
        btn:SetPoint("RIGHT", -80, 0)
        btn:SetScript("OnClick", function()
            SendChatMessage(raid.tele, "SAY")
        end)

        -- Check/Uncheck toggle button
        local checkBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        checkBtn:SetSize(70, 20)
        checkBtn:SetPoint("RIGHT", -5, 0)

        local function UpdateCheckState()
            if RaidWarpDB[raid.name] then
                checkBtn:SetText("✓Done")
                checkBtn:SetNormalFontObject("GameFontHighlight")
                checkBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
                checkBtn:GetNormalTexture():SetVertexColor(0, 0.8, 0) -- xanh lá nền nút
            else
                checkBtn:SetText("Check")
                checkBtn:SetBackdrop({ bgFile = "Interface/Buttons/UI-Panel-Button-Up" })
                checkBtn:GetNormalTexture():SetVertexColor(1, 1, 1) -- trắng mặc định
            end
        end

        checkBtn:SetScript("OnClick", function(self)
            if RaidWarpDB[raid.name] then
                RaidWarpDB[raid.name] = nil
            else
                RaidWarpDB[raid.name] = true
            end
            UpdateCheckState()
        end)

        UpdateCheckState()
    end

    local totalHeight = (#RAIDS * rowHeight) + 10
    content:SetHeight(totalHeight)
end

-- =========================
-- Toggle popup
-- =========================
mainBtn:SetScript("OnClick", function()
    if frame:IsShown() then
        frame:Hide()
    else
        RenderList()
        frame:Show()
    end
end)
