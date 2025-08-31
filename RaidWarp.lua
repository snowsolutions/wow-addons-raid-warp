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
-- Main button (draggable)
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
local frame = CreateFrame("Frame", "RaidWarpFrame", UIParent, "BackdropTemplate")
frame:SetSize(820, 500)
frame:SetPoint("CENTER")
frame:EnableMouse(true)
frame:Hide()

frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints(true)
frame.bg:SetColorTexture(0, 0, 0, 0.85)

-- Title
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("Raid Warp Menu")

-- Close button
local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
closeBtn:SetSize(60, 20)
closeBtn:SetText("Close")
closeBtn:SetPoint("TOPRIGHT", -10, -10)
closeBtn:SetScript("OnClick", function() frame:Hide() end)

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
    Classic = {0.6, 0.45, 0.2, 0.65},  -- vàng nâu
    TBC     = {0.0, 0.6, 0.0, 0.65},  -- xanh lá
    WotLK   = {0.0, 0.4, 0.8, 0.65},  -- xanh dương
}

-- =========================
-- Render list
-- =========================
local function RenderList()
    for _, child in ipairs({content:GetChildren()}) do child:Hide() end

    local y = -5
    local rowHeight = 28

    -- Header
    local header = CreateFrame("Frame", nil, content)
    header:SetSize(760, 25)
    header:SetPoint("TOPLEFT", 0, y)
    local labels = {"Raid", "Expansion", "Patch", "Tier Set", "Difficulty"}
    local xPos = {0, 260, 360, 430, 520}
    for i, label in ipairs(labels) do
        local h = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        h:SetPoint("LEFT", xPos[i], 0)
        h:SetText(label)
    end
    y = y - rowHeight

    -- Rows
    for _, raid in ipairs(RAIDS) do
        local row = CreateFrame("Frame", nil, content)
        row:SetSize(760, 25)
        row:SetPoint("TOPLEFT", 0, y)
        y = y - rowHeight

        -- màu nền theo expansion
        local color = EXP_COLORS[raid.exp] or {0.2, 0.2, 0.2, 0.5}
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(true)
        bg:SetColorTexture(unpack(color))

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
        local warpBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        warpBtn:SetSize(60, 20)
        warpBtn:SetText("Warp")
        warpBtn:SetPoint("RIGHT", -80, 0)
        warpBtn:SetScript("OnClick", function()
            C_ChatInfo.SendChatMessage(raid.tele, "SAY")
        end)

        -- Check button
        local checkBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        checkBtn:SetSize(70, 20)
        checkBtn:SetPoint("RIGHT", -5, 0)

        local function UpdateCheckState()
            if RaidWarpDB[raid.name] then
                checkBtn:SetText("✓Done")
                checkBtn:SetNormalFontObject("GameFontHighlight")
            else
                checkBtn:SetText("Check")
                checkBtn:SetNormalFontObject("GameFontNormal")
            end
        end

        checkBtn:SetScript("OnClick", function()
            if RaidWarpDB[raid.name] then
                RaidWarpDB[raid.name] = nil
            else
                RaidWarpDB[raid.name] = true
            end
            UpdateCheckState()
        end)

        UpdateCheckState()
    end
    content:SetHeight(-y)
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
