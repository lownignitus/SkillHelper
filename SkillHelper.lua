-- Title: Skill Helper
-- Author: JerichoHM
-- Maintainer: LownIgnitus
-- Version: 4.0.02
-- Desc: A simple addon for tracking and using skills

-- GLOBALS
local shSkillNames = { 
				["Archaeology"] = {
					["ID"] = 794,
					["Icon"] = "trade_archaeology",
					["Spells"] = {
						["Name"] = "Survey",
						["ID"] = 80451,
						["Icon"] = "inv_misc_shovel_01",
					},
				}, 
				["Cooking"] = {
					["ID"] = 185,
					["Icon"] = "inv_misc_food_15",
					["Spells"] = {
						["Name"] = "Cooking Fire",
						["ID"] = 818,
						["Icon"] = "spell_fire_fire",
					},
				}, 
				["Fishing"] = {
					["ID"] = 356,
					["Icon"] = "trade_fishing",
					["Spells"] = {
						["Name"] = "Fishing Skills",
						["ID"] = 271990,
						["Icon"] = "achievement_profession_fishing_northrendangler",
					},
				},
				["Alchemy"] = {
					["ID"] = 171,
					["Icon"] = "trade_alchemy",
				}, 
				["Blacksmithing"] = {
					["ID"] = 164,
					["Icon"] = "trade_blacksmithing",
				}, 
				["Enchanting"] = {
					["ID"] = 333,
					["Icon"] = "trade_engraving",
					["Spells"] = {
						["Name"] = "Disenchant",
						["ID"] = 13262,
						["Icon"] = "inv_enchant_disenchant",
					},
				}, 
				["Engineering"] = {
					["ID"] = 202,
					["Icon"] = "trade_engineering",
				}, 
				["Herbalism"] = {
					["ID"] = 182,
					["Icon"] = "spell_nature_naturetouchgrow",
					["Spells"] = {
						["Name"] = "Herbalism Skills",
						["ID"] = 193290,
						["Icon"] = "inv_misc_bag_18",
					},
				}, 
				["Inscription"] = {
					["ID"] = 773,
					["Icon"] = "inv_inscription_tradeskill01",
					["Spells"] = {
						["Name"] = "Milling",
						["ID"] = 51005,
						["Icon"] = "ability_miling",
					},
				}, 
				["Jewelcrafting"] = {
					["ID"] = 755,
					["Icon"] = "inv_misc_gem_01",
					["Spells"] = {
						["Name"] = "Prospecting",
						["ID"] = 31252,
						["Icon"] = "inv_misc_gem_bloodgem_01",
					},
				}, 
				["Leatherworking"] = {
					["ID"] = 165,
					["Icon"] = "inv_misc_armorkit_17",
				}, 
				["Mining"] = {
					["ID"] = 186,
					["Icon"] = "trade_mining",
					["Spells"] = {
						["Name"] = "Mining Skills",
						["ID"] = 2656,
						["Icon"] = "spell_fire_flameblades",
					},
				}, 
				["Skinning"] = {
					["ID"] = 393,
					["Icon"] = "inv_misc_pelt_wolf_01",
					["Spells"] = {
						["Name"] = "Skinning Skills",
						["ID"] = 194174,
						["Icon"] = "inv_misc_skinningknife",
					},
				}, 
				["Tailoring"] = {
					["ID"] = 197,
					["Icon"] = "trade_tailoring",
				}
			}

local SKILLCAP = 0
local classicCap = 300
local bcNRCataMopCap = 75
local wodLegionCap = 100
local bfa = 150
local y = -19
local imgFolder = "Interface\\ICONS\\"
local shFrameBG = { bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background.blp", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border.blp", tile = true, tileSize = 32, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}}
local shBarBG = { bgFile = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}}
SLASH_SKILLHELPER1, SLASH_SKILLHELPER2, SLASH_SKILLHELPER3, SLASH_SKILLHELPER4 = '/SHelper', '/shelper', '/Skillhelper', '/skillhelper'
local icon
CF = CreateFrame
local addon_name = "SkillHelper"
local shFrame
local shBarFrame
--local shLinksFrame
--local shClassicFrame

-- RegisterForEvent table
local shEvents_table = {}

shEvents_table.eventFrame = CF("Frame");
shEvents_table.eventFrame:RegisterEvent("ADDON_LOADED");
shEvents_table.eventFrame:RegisterEvent("SKILL_LINES_CHANGED");
shEvents_table.eventFrame:SetScript("OnEvent", function(self, event, ...)
	shEvents_table.eventFrame[event](self, ...);
end);

function shEvents_table.eventFrame:ADDON_LOADED(AddOn)
--	print(AddOn)
	if AddOn ~= addon_name then
		return -- not Skill Helper
	end

	-- Unregister ADDON_LOADED, reduce cpu lag
	shEvents_table.eventFrame:UnregisterEvent("ADDON_LOADED")
	
	-- Defaults
	local defaults = {
		["colors"] = {
			["full"] = 1,
			["half"] = 0.5,
	 		["maxr"] = 62/255,
			["maxg"] = 105/255,
			["maxb"] = 1,
			["trainr"] = 0.7,
			["traing"] = 0,
			["trainb"] = 0,
			["baser"] = 0,
			["baseg"] = 0.7,
			["baseb"] = 0,
		},
		["options"] = {
			["shscale"] = 1,
			["shalpha"] = 0,
			["shLock"] = true,
			["shMouseOver"] = false,
			["shHidden"] = false,
			--["shlHidden"] = true,
			["shcHidden"] = true,
			["shPrim1"] = true,
			["shPrim2"] = true,
			["shArch"] = true,
			["shFish"] = true,
			["shCook"] = true,
			["shAid"] = true,
			["shRev"] = false,
			["shDB"] = { hide = false },
			["shNewLayout"] = true,
		}
	}
	
	local function shSVCheck(src, dst)
		if type(src) ~= "table" then return {} end
		if type(dst) ~= "table" then dst = {} end
		for k, v in pairs(src) do
			if type(v) == "table" then
				dst[k] = shSVCheck(v,dst[k])
			elseif type(v) ~= type(dst[k]) then
				dst[k] = v
			end
		end
		return dst
	end

	shSettings = shSVCheck(defaults, shSettings)
	SKILLCAP = wodLegionCap

-- Initialize Main Frame
	shMainFrame()

--	print("Unregister")
	shMiniMap();
	shOptionsInit();
	shInitialize();
end

