-- Title: Skill Helper
-- Author: JerichoHM
-- Maintainer: LownIgnitus
-- Version: 5.0.51
-- Desc: A simple addon for tracking and using skills

-- GLOBALS [ID is aka skillLine in GetProfessionInfo]
local shSkillNames = { 
				["_165"] = {
					["enName"] = "Leatherworking",
					["Icon"] = "inv_misc_armorkit_17",
					["IconID"] = 133611,
				},
				["_164"] = {
					["enName"] = "Blacksmithing",
					["Icon"] = "trade_blacksmithing",
					["IconID"] = 136241,
				},
				["_171"] = {
					["enName"] = "Alchemy",
					["Icon"] = "trade_alchemy",
					["IconID"] = 136240,
				},
				["_182"] = {
					["enName"] = "Herbalism",
					["skill"] = "Herb Gathering",
					["Icon"] = "spell_nature_naturetouchgrow",
					["IconID"] = 136065,
					["Spells"] = {
						["Name"] = "Herbalism Journal",
						["ID"] = 193290,
						["Icon"] = "inv_misc_bag_18",
						["IconID"] = 133651,
					},
				},
				["_185"] = {
					["enName"] = "Cooking",
					["Icon"] = "inv_misc_food_15",
					["IconID"] = 133971,
					["Spells"] = {
						["Name"] = "Cooking Fire",
						["ID"] = 818,
						["Icon"] = "spell_fire_fire",
						["IconID"] = 135805,
					},
				},
				["_186"] = {
					["enName"] = "Mining",
					["Icon"] = "trade_mining",
					["IconID"] = 136248,
					["Spells"] = {
						["Name"] = "Mining Journal",
						["ID"] = 2656,
						["Icon"] = "spell_fire_flameblades",
						["IconID"] = 135811,
					},
				},
				["_197"] = {
					["enName"] = "Tailoring",
					["Icon"] = "trade_tailoring",
					["IconID"] = 136249,
				},
				["_202"] = {
					["enName"] = "Engineering",
					["Icon"] = "trade_engineering",
					["IconID"] = 136243,
				},
				["_333"] = {
					["enName"] = "Enchanting",
					["Icon"] = "trade_engraving",
					["IconID"] = 136244,
					["Spells"] = {
						["Name"] = "Disenchant",
						["ID"] = 13262,
						["Icon"] = "inv_enchant_disenchant",
						["IconID"] = 132853,
					},
				},
				["_356"] = {
					["enName"] = "Fishing",
					["Icon"] = "trade_fishing",
					["IconID"] = 136245,
					["Spells"] = {
						["Name"] = "Fishing Journal",
						["ID"] = 271990,
						["Icon"] = "achievement_profession_fishing_northrendangler",
						["IconID"] = 236574,
					},
				},
				["_393"] = {
					["enName"] = "Skinning",
					["Icon"] = "inv_misc_pelt_wolf_01",
					["IconID"] = 134366,
					["Spells"] = {
						["Name"] = "Skinning Journal",
						["ID"] = 194174,
						["Icon"] = "inv_misc_skinningknife",
						["IconID"] = 463557,
					},
				},
				["_755"] = {
					["enName"] = "Jewelcrafting",
					["Icon"] = "inv_misc_gem_01",
					["IconID"] = 134071,
					["Spells"] = {
						["Name"] = "Prospecting",
						["ID"] = 31252,
						["Icon"] = "inv_misc_gem_bloodgem_01",
						["IconID"] = 134081,
					},
				},
				["_773"] = {
					["enName"] = "Inscription",
					["Icon"] = "inv_inscription_tradeskill01",
					["IconID"] = 237171,
					["Spells"] = {
						["Name"] = "Milling",
						["ID"] = 51005,
						["Icon"] = "ability_miling",
						["IconID"] = 236229,
					},
				},
				["_794"] = {
					["enName"] = "Archaeology",
					["Icon"] = "trade_archaeology",
					["IconID"] = 441139,
					["Spells"] = {
						["Name"] = "Survey",
						["ID"] = 80451,
						["Icon"] = "inv_misc_shovel_01",
						["IconID"] = 134435,
					},
				}				
			}

