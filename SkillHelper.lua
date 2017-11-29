-- Title: Skill Helper
-- Author: JerichoHM
-- Maintainer: LownIgnitus
-- Version: 3.2.21
-- Desc: A simple addon for tracking and using skills

-- GLOBALS
local SKILLCAP = 800
local y = -15
local imgFolder = "Interface\\ICONS\\"
local shBarBG = { bgFile = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}}
SLASH_SKILLHELPER1, SLASH_SKILLHELPER2, SLASH_SKILLHELPER3, SLASH_SKILLHELPER4 = '/SHelper', '/shelper', '/Skillhelper', '/skillhelper'
local icon
CF = CreateFrame
local addon_name = "SkillHelper"

-- RegisterForEvent table
local shEvents_table = {}

shEvents_table.eventFrame = CF("Frame");
--shEvents_table.eventFrame:RegisterEvent("PLAYER_LOGIN");
shEvents_table.eventFrame:RegisterEvent("ADDON_LOADED");
shEvents_table.eventFrame:RegisterEvent("SKILL_LINES_CHANGED");
shEvents_table.eventFrame:SetScript("OnEvent", function(self, event, ...)
	shEvents_table.eventFrame[event](self, ...);
end);

function shEvents_table.eventFrame:PLAYER_LOGIN()
		-- 
end

function shEvents_table.eventFrame:ADDON_LOADED(AddOn)
--	print(AddOn)
	if AddOn ~= addon_name then
		return -- not Skill Helper
	end

	-- Unregister ADDON_LOADED, reduce cpu lag
	shEvents_table.eventFrame:UnregisterEvent("ADDON_LOADED")
	
	--Title Frames
	shFrame.title.text:SetText(GetAddOnMetadata(addon_name, "Title") .. " " .. GetAddOnMetadata(addon_name, "Version"))
	shLinksFrame.title.text:SetText("Links")
	
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
			["shlHidden"] = true,
			["shPrim1"] = true,
			["shPrim2"] = true,
			["shArch"] = true,
			["shFish"] = true,
			["shCook"] = true,
			["shAid"] = true,
			["shRev"] = false,
			["shDB"] = { hide = false },
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

--	shSettings = shSettings or {}

--	for var, value in pairs(defaults) do
--		if shSettings[var] == nil then
--			shSettings[var] = value
--		end
--	end

--	print("Unregister")
	shMiniMap();
	shOptionsInit();
	shInitialize();
end

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
	local desc = createfont("GameFontHighlight", GetAddOnMetadata(addon_name, "Notes"))
	desc:SetPoint("TOPLEFT", website, "BOTTOMLEFT", 0, -8)
	local desc2 = createfont("GameFontHighlight", GetAddOnMetadata(addon_name, "X-Notes2"))
	desc2:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -8)

	-- Misc Options Frame
	local shMiscFrame = CF("Frame", SHMiscFrame, shOptions)
	shMiscFrame:SetPoint("TOPLEFT", desc2, "BOTTOMLEFT", 0, -8)
	shMiscFrame:SetBackdrop(shOptionsBG)
	shMiscFrame:SetSize(240, 215)

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

	-- Toggle First Aid Profession bar
	local shAidOpt = createcheckbox("Hide First Aid Profession bar.", 18, 18, "TOPLEFT", shCookOpt, "BOTTOMLEFT", 0, 0, "shAidOpt")

	shAidOpt:SetScript("OnClick", function(self) shAidToggle() end)

	-- Reverse the skill bars, buttons, and link frame
	local shRevOpt = createcheckbox("Reverse the Skill Helper frame.", 18, 18, "TOPLEFT", shAidOpt, "BOTTOMLEFT", 0, 0, "shRevOpt")
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
		-- Skill Bar X Point
		barx = 42
		-- Skill Button 1 X Point
		btnax = -178
		-- Skill Button 2 X Point
		btnbx = -36
	end

	local bar = bars[name]
	if not bar then --if bar doesn't exist
		-- The Skill bar
		bar = CF("StatusBar", nil, shBarFrame)
		bar:SetFrameStrata("BACKGROUND")
		bar:SetPoint("TOPLEFT", shBarFrame, "TOPLEFT", barx, y-4)
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
		if name == "Mining" then
			barBtn1:SetAttribute("spell", shGetSpell(name, 2));
		end