function shMainFrame()
	-- shFrame Core UI
	shFrame = CF("Frame", "shFrame", UIParent)
	shFrame:SetPoint("CENTER", UIParent, "CENTER")
	shFrame:SetFrameStrata("BACKGROUND")
	shFrame:SetBackdrop(shFrameBG)
	if shSettings.options.shNewLayout == true then
		shFrame:SetSize(208, 36)
	else
		shFrame:SetSize(170, 28)
	end

	--Mouse Enabling, Movement constraints, and Movment functions
	shFrame:SetMovable(true)
	shFrame:SetClampedToScreen(true)
	shFrame:EnableMouse(true)
	shFrame:RegisterForDrag("LeftButton")
	shFrame:SetScript("OnDragStart", shFrame.StartMoving)
	shFrame:SetScript("OnDragStop", shFrame.StopMovingOrSizing)

	-- Mouse Over Functionality
	shFrame:SetScript("OnEnter", function(self) shMouseOverEnter(); end)
	shFrame:SetScript("OnLeave", function(self) shMouseOverLeave(); end)

	-- shFrame Hide on Pet Battle
	shFrame:SetScript("OnShow", function(self)
  		PetBattleFrame:HookScript("OnShow",function() self:Hide(); end);
  		PetBattleFrame:HookScript("OnHide",function() if shSettings.options.shHidden == false then self:Show(); end end);
  	end);

	-- shFrame New layout UI
	if shSettings.options.shNewLayout == true then
		-- Title
		shFrame.title = shFrame:CreateFontString("shFrameTitle", "BACKGROUND")
		shFrame.title:SetFont("Fonts\\FRIZQT__.TTF", 12)
		shFrame.title:SetSize(125, 16)
		shFrame.title:SetPoint("TOPLEFT", shFrame, "TOPLEFT", 10, -3)		
		shFrameTitle:SetText(GetAddOnMetadata(addon_name, "Title") .. " " .. GetAddOnMetadata(addon_name, "Version"))

		-- Buttons (Options|Profs|Links|Lock|Close)
		-- Close Button
		local shFrameCloseButton = CF("Button", "shFrameCloseBtn", shFrame, "UIPanelCloseButton")
		shFrameCloseButton:SetFrameStrata("LOW")
		shFrameCloseButton:SetSize(18, 18)
		shFrameCloseButton:SetPoint("TOPRIGHT", shFrame, "TOPRIGHT", -2, -2)

		shFrameCloseButton:SetScript("OnClick", function(self) shToggle(); end)
		shFrameCloseButton:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT"); 
												GameTooltip:ClearLines(); 
												GameTooltip:AddLine("Close");
												GameTooltip:AddLine("Click to Hide Skill Helper.");
												GameTooltip:Show();
												shMouseOverEnter(); end)
		shFrameCloseButton:SetScript("OnLeave", function(self) GameTooltip:Hide();
												shMouseOverLeave(); end)

		-- Lock Button
		local shFrameLockButton = CF("CheckButton", "shFrameLockButton", shFrame)
		shFrameLockButton:SetFrameStrata("LOW")
		shFrameLockButton:SetSize(18, 18)
		shFrameLockButton:SetPoint("TOPRIGHT", shFrame, "TOPRIGHT", -14, -3)

		shFrameLockButton:SetScript("OnClick", function(self) shLocker(); end)
		shFrameLockButton:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
												GameTooltip:ClearLines();
												GameTooltip:AddLine("Lock");
												GameTooltip:AddLine("Click to lock Skill Helper.");
												GameTooltip:Show();
												shMouseOverEnter(); end)
		shFrameLockButton:SetScript("OnLeave", function(self) GameTooltip:Hide();
												shMouseOverLeave(); end)

		shFrameLockButton:SetNormalTexture("Interface\\Buttons\\LockButton-Locked-Up")
		shFrameLockButton:SetPushedTexture("Interface\\Buttons\\LockButton-Unlocked-Down")
		shFrameLockButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
		shFrameLockButton:SetCheckedTexture("Interface\\Buttons\\LockButton-Unlocked-Up")

		--[[ Links Open Button
		local shFrameLinksButton = CF("Button", "shFrameLinksButton", shFrame)
		shFrameLinksButton:SetFrameStrata("LOW")
		shFrameLinksButton:SetSize(18, 18)
		shFrameLinksButton:SetPoint("TOPRIGHT", shFrame, "TOPRIGHT", -26, -3)

		shFrameLinksButton:SetScript("OnClick", function(self) shLinks(); end)
		shFrameLinksButton:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
												GameTooltip:ClearLines();
												GameTooltip:AddLine("Links");
												GameTooltip:AddLine("Click to toggle the Links frame.");
												GameTooltip:Show();
												shMouseOverEnter(); end)
		shFrameLinksButton:SetScript("OnLeave", function(self) GameTooltip:Hide();
												shMouseOverLeave(); end)

		shFrameLinksButton:SetNormalTexture("Interface\\Buttons\\UI-LinkProfession-Up")
		shFrameLinksButton:SetPushedTexture("Interface\\Buttons\\UI-LinkProfession-Down")
		shFrameLinksButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")]]

		-- Classic Ranks Open Button

		-- Prof Open Button
		local shFrameProfsButton = CF("Button", "shFrameProfsButton", shFrame)
		shFrameProfsButton:SetFrameStrata("LOW")
		shFrameProfsButton:SetSize(18, 19)
		shFrameProfsButton:SetPoint("TOPRIGHT", shFrame, "TOPRIGHT", -26, 1) -- -42, 1

		shFrameProfsButton:SetScript("OnClick", function(self) ToggleSpellBook("professions"); end)
		shFrameProfsButton:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
												GameTooltip:ClearLines();
												GameTooltip:AddLine("Professions Pane");
												GameTooltip:AddLine("Click to Open the Professions Pane.");
												GameTooltip:Show();
												shMouseOverEnter(); end)
		shFrameProfsButton:SetScript("OnLeave", function(self) GameTooltip:Hide();
												shMouseOverLeave(); end)

		shFrameProfsButton:SetNormalTexture("Interface\\Buttons\\UI-MicroButton-Spellbook-Up")
		shFrameProfsButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Spellbook-Down")
		shFrameProfsButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

		-- Options Open Button
		local shFrameOptionsButton = CF("Button", "shFrameOptionsButton", shFrame)
		shFrameOptionsButton:SetFrameStrata("LOW")
		shFrameOptionsButton:SetSize(12, 12)
		shFrameOptionsButton:SetPoint("TOPRIGHT", shFrame, "TOPRIGHT", -42, -6) -- -59, -6

		shFrameOptionsButton:SetScript("OnClick", function(self) shOption(); end)
		shFrameOptionsButton:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
													GameTooltip:ClearLines();
													GameTooltip:AddLine("Skill Helper Options");
													GameTooltip:AddLine("Click to Open Skill Helper Options Pane.");
													GameTooltip:Show();
													shMouseOverEnter(); end)
		shFrameOptionsButton:SetScript("OnLeave", function(self) GameTooltip:Hide();
													shMouseOverLeave(); end)

		shFrameOptionsButton:SetNormalTexture("Interface\\ICONS\\INV_Eng_GearspringParts")
		shFrameOptionsButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

		--shClassicFrame()
		--shLinkFrame()
	end

	-- shBarFrame
	shBarFrame = CF("Frame", "shBarFrame", shFrame)
	shBarFrame:SetSize(200, 26)
	if shSettings.options.shNewLayout == true then
		shBarFrame:SetPoint("TOPLEFT", shFrame, "TOPLEFT", 20, -3)
	else
		shBarFrame:SetPoint("TOPLEFT", shFrame, "TOPLEFT", 3, -3)
	end
	
	-- Display Main frame
	shFrame:Show()
end