local shSkillCaps = {
	["SKILLCAP"] = 0,
	["classicCap"] = 300,
	["bcNRCataMopCap"] = 75,
	["archCap"] = 150,
	["wodLegionCap"] = 150,
	["bfa"] = 175,
	["slFish"] = 200,
	["slGather"] = 150,
	["slAlch"] = 175,
	["slCraft"] = 100,
	["slCook"] = 75,
	["twwCap"] = 100,
}
local y = -19
local imgFolder = "Interface\\ICONS\\"
local shFrameBG = { bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background.blp", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border.blp", tile = true, tileSize = 32, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}}
local shBarBG = { bgFile = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}}
SLASH_SKILLHELPER1, SLASH_SKILLHELPER2, SLASH_SKILLHELPER3, SLASH_SKILLHELPER4 = '/SHelper', '/shelper', '/Skillhelper', '/skillhelper'
local icon
local CF = CreateFrame
local addon_name = "SkillHelper"
local shFrame
local shBarFrame

-- RegisterEvent table
local shEvents_table = {}

shEvents_table.eventFrame = CF("Frame");
shEvents_table.eventFrame:RegisterEvent("ADDON_LOADED");
shEvents_table.eventFrame:RegisterEvent("SKILL_LINES_CHANGED")
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

-- Initialize Main Frame
	shMainFrame()

--	print("Unregister")
	shMiniMap();
	shOptionsInit();
	shInitialize();
end

function shMainFrame()
	-- shFrame Core UI
	shFrame = CF("Frame", "shFrame", UIParent, "BackdropTemplate")
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

	-- shFrame New layout UI
	if shSettings.options.shNewLayout == true then
		-- Title
		shFrame.title = shFrame:CreateFontString("shFrameTitle", "BACKGROUND")
		shFrame.title:SetFont("Fonts\\FRIZQT__.TTF", 12)
		shFrame.title:SetSize(125, 16)
		shFrame.title:SetPoint("TOPLEFT", shFrame, "TOPLEFT", 10, -3)		
		shFrameTitle:SetText(C_AddOns.GetAddOnMetadata(addon_name, "Title") .. " " .. C_AddOns.GetAddOnMetadata(addon_name, "Version"))
		shFrameTitle:SetScript("OnEnter", function(self) shMouseOverEnter(); end)
		shFrameTitle:SetScript("OnLeave", function(self) shMouseOverLeave(); end)

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

		-- Prof Open Button
		local shFrameProfsButton = CF("Button", "shFrameProfsButton", shFrame)
		shFrameProfsButton:SetFrameStrata("LOW")
		shFrameProfsButton:SetSize(18, 19)
		shFrameProfsButton:SetPoint("TOPRIGHT", shFrame, "TOPRIGHT", -26, 1) -- -42, 1

		shFrameProfsButton:SetScript("OnClick", function(self) ToggleProfessionsBook(); end)
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

function shEvents_table.eventFrame:SKILL_LINES_CHANGED()
--	print("Skill Change")
	if not InCombatLockdown() then
		shUpdateData()
	end
end

-- Skill Helper Options
function shOptionsInit()
	local shOptions = CF("Frame", nil, SettingsPanel.Container);
	local panelWidth = SettingsPanel.Container:GetWidth() -- ~623
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
	local title = createfont("SystemFont_OutlineThick_WTF", C_AddOns.GetAddOnMetadata(addon_name, "Title"))
	title:SetPoint("TOPLEFT", 16, -16)
	local ver = createfont("SystemFont_Huge1", C_AddOns.GetAddOnMetadata(addon_name, "Version"))
	ver:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 4, 0)
	local date = createfont("GameFontNormalLarge", "Version Date: " .. C_AddOns.GetAddOnMetadata(addon_name, "X-Date"))
	date:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	local author = createfont("GameFontNormal", "Author: " .. C_AddOns.GetAddOnMetadata(addon_name, "Author"))
	author:SetPoint("TOPLEFT", date, "BOTTOMLEFT", 0, -8)
	local maintainer = createfont("GameFontNormal", "Maintainer: " .. C_AddOns.GetAddOnMetadata(addon_name, "X-Maintainer"))
	maintainer:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -8)
	local website = createfont("GameFontNormal", "Website: " .. C_AddOns.GetAddOnMetadata(addon_name, "X-Website"))
	website:SetPoint("TOPLEFT", maintainer, "BOTTOMLEFT", 0, -8)
	local desc = createfont("GameFontHighlight", C_AddOns.GetAddOnMetadata(addon_name, "Notes"))
	desc:SetPoint("TOPLEFT", website, "BOTTOMLEFT", 0, -8)

	-- Misc Options Frame
	local shMiscFrame = CF("Frame", SHMiscFrame, shOptions, "BackdropTemplate")
	shMiscFrame:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -8)
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
	local reloadBtn = CF("Button", "Reload", shMiscFrame, "UIPanelButtonTemplate")
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
	local shScaleFrame = CF("Frame", "SHScaleFrame", shOptions, "BackdropTemplate")
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
	local shAlphaFrame = CF("Frame", "SHAlphaFrame", shOptions, "BackdropTemplate")
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
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(shOptions)
	else
		local category, layout = _G.Settings.RegisterCanvasLayoutCategory(shOptions, shOptions.name)
		_G.Settings.RegisterAddOnCategory(category)
	end
	-- End Skill Helper Options