--		imgFolder .. shGetButton(name, 1)
		barBtn1BG = { bgFile = imgFolder .. shGetButton(name, 1), edgeFile = nil, tile = false, tileSize = 18, edgeSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}};
		barBtn1:SetBackdrop(barBtn1BG);
		barBtn1:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:ClearLines(); GameTooltip:AddLine(name); GameTooltip:Show(); shMouseOverEnter(); end)
		barBtn1:SetScript("OnLeave", function(self) GameTooltip:Hide(); shMouseOverLeave(); end)
		bar.btn1 = barBtn1

		-- The second button on the skills action bar if applicable
		if numSpells == 2 then
--			print("Button 2" .. name)
			if name ~= "Tailoring" and name ~= "Alchemy" and name ~= "Engineering" and name ~= "Blacksmithing" and name ~= "Leatherworking" and name ~= "Mining" then
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

function shLinksButtons(name, y)
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
	
	shLinksFrame:SetHeight((y - 27)* -1)
end

function shUpdateData()
	
	-- Capture the SkillIndes for the players Professions
	local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
--	print(prof1 .. ", " .. prof2 .. ", " .. archaeology .. ", " .. fishing .. ", " .. cooking .. ", " .. firstAid)
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

	if shSettings.options.shAid == true then
		-- Build an array of primary professions
		tinsert(profs, firstAid)
	end
--	table.foreach(profs, print)
			
	for k, v in pairs(profs) do
		-- Fetch the details for each Profession
		local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier, specializationIndex, specializationOffset = GetProfessionInfo(v)
--		print(name .. ", " .. texture .. ", " .. rank .. ", " .. maxRank .. ", " .. numSpells .. ", " .. spelloffset .. ", " .. skillLine .. ", " .. rankModifier .. ", " .. specializationIndex .. ", " .. specializationOffset)
		shDrawBar(name, texture, rank, rankModifier, maxRank, numSpells, y)
		shLinksButtons(name, y)
		y = y - 18

		tinsert( skills, name)
	end
	shCleanUp()

	y = -15
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
		shFrame.buttonLock:SetChecked(true)
	else
		shFrame:EnableMouse(false)
		shFrame.buttonLock:SetChecked(false)
	end
			
	if shSettings.options.shHidden == false then
		shFrame:Show()
	else
		shFrame:Hide()
	end			

	if shSettings.options.shlHidden == false then
		shLinksFrame:Show()
	else
		shLinksFrame:Hide()
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

	if shSettings.options.shAid == true then
		shAidOpt:SetChecked(false)
	else
		shAidOpt:SetChecked(true)
	end

	if shSettings.options.shRev == false then
		shRevOpt:SetChecked(false)
		shLinksFrame:SetPoint("TOPLEFT", shFrame, "TOPRIGHT", -5, 0)
	else
		shRevOpt:SetChecked(true)
		shLinksFrame:SetPoint("TOPLEFT", shFrame, "TOPRIGHT", -255, 0)
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
			return "trade_alchemy"
		end
	elseif name == "Archaeology" then
		if spellNum == 1 then
			return "trade_archaeology"
		elseif spellNum == 2 then
			return "inv_misc_shovel_01"
		end
	elseif name == "Blacksmithing" then
		if spellNum == 1 then
			return "trade_blacksmithing"
		end
	elseif name == "Cooking" then
		if spellNum == 1 then
			return "inv_misc_food_15"
		elseif spellNum == 2 then
			return "spell_fire_fire"
		end
	elseif name == "Enchanting" then
		if spellNum == 1 then
			return "trade_engraving"
		elseif spellNum == 2 then
			return "INV_Enchant_Disenchant"
		end
	elseif name == "Engineering" then
		if spellNum == 1 then
			return "trade_engineering"
		end
	elseif name == "First Aid" then
		if spellNum == 1 then
			return "spell_holy_sealofsacrifice"
		end
	elseif name == "Fishing" then
		if spellNum == 1 then
			return "trade_fishing"
		end
	elseif name == "Herbalism" then
		if spellNum == 1 then
			return "spell_nature_naturetouchgrow"
		elseif spellNum == 2 then
			return "inv_misc_bag_18"
		end
	elseif name == "Inscription" then
		if spellNum == 1 then
			return "inv_inscription_tradeskill01"
		elseif spellNum == 2 then
			return "ability_miling"
		end
	elseif name == "Jewelcrafting" then
		if spellNum == 1 then
			return "inv_misc_gem_01"
		elseif spellNum == 2 then
			return "inv_misc_gem_bloodgem_01"
		end
	elseif name == "Leatherworking" then
		if spellNum == 1 then
			return "inv_misc_armorkit_17"
		end
	elseif name == "Mining" then
		if spellNum == 1 then
			return "spell_fire_flameblades"
		elseif spellNum == 2 then
			return "trade_mining"
		end
	elseif name == "Skinning" then
		if spellNum == 1 then
			return "inv_misc_pelt_wolf_01"
		elseif spellNum == 2 then
			return "inv_misc_skinningknife"
		end
	elseif name == "Tailoring" then
		if spellNum == 1 then
			return "trade_tailoring"
		end
	end