--[[function shClassicFrame()
	-- shClassicFrame Core UI
	shClassicFrame = CF("Frame", "shClassicFrame", shFrame)
	shClassicFrame:SetPoint("TOPRIGHT", shFrame, "BOTTOMRIGHT", 0, 5)
	shClassicFrame:SetFrameStrata("BACKGROUND")
	shClassicFrame:SetBackdrop(shFrameBG)
	shClassicFrame:SetSize(170, 36)
	shClassicFrame:SetClampedToScreen(true)

	-- shClassicFrame title bar
	shClassicFrame.title = shClassicFrame:CreateFontString("shClassicFrameTitle", "BACKGROUND")
	shClassicFrame.title:SetFont("Fonts\\FRIZQT__.TTF", 14)
	shClassicFrame.title:SetSize(90, 16)
	shClassicFrame.title:SetPoint("TOP", shClassicFrame, "TOP", 0, -3)
	shClassicFrame.title:SetText("Classic Ranks")

	-- Mouse Over Functionality
	shClassicFrame:SetScript("OnEnter", function(self) shMouseOverEnter(); end)
	shClassicFrame:SetScript("OnLeave", function(self) shMouseOverLeave(); end)
end]]

--[[function shLinkFrame()
	-- shLinkFrame Core UI
	shLinksFrame = CF("Frame", "shLinkFrame", shFrame)
	shLinksFrame:SetPoint("TOPLEFT", shFrame, "TOPRIGHT", -5, 0)
	shLinksFrame:SetFrameStrata("BACKGROUND")
	shLinksFrame:SetBackdrop(shFrameBG)
	shLinksFrame:SetSize(52, 36)
	shLinksFrame:SetClampedToScreen(true)

	-- shLinksFrame title bar
	shLinksFrame.title = shLinksFrame:CreateFontString("shLinkFrameTitle", "BACKGROUND")
	shLinksFrame.title:SetFont("Fonts\\FRIZQT__.TTF", 14)
	shLinksFrame.title:SetSize(45, 16)
	shLinksFrame.title:SetPoint("TOPLEFT", shLinksFrame, "TOPLEFT", 4, -3)
	shLinksFrame.title:SetText("Links")

	-- Mouse Over Functionality
	shLinksFrame:SetScript("OnEnter", function(self) shMouseOverEnter(); end)
	shLinksFrame:SetScript("OnLeave", function(self) shMouseOverLeave(); end)
end]]

function shEvents_table.eventFrame:SKILL_LINES_CHANGED()
--	print("Skill Change")
	if not InCombatLockdown() then
		shUpdateData()
	end
end