end

-- Skills Table
local skills = {}

-- Frames Table
local bars = {}

function shDrawBar(name, iconID, rank, rankModifier, maxRank, numSpells, skillLine, SKILLCAP, y)
	local name2, iconID2
	--name, iconLink, rank, rankModifier, maxRank, numSpells, skillLine, twwCap, y
--	print("Profession: " .. name .. ", skillLine: " .. skillLine .. ", iconID: " .. iconID)
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
			btnax = -197
			-- Skill Button 2 X Point
			btnbx = 0
		else
			-- Skill Bar X Point
			barx = 6
			-- Skill Button 1 X Point
			btnax = -197
			-- Skill Button 2 X Point
			btnbx = 0
		end
	end

	if shSettings.options.shNewLayout == false then
		y = y + 17
	end

	local bar = bars[name]
	if not bar then --if bar doesn't exist
		-- The Skill bar
		bar = CF("StatusBar", nil, shBarFrame, "BackdropTemplate")
		bar:SetFrameStrata("BACKGROUND")
		bar:SetPoint("TOPLEFT", shBarFrame, "TOPLEFT", barx, y)
		bar:SetSize(160,18)
		bar:SetBackdrop(shBarBG)
		bar:SetBackdropColor(shSettings.colors.baser, shSettings.colors.baseg, shSettings.colors.baseb, shSettings.colors.half)
		bar:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
		bar:SetStatusBarColor(shSettings.colors.baser, shSettings.colors.baseg, shSettings.colors.baseb, shSettings.colors.full)
		bar:SetMinMaxValues(0,1)
		bar:SetValue((rank + rankModifier)/maxRank)
		bar:SetScript("OnEnter", function(self) shMouseOverEnter(); end)
		bar:SetScript("OnLeave", function(self) shMouseOverLeave(); end)

		-- The text on the Skill Bar
		local barTxt = bar:CreateFontString(nil, "ARTWORK");
		isValid = barTxt:SetFont("Fonts\\FRIZQT__.TTF", 10);
		barTxt:SetPoint("CENTER", bar, "CENTER", 0, 1);
		bar.text = barTxt

		-- Text formatting for the text on the Skill Bar
		bar.text:SetFormattedText("|cFFFFFF00%s: |cFFFFFFFF%s+%s/%s", name, rank, rankModifier, maxRank)

		-- The first button on the skills action bar
		local barBtn1 = CF("Button", barBtn1, bar, "SecureActionButtonTemplate");
		barBtn1:SetPoint("TOPLEFT", bar, "TOPRIGHT", btnax, 0);
		barBtn1:SetSize(18,18);
		barBtn1:SetMouseClickEnabled(true);
		barBtn1:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
		if skillLine == 356 or skillLine == 186 or skillLine == 393 or skillLine == 182 then
			if numSpells == 2 then
				--Is Fishing or Mining or Skinning or Herbalism swap spell 1 and 2
				name2 = name
				iconID2 = iconID			
				name, iconID = shGetButton(skillLine, numSpells)
			else
				--nothing
			end
		end
		barBtn1:SetNormalTexture(iconID)
		barBtn1:SetScript("OnEnter", function(self)	GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:ClearLines();	 GameTooltip:AddLine(name); GameTooltip:Show(); shMouseOverEnter(); end)
		barBtn1:SetScript("OnLeave", function(self) GameTooltip:Hide(); shMouseOverLeave(); end)
		local state
		barBtn1:SetScript("OnClick", function(self)  
			if state == "close" or state == nil then 
				state = C_TradeSkillUI.OpenTradeSkill(skillLine)
			else
				state = "close"
				C_TradeSkillUI.CloseTradeSkill()
			end
		end);
		bar.btn1 = barBtn1

		-- The second button on the skills action bar if applicable
		if numSpells == 2 then