end

function shGetSpell(name, spellNum)
	if name == "Archaeology" then
		if spellNum == 2 then
			return "Survey"
		end
	elseif name == "Cooking" then
		if spellNum == 2 then
			return "Cooking Fire"
		end
	elseif name == "Enchanting" then
		if spellNum == 2 then
			return "Disenchant"
		end
	elseif name == "Herbalism" then
		if spellNum == 2 then
			return "Herbalism Skills"
		end
	elseif name == "Inscription" then
		if spellNum == 2 then
			return "Milling"
		end
	elseif name == "Jewelcrafting" then
		if spellNum == 2 then
			return "Prospecting"
		end
	elseif name == "Mining" then
		if spellNum == 2 then
			return "Mining Skills"
		end
	elseif name == "Skinning" then
		if spellNum == 2 then
			return "Skinning Skills"
		end
	end
end

function SlashCmdList.SKILLHELPER(msg, Editbox)
	if msg == "toggle" then
		shToggle()
	elseif msg == "lock" then
		shLocker()
	elseif msg == "links" then
		shLinks()
	elseif msg == "reset" then
		shReset()
	elseif msg == "mmtoggle" then
		shMMToggle()
	elseif msg == "options" then
		shOption()
	elseif msg == "info" then
		shInfo()
	else
		ChatFrame1:AddMessage("|cff71C671Skill Helper Slash Commands|r")
		ChatFrame1:AddMessage("|cff71C671type /SHelper followed by:|r")
		ChatFrame1:AddMessage("|cff71C671  -- toggle to toggle the addon hidden state|r")
		ChatFrame1:AddMessage("|cff71C671  -- lock to toggle locking|r")
		ChatFrame1:AddMessage("|cff71C671  -- links to toggle the Skill Links frame|r")
		ChatFrame1:AddMessage("|cff71C671  -- reset to reset to default position|r")
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

function shLinks()
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

function shAidToggle()
	-- true for bars displayed
	if shSettings.options.shAid == false then
		shSettings.options.shAid = true
		ChatFrame1:AddMessage("First Aid Bar |cff00ff00visible|r!")
		shAidOpt:SetChecked(false)
		shUpdateData();
	elseif shSettings.options.shAid == true then
		shSettings.options.shAid = false
		ChatFrame1:AddMessage("First Aid Bar |cffff0000hidden|r!")
		shAidOpt:SetChecked(true)
		shUpdateData();
	end
end

function shRevToggle()
	if shSettings.options.shRev == true then
		shSettings.options.shRev = false
		shLinksFrame:SetPoint("TOPLEFT", shFrame, "TOPRIGHT", -5, 0)
		ChatFrame1:AddMessage("Skill Helper set to normal")
		shUpdateData();
	else
		shSettings.options.shRev = true
		shLinksFrame:SetPoint("TOPRIGHT", shFrame, "TOPLEFT", -255, 0)
		ChatFrame1:AddMessage("Skill Helper reversed")
		shUpdateData();
	end
end

function shLocker()
	-- Remember shLock is backwards. true for unlocked and false for locked
	if shSettings.options.shLock == true then
		shSettings.options.shLock = false
		shFrame.buttonLock:SetChecked(false)
		shFrame:EnableMouse(shSettings.options.shLock)
		ChatFrame1:AddMessage("Skill Helper |cffff0000locked|r!")
	elseif shSettings.options.shLock == false then
		shSettings.options.shLock = true
		shFrame.buttonLock:SetChecked(true)
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
					shLinks()
				else
					shLocker()
				end
			elseif button == "MiddleButton" then
				shReset()
			elseif button == "LeftButton" then
				if IsShiftKeyDown() then
					shOption()
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
			tt:AddLine("|r  Shift+Left-Click to open Options")
			tt:AddLine("|r  Right-Click to toggle lock")
			tt:AddLine("|r  Shift+Right-Click to toggle the Links frame")
			tt:AddLine("|r  Middle-Click to reset")
		end,
	})
	if shLDB then
		icon = LibStub("LibDBIcon-1.0", true)
		if not icon then return end
		icon:Register("SkillHelper", shLDB, shSettings.options.shDB)
	end
end