-- Skill Helper Options
function shOptionsInit()
	local shOptions = CF("Frame", nil, InterfaceOptionsFramePanelContainer);
	local panelWidth = InterfaceOptionsFramePanelContainer:GetWidth() -- ~623
	local wideWidth = panelWidth - 40
	shOptions:SetWidth(wideWidth)
	shOptions:Hide();
	shOptions.name = "|cff00ff00Skill Helper|r"
	shOptionsBG = { edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, edgeSize = 16 }

	-- Special thanks to Ro for inspiration for the overall structure of this options panel (and the title/version/description code)
	local function createfont(fontName, r, g, b, anchorPoint, relativeto, relativePoint, cx, cy, xoff, yoff, text)
		local font = shOptions:CreateFontString(nil, "BACKGROUND", fontName)
		font:SetJustifyH("LEFT")
		font:SetJustifyV("TOP")
		if type(r) == "string" then -- r is text, not position
			text = r
		else
			if r then
				font:SetTextColor(r, g, b, 1)
			end
			font:SetSize(cx, cy)
			font:SetPoint(anchorPoint, relativeto, relativePoint, xoff, yoff)
		end
		font:SetText(text)
		return font
	end

	-- Special thanks to Hugh & Simca for checkbox creation 
	local function createcheckbox(text, cx, cy, anchorPoint, relativeto, relativePoint, xoff, yoff, frameName, font)
		local checkbox = CF("CheckButton", frameName, shOptions, "UICheckButtonTemplate")
		checkbox:SetPoint(anchorPoint, relativeto, relativePoint, xoff, yoff)
		checkbox:SetSize(cx, cy)
		local checkfont = font or "GameFontNormal"
		checkbox.text:SetFontObject(checkfont)
		checkbox.text:SetText(" " .. text)
		return checkbox
	end
	
	--GameFontNormalHuge GameFontNormalLarge 
	local title = createfont("SystemFont_OutlineThick_WTF", GetAddOnMetadata(addon_name, "Title"))
	title:SetPoint("TOPLEFT", 16, -16)
	local ver = createfont("SystemFont_Huge1", GetAddOnMetadata(addon_name, "Version"))
	ver:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 4, 0)
	local date = createfont("GameFontNormalLarge", "Version Date: " .. GetAddOnMetadata(addon_name, "X-Date"))
	date:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	local author = createfont("GameFontNormal", "Author: " .. GetAddOnMetadata(addon_name, "Author"))
	author:SetPoint("TOPLEFT", date, "BOTTOMLEFT", 0, -8)
	local maintainer = createfont("GameFontNormal", "Maintainer: " .. GetAddOnMetadata(addon_name, "X-Maintainer"))
	maintainer:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -8)
	local website = createfont("GameFontNormal", "Website: " .. GetAddOnMetadata(addon_name, "X-Website"))
	website:SetPoint("TOPLEFT", maintainer, "BOTTOMLEFT", 0, -8)
	local contact = createfont("GameFontNormal", "Contact: " .. GetAddOnMetadata(addon_name, "X-Contact"))
	contact:SetPoint("TOPLEFT", website, "BOTTOMLEFT", 0, -8)
	local desc = createfont("GameFontHighlight", GetAddOnMetadata(addon_name, "Notes"))
	desc:SetPoint("TOPLEFT", contact, "BOTTOMLEFT", 0, -8)
	local desc2 = createfont("GameFontHighlight", GetAddOnMetadata(addon_name, "X-Notes2"))
	desc2:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -8)

	-- Misc Options Frame
	local shMiscFrame = CF("Frame", SHMiscFrame, shOptions)
	shMiscFrame:SetPoint("TOPLEFT", desc2, "BOTTOMLEFT", 0, -8)
	shMiscFrame:SetBackdrop(shOptionsBG)
	shMiscFrame:SetSize(240, 240)

	local miscTitle = createfont("GameFontNormal", nil, nil, nil, "TOP", shMiscFrame, "TOP", 150, 16, 0, -8, "Miscellaneous Options")

	-- Enable Mouseover
	local shMouseOverOpt = createcheckbox("Enable Mouseover of Skill Helper.", 18, 18, "TOPLEFT", miscTitle, "TOPLEFT", -40, -16, "shMouseOverOpt")

	shMouseOverOpt:SetScript("OnClick", function(self)
		if shMouseOverOpt:GetChecked() == true then
			shSettings.options.shMouseOver = true
			shFrame:SetAlpha(shSettings.options.shalpha)
			ChatFrame1:AddMessage("Mouseover |cff00ff00enabled|r!")
			--shFrame:SetAlpha(0)
		else
			shSettings.options.shMouseOver = false
			shFrame:SetAlpha(1)
			ChatFrame1:AddMessage("Mouseover |cffff0000disabled|r!")
		end
	end)

	-- Toggle Minimap Icon
	local shMMToggleOpt = createcheckbox("Hide the Minimap Icon.", 18, 18, "TOPLEFT", shMouseOverOpt, "BOTTOMLEFT", 0, 0, "shMMToggleOpt")

	shMMToggleOpt:SetScript("OnClick", function(self) shMMToggle() end)

	-- Toggle First Profession bar
	local shPrim1Opt = createcheckbox("Hide First Primary Profession bar.", 18, 18, "TOPLEFT", shMMToggleOpt, "BOTTOMLEFT", 0, 0, "shPrim1Opt")

	shPrim1Opt:SetScript("OnClick", function(self) shPrim1Toggle() end)

	-- Toggle Second Profession bar
	local shPrim2Opt = createcheckbox("Hide Second Primary Profession bar.", 18, 18, "TOPLEFT", shPrim1Opt, "BOTTOMLEFT", 0, 0, "shPrim2Opt")

	shPrim2Opt:SetScript("OnClick", function(self) shPrim2Toggle() end)

	-- Toggle Archaeology Profession bar
	local shArchOpt = createcheckbox("Hide Archaeology Profession bar.", 18, 18, "TOPLEFT", shPrim2Opt, "BOTTOMLEFT", 0, 0, "shArchOpt")

	shArchOpt:SetScript("OnClick", function(self) shArchToggle() end)

	-- Toggle Fishing Profession bar
	local shFishOpt = createcheckbox("Hide Fishing Profession bar.", 18, 18, "TOPLEFT", shArchOpt, "BOTTOMLEFT", 0, 0, "shFishOpt")

	shFishOpt:SetScript("OnClick", function(self) shFishToggle() end)

	-- Toggle Cooking Profession bar
	local shCookpt = createcheckbox("Hide Cooking Profession bar.", 18, 18, "TOPLEFT", shFishOpt, "BOTTOMLEFT", 0, 0, "shCookOpt")

	shCookOpt:SetScript("OnClick", function(self) shCookToggle() end)

	-- Old addon style
	local shLayoutOpt = createcheckbox("Use new GUI Layout for Skill Helper.", 18, 18, "TOPLEFT", shCookOpt, "BOTTOMLEFT", 0, 0, "shLayoutOpt")
	shLayoutOpt:SetScript("OnClick", function() shLayoutToggle() end)

	-- Layout addition Description
	local layDesc = createfont("GameFontNormal", "Requires a /reload.")
	layDesc:SetPoint("TOPLEFT", shLayoutOpt, "BOTTOMLEFT", 35, 0)

	-- Reverse the skill bars, buttons, and link frame
	local shRevOpt = createcheckbox("Reverse the Skill Helper frame.", 18, 18, "TOPLEFT", layDesc, "BOTTOMLEFT", -35, 0, "shRevOpt")
	--shRevOpt:Disable()

	shRevOpt:SetScript("OnClick", function() shRevToggle() end)

	-- Reverse addition Description
	local revDesc = createfont("GameFontNormal", "Requires a /reload.")
	revDesc:SetPoint("TOPLEFT", shRevOpt, "BOTTOMLEFT", 35, 0)

	-- Reload button for Reverse
	local reloadBtn = CF("Button", "Reload", shMiscFrame, "OptionsButtonTemplate")
	reloadBtn:SetSize(54, 18)
	reloadBtn:SetPoint("TOPLEFT", revDesc, "TOPRIGHT", 10, 4)

	reloadBtn:SetScript("OnClick", function(self)	ReloadUI(); end);

	-- Button text
	local reloadTxt = reloadBtn:CreateFontString(nil, "ARTWORK");
	isValid = reloadTxt:SetFontObject("GameFontNormal");
	reloadTxt:SetPoint("CENTER", reloadBtn, "CENTER", 0, 0);
	reloadBtn.text = reloadTxt
	reloadBtn.text:SetText("Reload")

	-- Scale Frame
	local shScaleFrame = CF("Frame", "SHScaleFrame", shOptions)
	shScaleFrame:SetPoint("TOPLEFT", shMiscFrame, "TOPRIGHT", 8, 0)
	shScaleFrame:SetBackdrop(shOptionsBG)
	shScaleFrame:SetSize(150, 75)

	-- Skill Helper Scale
	local shScale = CF("Slider", "SHScale", shScaleFrame, "OptionsSliderTemplate")
	shScale:SetSize(120, 16)
	shScale:SetOrientation('HORIZONTAL')
	shScale:SetPoint("TOP", shScaleFrame, "TOP", 0, -25)

	_G[shScale:GetName() .. 'Low']:SetText('0.5') -- Sets left side of slider text [default is "Low"]
	_G[shScale:GetName() .. 'High']:SetText('1.5') -- Sets right side of slider text [default is "High"]
	_G[shScale:GetName() .. 'Text']:SetText('|cffFFCC00Scale|r') -- Sets the title text [top-center of slider]

	shScale:SetMinMaxValues(0.5, 1.5)
	shScale:SetValueStep(0.05);

	-- Scale Display Editbox
	local shScaleDisplay = CF("Editbox", "SHScaleDisplay", shScaleFrame, "InputBoxTemplate")
	shScaleDisplay:SetSize(32, 16)
	shScaleDisplay:ClearAllPoints()
	shScaleDisplay:SetPoint("TOP", shScale, "BOTTOM", 0, -10)
	shScaleDisplay:SetAutoFocus(false)
	shScaleDisplay:SetEnabled(false)
	shScaleDisplay:SetText(shSettings.options.shscale)

	shScale:SetScript("OnValueChanged", function(self, value)
		value = floor(value/0.05)*0.05
		shFrame:SetScale(value)
		shSettings.options.shscale = value
		shScaleDisplay:SetText(shSettings.options.shscale)
	--	print(shSettings.options.shscale)
	end);

	-- Alpha Frame
	local shAlphaFrame = CF("Frame", "SHAlphaFrame", shOptions)
	shAlphaFrame:SetPoint("TOPLEFT", shScaleFrame, "TOPRIGHT", 8, 0)
	shAlphaFrame:SetBackdrop(shOptionsBG)
	shAlphaFrame:SetSize(150, 75)

	-- Skill Helper Alpha
	local shAlpha = CF("Slider", "SHAlpha", shAlphaFrame, "OptionsSliderTemplate")
	shAlpha:SetSize(120, 16)
	shAlpha:SetOrientation('HORIZONTAL')
	shAlpha:SetPoint("TOP", shAlphaFrame, "TOP", 0, -25)

	_G[shAlpha:GetName() .. 'Low']:SetText('0') -- Sets left side of slider text [default is "Low"]
	_G[shAlpha:GetName() .. 'High']:SetText('1') -- Sets right side of slider text [default is "High"]
	_G[shAlpha:GetName() .. 'Text']:SetText('|cffFFCC00Minimum Alpha|r') -- Sets the title text [top-center of slider]

	shAlpha:SetMinMaxValues(0, 1)
	shAlpha:SetValueStep(0.05);

	-- Alpha Display Editbox
	local shAlphaDisplay = CF("Editbox", "SHScaleDisplay", shAlphaFrame, "InputBoxTemplate")
	shAlphaDisplay:SetSize(32, 16)
	shAlphaDisplay:ClearAllPoints()
	shAlphaDisplay:SetPoint("TOP", shAlpha, "BOTTOM", 0, -10)
	shAlphaDisplay:SetAutoFocus(false)
	shAlphaDisplay:SetEnabled(false)
	shAlphaDisplay:SetText(shSettings.options.shalpha)

	shAlpha:SetScript("OnValueChanged", function(self, value)
		value = floor(value/0.05)*0.05
		shSettings.options.shalpha = value
		if shSettings.options.shMouseOver == true then
			shFrame:SetAlpha(shSettings.options.shalpha)
		end
		shAlphaDisplay:SetText(shSettings.options.shalpha)
	--	print(shSettings.options.shalpha)
	end);

	shOptions.refresh = function()
	--	print("refresh")
		shScale:SetValue(shSettings.options.shscale);
		shAlpha:SetValue(shSettings.options.shalpha);
	end

	function shOptions.okay()
		shOptions:Hide();
	end

	function shOptions.cancel()
		shOptions:Hide();
	end

	function shOptions.default()
		shReset();
	end

	-- add the Options panel to the Blizzard list
	InterfaceOptions_AddCategory(shOptions);
	-- End Skill Helper Options