--			print("Button 2" .. name)
			-- Alchemy, Blacksmithing, Leatherworking, or Tailoring
			if skillLine == 171 or skillLine == 164 or skillLine == 165 or skillLine == 197 then
				print("Spell 2 found for " .. name .. ", please report this.")
			elseif skillLine == 202 then
				--Engineering Do nothing
			else
				local barBtn2 = CF("Button", barBtn2, barBtn1, "SecureActionButtonTemplate");
				barBtn2:SetPoint("TOPLEFT", barBtn1, "TOPRIGHT", btnbx, 0);
				barBtn2:SetSize(18,18);
				barBtn2:SetMouseClickEnabled(true);
				barBtn2:RegisterForClicks("AnyUp", "AnyDown");
				if skillLine == 356 or skillLine == 186 or skillLine == 393 or skillLine == 182 then
					--is Fishing nothing
				else
					name2, iconID2 = shGetButton(skillLine, numSpells)
				end
--				print("name2 " ..name2.. ", iconID2 " ..iconID2)
				barBtn2:SetNormalTexture(iconID2)
				barBtn2:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
				barBtn2:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:ClearLines(); GameTooltip:AddLine(name2); GameTooltip:Show(); shMouseOverEnter(); end)
				barBtn2:SetScript("OnLeave", function(self) GameTooltip:Hide(); shMouseOverLeave(); end)
				barBtn2:SetAttribute("type1", "spell");
				barBtn2:SetAttribute("spell", name2);
				bar.btn2 = barBtn2
			end
		end

		-- Add to the array
		if skillLine == 356 then
			bars[name2] = bar
		else
			bars[name] = bar
		end
	else --if bar exists
		bar:ClearAllPoints()
	end

	-- if the rank is in trainable range and not skill cap then turn bar red
	bar:SetPoint("TOPLEFT", shFrame, "TOPLEFT", barx, y-4)
	bar:SetValue((rank + rankModifier)/maxRank)

	if	rank >= maxRank - 25 and maxRank < SKILLCAP then
		bar:SetStatusBarColor(shSettings.colors.trainr, shSettings.colors.trainb, shSettings.colors.traing, shSettings.colors.full)
		bar:SetBackdropColor(shSettings.colors.trainr, shSettings.colors.trainb, shSettings.colors.traing, shSettings.colors.half)
		
		bar.text:SetFormattedText("|cFFFF0000%s: |cFFFFFFFF%s+%s/%s", name, rank, rankModifier, maxRank)
	elseif rank == maxRank then -- set maxed skill level bar royal blue
		bar:SetStatusBarColor(shSettings.colors.maxr, shSettings.colors.maxg, shSettings.colors.maxb, shSettings.colors.full)
		bar:SetBackdropColor(shSettings.colors.maxr, shSettings.colors.maxg, shSettings.colors.maxb, shSettings.colors.half)
		
		bar.text:SetFormattedText("|cFF00FF00%s: |cFFFFFFFF%s+%s/%s", name, rank, rankModifier, maxRank)
	else -- otherwise keep bar green
		bar:SetStatusBarColor(shSettings.colors.baser, shSettings.colors.baseg, shSettings.colors.baseb, shSettings.colors.full)
		bar:SetBackdropColor(shSettings.colors.baser, shSettings.colors.baseg, shSettings.colors.baseb, shSettings.colors.half)
		
		bar.text:SetFormattedText("|cFFFFFF00%s: |cFFFFFFFF%s+%s/%s", name, rank, rankModifier, maxRank)
	end

	shFrame:SetHeight((y - 27)* -1)
	shBarFrame:SetHeight((y - 27)* -1)
end

function shUpdateData()
	
	-- Capture the SkillIndes for the players Professions
	local prof1, prof2, archaeology, fishing, cooking = GetProfessions()

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
	local skillCap
	for k, v in pairs(profs) do
		if skillLine == 794 then
			skillCap = shSkillCaps.archCap
		else
			skillCap = shSkillCaps.twwCap
		end
		-- Fetch the details for each Profession
		-- name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, skillModifier, specializationIndex, specializationOffset
		local name, iconLink, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier, specializationIndex, specializationOffset = GetProfessionInfo(v)
