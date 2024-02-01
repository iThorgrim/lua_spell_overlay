local AIO = AIO or require("AIO")
if AIO.AddAddon() then return end

local Server                        = AIO.AddHandlers("SpellOverlay", {})
local Spell_Activation_Overlay      = { }

function Spell_Activation_Overlay.Generate(texture, spell_id)
    if (not Spell_Activation_Overlay.Frame) then
        Spell_Activation_Overlay.GenerateMainFrame()
    end
    Spell_Activation_Overlay.SetTexture(texture)

    Spell_Activation_Overlay.GenerateSpellIcon(spell_id)
    Spell_Activation_Overlay.GenerateCoolDown(Spell_Activation_Overlay.ExtraIcon)
    Spell_Activation_Overlay.SetCooldown(Spell_Activation_Overlay.ExtraIcon)
end

function Spell_Activation_Overlay.GenerateMainFrame()
    Spell_Activation_Overlay.Frame = CreateFrame("Frame", "ExtraButtonFrame", UIParent)

    Spell_Activation_Overlay.Frame:EnableMouse(true)
    Spell_Activation_Overlay.Frame:SetToplevel(true)
    Spell_Activation_Overlay.Frame:SetMovable(true)
    Spell_Activation_Overlay.Frame:SetClampedToScreen(true)

    Spell_Activation_Overlay.Frame:SetSize(250, 120)

    Spell_Activation_Overlay.Frame:SetPoint("CENTER")
    Spell_Activation_Overlay.Frame:RegisterForDrag("LeftButton")
    Spell_Activation_Overlay.Frame:SetScript("OnDragStart", Spell_Activation_Overlay.Frame.StartMoving)
    Spell_Activation_Overlay.Frame:SetScript("OnHide", Spell_Activation_Overlay.Frame.StopMovingOrSizing)
    Spell_Activation_Overlay.Frame:SetScript("OnDragStop", Spell_Activation_Overlay.Frame.StopMovingOrSizing)

    AIO.SavePosition(Spell_Activation_Overlay.Frame)
end

function Spell_Activation_Overlay.GenerateSpellIcon(spellId)
    Spell_Activation_Overlay.ExtraButtonIcon = CreateFrame("Button", Spell_Activation_Overlay.ExtraButtonIcon, Spell_Activation_Overlay.Frame)
    Spell_Activation_Overlay.ExtraButtonIcon:SetSize(50, 50)
    Spell_Activation_Overlay.ExtraButtonIcon:SetPoint("Center", 1, 0)

    local _, _, icon, _, _, _, _, _, _ = GetSpellInfo(spellId)
    Spell_Activation_Overlay.ExtraButtonIcon:SetFrameLevel(Spell_Activation_Overlay.ExtraButtonIcon:GetParent():GetFrameLevel() - 1)
    Spell_Activation_Overlay.ExtraButtonIcon:SetNormalTexture(icon)

    Spell_Activation_Overlay.ExtraIcon = CreateFrame("Button", Spell_Activation_Overlay.ExtraIcon, Spell_Activation_Overlay.Frame)
    Spell_Activation_Overlay.ExtraIcon:SetSize(45, 45)
    Spell_Activation_Overlay.ExtraIcon:SetPoint("Center", 0, 0)
    Spell_Activation_Overlay.ExtraIcon:SetAttribute("spellId", spellId)
    Spell_Activation_Overlay.ExtraIcon:SetFrameLevel(Spell_Activation_Overlay.ExtraIcon:GetParent():GetFrameLevel() + 1)

    Spell_Activation_Overlay.ExtraIcon:SetScript("OnClick", function()
        AIO.Handle("SpellOverlay", "Cast", spellId)
    end)

    Spell_Activation_Overlay.ExtraIcon:SetScript("OnEnter", function(self, button, down)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink("spell:" .. spellId)
        GameTooltip:Show()
    end)

    Spell_Activation_Overlay.ExtraIcon:SetScript("OnLeave", function (self, button, down)
        GameTooltip:Hide()
    end)
end

function Spell_Activation_Overlay.GenerateCoolDown(parent)
    Spell_Activation_Overlay.Cooldown = CreateFrame("Cooldown", Spell_Activation_Overlay.Cooldown, parent, "CooldownFrameTemplate")
    Spell_Activation_Overlay.Cooldown:SetAllPoints()

    Spell_Activation_Overlay.Cooldown:SetCooldown(0, 0)
    Spell_Activation_Overlay.Cooldown:Show()

    Spell_Activation_Overlay.Cooldown:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    Spell_Activation_Overlay.Cooldown:SetScript("OnEvent", function(_, event, ...)
        if (event == "SPELL_UPDATE_COOLDOWN") then
            Spell_Activation_Overlay.SetCooldown(parent)
        end

    end)
end

function Spell_Activation_Overlay.SetCooldown(parent)
    if (not Spell_Activation_Overlay.Cooldown) then
        Spell_Activation_Overlay.GenerateCoolDown(parent)
    end

    local start, duration, _ = GetSpellCooldown(parent:GetAttribute("spellId"));
    if (duration and duration > 0) then
        Spell_Activation_Overlay.Cooldown:SetCooldown(start, duration)
    else
        Spell_Activation_Overlay.Cooldown:SetCooldown(0, 0)
    end
    Spell_Activation_Overlay.Cooldown:Show()
end

function Spell_Activation_Overlay.SetTexture(texture)
    Spell_Activation_Overlay.Texture = Spell_Activation_Overlay.Frame:CreateTexture()
    Spell_Activation_Overlay.Texture:SetSize(250, 120)
    Spell_Activation_Overlay.Texture:SetPoint("CENTER")
    Spell_Activation_Overlay.Texture:SetTexture("Interface/extrabutton/" .. texture)
end

function Server.StartCooldown()
    Spell_Activation_Overlay.ExtraIcon:SetCooldown(Spell_Activation_Overlay.ExtraIcon)
end

function Server.ShowFrame(_, texture, spell_id)
    if (Spell_Activation_Overlay.Frame) then
        Spell_Activation_Overlay.Frame:Hide()

        Spell_Activation_Overlay.Frame = nil
        Spell_Activation_Overlay.ExtraIcon = nil
        Spell_Activation_Overlay.ExtraButtonIcon = nil
        Spell_Activation_Overlay.Cooldown = nil
        Spell_Activation_Overlay.Texture = nil
    end

    Spell_Activation_Overlay.Generate(texture, spell_id)

    if (not Spell_Activation_Overlay.Frame:IsShown()) then
        Spell_Activation_Overlay.Frame:Show()
    end
end

function Server.HideFrame(_)
    if (not Spell_Activation_Overlay.Frame) then
        return
    end

    Spell_Activation_Overlay.Frame:Hide()
end