end

-- Skills Table
local skills = {}

-- Frames Table
local bars = {}

function shDrawBar(name, texture, rank, rankModifier, maxRank, numSpells, y)
--	print("Profession: " .. name .. ", texture: " .. texture)
	if shSettings.options.shRev == false then
		-- Skill Bar XbPoint
		barx = 6
		-- Skill Button 1 X Point
		btnax = 0
		-- Skill Button 2 X Point
		btnbx = 0
	else
		if shSettings.options.shNewLayout == true then
			-- Skill Bar X Point
			barx = 42
			-- Skill Button 1 X Point
			btnax = -178
			-- Skill Button 2 X Point
			btnbx = -36
		else
			-- Skill Bar X Point
			barx = 6
			-- Skill Button 1 X Point
			btnax = -178
			-- Skill Button 2 X Point
			btnbx = -36
		end
	end

	if shSettings.options.shNewLayout == false then
		y = y + 17
	end

	local bar = bars[name]
	if not bar then --if bar doesn't exist
		-- The Skill bar
		bar = CF("StatusBar", nil, shBarFrame)
		bar:SetFrameStrata("BACKGROUND")
		bar:SetPoint("TOPLEFT", shBarFrame, "TOPLEFT", barx, y)
		bar:SetSize(160,18)
		bar:SetBackdrop(shBarBG)
		bar:SetBackdropColor(shSettings.colors.baser, shSettings.colors.baseg, shSettings.colors.baseb, shSettings.colors.half)
		bar:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
		bar:SetStatusBarColor(shSettings.colors.baser, shSettings.colors.baseg, shSettings.colors.baseb, shSettings.colors.full)
		bar:SetMinMaxValues(0,1)
		bar:SetValue((rank + rankModifier)/maxRank)

		-- The text on the Skill Bar
		local barTxt = bar:CreateFontString(nil, "ARTWORK");
		isValid = barTxt:SetFont("Fonts\\FRIZQT__.TTF", 10);
		barTxt:SetPoint("CENTER", bar, "CENTER", 0, 1);
		bar.text = barTxt

		-- The first button on the skills action bar
		local barBtn1 = CF("Button", nil, bar, "SecureActionButtonTemplate");
		barBtn1:SetFrameStrata("BACKGROUND");
		barBtn1:SetPoint("TOPLEFT", bar, "TOPRIGHT", btnax, 0);
		barBtn1:SetSize(18,18);
		barBtn1:EnableMouse(true);
		barBtn1:SetAttribute("type", "spell");
		barBtn1:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
		barBtn1:SetAttribute("spell", name);
		barBtn1BG = { bgFile = imgFolder .. shGetButton(name, 1), edgeFile = nil, tile = false, tileSize = 18, edgeSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}};
		barBtn1:SetBackdrop(barBtn1BG);
		barBtn1:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:ClearLines(); GameTooltip:AddLine(name); GameTooltip:Show(); shMouseOverEnter(); end)
		barBtn1:SetScript("OnLeave", function(self) GameTooltip:Hide(); shMouseOverLeave(); end)
		bar.btn1 = barBtn1

		-- The second button on the skills action bar if applicable
		if numSpells == 2 or name == "Mining" then
--			print("Button 2" .. name)
			if name == "Alchemy" or name == "Blacksmithing" or name == "Engineering" or name == "Leatherworking" or name == "Tailoring" then
				print("Spell 2 found for " .. name .. ".")
			else
				local barBtn2 = CF("Button", nil, barBtn1, "SecureActionButtonTemplate");
				barBtn2:SetFrameStrata("BACKGROUND");
				barBtn2:SetPoint("TOPLEFT", barBtn1, "TOPRIGHT", btnbx, 0);
				barBtn2:SetSize(18,18);
				barBtn2:EnableMouse(true);
				barBtn2:SetAttribute("type", "spell");
				barBtn2:SetAttribute("spell", shGetSpell(name, 2));
				barBtn2BG = { bgFile = imgFolder .. shGetButton(name, 2) .. ".BLP", edgeFile = nil, tile = false, tileSize = 18, edgeSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}};
				barBtn2:SetBackdrop(barBtn2BG);
				barBtn2:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
				barBtn2:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:ClearLines(); GameTooltip:AddLine(shGetSpell(name, 2)); GameTooltip:Show(); shMouseOverEnter(); end)
				barBtn2:SetScript("OnLeave", function(self) GameTooltip:Hide(); shMouseOverLeave(); end)
				bar.btn2 = barBtn2
			end
		end

		-- Text formatting for the text on the Skill Bar
		bar.text:SetFormattedText("|cFFFFFF00%s: |cFFFFFFFF%s+%s/%s", name, rank, rankModifier, maxRank)

		-- Add to the array
		bars[name] = bar
	else --if bar exists
		bar:ClearAllPoints()
	end

	-- if the rank is in trainable range and not skill cap then turn bar red
	if	rank >= maxRank - 25 and maxRank < SKILLCAP then
		bar:SetPoint("TOPLEFT", shFrame, "TOPLEFT", barx, y-4)
		bar:SetStatusBarColor(shSettings.colors.trainr, shSettings.colors.trainb, shSettings.colors.traing, shSettings.colors.full)
		bar:SetBackdropColor(shSettings.colors.trainr, shSettings.colors.trainb, shSettings.colors.traing, shSettings.colors.half)
		bar:SetValue((rank + rankModifier)/maxRank)

		bar.text:SetFormattedText("|cFFFF0000%s: |cFFFFFFFF%s+%s/%s", name, rank, rankModifier, maxRank)
	elseif rank == maxRank then -- set maxed skill level bar royal blue
		bar:SetPoint("TOPLEFT", shFrame, "TOPLEFT", barx, y-4)
		bar:SetStatusBarColor(shSettings.colors.maxr, shSettings.colors.maxg, shSettings.colors.maxb, shSettings.colors.full)
		bar:SetBackdropColor(shSettings.colors.maxr, shSettings.colors.maxg, shSettings.colors.maxb, shSettings.colors.half)
		bar:SetValue((rank + rankModifier)/maxRank)

		bar.text:SetFormattedText("|cFF00FF00%s: |cFFFFFFFF%s+%s/%s", name, rank, rankModifier, maxRank)
	else -- otherwise keep bar green
		bar:SetPoint("TOPLEFT", shFrame, "TOPLEFT", barx, y-4)
		bar:SetStatusBarColor(shSettings.colors.baser, shSettings.colors.baseg, shSettings.colors.baseb, shSettings.colors.full)
		bar:SetBackdropColor(shSettings.colors.baser, shSettings.colors.baseg, shSettings.colors.baseb, shSettings.colors.half)
		bar:SetValue((rank + rankModifier)/maxRank)

		bar.text:SetFormattedText("|cFFFFFF00%s: |cFFFFFFFF%s+%s/%s", name, rank, rankModifier, maxRank)
	end

	shFrame:SetHeight((y - 27)* -1)
	shBarFrame:SetHeight((y - 27)* -1)