--		print(name .. ", " .. iconLink .. ", " .. rank .. ", " .. maxRank .. ", " .. numSpells .. ", " .. spelloffset .. ", " .. skillLine .. ", " .. rankModifier .. ", " .. specializationIndex .. ", " .. specializationOffset)
		shDrawBar(name, iconLink, rank, rankModifier, maxRank, numSpells, skillLine, skillCap, y)
		y = y - 18

		tinsert( skills, name)
	end
	shCleanUp()

	y = -19
end

function shCleanUp()
	local match = false
	local clnBar

	for k, v in pairs(bars) do -- cycle bar names
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
	else
		shRevOpt:SetChecked(true)
	end

	if shSettings.options.shNewLayout == true then
		shLayoutOpt:SetChecked(true)
	else
		shLayoutOpt:SetChecked(false)
	end

	shUpdateData()
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

function shGetButton(skillLine, spellNum)
	local iconName, iconID
	if skillLine == 794 then -- Archaeology
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._794.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._794.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 171 then -- Alchemy
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._171.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._171.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 164 then -- Blacksmithing
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._164.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._164.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 185 then -- Cooking
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._185.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._185.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 333 then -- Enchanting
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._333.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._333.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 202 then -- Engineering
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._202.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._202.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 356 then -- Fishing
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._356.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._356.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 182 then -- Herbalism
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._182.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._182.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 773 then -- Inscription
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._773.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._773.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 755 then -- Jewelcrafting
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._755.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._755.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 165 then -- Leatherworking
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._165.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._165.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 186 then -- Mining
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._186.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._186.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 393 then -- Skinning
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._393.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._393.Spells.ID)
			return iconName, iconID
		end
	elseif skillLine == 197 then -- Tailoring
		if spellNum == 2 then
			iconName = C_Spell.GetSpellName(shSkillNames._197.Spells.ID)
			iconID, _ = C_Spell.GetSpellTexture(shSkillNames._197.Spells.ID)
			return iconName, iconID
		end
	end
end

function SlashCmdList.SKILLHELPER(msg, Editbox)
	if msg == "toggle" then
		shToggle()
	elseif msg == "lock" then
		shLocker()
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
		ChatFrame1:AddMessage("Skill Helper set to Left aligned.")
		shUpdateData();
	else
		shSettings.options.shRev = true
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
		shFrame:EnableMouse(false)
		ChatFrame1:AddMessage("Skill Helper |cffff0000locked|r!")
	elseif shSettings.options.shLock == false then
		shSettings.options.shLock = true
		shFrameLockButton:SetChecked(true)
		shFrame:EnableMouse(true)
		ChatFrame1:AddMessage("Skill Helper |cff00ff00unlocked|r!")
	end
end

function shReset()
	shFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	shSettings = defaults
	ChatFrame1:AddMessage("Skill Helper Reset!")
end

function shOption()
	if Settings then
		Settings.OpenToCategory("|cff00ff00Skill Helper|r")
	elseif InterfaceOptionsFrame_OpenToCategory then		
		InterfaceOptionsFrame_OpenToCategory("|cff00ff00Skill Helper|r");
		InterfaceOptionsFrame_OpenToCategory("|cff00ff00Skill Helper|r");
	end
end

function shInfo()
	ChatFrame1:AddMessage(C_AddOns.GetAddOnMetadata("SkillHelper", "Title") .. " " .. C_AddOns.GetAddOnMetadata("SkillHelper", "Version"))
	ChatFrame1:AddMessage("Author: " .. C_AddOns.GetAddOnMetadata("SkillHelper", "Author") .. " / Maintainer: " .. C_AddOns.GetAddOnMetadata("SkillHelper", "X-Maintainer"))
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
			tt:AddLine(C_AddOns.GetAddOnMetadata("SkillHelper", "Title") .. " " .. C_AddOns.GetAddOnMetadata("SkillHelper", "Version"))
			tt:AddDoubleLine("-------------------------", " ")
			tt:AddLine("Author: " .. C_AddOns.GetAddOnMetadata("SkillHelper", "Author"))
			tt:AddLine("Maintainer: " .. C_AddOns.GetAddOnMetadata("SkillHelper", "X-Maintainer"))
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

-- shFrame Hide on Pet Battle
PetBattleFrame:HookScript("OnShow",function() shFrame:Hide(); end);
PetBattleFrame:HookScript("OnHide",function() if shSettings.options.shHidden == false then shFrame:Show(); end end);