end

--[[function shLinksButtons(name, y)
	if shSettings.options.shNewLayout == true then
		linkBtn = CF("Button", nil, shLinksFrame, nil)
		linkBtn:SetFrameStrata("BACKGROUND")
		linkBtn:SetPoint("TOPRIGHT", shLinksFrame, "TOPRIGHT", -5, y-4)
		linkBtn:SetSize(40, 18)
		linkBtn:EnableMouse(true)
		linkBtnBG = { edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 32, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}};
		linkBtn:SetBackdrop(linkBtnBG);
		linkBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
		linkBtn:SetScript("OnClick", function(self)
			local link = select(2, GetSpellLink(name))
			--local link = GetSpellLink(name)
	--		print(link)
			if link == nil then ChatFrame1:AddMessage("Could not get link for profession.") return end

			local activeEditBox = ChatEdit_GetActiveWindow()
			if MacroFrameText and MacroFrameText:IsShown() and MacroFrameText:HasFocus() then
				local text = MacroFrameText:GetText() .. link
				if strlenutf8(text) <= 255 then
					MacroFrameText:Insert(link)
				end
			elseif activeEditBox then
				ChatEdit_InsertLink(link)
			end
		end)
		
		local linkTxt = linkBtn:CreateFontString(nil, "ARTWORK");
		isValid = linkTxt:SetFont("Fonts\\FRIZQT__.TTF", 14);
		linkTxt:SetPoint("CENTER", linkBtn, "CENTER", 0, 0);
		linkBtn.text = linkTxt

		linkBtn:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:ClearLines(); GameTooltip:AddLine(name .. " Link"); GameTooltip:Show(); shMouseOverEnter(); end)
		linkBtn:SetScript("OnLeave", function(self) GameTooltip:Hide(); shMouseOverLeave(); end)

		linkBtn.text:SetText("|cFFFFFF00Link|r")
		
		shLinksFrame:SetHeight((y - 23)* -1)
	end
end]]

function shUpdateData()
	
	-- Capture the SkillIndes for the players Professions
	local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
	--print(prof1 .. ", " .. prof2 .. ", " .. archaeology .. ", " .. fishing .. ", " .. cooking)
	--local testLink = GetTradePlayerItemLink(prof1)
	--print(testLink)
	local profs = {}

	if shSettings.options.shPrim1 == true then
		-- Build an array of primary professions
		tinsert(profs, prof1)
	end	

	if shSettings.options.shPrim2 == true then
		-- Build an array of primary professions
		tinsert(profs, prof2)
	end

	if shSettings.options.shArch == true then
		-- Build an array of primary professions
		tinsert(profs, archaeology)
	end

	if shSettings.options.shFish == true then
		-- Build an array of primary professions
		tinsert(profs, fishing)
	end

	if shSettings.options.shCook == true then
		-- Build an array of primary professions
		tinsert(profs, cooking)
	end

--	table.foreach(profs, print)
			
	for k, v in pairs(profs) do
		-- Fetch the details for each Profession
		local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier, specializationIndex, specializationOffset = GetProfessionInfo(v)
--		print(name .. ", " .. texture .. ", " .. rank .. ", " .. maxRank .. ", " .. numSpells .. ", " .. spelloffset .. ", " .. skillLine .. ", " .. rankModifier .. ", " .. specializationIndex .. ", " .. specializationOffset)
		shDrawBar(name, texture, rank, rankModifier, maxRank, numSpells, y)
		--shLinksButtons(name, y)
		y = y - 18

		tinsert( skills, name)
	end
	shCleanUp()

	y = -19
end

function shCleanUp()
	local match = false
	local clnBar

	for k, d in pairs(bars) do -- cycle bar names
		for i, v in ipairs(skills) do -- cycle skill nams
			if k == v then -- if the names match set true
				match = true
				break
			else -- otherwise false
				match = false
			end
		end

		-- store bar to local variable
		clnBar = bars[k]

		if match == false then -- If bar and skill don't match hide bar and set to false
			clnBar:Hide()
			match = false
		elseif match == true then -- If bar and skill match show
			clnBar:Show()
		end
	end

	while ((# skills) > 0) do -- cycle through number of skills
		tremove( skills, 1 ) -- remove skills from the table
	end
end

function shInitialize()
	shFrame:SetScale(shSettings.options.shscale)

	if shSettings.options.shLock == true then
		shFrame:EnableMouse(true)
		if shSettings.options.shNewLayout == true then
			shFrameLockButton:SetChecked(true)
		end
	else
		shFrame:EnableMouse(false)
		if shSettings.options.shNewLayout == true then
			shFrameLockButton:SetChecked(false)
		end
	end
			
	if shSettings.options.shHidden == false then
		shFrame:Show()
	else
		shFrame:Hide()
	end			

	--[[if shSettings.options.shlHidden == false and shSettings.options.shNewLayout == true then
		shLinksFrame:Show()
	elseif shSettings.options.shlHidden == true and shSettings.options.shNewLayout == true then
		shLinksFrame:Hide()
	end]]

	if shSettings.options.shDB.hide == true then
		icon:Hide("SkillHelper")
		shMMToggleOpt:SetChecked(true)
	else
		icon:Show("SkillHelper")
		shMMToggleOpt:SetChecked(false)
	end

	if shSettings.options.shMouseOver == true then
		shMouseOverOpt:SetChecked(true)
		shFrame:SetAlpha(shSettings.options.shalpha)
	else
		shMouseOverOpt:SetChecked(false)
	end

	if shSettings.options.shPrim1 == true then
		shPrim1Opt:SetChecked(false)
	else
		shPrim1Opt:SetChecked(true)
	end

	if shSettings.options.shPrim2 == true then
		shPrim2Opt:SetChecked(false)
	else
		shPrim2Opt:SetChecked(true)
	end

	if shSettings.options.shArch == true then
		shArchOpt:SetChecked(false)
	else
		shArchOpt:SetChecked(true)
	end

	if shSettings.options.shFish == true then
		shFishOpt:SetChecked(false)
	else
		shFishOpt:SetChecked(true)
	end

	if shSettings.options.shCook == true then
		shCookOpt:SetChecked(false)
	else
		shCookOpt:SetChecked(true)
	end

	if shSettings.options.shRev == false then
		shRevOpt:SetChecked(false)
		--[[if shSettings.options.shNewLayout == true then
			shLinksFrame:SetPoint("TOPLEFT", shFrame, "TOPRIGHT", -5, 0)
		end]]
	else
		shRevOpt:SetChecked(true)
		--[[if shSettings.options.shNewLayout == true then
			shLinksFrame:SetPoint("TOPLEFT", shFrame, "TOPRIGHT", -255, 0)
		end]]
	end

	if shSettings.options.shNewLayout == true then
		shLayoutOpt:SetChecked(true)
	else
		shLayoutOpt:SetChecked(false)
	end
end

function shMouseOverEnter()
	if shSettings.options.shMouseOver == true then
		shFrame:SetAlpha(1);
	end
end

function shMouseOverLeave()
	if shSettings.options.shMouseOver == true then
		shFrame:SetAlpha(shSettings.options.shalpha);
	end
end

function shGetButton(name, spellNum)
--	local sName, rank, icon, castTime, minRange, maxRange = GetSpellInfo(name)
--	print(sName .. ", " .. rank .. ", " .. icon .. ", " .. castTime .. ", " .. minRange .. ", " .. maxRange)
	if name == "Alchemy" then
		if spellNum == 1 then
			return shSkillNames.Alchemy.Icon
		end
	elseif name == "Archaeology" then
		if spellNum == 1 then
			return shSkillNames.Archaeology.Icon
		elseif spellNum == 2 then
			return shSkillNames.Archaeology.Spells.Icon
		end
	elseif name == "Blacksmithing" then
		if spellNum == 1 then
			return shSkillNames.Blacksmithing.Icon
		end
	elseif name == "Cooking" then
		if spellNum == 1 then
			return shSkillNames.Cooking.Icon
		elseif spellNum == 2 then
			return shSkillNames.Cooking.Spells.Icon
		end
	elseif name == "Enchanting" then
		if spellNum == 1 then
			return shSkillNames.Enchanting.Icon
		elseif spellNum == 2 then
			return shSkillNames.Enchanting.Spells.Icon
		end
	elseif name == "Engineering" then
		if spellNum == 1 then
			return shSkillNames.Engineering.Icon
		end
	elseif name == "Fishing" then
		if spellNum == 1 then
			return shSkillNames.Fishing.Icon
		elseif spellNum == 2 then
			return shSkillNames.Fishing.Spells.Icon
		end
	elseif name == "Herbalism" then
		if spellNum == 1 then
			return shSkillNames.Herbalism.Icon
		elseif spellNum == 2 then
			return shSkillNames.Herbalism.Spells.Icon
		end
	elseif name == "Inscription" then
		if spellNum == 1 then
			return shSkillNames.Inscription.Icon
		elseif spellNum == 2 then
			return shSkillNames.Inscription.Spells.Icon
		end
	elseif name == "Jewelcrafting" then
		if spellNum == 1 then
			return shSkillNames.Jewelcrafting.Icon
		elseif spellNum == 2 then
			return shSkillNames.Jewelcrafting.Spells.Icon
		end
	elseif name == "Leatherworking" then
		if spellNum == 1 then
			return shSkillNames.Leatherworking.Icon
		end
	elseif name == "Mining" then
		if spellNum == 1 then
			return shSkillNames.Mining.Icon
		elseif spellNum == 2 then
			return shSkillNames.Mining.Spells.Icon
		end
	elseif name == "Skinning" then
		if spellNum == 1 then
			return shSkillNames.Skinning.Icon
		elseif spellNum == 2 then
			return shSkillNames.Skinning.Spells.Icon
		end
	elseif name == "Tailoring" then
		if spellNum == 1 then
			return shSkillNames.Tailoring.Icon
		end
	end
end

function shGetSpell(name, spellNum)
	if name == "Archaeology" then
		if spellNum == 2 then
			return shSkillNames.Archaeology.Spells.Name
		end
	elseif name == "Cooking" then
		if spellNum == 2 then
			return shSkillNames.Cooking.Spells.Name
		end
	elseif name == "Enchanting" then
		if spellNum == 2 then
			return shSkillNames.Enchanting.Spells.Name
		end
	elseif name == "Fishing" then
		if spellNum == 2 then
			return shSkillNames.Fishing.Spells.Name
		end
	elseif name == "Herbalism" then
		if spellNum == 2 then
			return shSkillNames.Herbalism.Spells.Name
		end
	elseif name == "Inscription" then
		if spellNum == 2 then
			return shSkillNames.Inscription.Spells.Name
		end
	elseif name == "Jewelcrafting" then
		if spellNum == 2 then
			return shSkillNames.Jewelcrafting.Spells.Name
		end
	elseif name == "Mining" then
		if spellNum == 2 then
			return shSkillNames.Mining.Spells.Name
		end
	elseif name == "Skinning" then
		if spellNum == 2 then
			return shSkillNames.Skinning.Spells.Name
		end
	end
end

function SlashCmdList.SKILLHELPER(msg, Editbox)
	if msg == "toggle" then
		shToggle()
	elseif msg == "lock" then
		shLocker()
	--[[elseif msg == "links" then
		shLinks()]]
	elseif msg == "layout" then
		shLayoutToggle()
	elseif msg == "mmtoggle" then
		shMMToggle()
	elseif msg == "options" then
		shOption()
	elseif msg == "info" then
		shInfo()
	elseif msg == "test" then
		shUpdateData()
	else
		ChatFrame1:AddMessage("|cff71C671Skill Helper Slash Commands|r")
		ChatFrame1:AddMessage("|cff71C671type /SHelper followed by:|r")
		ChatFrame1:AddMessage("|cff71C671  -- toggle to toggle the addon hidden state|r")
		ChatFrame1:AddMessage("|cff71C671  -- lock to toggle locking|r")
		--ChatFrame1:AddMessage("|cff71C671  -- links to toggle the Skill Links frame|r")
		ChatFrame1:AddMessage("|cff71C671  -- layout to switch between old and new layouts|r")
		ChatFrame1:AddMessage("|cff71C671  -- mmtoggle to toggle the minimap button on/off|r")
		ChatFrame1:AddMessage("|cff71C671  -- options to open addon options|r")
		ChatFrame1:AddMessage("|cff71C671  -- info to view current build information|r")
	end
end

function shToggle()
	-- true for it is hidden and false for it isn't hidden
	if shSettings.options.shHidden == false then
		shFrame:Hide()
		ChatFrame1:AddMessage("Skill Helper |cffff0000hidden|r!")
		shSettings.options.shHidden = true
	elseif shSettings.options.shHidden == true then
		shFrame:Show()
		ChatFrame1:AddMessage("Skill Helper |cff00ff00visible|r!")
		shSettings.options.shHidden = false
	end
end

--[[function shLinks()
	-- functions on same pcinciple as shToggle
	if shSettings.options.shlHidden == false then
		shLinksFrame:Hide()
		ChatFrame1:AddMessage("Links frame |cffff0000hidden|r!")
		shSettings.options.shlHidden = true
	elseif shSettings.options.shlHidden == true then
		shLinksFrame:Show()
		ChatFrame1:AddMessage("Links frame |cff00ff00visible|r!")
		shSettings.options.shlHidden = false
	end
end]]

function shPrim1Toggle()
	-- true for bars displayed
	if shSettings.options.shPrim1 == true then
		shSettings.options.shPrim1 = false
		ChatFrame1:AddMessage("First Primary Bar |cffff0000hidden|r!")
		shPrim1Opt:SetChecked(true)
		shUpdateData();
	elseif shSettings.options.shPrim1 == false then
		shSettings.options.shPrim1 = true
		ChatFrame1:AddMessage("First Primary Bar |cff00ff00visible|r!")
		shPrim1Opt:SetChecked(false)
		shUpdateData();
	end
end

function shPrim2Toggle()
	-- true for bars displayed
	if shSettings.options.shPrim2 == false then
		shSettings.options.shPrim2 = true
		ChatFrame1:AddMessage("Second Primary Bar |cff00ff00visible|r!")
		shPrim2Opt:SetChecked(false)
		shUpdateData();
	elseif shSettings.options.shPrim2 == true then
		shSettings.options.shPrim2 = false
		ChatFrame1:AddMessage("Second Primary Bar |cffff0000hidden|r!")
		shPrim2Opt:SetChecked(true)
		shUpdateData();
	end
end

function shArchToggle()
	-- true for bars displayed
	if shSettings.options.shArch == false then
		shSettings.options.shArch = true
		ChatFrame1:AddMessage("Archaeology Bar |cff00ff00visible|r!")
		shArchOpt:SetChecked(false)
		shUpdateData();
	elseif shSettings.options.shArch == true then
		shSettings.options.shArch = false
		ChatFrame1:AddMessage("Archaeology Bar |cffff0000hidden|r!")
		shArchOpt:SetChecked(true)
		shUpdateData();
	end
end

function shFishToggle()
	-- true for bars displayed
	if shSettings.options.shFish == false then
		shSettings.options.shFish = true
		ChatFrame1:AddMessage("Fishing Bar |cff00ff00visible|r!")
		shFishOpt:SetChecked(false)
		shUpdateData();
	elseif shSettings.options.shFish == true then
		shSettings.options.shFish = false
		ChatFrame1:AddMessage("Fishing Bar |cffff0000hidden|r!")
		shFishOpt:SetChecked(true)
		shUpdateData();
	end
end

function shCookToggle()
	-- true for bars displayed
	if shSettings.options.shCook == false then
		shSettings.options.shCook = true
		ChatFrame1:AddMessage("Cooking Bar |cff00ff00visible|r!")
		shCookOpt:SetChecked(false)
		shUpdateData();
	elseif shSettings.options.shCook == true then
		shSettings.options.shCook = false
		ChatFrame1:AddMessage("Cooking Bar |cffff0000hidden|r!")
		shCookOpt:SetChecked(true)
		shUpdateData();
	end
end

function shRevToggle()
	if shSettings.options.shRev == true then
		shSettings.options.shRev = false
		--[[if shSettings.options.shNewLayout == true then
			shLinksFrame:SetPoint("TOPLEFT", shFrame, "TOPRIGHT", -5, 0)
		end]]
		ChatFrame1:AddMessage("Skill Helper set to Left aligned.")
		shUpdateData();
	else
		shSettings.options.shRev = true		
		--[[if shSettings.options.shNewLayout == true then
			shLinksFrame:SetPoint("TOPRIGHT", shFrame, "TOPLEFT", -255, 0)
		end]]
		ChatFrame1:AddMessage("Skill Helper set to Right aligned.")
		shUpdateData();
	end
end

function shLayoutToggle()
	if shSettings.options.shNewLayout == true then
		shSettings.options.shNewLayout = false
		ChatFrame1:AddMessage("Skill Helper set to Old Layout. Your UI needs a Reload.")
	else
		shSettings.options.shNewLayout = true
		ChatFrame1:AddMessage("Skill Helper set to New Layout. Your UI needs a Reload.")
	end
end

function shLocker()
	-- Remember shLock is backwards. true for unlocked and false for locked
	if shSettings.options.shLock == true then
		shSettings.options.shLock = false
		shFrameLockButton:SetChecked(false)
		shFrame:EnableMouse(shSettings.options.shLock)
		ChatFrame1:AddMessage("Skill Helper |cffff0000locked|r!")
	elseif shSettings.options.shLock == false then
		shSettings.options.shLock = true
		shFrameLockButton:SetChecked(true)
		shFrame:EnableMouse(shSettings.options.shLock)
		ChatFrame1:AddMessage("Skill Helper |cff00ff00unlocked|r!")
	end
end

function shReset()
	shFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	shSettings = defaults
	ChatFrame1:AddMessage("Skill Helper Reset!")
end

function shOption()
	InterfaceOptionsFrame_OpenToCategory("|cff00ff00Skill Helper|r");
	InterfaceOptionsFrame_OpenToCategory("|cff00ff00Skill Helper|r");
end

function shInfo()
	ChatFrame1:AddMessage(GetAddOnMetadata("SkillHelper", "Title") .. " " .. GetAddOnMetadata("SkillHelper", "Version"))
	ChatFrame1:AddMessage("Author: " .. GetAddOnMetadata("SkillHelper", "Author") .. " / Maintainer: " .. GetAddOnMetadata("SkillHelper", "X-Maintainer"))
end

function shMMToggle()
	if shSettings.options.shDB.hide == true then
		icon:Show("SkillHelper")
		shSettings.options.shDB.hide = false
		ChatFrame1:AddMessage("Skill Helper Minimap Icon |cff00ff00visible|r!")
		shMMToggleOpt:SetChecked(false)
	else
		icon:Hide("SkillHelper")
		shSettings.options.shDB.hide = true
		ChatFrame1:AddMessage("Skill Helper Minimap Icon |cffff0000hidden|r!")
		shMMToggleOpt:SetChecked(true)
	end
end

function shMiniMap()
	local ldb = LibStub("LibDataBroker-1.1", true)
	if not ldb then return end
	local shLDB = ldb:NewDataObject("SkillHelper", {
		type = "launcher",
		icon = "Interface\\AddOns\\SkillHelper\\IMAGES\\icon",
		OnClick = function(clickedframe, button)
			if button == "RightButton" then
				if IsShiftKeyDown() then
					--shLinks()
				else
					shLocker()
				end
			elseif button == "MiddleButton" then
				shOption()
			elseif button == "LeftButton" then
				if IsShiftKeyDown() then
					shLayoutToggle()
				else
					shToggle()
				end
			end
		end,
		OnTooltipShow = function(tt)
			tt:AddLine(GetAddOnMetadata("SkillHelper", "Title") .. " " .. GetAddOnMetadata("SkillHelper", "Version"))
			tt:AddDoubleLine("-------------------------", " ")
			tt:AddLine("Author: " .. GetAddOnMetadata("SkillHelper", "Author"))
			tt:AddLine("Maintainer: " .. GetAddOnMetadata("SkillHelper", "X-Maintainer"))
			tt:AddLine("|r  Left-Click to toggle window")
			tt:AddLine("|r  Shift+Left-Click to change Layout")
			tt:AddLine("|r  Right-Click to toggle lock")
			tt:AddLine("|r  Shift+Right-Click to toggle the Links frame")
			tt:AddLine("|r  Middle-Click to open Options")
		end,
	})
	if shLDB then
		icon = LibStub("LibDBIcon-1.0", true)
		if not icon then return end
		icon:Register("SkillHelper", shLDB, shSettings.options.shDB)
	end
end
