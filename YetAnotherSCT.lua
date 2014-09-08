-----------------------------------------------------------------------------------------------
-- Client Lua Script for FloatTextPanel
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "Spell"
require "CombatFloater"
require "GameLib"
require "Unit"

--Fonts

local fontList = {
	"CRB_Dialog_Heading_Huge",
	"CRB_FloaterHuge",
	"CRB_HeaderHuge",
	"CRB_Interface14",
	"CRB_Pixel",
	"Default",
	"Subtitle",
	"Courier"
}

local YetAnotherSCT = {
	userSettings = {
	--General
		ccStatePlayerFontColor = "ff2b2b",
		ccStateEnemyFontColor = "ffe691",
		ccStateFont = "CRB_FloaterLarge",
		ccStatePlayerFontSize = 1,
		ccStateEnemyFontSize = 1,
		ccStatePlayerFontDuration = 2,
		ccStateEnemyFontDuration = 2,
		splitIncoming = 0,
		swapIncoming = 0,
		mergeIncoming = 0,
		invertMergeIncoming = 0,
		splitOutgoing = 0,
		swapOutgoing = 0,
		mergeOutgoing = 0,
		invertMergeOutgoing = 0,
		hideSpellCastFail = 0,
		CriticalHitMarker = "*",
		sCombatTextAnchor = CombatFloater.CodeEnumFloaterLocation.Head,
	--Outgoing Damage
		outgoingDamageDisable = 0,
		outgoingShieldDamageDisable = 0,
		outgoingDamageMinimumShown = 0,
		outgoingDamageFont = "CRB_FloaterLarge",
		outgoingCritDamageFont = "CRB_FloaterLarge",
		outgoingDamageFontSize = 0.8,
		outgoingCritDamageFontSize = 1,
		outgoingDamageDuration = 2,
		outgoingCritDamageDuration = 2,
		outgoingDamageFontColor = "e5feff",
		outgoingCritDamageFontColor = "fffb93",
		outgoingCritDamageFlash = 1.75,
		outgoingDamageFlashColor = "ffffff",
	--Outgoing Heal
		outgoingHealDisable = 0,
		outgoingHealMinimumShown = 0,
		outgoingHealFont = "CRB_FloaterLarge",
		outgoingCritHealFont = "CRB_FloaterLarge",
		outgoingHealFontSize = 0.8,
		outgoingCritHealFontSize = 0.9,
		outgoingHealDuration = 2,
		outgoingCritHealDuration = 2,
		outgoingHealFontColor = "b0ff6a",
		outgoingCritHealFontColor = "cdffa0",
		outgoingCritHealFlash = 1.75,
		outgoingHealFlashColor = "ffffff",
	--Incoming Damage
		incomingDamageDisable = 0,
		incomingShieldDamageDisable = 0,
		incomingDamageFont = "CRB_FloaterLarge",
		incomingCritDamageFont = "CRB_FloaterLarge",
		incomingDamageFontSize = 0.8,
		incomingCritDamageFontSize = 1.2,
		incomingDamageDuration = 0.55,
		incomingCritDamageDuration = 0.75,
		incomingDamageFontColor = "f8f3d7",
		incomingCritDamageFontColor = "ffab3d",
		incomingCritDamageFlash = 1.75,
		incomingDamageFlashColor = "ffffff",
	--Incoming Heal
		incomingHealDisable = 0,
		incomingHealMinimumShown = 0,
		incomingHealFont = "CRB_FloaterLarge",
		incomingCritHealFont = "CRB_FloaterLarge",
		incomingHealFontSize = 0.8,
		incomingCritHealFontSize = 1.2,
		incomingHealDuration = 0.55,
		incomingCritHealDuration = 0.75,
		incomingHealFontColor = "b0ff6a",
		incomingCritHealFontColor = "c6ff94",
		incomingCritHealFlash = 0.75,
		incomingHealFlashColor = "ffffff",
	},
}

local outgoingCritColorAsCColor = CColor.new(1, 1, 1, 1)
local outgoingDamageColorAsCColor = CColor.new(1, 1, 1, 1)

local outgoingHealColorAsCColor = CColor.new(1, 1, 1, 1)
local outgoingCritHealColorAsCColor = CColor.new(1, 1, 1, 1)

local incomingCritColorAsCColor = CColor.new(1, 1, 1, 1)
local incomingDamageColorAsCColor = CColor.new(1, 1, 1, 1)

local incomingHealColorAsCColor = CColor.new(1, 1, 1, 1)
local incomingCritHealColorAsCColor = CColor.new(1, 1, 1, 1)

local ccStatePlayerColorAsCColor = CColor.new(1, 1, 1, 1)
local ccStateEnemyColorAsCColor = CColor.new(1, 1, 1, 1)

--local YetAnotherSCT = {}

local knTestingVulnerable = -1

function YetAnotherSCT:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function YetAnotherSCT:Init()
	Apollo.RegisterAddon(self)
end

function YetAnotherSCT:OnLoad() -- OnLoad then GetAsyncLoad then OnRestore
	Apollo.RegisterEventHandler("OptionsUpdated_Floaters", 					"OnOptionsUpdated", self)
	Apollo.RegisterSlashCommand("yasct", 					"OnYetAnotherSCTOn", self)
	Apollo.RegisterSlashCommand("YASCT", 					"OnYetAnotherSCTOn", self)
	self.xmlDoc = XmlDoc.CreateFromFile("OptionsForm.xml")
	self.Custom = XmlDoc.CreateFromFile("YASCTCustomizationAssist.xml")

	
	--TODO
	--self:DefaultSettings()
end

function YetAnotherSCT:OnInterfaceMenuListHasLoaded()

		Event_FireGenericEvent("InterfaceMenuList_NewAddOn",
			"YetAnotherSCT",
			{"ShowSCTMenu", "", ""})

end

-- Save User Settings
function YetAnotherSCT:OnSave(eType)
Print("OnSave")
	tSave = self.userSettings
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Account then
		return nil
	else 
		return tSave
	end
end

-- Restore Saved User Settings
function YetAnotherSCT:OnRestore(eType, tData)
if eType == GameLib.CodeEnumAddonSaveLevel.Account then 
		for Dkey, Dvalue in pairs(self.userSettings) do
			if tData[Dkey] ~= nil then
				self.userSettings[Dkey] = tData[Dkey]
			end
		end
	--self:LoadUserSettings()
	end
end


-- Set Default Settings Options
function YetAnotherSCT:DefaultSettings()
	self.userSettings.outgoingDamageDisable = 0
	self.userSettings.outgoingShieldDamageDisable = 0
	self.userSettings.outgoingDamageMinimumShown = 0
	self.userSettings.outgoingDamageFont = "CRB_FloaterLarge"
	self.userSettings.outgoingCritDamageFont = "CRB_FloaterLarge"
	self.userSettings.outgoingDamageFontSize = 0.8
	self.userSettings.outgoingCritDamageFontSize = 1
	self.userSettings.outgoingDamageDuration = 2
	self.userSettings.outgoingDamageMinimumShown = 0
	self.userSettings.outgoingCritDamageDuration = 2
	self.userSettings.outgoingDamageFontColor = "e5feff"
	self.userSettings.outgoingCritDamageFontColor = "fffb93"
	self.userSettings.outgoingCritDamageFlash = 1.75
	self.userSettings.outgoingDamageFlashColor = "ffffff"

	self.userSettings.outgoingHealDisable = 0
	self.userSettings.outgoingHealMinimumShown = 0
	self.userSettings.outgoingHealFont = "CRB_FloaterLarge"
	self.userSettings.outgoingCritHealFont = "CRB_FloaterLarge"
	self.userSettings.outgoingHealFontSize = 0.8
	self.userSettings.outgoingCritHealFontSize = 0.9
	self.userSettings.outgoingHealDuration = 2
	self.userSettings.outgoingCritHealDuration = 2
	self.userSettings.outgoingHealFontColor = "b0ff6a"
	self.userSettings.outgoingCritHealFontColor = "cdffa0"
	self.userSettings.outgoingCritHealFlash = 1.75
	self.userSettings.outgoingHealFlashColor = "ffffff"

	self.userSettings.incomingDamageDisable = 0
	self.userSettings.incomingShieldDamageDisable = 0
	self.userSettings.incomingDamageFont = "CRB_FloaterLarge"
	self.userSettings.incomingCritDamageFont = "CRB_FloaterLarge"
	self.userSettings.incomingDamageFontSize = 0.8
	self.userSettings.incomingCritDamageFontSize = 1.2
	self.userSettings.incomingDamageDuration = 0.55
	self.userSettings.incomingCritDamageDuration = 0.75
	self.userSettings.incomingDamageFontColor = "f8f3d7"
	self.userSettings.incomingCritDamageFontColor = "ffab3d"
	self.userSettings.incomingCritDamageFlash = 1.75
	self.userSettings.incomingDamageFlashColor = "ffffff"

	self.userSettings.incomingHealDisable = 0
	self.userSettings.incomingHealMinimumShown = 0
	self.userSettings.incomingHealFont = "CRB_FloaterLarge"
	self.userSettings.incomingCritHealFont = "CRB_FloaterLarge"
	self.userSettings.incomingHealFontSize = 0.8
	self.userSettings.incomingCritHealFontSize = 1.2
	self.userSettings.incomingHealDuration = 0.55
	self.userSettings.incomingCritHealDuration = 0.75
	self.userSettings.incomingHealFontColor = "b0ff6a"
	self.userSettings.incomingCritHealFontColor = "c6ff94"
	self.userSettings.incomingCritHealFlash = 0.75
	self.userSettings.incomingHealFlashColor = "ffffff"
	
	self.userSettings.ccStatePlayerFontColor = "ff2b2b"
	self.userSettings.ccStateEnemyFontColor = "ffe691"
	self.userSettings.ccStateFont = "CRB_FloaterLarge"
	self.userSettings.ccStatePlayerFontSize = 1
	self.userSettings.ccStateEnemyFontSize = 1
	self.userSettings.ccStatePlayerFontDuration = 2
	self.userSettings.ccStateEnemyFontDuration = 2
	self.userSettings.splitIncoming = 0
	self.userSettings.swapIncoming = 0
	self.userSettings.mergeIncoming = 0
	self.userSettings.splitOutgoing = 0
	self.userSettings.swapOutgoing = 0
	self.userSettings.mergeOutgoing = 0
	self.userSettings.hideSpellCastFail = 0
	self.userSettings.CriticalHitMarker = "*"
	self.userSettings.invertMergeIncoming = 0
	self.userSettings.invertMergeOutgoing = 0
	self.userSettings.sCombatTextAnchor = CombatFloater.CodeEnumFloaterLocation.Head

	--TODO SetDefaultValues
	self:LoadUserSettings()
end

-- Load Options

function YetAnotherSCT:LoadUserSettings()
	-- Load Values
	--General Settings
	self.wndMain:FindChild("CCStatePlayerTextSize"):SetText(self.userSettings.ccStatePlayerFontSize)
	self.wndMain:FindChild("CCStateEnemyTextSize"):SetText(self.userSettings.ccStateEnemyFontSize)
	self.wndMain:FindChild("CCStatePlayerTextDuration"):SetText(self.userSettings.ccStatePlayerFontDuration)
	self.wndMain:FindChild("CCStateEnemyTextDuration"):SetText(self.userSettings.ccStateEnemyFontDuration)
	self.wndMain:FindChild("CriticalHitMarker"):SetText(self.userSettings.CriticalHitMarker)
	--CheckBox
	local sI = tonumber(self.userSettings.splitIncoming)
	if  sI == 0 then
		self.wndMain:FindChild("SplitIncoming"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("SplitIncoming"):SetCheck(true)
	end
	
	local sO = tonumber(self.userSettings.splitOutgoing)
	if  sO == 0 then
		self.wndMain:FindChild("SplitOutgoing"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("SplitOutgoing"):SetCheck(true)
	end
	
	local hS = tonumber(self.userSettings.hideSpellCastFail)
	if  hS == 0 then
		self.wndMain:FindChild("SpellCastFail"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("SpellCastFail"):SetCheck(true)
	end

	local swapI = tonumber(self.userSettings.swapIncoming)
	if  swapI == 0 then
		self.wndMain:FindChild("SwapIncoming"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("SwapIncoming"):SetCheck(true)
	end

	local swapO = tonumber(self.userSettings.swapOutgoing)
	if  swapO == 0 then
		self.wndMain:FindChild("SwapOutgoing"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("SwapOutgoing"):SetCheck(true)
	end

	local mI = tonumber(self.userSettings.mergeIncoming)
	if  mI == 0 then
		self.wndMain:FindChild("MergeIncoming"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("MergeIncoming"):SetCheck(true)
	end

	local mO = tonumber(self.userSettings.mergeOutgoing)
	if  mO == 0 then
		self.wndMain:FindChild("MergeOutgoing"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("MergeOutgoing"):SetCheck(true)
	end

	local invertMI = tonumber(self.userSettings.invertMergeIncoming)
	if  invertMI == 0 then
		self.wndMain:FindChild("InvertMergedIncoming"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("InvertMergedIncoming"):SetCheck(true)
	end

	local invertMO = tonumber(self.userSettings.invertMergeOutgoing)
	if  invertMO == 0 then
		self.wndMain:FindChild("InvertMergedOutgoing"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("InvertMergedOutgoing"):SetCheck(true)
	end
	
	ccStatePlayerColorAsCColor = self:Hex_To_CColor(self.userSettings.ccStatePlayerFontColor)
	ccStateEnemyColorAsCColor = self:Hex_To_CColor(self.userSettings.ccStateEnemyFontColor)
	self.wndMain:FindChild("label_102"):SetTextColor("ff"..self.userSettings.ccStatePlayerFontColor)
	self.wndMain:FindChild("label_103"):SetTextColor("ff"..self.userSettings.ccStateEnemyFontColor)
	
	-- Outgoing Damage
	local oDD = tonumber(self.userSettings.outgoingDamageDisable)
	if  oDD == 0 then
		self.wndMain:FindChild("DisableOutgoingDamage"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("DisableOutgoingDamage"):SetCheck(true)
	end
	self.wndMain:FindChild("ODamageMinimumShown"):SetText(self.userSettings.outgoingDamageMinimumShown)
	self.wndMain:FindChild("ODamageTextSize"):SetText(self.userSettings.outgoingDamageFontSize)
	self.wndMain:FindChild("ODamageTextDuration"):SetText(self.userSettings.outgoingDamageDuration)
	self.wndMain:FindChild("ODamageCritTextSize"):SetText(self.userSettings.outgoingCritDamageFontSize)
	self.wndMain:FindChild("ODamageCritTextDuration"):SetText(self.userSettings.outgoingCritDamageDuration)
	self.wndMain:FindChild("ODamageFlashTextSize"):SetText(self.userSettings.outgoingCritDamageFlash)
	self.wndMain:FindChild("ODTF"):SetTextColor("ff"..self.userSettings.outgoingDamageFontColor)
	self.wndMain:FindChild("ODCTF"):SetTextColor("ff"..self.userSettings.outgoingCritDamageFontColor)
	self.wndMain:FindChild("ODCTF"):SetFont(self.userSettings.outgoingCritDamageFont)
	self.wndMain:FindChild("ODTF"):SetFont(self.userSettings.outgoingDamageFont)
	outgoingDamageColorAsCColor = self:Hex_To_CColor(self.userSettings.outgoingDamageFontColor)
	outgoingCritColorAsCColor = self:Hex_To_CColor(self.userSettings.outgoingCritDamageFontColor)
	
	-- Outgoing Shield Damage
	local oSDD = tonumber(self.userSettings.outgoingShieldDamageDisable)
	if oSDD == 0 then
		self.wndMain:FindChild("DisableOutgoingShieldDamage"):SetCheck(false)
	else
		self.wndMain:FindChild("DisableOutgoingShieldDamage"):SetCheck(true)
	end

	--Outgoing Heal
	local oHD = tonumber(self.userSettings.outgoingHealDisable)
	if  oHD == 0 then
		self.wndMain:FindChild("DisableOutgoingHealing"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("DisableOutgoingHealing"):SetCheck(true)
	end
	self.wndMain:FindChild("OHealTextSize"):SetText(self.userSettings.outgoingHealFontSize)
	self.wndMain:FindChild("OHealTextDuration"):SetText(self.userSettings.outgoingHealDuration)
	self.wndMain:FindChild("OHealCritTextSize"):SetText(self.userSettings.outgoingCritHealFontSize)
	self.wndMain:FindChild("OHealCritTextDuration"):SetText(self.userSettings.outgoingCritHealDuration)
	self.wndMain:FindChild("OHealFlashTextSize"):SetText(self.userSettings.outgoingCritHealFlash)
	self.wndMain:FindChild("OHTF"):SetTextColor("ff"..self.userSettings.outgoingHealFontColor)
	self.wndMain:FindChild("OHCTF"):SetTextColor("ff"..self.userSettings.outgoingCritHealFontColor)
	self.wndMain:FindChild("OHCTF"):SetFont(self.userSettings.outgoingCritHealFont)
	self.wndMain:FindChild("OHTF"):SetFont(self.userSettings.outgoingHealFont)
	self.wndMain:FindChild("OHealMinimumShown"):SetText(self.userSettings.outgoingHealMinimumShown)
	outgoingHealColorAsCColor = self:Hex_To_CColor(self.userSettings.outgoingHealFontColor)
	outgoingCritHealColorAsCColor = self:Hex_To_CColor(self.userSettings.outgoingCritHealFontColor)

	--Incoming Damage
	local iDD = tonumber(self.userSettings.incomingDamageDisable)
	if  iDD == 0 then
		self.wndMain:FindChild("DisableIncomingDamage"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("DisableIncomingDamage"):SetCheck(true)
	end
	self.wndMain:FindChild("IDamageTextSize"):SetText(self.userSettings.incomingDamageFontSize)
	self.wndMain:FindChild("IDamageTextDuration"):SetText(self.userSettings.incomingDamageDuration)
	self.wndMain:FindChild("IDamageCritTextSize"):SetText(self.userSettings.incomingCritDamageFontSize)
	self.wndMain:FindChild("IDamageCritTextDuration"):SetText(self.userSettings.incomingCritDamageDuration)
	self.wndMain:FindChild("IDamageFlashTextSize"):SetText(self.userSettings.incomingCritDamageFlash)
	self.wndMain:FindChild("IDTF"):SetTextColor("ff"..self.userSettings.incomingDamageFontColor)
	self.wndMain:FindChild("IDCTF"):SetTextColor("ff"..self.userSettings.incomingCritDamageFontColor)
	self.wndMain:FindChild("IDCTF"):SetFont(self.userSettings.incomingCritDamageFont)
	self.wndMain:FindChild("IDTF"):SetFont(self.userSettings.incomingDamageFont)
	incomingDamageColorAsCColor = self:Hex_To_CColor(self.userSettings.incomingDamageFontColor)
	incomingCritColorAsCColor = self:Hex_To_CColor(self.userSettings.incomingCritDamageFontColor)

		-- Incoming Shield Damage
	local iSDD = tonumber(self.userSettings.incomingShieldDamageDisable)
	if iSDD == 0 then
		self.wndMain:FindChild("DisableIncomingShieldDamage"):SetCheck(false)
	else
		self.wndMain:FindChild("DisableIncomingShieldDamage"):SetCheck(true)
	end

	--Incoming Heal
	local iHD = tonumber(self.userSettings.incomingHealDisable)
	if  iHD == 0 then
		self.wndMain:FindChild("DisableIncomingHealing"):SetCheck(false)
	else 
	 	self.wndMain:FindChild("DisableIncomingHealing"):SetCheck(true)
	end
	self.wndMain:FindChild("IHealTextSize"):SetText(self.userSettings.incomingHealFontSize)
	self.wndMain:FindChild("IHealTextDuration"):SetText(self.userSettings.incomingHealDuration)
	self.wndMain:FindChild("IHealCritTextSize"):SetText(self.userSettings.incomingCritHealFontSize)
	self.wndMain:FindChild("IHealCritTextDuration"):SetText(self.userSettings.incomingCritHealDuration)
	self.wndMain:FindChild("IHealFlashTextSize"):SetText(self.userSettings.incomingCritHealFlash)
	self.wndMain:FindChild("IHTF"):SetTextColor("ff"..self.userSettings.incomingHealFontColor)
	self.wndMain:FindChild("IHCTF"):SetTextColor("ff"..self.userSettings.incomingCritHealFontColor)
	self.wndMain:FindChild("IHCTF"):SetFont(self.userSettings.incomingCritHealFont)
	self.wndMain:FindChild("IHTF"):SetFont(self.userSettings.incomingHealFont)
	self.wndMain:FindChild("IHealMinimumShown"):SetText(self.userSettings.incomingHealMinimumShown)
	incomingHealColorAsCColor = self:Hex_To_CColor(self.userSettings.incomingHealFontColor)
	incomingCritHealColorAsCColor = self:Hex_To_CColor(self.userSettings.incomingCritHealFontColor)
end

function YetAnotherSCT:OnYetAnotherSCTOn(cmd, args)
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "SettingsForm", nil, self)
	self.wndSettingsList = Apollo.LoadForm(self.xmlDoc, "SettingsList", self.wndMain:FindChild("Window_MainSettings"), self)
	self.wndGeneralSettings = Apollo.LoadForm(self.xmlDoc,"GeneralSettings",self.wndSettingsList, self)
	self.wndIncomingDamageSettings = Apollo.LoadForm(self.xmlDoc,"Incoming_DamageSettings",self.wndSettingsList, self)
	self.wndOutgoingDamageSettings = Apollo.LoadForm(self.xmlDoc,"Outgoing_DamageSettings",self.wndSettingsList, self)
	self.wndIncomingHealSettings = Apollo.LoadForm(self.xmlDoc,"Incoming_HealSettings",self.wndSettingsList, self)
	self.wndOutgoingHealSettings = Apollo.LoadForm(self.xmlDoc,"Outgoing_HealSettings",self.wndSettingsList, self)
	self.wndSettingsList:ArrangeChildrenVert()
	
	self:LoadFonts()	
	self:LoadUserSettings()
	self.wndMain:Show(true)
	if args == string.lower("align") then
		if GameLib.GetPlayerUnit():GetName() == "Thoughtcrime" then 
			self.wndSettingsList:Show(false)
			self.wndMain:Show(false)
		end
	end
end

function YetAnotherSCT:LoadFonts()
	local fonts = Apollo.GetGameFonts()
	local fontSelectList = self.wndSettingsList:FindChild("ODamageFont_CB")
	local critFontSelectList = self.wndSettingsList:FindChild("ODamageCritFont_CB")
	
	local healFontSelectList = self.wndSettingsList:FindChild("OHealFont_CB")
	local critHealFontSelectList = self.wndSettingsList:FindChild("OHealCritFont_CB")
	
	local ifontSelectList = self.wndSettingsList:FindChild("IDamageFont_CB")
	local icritFontSelectList = self.wndSettingsList:FindChild("IDamageCritFont_CB")

	local ihealFontSelectList = self.wndSettingsList:FindChild("IHealFont_CB")
	local icritHealFontSelectList = self.wndSettingsList:FindChild("IHealCritFont_CB")
	
	local ccStateSelectList = self.wndSettingsList:FindChild("CCStateFont_CB")

	-- For own define Font Lists
	--for _, font in pairs(fontList) do
		--Damage
		--fontSelectList:AddItem(font)
	--end	
	
	for _, font in pairs(Apollo.GetGameFonts()) do
		--Damage
		fontSelectList:AddItem(font.name)
		critFontSelectList:AddItem(font.name)
		--fontSelectList:AddItem(font.name.." : "..font.face.." : "..font.size)
		--Heal
		healFontSelectList:AddItem(font.name)
		critHealFontSelectList:AddItem(font.name)
		--Incoming Damage
		ifontSelectList:AddItem(font.name)
		icritFontSelectList:AddItem(font.name)
		--Incoming Heal
		ihealFontSelectList:AddItem(font.name)
		icritHealFontSelectList:AddItem(font.name)
		--General
		ccStateSelectList:AddItem(font.name)
	end	
	
	--Damage
	critFontSelectList:SelectItemByText(self.userSettings.outgoingCritDamageFont)
	fontSelectList:SelectItemByText(self.userSettings.outgoingDamageFont)
	self.wndSettingsList:FindChild("ODCTF"):SetFont(self.userSettings.outgoingCritDamageFont)
	self.wndSettingsList:FindChild("ODTF"):SetFont(self.userSettings.outgoingDamageFont)
	
	--Heal
	critHealFontSelectList:SelectItemByText(self.userSettings.outgoingCritHealFont)
	healFontSelectList:SelectItemByText(self.userSettings.outgoingHealFont)
	self.wndSettingsList:FindChild("OHCTF"):SetFont(self.userSettings.outgoingCritHealFont)
	self.wndSettingsList:FindChild("OHTF"):SetFont(self.userSettings.outgoingHealFont)
	
	--Incoming Damage
	icritFontSelectList:SelectItemByText(self.userSettings.incomingCritDamageFont)
	ifontSelectList:SelectItemByText(self.userSettings.incomingDamageFont)
	self.wndSettingsList:FindChild("IDCTF"):SetFont(self.userSettings.incomingCritDamageFont)
	self.wndSettingsList:FindChild("IDTF"):SetFont(self.userSettings.incomingDamageFont)

	--Incoming Heal
	icritHealFontSelectList:SelectItemByText(self.userSettings.incomingCritHealFont)
	ihealFontSelectList:SelectItemByText(self.userSettings.incomingHealFont)
	self.wndSettingsList:FindChild("IHCTF"):SetFont(self.userSettings.incomingCritHealFont)
	self.wndSettingsList:FindChild("IHTF"):SetFont(self.userSettings.incomingHealFont)
	
	--General
	ccStateSelectList:SelectItemByText(self.userSettings.ccStateFont)
	self.wndSettingsList:FindChild("CCStateTextTF"):SetFont(self.userSettings.ccStateFont)
end

-- END
function YetAnotherSCT:GetAsyncLoadStatus()
	if g_InterfaceOptionsLoaded then
		self:Initialize()
		return Apollo.AddonLoadStatus.Loaded
	end
	return Apollo.AddonLoadStatus.Loading
end

function YetAnotherSCT:Initialize()
	Apollo.RegisterEventHandler("LootedMoney", 								"OnLootedMoney", self)
	Apollo.RegisterEventHandler("SpellCastFailed", 							"OnSpellCastFailed", self)
	Apollo.RegisterEventHandler("DamageOrHealingDone",				 		"OnDamageOrHealing", self)
	Apollo.RegisterEventHandler("CombatMomentum", 							"OnCombatMomentum", self)
	Apollo.RegisterEventHandler("ExperienceGained", 						"OnExperienceGained", self)	-- UI_XPChanged ?
	Apollo.RegisterEventHandler("ElderPointsGained", 						"OnElderPointsGained", self)
	Apollo.RegisterEventHandler("UpdatePathXp", 							"OnPathExperienceGained", self)
	Apollo.RegisterEventHandler("AttackMissed", 							"OnMiss", self)
	Apollo.RegisterEventHandler("SubZoneChanged", 							"OnSubZoneChanged", self)
	Apollo.RegisterEventHandler("RealmBroadcastTierMedium", 				"OnRealmBroadcastTierMedium", self)
	Apollo.RegisterEventHandler("GenericError", 							"OnGenericError", self)
	Apollo.RegisterEventHandler("PrereqFailureMessage",					 	"OnPrereqFailed", self)
	Apollo.RegisterEventHandler("GenericFloater", 							"OnGenericFloater", self)
	Apollo.RegisterEventHandler("UnitEvaded", 								"OnUnitEvaded", self)
	Apollo.RegisterEventHandler("QuestShareFloater", 						"OnQuestShareFloater", self)
	Apollo.RegisterEventHandler("CountdownTick", 							"OnCountdownTick", self)
	Apollo.RegisterEventHandler("TradeSkillFloater",				 		"OnTradeSkillFloater", self)
	Apollo.RegisterEventHandler("FactionFloater", 							"OnFactionFloater", self)
	Apollo.RegisterEventHandler("CombatLogTransference", 					"OnCombatLogTransference", self)
	Apollo.RegisterEventHandler("CombatLogCCState", 						"OnCombatLogCCState", self)
	Apollo.RegisterEventHandler("ActionBarNonSpellShortcutAddFailed", 		"OnActionBarNonSpellShortcutAddFailed", self)
	Apollo.RegisterEventHandler("GenericEvent_GenericError",				"OnGenericError", self)
	Apollo.RegisterEventHandler("ShowSCTMenu", 					"OnYetAnotherSCTOn", self)
	Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
	--Apollo.RegisterEventHandler("CombatLogDamage", 					"OnCombatLogDamage", self)
	
		-- set the max count of floater text
	CombatFloater.SetMaxFloaterCount(500)
	CombatFloater.SetMaxFloaterPerUnitCount(500)

	-- loading digit sprite sets
	Apollo.LoadSprites("UI\\SpriteDocs\\CRB_NumberFloaters.xml")
	Apollo.LoadSprites("UI\\SpriteDocs\\CRB_CritNumberFloaters.xml")

	self.iDigitSpriteSetNormal 		= CombatFloater.AddDigitSpriteSet("sprFloater_Normal")
	self.iDigitSpriteSetVulnerable 	= CombatFloater.AddDigitSpriteSet("sprFloater_Vulnerable")
	self.iDigitSpriteSetCritical 	= CombatFloater.AddDigitSpriteSet("sprFloater_Critical")
	self.iDigitSpriteSetHeal 		= CombatFloater.AddDigitSpriteSet("sprFloater_Heal")
	self.iDigitSpriteSetShields 	= CombatFloater.AddDigitSpriteSet("sprFloater_Shields")
	self.iDigitSpriteSetShieldsDown = CombatFloater.AddDigitSpriteSet("sprFloater_NormalNoShields")

	-- add bg sprite for text
	self.iFloaterBackerCritical 	= CombatFloater.AddTextBGSprite("sprFloater_BackerCritical")
	self.iFloaterBackerNormal 		= CombatFloater.AddTextBGSprite("sprFloater_BackerNormal")
	self.iFloaterBackerVulnerable 	= CombatFloater.AddTextBGSprite("sprFloater_BackerVulnerable")
	self.iFloaterBackerHeal 		= CombatFloater.AddTextBGSprite("sprFloater_BackerHeal")
	self.iFloaterBackerShieldsDown 	= CombatFloater.AddTextBGSprite("sprFloater_BackerNormalNoShields")
	
	-- float text queue for delayed text
	self.tDelayedFloatTextQueue = Queue:new()
	self.iTimerIndex = 1

	self.fLastDamageTime = GameLib.GetGameTime()
	self.fLastOffset = 0

	self.bSpellErrorMessages = g_InterfaceOptions.Carbine.bSpellErrorMessages
	
	--if GameLib.GetPlayerUnit() then self:OptionsChanged() end
end

function YetAnotherSCT:OnOptionsUpdated()
	self.bSpellErrorMessages = g_InterfaceOptions.Carbine.bSpellErrorMessages
end

function YetAnotherSCT:GetDefaultTextOption()
	local tTextOption =
	{
		strFontFace 				= "CRB_FloaterLarge",
		fDuration 					= 2,
		fScale 						= 0.9,
		fExpand 					= 1,
		fVibrate 					= 0,
		fSpinAroundRadius 			= 0,
		fFadeInDuration 			= 0,
		fFadeOutDuration 			= 0,
		fVelocityDirection 			= 0,
		fVelocityMagnitude 			= 0,
		fAccelDirection 			= 0,
		fAccelMagnitude 			= 0,
		fEndHoldDuration 			= 0,
		eLocation 					= self.userSettings.sCombatTextAnchor,
		fOffsetDirection 			= 0,
		fOffset 					= 0,
		eCollisionMode 				= CombatFloater.CodeEnumFloaterCollisionMode.Horizontal,
		fExpandCollisionBoxWidth 	= 1,
		fExpandCollisionBoxHeight 	= 1,
		nColor 						= 0xFFFFFF,
		iUseDigitSpriteSet 			= nil,
		bUseScreenPos 				= false,
		bShowOnTop 					= false,
		fRotation 					= 0,
		fDelay 						= 0,
		nDigitSpriteSpacing 		= 0,
	}
	return tTextOption
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnSpellCastFailed( eMessageType, eCastResult, unitTarget, unitSource, strMessage )
	if unitTarget == nil or not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end
	
	local hS = tonumber(self.userSettings.hideSpellCastFail)
	if  hS == 1 then
		return
	end
	
	-- modify the text to be shown
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.bUseScreenPos = true
	tTextOption.fOffset = -80
	tTextOption.nColor = 0xFFFFFF
	tTextOption.strFontFace = "CRB_Interface16_BO"
	tTextOption.bShowOnTop = true
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,		fScale = 1.5,	fAlpha = 0.8,},
		[2] = {fTime = 0.1,		fScale = 1,	fAlpha = 0.8,},
		[3] = {fTime = 1.1,		fScale = 1,	fAlpha = 0.8,	fVelocityDirection = 0,},
		[4] = {fTime = 1.3,		fScale = 1,	fAlpha = 0.0,	fVelocityDirection = 0,},
	}

	if self.bSpellErrorMessages then -- This is set by interface options
		self:RequestShowTextFloater(LuaEnumMessageType.SpellCastError, unitSource, strMessage, tTextOption)
	end
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnSubZoneChanged(idZone, strZoneName)
	-- if you're in a taxi, don't show zone change
	if GameLib.GetPlayerTaxiUnit() then
		return
	end

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.bUseScreenPos = true
	tTextOption.fOffset = -280
	tTextOption.nColor = 0x80ffff
	tTextOption.strFontFace = "CRB_HeaderGigantic_O"
	tTextOption.bShowOnTop = true
	tTextOption.arFrames=
	{
		[1] = {fTime = 0,	fAlpha = 0,		fScale = .8,},
		[2] = {fTime = 0.6, fAlpha = 1.0,},
		[3] = {fTime = 4.6,	fAlpha = 1.0,},
		[4] = {fTime = 5.2, fAlpha = 0,},
	}

	self:RequestShowTextFloater( LuaEnumMessageType.ZoneName, GameLib.GetControlledUnit(), strZoneName, tTextOption )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnRealmBroadcastTierMedium(strMessage)
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.bUseScreenPos = true
	tTextOption.fOffset = -180
	tTextOption.nColor = 0x80ffff
	tTextOption.strFontFace = "CRB_HeaderGigantic_O"
	tTextOption.bShowOnTop = true
	tTextOption.arFrames=
	{
		[1] = {fTime = 0,	fAlpha = 0,		fScale = .8,},
		[2] = {fTime = 0.6, fAlpha = 1.0,},
		[3] = {fTime = 4.6,	fAlpha = 1.0,},
		[4] = {fTime = 5.2, fAlpha = 0,},
	}

	self:RequestShowTextFloater( LuaEnumMessageType.RealmBroadcastTierMedium, GameLib.GetControlledUnit(), strMessage, tTextOption )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnActionBarNonSpellShortcutAddFailed()
	local strMessage = Apollo.GetString("FloatText_ActionBarAddFail")
	self:OnSpellCastFailed( LuaEnumMessageType.GenericPlayerInvokedError, nil, GameLib.GetControlledUnit(), GameLib.GetControlledUnit(), strMessage )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnGenericError(eError, strMessage)
	local arExciseListItem =  -- index is enums to respond to, value is optional (UNLOCALIZED) replacement string (otherwise the passed string is used)
	{
		[GameLib.CodeEnumGenericError.DbFailure] 						= "",
		[GameLib.CodeEnumGenericError.Item_BadId] 						= "",
		[GameLib.CodeEnumGenericError.Vendor_StackSize] 				= "",
		[GameLib.CodeEnumGenericError.Vendor_SoldOut] 					= "",
		[GameLib.CodeEnumGenericError.Vendor_UnknownItem] 				= "",
		[GameLib.CodeEnumGenericError.Vendor_FailedPreReq] 				= "",
		[GameLib.CodeEnumGenericError.Vendor_NotAVendor] 				= "",
		[GameLib.CodeEnumGenericError.Vendor_TooFar] 					= "",
		[GameLib.CodeEnumGenericError.Vendor_BadItemRec] 				= "",
		[GameLib.CodeEnumGenericError.Vendor_NotEnoughToFillQuantity] 	= "",
		[GameLib.CodeEnumGenericError.Vendor_NotEnoughCash] 			= "",
		[GameLib.CodeEnumGenericError.Vendor_UniqueConstraint] 			= "",
		[GameLib.CodeEnumGenericError.Vendor_ItemLocked] 				= "",
		[GameLib.CodeEnumGenericError.Vendor_IWontBuyThat] 				= "",
		[GameLib.CodeEnumGenericError.Vendor_NoQuantity] 				= "",
		[GameLib.CodeEnumGenericError.Vendor_BagIsNotEmpty] 			= "",
		[GameLib.CodeEnumGenericError.Vendor_CuratorOnlyBuysRelics] 	= "",
		[GameLib.CodeEnumGenericError.Vendor_CannotBuyRelics] 			= "",
		[GameLib.CodeEnumGenericError.Vendor_NoBuyer] 					= "",
		[GameLib.CodeEnumGenericError.Vendor_NoVendor] 					= "",
		[GameLib.CodeEnumGenericError.Vendor_Buyer_NoActionCC] 			= "",
		[GameLib.CodeEnumGenericError.Vendor_Vendor_NoActionCC] 		= "",
		[GameLib.CodeEnumGenericError.Vendor_Vendor_Disposition] 		= "",
	}

	if arExciseListItem[eError] then -- list of errors we don't want to show floaters for
		return
	end

	self:OnSpellCastFailed( LuaEnumMessageType.GenericPlayerInvokedError, nil, GameLib.GetControlledUnit(), GameLib.GetControlledUnit(), strMessage )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnPrereqFailed(strMessage)
	self:OnGenericError(nil, strMessage)
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnGenericFloater(unitTarget, strMessage)
	-- modify the text to be shown
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fDuration = 2
	tTextOption.bUseScreenPos = true
	tTextOption.fOffset = 0
	tTextOption.nColor = 0x00FFFF
	tTextOption.strFontFace = "CRB_HeaderLarge_O"
	tTextOption.bShowOnTop = true

	CombatFloater.ShowTextFloater( unitTarget, strMessage, tTextOption )
end

function YetAnotherSCT:OnUnitEvaded(unitSource, unitTarget, eReason, strMessage)
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 1.0
	tTextOption.fDuration = 2
	tTextOption.nColor = 0xbaeffb
	tTextOption.strFontFace = "CRB_FloaterSmall"
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.IgnoreCollision
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = -0.8
	tTextOption.fOffsetDirection = 0

	tTextOption.arFrames =
	{
		[1] = {fTime = 0,		fScale = 2.0,	fAlpha = 1.0,	nColor = 0xFFFFFF,},
		[2] = {fTime = 0.15,	fScale = 0.9,	fAlpha = 1.0,},
		[3] = {fTime = 1.1,		fScale = 0.9,	fAlpha = 1.0,	fVelocityDirection = 0,	fVelocityMagnitude = 5,},
		[4] = {fTime = 1.3,						fAlpha = 0.0,	fVelocityDirection = 0,},
	}

	CombatFloater.ShowTextFloater( unitSource, strMessage, tTextOption )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnAlertTitle(strMessage)
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fDuration = 2
	tTextOption.fFadeInDuration = 0.2
	tTextOption.fFadeOutDuration = 0.5
	tTextOption.fVelocityMagnitude = 0.2
	tTextOption.fOffset = 0.2
	tTextOption.nColor = 0xFFFF00
	tTextOption.strFontFace = "CRB_HeaderLarge_O"
	tTextOption.bShowOnTop = true
	tTextOption.fScale = 1
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor

	CombatFloater.ShowTextFloater( GameLib.GetControlledUnit(), strMessage, tTextOption )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnQuestShareFloater(unitTarget, strMessage)
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fDuration = 2
	tTextOption.fFadeInDuration = 0.2
	tTextOption.fFadeOutDuration = 0.5
	tTextOption.fVelocityMagnitude = 0.2
	tTextOption.fOffset = 0.2
	tTextOption.nColor = 0xFFFF00
	tTextOption.strFontFace = "CRB_HeaderLarge_O"
	tTextOption.bShowOnTop = true
	tTextOption.fScale = 1
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor

	CombatFloater.ShowTextFloater( unitTarget, strMessage, tTextOption )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnCountdownTick(strMessage)
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fDuration = 1
	tTextOption.fFadeInDuration = 0.2
	tTextOption.fFadeOutDuration = 0.2
	tTextOption.fVelocityMagnitude = 0.2
	tTextOption.fOffset = 0.2
	tTextOption.nColor = 0x00FF00
	tTextOption.strFontFace = "CRB_HeaderLarge_O"
	tTextOption.bShowOnTop = true
	tTextOption.fScale = 1
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor

	CombatFloater.ShowTextFloater( GameLib.GetControlledUnit(), strMessage, tTextOption )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnDeath()
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fDuration = 2
	tTextOption.fFadeOutDuration = 1.5
	tTextOption.fScale = 1.2
	tTextOption.nColor = 0xFFFFFF
	tTextOption.strFontFace = "CRB_HeaderLarge_O"
	tTextOption.bShowOnTop = true
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = 1

	CombatFloater.ShowTextFloater( GameLib.GetControlledUnit(), Apollo.GetString("Player_Incapacitated"), tTextOption )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnCombatLogTransference(tEventArgs)
	local bCritical = tEventArgs.eCombatResult == GameLib.CodeEnumCombatResult.Critical
	if tEventArgs.unitCaster == GameLib.GetControlledUnit() then -- Target does the transference to the source
		self:OnDamageOrHealing( tEventArgs.unitCaster, tEventArgs.unitTarget, tEventArgs.eDamageType, math.abs(tEventArgs.nDamageAmount), 0, 0, bCritical )
	else -- creature taking damage
		self:OnPlayerDamageOrHealing( tEventArgs.unitTarget, tEventArgs.eDamageType, math.abs(tEventArgs.nDamageAmount), 0, 0, bCritical )
	end

	-- healing data is stored in a table where each subtable contains a different vital that was healed
	for _, tHeal in ipairs(tEventArgs.tHealData) do
		if tEventArgs.unitCaster == GameLib.GetPlayerUnit() then -- source recieves the transference from the taker
			self:OnPlayerDamageOrHealing( tEventArgs.unitCaster, tEventArgs.eDamageType, math.abs(tHeal.nHealAmount), 0, 0, bCritical )
		else
			self:OnDamageOrHealing(tEventArgs.unitTarget, tEventArgs.unitCaster, tEventArgs.eDamageType, math.abs(tHeal.nHealAmount), 0, 0, bCritical )
		end
	end
end

--TODO: Helper Testen

-----------------------------------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------------------------------

--function YetAnotherSCT:OnCombatLogDamage(tEventArgs)
	
--	local tTextInfo = self:HelperCasterTargetSpell(tEventArgs, true, true, true)
--	local spell = tEventArgs.splCallingSpell
--	self.spellName = tTextInfo.strSpellName
--	self.spellIcon = spell:GetIcon()
	--Print(self.spellIcon)
	--Print("Player: "..tEventArgs.unitCaster:GetName().." Spell: "..tTextInfo.strSpellName.." Id: "..spell:GetId())
--end

function YetAnotherSCT:HelperCasterTargetSpell(tEventArgs, bTarget, bSpell, bColor)
	local tInfo =
	{
		strCaster = nil,
		strTarget = nil,
		strSpellName = nil,
		strColor = nil
	}

	tInfo.strCaster = self:HelperGetNameElseUnknown(tEventArgs.unitCaster)
	if tEventArgs.unitCasterOwner and tEventArgs.unitCasterOwner:GetName() then
		tInfo.strCaster = string.format("%s (%s)", tInfo.strCaster, tEventArgs.unitCasterOwner:GetName())
	end

	if bTarget then
		tInfo.strTarget = self:HelperGetNameElseUnknown(tEventArgs.unitTarget)
		if tEventArgs.unitTargetOwner and tEventArgs.unitTargetOwner:GetName() then
			tInfo.strTarget = string.format("%s (%s)", tInfo.strTarget, tEventArgs.unitTargetOwner:GetName())
		end

		if bColor then
			tInfo.strColor = self:HelperPickColor(tEventArgs)
		end
	end		
	
	if bSpell then
		tInfo.strSpellName = self:HelperGetNameElseUnknown(tEventArgs.splCallingSpell) --GetSpellName
	end

	return tInfo
end

function YetAnotherSCT:HelperGetNameElseUnknown(nArg)
	if nArg and nArg:GetName() then
		return nArg:GetName()
	end
	return Apollo.GetString("CombatLog_SpellUnknown")
end

function YetAnotherSCT:HelperDamageColor(nArg)
	if nArg and self.tTypeColor[nArg] then
		return self.tTypeColor[nArg]
	end
	return kstrColorCombatLogUNKNOWN
end

function YetAnotherSCT:HelperPickColor(tEventArgs)
	if not self.unitPlayer then
		self.unitPlayer = GameLib.GetControlledUnit()
	end

	-- Try player matching first
	if tEventArgs.unitCaster == self.unitPlayer then
		return kstrColorCombatLogOutgoing
	elseif tEventArgs.unitTarget == self.unitPlayer and tEventArgs.splCallingSpell and tEventArgs.splCallingSpell:IsBeneficial() then
		return kstrColorCombatLogIncomingGood
	elseif tEventArgs.unitTarget == self.unitPlayer then
		return kstrColorCombatLogIncomingBad
	end

	-- Try pets second
	for idx, tPetUnit in pairs(self.tPetUnits) do
		if tEventArgs.unitCaster == tPetUnit then
			return kstrColorCombatLogOutgoing
		elseif tEventArgs.unitTarget == tPetUnit and tEventArgs.splCallingSpell and tEventArgs.splCallingSpell:IsBeneficial() then
			return kstrColorCombatLogIncomingGood
		elseif tEventArgs.unitTarget == tPetUnit then
			return kstrColorCombatLogIncomingBad
		end
	end

	return kstrColorCombatLogUNKNOWN
end


---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnCombatMomentum( eMomentumType, nCount, strText )
	-- Passes: type enum, player's total count for that bonus type, string combines these things (ie. "3 Evade")
	local arMomentumStrings =
	{
		[CombatFloater.CodeEnumCombatMomentum.Impulse] 				= "FloatText_Impulse",
		[CombatFloater.CodeEnumCombatMomentum.KillingPerformance] 	= "FloatText_KillPerformance",
		[CombatFloater.CodeEnumCombatMomentum.KillChain] 			= "FloatText_KillChain",
		[CombatFloater.CodeEnumCombatMomentum.Evade] 				= "FloatText_Evade",
		[CombatFloater.CodeEnumCombatMomentum.Interrupt] 			= "FloatText_Interrupt",
		[CombatFloater.CodeEnumCombatMomentum.CCBreak] 				= "FloatText_StateBreak",
	}

	if not Apollo.GetConsoleVariable("ui.showCombatFloater") or arMomentumStrings[eMomentumType] == nil  then
		return
	end

	local nBaseColor = 0x7eff8f
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.8
	tTextOption.fDuration = 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = 2.0
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = "CRB_FloaterSmall"
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,		nColor = 0xFFFFFF,		fAlpha = 0,		fVelocityDirection = 0,	fVelocityMagnitude = 1,		fScale = 1.25},
		[2] = {fTime = 0.15,							fAlpha = 1.0,	fVelocityDirection = 0,	fVelocityMagnitude = 1.5,		fScale = .75},
		[3] = {fTime = 0.5,		nColor = nBaseColor,},
		[4] = {fTime = 1.0,		nColor = nBaseColor,},
		[5] = {fTime = 1.1,		nColor = 0xFFFFFF,		fAlpha = 1.0,	fVelocityDirection 	= 0,	fVelocityMagnitude 	= 3,},
		[6] = {fTime = 1.3,		nColor 	= nBaseColor,	fAlpha 	= 0.0,},
	}

	local unitToAttachTo = GameLib.GetControlledUnit()
	local strMessage = String_GetWeaselString(Apollo.GetString(arMomentumStrings[eMomentumType]), nCount)
	if eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount == 2 then
		strMessage = Apollo.GetString("FloatText_DoubleKill")
		tTextOption.strFontFace = "CRB_FloaterMedium"
	elseif eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount == 3 then
		strMessage = Apollo.GetString("FloatText_TripleKill")
		tTextOption.strFontFace = "CRB_FloaterMedium"
	elseif eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount == 5 then
		strMessage = Apollo.GetString("FloatText_PentaKill")
		tTextOption.strFontFace = "CRB_FloaterHuge"
	elseif eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount > 5 then
		tTextOption.strFontFace = "CRB_FloaterHuge"
	end

	CombatFloater.ShowTextFloater(unitToAttachTo, strMessage, tTextOption)
end

function YetAnotherSCT:OnExperienceGained(eReason, unitTarget, strText, fDelay, nAmount)
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") or nAmount < 0 then
		return
	end

	local strFormatted = ""
	local eMessageType = LuaEnumMessageType.XPAwarded
	local unitToAttachTo = GameLib.GetControlledUnit() -- unitTarget potentially nil

	local tContent = {}
	tContent.eType = LuaEnumMessageType.XPAwarded
	tContent.nNormal = 0
	tContent.nRested = 0

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.8
	tTextOption.fDuration = 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = 1.0 -- GOTCHA: Different
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = "CRB_FloaterSmall"
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,			fAlpha = 0,		fVelocityDirection = 0,	fVelocityMagnitude = 1,		fScale = 1 },-- Default 0.8},
		[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = 0,	fVelocityMagnitude = 2,		fScale =  .75},
		[3] = {fTime = 0.5,	},
		[4] = {fTime = 1.0,	},
		[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= 0,	fVelocityMagnitude 	= 3,},
		[6] = {fTime = 1.3,			fAlpha 	= 0.0,},
	}

	-- GOTCHA: UpdateOrAddXpFloater will stomp on these text formats anyways (TODO REFACTOR)
	if eReason == CombatFloater.CodeEnumExpReason.KillPerformance or eReason == CombatFloater.CodeEnumExpReason.MultiKill or eReason == CombatFloater.CodeEnumExpReason.KillingSpree then
		return -- should not be delivered via the XP event
	elseif eReason == CombatFloater.CodeEnumExpReason.Rested then
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
		strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_RestXPGained"), nAmount)
		tContent.nRested = nAmount
	else
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
		strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_XPGained"), nAmount)
		tContent.nNormal = nAmount
	end

	self:RequestShowTextFloater(eMessageType, unitToAttachTo, strFormatted, tTextOption, fDelay, tContent)
end

function YetAnotherSCT:OnElderPointsGained(nAmount)
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") or nAmount < 0 then
		return
	end

	local tContent = {}
	tContent.eType = LuaEnumMessageType.XPAwarded
	tContent.nNormal = nAmount
	tContent.nRested = 0

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.8
	tTextOption.fDuration = 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = 2.0 -- GOTCHA: Different
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = "CRB_FloaterSmall"
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,			fAlpha = 0,		fVelocityDirection = 0,	fVelocityMagnitude = 1,		fScale = 1},
		[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = 0,	fVelocityMagnitude = 1.5,		fScale = .75},
		[3] = {fTime = 0.5,	},
		[4] = {fTime = 1.0,	},
		[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= 0,	fVelocityMagnitude 	= 3,},
		[6] = {fTime = 1.3,			fAlpha 	= 0.0,},
	}

	local eMessageType = LuaEnumMessageType.XPAwarded
	local unitToAttachTo = GameLib.GetControlledUnit()
	local strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_EPGained"), nAmount)

	self:RequestShowTextFloater(eMessageType, unitToAttachTo, strFormatted, tTextOption, 0, tContent)
end

function YetAnotherSCT:OnPathExperienceGained( nAmount, strText )
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end

	local eMessageType = LuaEnumMessageType.PathXp
	local unitToAttachTo = GameLib.GetControlledUnit()
	local strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_PathXP"), nAmount)

	local tContent =
	{
		eType = LuaEnumMessageType.PathXp,
		nAmount = nAmount,
	}

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.8
	tTextOption.fDuration = 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = 2.0 -- GOTCHA: Different
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = "CRB_FloaterSmall"
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,			fAlpha = 0,		fVelocityDirection = 180,	fVelocityMagnitude = 1,		fScale = 1.25},
		[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = 180,	fVelocityMagnitude = 1.5,		fScale = .8},
		[3] = {fTime = 0.5,	},
		[4] = {fTime = 1.0,	},
		[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= 180,	fVelocityMagnitude 	= 3,},
		[6] = {fTime = 1.3,			fAlpha 	= 0.0,},
	}

	local unitToAttachTo = GameLib.GetControlledUnit() -- make unitToAttachTo to controlled unit because with the message system,
	self:RequestShowTextFloater( eMessageType, unitToAttachTo, strFormatted, tTextOption, 0, tContent )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnFactionFloater(unitTarget, strMessage, nAmount, strFactionName, idFaction) -- Reputation Floater
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") or strFactionName == nil or nAmount < 1 then
		return
	end

	local eMessageType = LuaEnumMessageType.ReputationIncrease
	local unitToAttachTo = unitTarget or GameLib.GetControlledUnit()
	local strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_Rep"), nAmount, strFactionName)

	local tContent = {}
	tContent.eType = LuaEnumMessageType.ReputationIncrease
	tContent.nAmount = nAmount
	tContent.idFaction = idFaction
	tContent.strName = strFactionName

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.8
	tTextOption.fDuration = 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = 2.0 -- GOTCHA: Extra Different
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = "CRB_FloaterSmall"
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,			fAlpha = 0,		fVelocityDirection = 180,	fVelocityMagnitude = 1,		fScale = 1},
		[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = 180,	fVelocityMagnitude = 1.5,		fScale = .75},
		[3] = {fTime = 0.5,	},
		[4] = {fTime = 1.0,	},
		[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= 180,	fVelocityMagnitude 	= 3,},
		[6] = {fTime = 1.3,			fAlpha 	= 0.0,},
	}

	self:RequestShowTextFloater(eMessageType, GameLib.GetControlledUnit(), strFormatted, tTextOption, 0, tContent)
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnLootedMoney(monLooted) -- karCurrencyTypeToString filters to most alternate currencies but Money. Money displays in LootNotificationWindow.
	local arCurrencyTypeToString =
	{
		[Money.CodeEnumCurrencyType.Renown] 			= "CRB_Renown",
		[Money.CodeEnumCurrencyType.ElderGems] 			= "CRB_Elder_Gems",
		[Money.CodeEnumCurrencyType.Prestige] 			= "CRB_Prestige",
		[Money.CodeEnumCurrencyType.CraftingVouchers]	= "CRB_Crafting_Vouchers",
	}

	local strCurrencyType = arCurrencyTypeToString[monLooted:GetMoneyType()] or ""
	if strCurrencyType == "" then
		return
	else
		strCurrencyType = Apollo.GetString(strCurrencyType)
	end

	-- TODO
	local eMessageType = LuaEnumMessageType.AlternateCurrency
	local strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_AlternateMoney"), monLooted:GetAmount(), strCurrencyType)

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 1.0
	tTextOption.fDuration = 2
	tTextOption.strFontFace = "CRB_FloaterSmall"
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = -1
	tTextOption.fOffsetDirection = 0
	tTextOption.arFrames =
	{
		[1] = {fScale = 0.8,	fTime = 0,		fAlpha = 0.0,	fVelocityDirection = 0,		fVelocityMagnitude = 0,	},
		[2] = {fScale = 0.8,	fTime = 0.1,	fAlpha = 1.0,	fVelocityDirection = 0,		fVelocityMagnitude = 0,	},
		[3] = {fScale = 0.8,	fTime = 0.5,	fAlpha = 1.0,														},
		[4] = {					fTime = 1,		fAlpha = 1.0,	fVelocityDirection = 180,	fVelocityMagnitude = 3,	},
		[5] = {					fTime = 1.5,	fAlpha = 0.0,	fVelocityDirection = 180,							},
	}

	local tContent =
	{
		eType = LuaEnumMessageType.AlternateCurrency,
		nAmount = monLooted:GetAmount(),
	}

	self:RequestShowTextFloater(eMessageType, GameLib.GetControlledUnit(), strFormatted, tTextOption, 0, tContent)
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnTradeSkillFloater(unitTarget, strMessage)
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end

	local eMessageType = LuaEnumMessageType.TradeskillXp
	local tTextOption = self:GetDefaultTextOption()
	local unitToAttachTo = GameLib.GetControlledUnit()

	-- XP Defaults
	tTextOption.fScale = 1.0
	tTextOption.fDuration = 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = -0.3
	tTextOption.fOffsetDirection = 0

	tTextOption.nColor = 0xffff80
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical --Horizontal  --IgnoreCollision
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = -0.3
	tTextOption.fOffsetDirection = 0

	-- scale and movement
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,	fScale = 1.0,	fAlpha = 0.0,},
		[2] = {fTime = 0.1,	fScale = 0.7,	fAlpha = 0.8,},
		[3] = {fTime = 0.9,	fScale = 0.7,	fAlpha = 0.8,	fVelocityDirection = 180,},
		[4] = {fTime = 1.0,	fScale = 1.0,	fAlpha = 0.0,	fVelocityDirection = 180,},
	}


	local unitToAttachTo = GameLib.GetControlledUnit()
	self:RequestShowTextFloater( eMessageType, unitToAttachTo, strMessage, tTextOption, 0 )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnMiss( unitCaster, unitTarget, eMissType )
	if unitTarget == nil or not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end

	-- modify the text to be shown
	local tTextOption = self:GetDefaultTextOption()
	if GameLib.IsControlledUnit( unitTarget ) or unitTarget:GetType() == "Mount" then -- if the target unit is player's char
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal --Vertical--Horizontal  --IgnoreCollision
		tTextOption.eLocation = self.userSettings.sCombatTextAnchor
		tTextOption.nColor = 0xbaeffb
		tTextOption.fOffset = -0.5
		tTextOption.fOffsetDirection = 180
		tTextOption.arFrames =
		{
			[1] = {fScale = 1.0,	fTime = 0,						fVelocityDirection = 180,		fVelocityMagnitude = 0,},
			[2] = {fScale = 0.6,	fTime = 0.05,	fAlpha = 1.0,},
			[3] = {fScale = 0.6,	fTime = .2,		fAlpha = 1.0,	fVelocityDirection = 180,		fVelocityMagnitude = 3,},
			[4] = {fScale = 0.6,	fTime = .45,	fAlpha = 0.2,	fVelocityDirection = 180,},
		}
	else

		tTextOption.fScale = 1.0
		tTextOption.fDuration = 2
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal --Horizontal
		tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Top
		tTextOption.fOffset = .5
		tTextOption.fOffsetDirection = 0
		tTextOption.arFrames =
		{
			[1] = {fScale = 1.25,	fTime = 0,		fAlpha = 1.0,	nColor = 0xb0b0b0,	fVelocityDirection = 0, 	fVelocityMagnitude = .75},
			[2] = {fScale = 0.7,	fTime = 0.1,	fAlpha = 1.0,						fVelocityDirection = 0, 	fVelocityMagnitude = 1.5},
			[3] = {					fTime = 0.3,										fVelocityDirection = 0, 	fVelocityMagnitude = 3},
			[4] = {fScale = 0.7,	fTime = 0.8,	fAlpha = 1.0,						fVelocityDirection = 0, 	fVelocityMagnitude = 5},
			[5] = {					fTime = 0.9,	fAlpha = 0.0,						fVelocityDirection = 0, 	fVelocityMagnitude = 7},
		}
	end

	-- display the text
	local strText = (eMissType == GameLib.CodeEnumMissType.Dodge) and Apollo.GetString("CRB_Dodged") or Apollo.GetString("CRB_Blocked")
	CombatFloater.ShowTextFloater( unitTarget, strText, tTextOption )
end

---------------------------------------------------------------------------------------------------
function YetAnotherSCT:OnDamageOrHealing( unitCaster, unitTarget, eDamageType, nDamage, nShieldDamaged, nAbsorptionAmount, bCritical )
	local nTargetOverheadAnchor = nil
	local nPlayerOverheadAnchor = nil
	if unitTarget == nil or not Apollo.GetConsoleVariable("ui.showCombatFloater") or nDamage == nil then
		return
	end

	if GameLib.IsControlledUnit(unitTarget) or unitTarget:IsMounted() then
		self:OnPlayerDamageOrHealing( unitTarget, eDamageType, nDamage, nShieldDamaged, nAbsorptionAmount, bCritical )
		return
	end

	if eDamageType == GameLib.CodeEnumDamageType.Heal or eDamageType == GameLib.CodeEnumDamageType.HealShields then
		local oHD = tonumber(self.userSettings.outgoingHealDisable)
		if  oHD == 1 then
			return
		end
	else
		local oDD = tonumber(self.userSettings.outgoingDamageDisable)
		if  oDD == 1 then
			return
		end
	end
	if  unitTarget ~= nil and unitTarget:GetOverheadAnchor() ~= nil and unitTarget:GetOverheadAnchor().y ~= nil then 
		nTargetOverheadAnchor = unitTarget:GetOverheadAnchor().y
		nPlayerOverheadAnchor = GameLib.GetPlayerUnit():GetOverheadAnchor().y
	else
		nTargetOverheadAnchor = Apollo.GetDisplaySize().nHeight/3
		nPlayerOverheadAnchor = GameLib.GetPlayerUnit():GetOverheadAnchor().y
	end
	

	-- NOTE: This needs to be changed if we're ever planning to display shield and normal damage in different formats.
	-- NOTE: Right now, we're just telling the player the amount of damage they did and not the specific type to keep things neat
	-- Carbine plan it I deliver it!
	local nTotalDamage = nDamage
	local oSDD = tonumber(self.userSettings.outgoingShieldDamageDisable)
	if type(nShieldDamaged) == "number" and nShieldDamaged > 0 then
		if oSDD == 1 then
			--nTotalDamage = nDamage + nShieldDamaged
			nTotalDamage = nDamage
		else
			nTotalDamage = nDamage.."("..nShieldDamaged..")" --Shield Damage in "()"
		end

	end

	local tTextOption = self:GetDefaultTextOption()
	local tTextOptionAbsorb = self:GetDefaultTextOption()
	local unitToAttachTo = unitTarget

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then --absorption is its own separate type
		tTextOptionAbsorb.fScale = 1.0
		tTextOptionAbsorb.fDuration = 2
		tTextOptionAbsorb.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.IgnoreCollision --Horizontal
		tTextOptionAbsorb.eLocation = self.userSettings.sCombatTextAnchor
		tTextOptionAbsorb.fOffset = -0.8
		tTextOptionAbsorb.fOffsetDirection = 0
		tTextOptionAbsorb.arFrames={}

		tTextOptionAbsorb.arFrames =
		{
			[1] = {fScale = 1.1,	fTime = 0,		fAlpha = 1.0,	nColor = 0xb0b0b0,},
			[2] = {fScale = 0.7,	fTime = 0.1,	fAlpha = 1.0,},
			[3] = {					fTime = 0.3,	},
			[4] = {fScale = 0.7,	fTime = 0.8,	fAlpha = 1.0,},
			[5] = {					fTime = 0.9,	fAlpha = 0.0,},
		}
	end

	local bHeal = eDamageType == GameLib.CodeEnumDamageType.Heal or eDamageType == GameLib.CodeEnumDamageType.HealShields
	
	local nBaseColor = 0x00ffff
	local fMaxSize = self.userSettings.outgoingDamageFontSize --Default: 0.8 Normal Damage Size 
	local nOffsetDirection = 0
	local fMaxDuration = self.userSettings.outgoingDamageDuration --Default 0.7
	local flashSizeMultiplier = 1.75
	local flashColor = 0x00ffff

	tTextOption.strFontFace = self.userSettings.outgoingDamageFont --Default: "CRB_FloaterHuge_O"
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
	tTextOption.eLocation = self:FloaterOffsetAdjustment(nPlayerOverheadAnchor,nTargetOverheadAnchor)
	tTextOption.fOffsetDirection = nOffsetDirection
	tTextOption.fVelocityMagnitude = 1
	




	if not bHeal and bCritical == true then -- Crit not vuln 
		tTextOption.strFontFace = self.userSettings.outgoingCritDamageFont --Default: "CRB_FloaterHuge_O"
		nBaseColor = "0x"..self.userSettings.outgoingCritDamageFontColor --Default: 0xfffb93
		flashColor = "0x"..self.userSettings.outgoingCritDamageFontColor 
		fMaxSize = self.userSettings.outgoingCritDamageFontSize --Default: 1.0
		--nTotalDamage = nTotalDamage.."  "..self.userSettings.CriticalHitMarker
		fMaxDuration = self.userSettings.outgoingCritDamageDuration
		flashSizeMultiplier = self.userSettings.outgoingCritDamageFlash
	elseif not bHeal and (unitTarget:IsInCCState( Unit.CodeEnumCCState.Vulnerability ) or eDamageType == knTestingVulnerable ) then -- vuln not crit
		nBaseColor = 0xf5a2ff
	else -- normal damage/healing
	if eDamageType == GameLib.CodeEnumDamageType.Heal then -- healing params
		if nDamage < tonumber(self.userSettings.outgoingHealMinimumShown) then return end --healing value below minimum shown, dump
		-- healing above minimum shown threshold, continue
		nBaseColor = bCritical and "0x"..self.userSettings.outgoingCritHealFontColor or "0x"..self.userSettings.outgoingHealFontColor --Default: and 0xcdffa0 or 0xb0ff6a
		fMaxSize = bCritical and self.userSettings.outgoingCritHealFontSize or self.userSettings.outgoingHealFontSize --Default: and 0.9 or 0.7
		tTextOption.strFontFace = bCritical and self.userSettings.outgoingCritHealFont or self.userSettings.outgoingHealFont
		fMaxDuration = bCritical and self.userSettings.outgoingCritHealDuration or self.userSettings.outgoingHealDuration
		flashSizeMultiplier = self.userSettings.outgoingCritHealFlash
		--nTotalDamage = bCritical and nTotalDamage.."  "..self.userSettings.CriticalHitMarker or nTotalDamage
		flashColor = bCritical and "0x"..self.userSettings.outgoingCritHealFontColor or "0x"..self.userSettings.outgoingHealFontColor
		
	elseif eDamageType == GameLib.CodeEnumDamageType.HealShields then -- healing shields params
		nBaseColor = bCritical and 0xc9fffb or 0x6afff3
		fMaxSize = bCritical and 0.9 or 0.7 
	else -- regular target damage params
		if nDamage < tonumber(self.userSettings.outgoingDamageMinimumShown) then return end-- normal damage below minimum shown, dump
		-- normal damage above minimum threshold, continue 
			nBaseColor = "0x"..self.userSettings.outgoingDamageFontColor --Default: 0xe5feff 
			flashColor = "0x"..self.userSettings.outgoingDamageFontColor
			fMaxDuration = self.userSettings.outgoingDamageDuration
		
	end
end

local sO = tonumber(self.userSettings.splitOutgoing)
local mO = tonumber(self.userSettings.mergeOutgoing)


	if  sO == 1 then
		local swapO = tonumber(self.userSettings.swapOutgoing)
		local velocityDirection = 0
		if bHeal == true then 

			--tTextOption.fOffsetDirection = nOffset
			tTextOption.fOffset = math.random(1, 1)
			tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
			tTextOption.eLocation = self.userSettings.sCombatTextAnchor
			--tTextOption.fOffset = 4.0 -- GOTCHA: Different
			
			if swapO == 1 then
				tTextOption.fOffsetDirection = 90
				velocityDirection = 90
			else
				tTextOption.fOffsetDirection = 270
				velocityDirection = 270
			end
			
		else
			--tTextOption.fOffsetDirection = nOffset
			tTextOption.fOffset = math.random(1, 1)
			tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
			tTextOption.eLocation = self.userSettings.sCombatTextAnchor
			--tTextOption.fOffset = 4 -- GOTCHA: Different

			if swapO == 1 then
				tTextOption.fOffsetDirection = 270
				velocityDirection = 270
			else
				tTextOption.fOffsetDirection = 90
				velocityDirection = 90
			end
		end
		
		tTextOption.arFrames =
			{
			[1] = {fScale = fMaxSize * flashSizeMultiplier * 0.5, nColor = nBaseColor, fTime = 0,			fAlpha = 0,		fVelocityDirection = velocityDirection,	fVelocityMagnitude = 5,	 },-- Default 0.8},
			[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = velocityDirection,	fVelocityMagnitude = .2, nColor = nBaseColor},
			[3] = {fTime = 0.5,			fAlpha = 1.0,	fVelocityDirection = velocityDirection,	fVelocityMagnitude = .2},
			[4] = {fTime = 1.0,	},
			[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= 0,	fVelocityMagnitude 	= 15,},
			[6] = {fTime = 1.3 + fMaxDuration * 0.1,			fAlpha 	= 0.0,},
			}
	elseif mO == 1 then 
		local iMO = tonumber(self.userSettings.invertMergeOutgoing)
		local velocityDirection = 0
		unitToAttachTo = unitCaster
		if bHeal == true then 

			--tTextOption.fOffsetDirection = nOffset
			tTextOption.fOffset = math.random(2, 2)
			tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
			tTextOption.eLocation = self.userSettings.sCombatTextAnchor
			--tTextOption.fOffset = 4.0 -- GOTCHA: Different
			
			if iMO == 1 then
				tTextOption.fOffsetDirection = 270
				velocityDirection = 0
			else
				tTextOption.fOffsetDirection = 270
				velocityDirection = 180
			end
			
		else
			--tTextOption.fOffsetDirection = nOffset
			tTextOption.fOffset = math.random(2,2)
			tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
			tTextOption.eLocation = self.userSettings.sCombatTextAnchor
			--tTextOption.fOffset = 4 -- GOTCHA: Different

			if iMO == 1 then
				tTextOption.fOffsetDirection = 270
				velocityDirection = 0
			else
				tTextOption.fOffsetDirection = 270
				velocityDirection = 180
			end
		end
		
		tTextOption.arFrames =
			{
			[1] = {fScale = fMaxSize * flashSizeMultiplier * 0.5, nColor = nBaseColor, fTime = 0,			fAlpha = 0,		fVelocityDirection = velocityDirection,	fVelocityMagnitude = 5, },-- Default 0.8},
			[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = velocityDirection,	fVelocityMagnitude = .2, nColor = nBaseColor},
			[3] = {fTime = 0.5,			fAlpha = 1.0,	fVelocityDirection = velocityDirection,	fVelocityMagnitude = .2},
			[4] = {fTime = 1.0,	},
			[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= velocityDirection,	fVelocityMagnitude 	= 15,},
			[6] = {fTime = 1.3 + fMaxDuration * 0.1,			fAlpha 	= 0.0,},
			}

	else
		-- determine offset direction; re-randomize if too close to the last
		local nOffset = math.random(0, 0)  -- disabled randomization of offset by setting min/max to 0,0
		if nOffset <= (self.fLastOffset + 75) and nOffset >= (self.fLastOffset - 75) then
			nOffset = math.random(0, 0)  -- disabled randomization of offset by setting min/max to 0,0
		end
		self.fLastOffset = nOffset

		-- set offset
		tTextOption.fOffsetDirection = nOffset
		tTextOption.fOffset = math.random(10,30)/100
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal

		-- scale and movement
		nStallTime = .4
		tTextOption.arFrames =
		{
		[1] = {fScale = fMaxSize * flashSizeMultiplier * .5,	fTime = 0,											nColor = nHighlightColor,	fVelocityDirection = 0,		fVelocityMagnitude = 0,},
		[2] = {fScale = fMaxSize * 1.5,					fTime = 0.1,										nColor = nHighlightColor,	fVelocityDirection = 0,		fVelocityMagnitude = .5,},
		[3] = {fScale = fMaxSize,						fTime = 0.3,					fAlpha = 1.0,		nColor = nBaseColor,		fVelocityDirection = 0,		fVelocityMagnitude = 2,},
		[4] = {											fTime = 0.5 + nStallTime,		fAlpha = .75,									fVelocityDirection = 0,		fVelocityMagnitude = 5,},
		[5] = {											fTime = 0.0 + fMaxDuration,		fAlpha = 0.0,									fVelocityDirection = 0,		fVelocityMagnitude = 7,},
		}
	end
	
	if bCritical == true then
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
		nTotalDamage = nTotalDamage.."  "..self.userSettings.CriticalHitMarker
	end

	if not bHeal then
		self.fLastDamageTime = GameLib.GetGameTime()
	end
	
	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then -- secondary "if" so we don't see absorption and "0"
		CombatFloater.ShowTextFloater( unitTarget, String_GetWeaselString(Apollo.GetString("FloatText_Absorbed"), nAbsorptionAmount), tTextOptionAbsorb )

		if nDamage > 0 then
			--tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
			if bHeal then
				CombatFloater.ShowTextFloater( unitTarget, String_GetWeaselString(Apollo.GetString("FloatText_PlusValue"), nTotalDamage), tTextOption ) --
			else
				CombatFloater.ShowTextFloater( unitTarget, nTotalDamage, tTextOption )
			end
		end
	elseif bHeal then
		CombatFloater.ShowTextFloater( unitToAttachTo, "+"..nTotalDamage, tTextOption ) -- we show "0" when there's no absorption ,String_GetWeaselString(Apollo.GetString("FloatText_PlusValue") ,nTotalDamage)
	else
		CombatFloater.ShowTextFloater( unitToAttachTo, nTotalDamage, tTextOption )		 
	end
end

------------------------------------------------------------------
function YetAnotherSCT:OnPlayerDamageOrHealing(unitPlayer, eDamageType, nDamage, nShieldDamaged, nAbsorptionAmount, bCritical)
	if unitPlayer == nil or not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end
	
	-- If there is no damage, don't show a floater
	if nDamage == nil then
		return
	end
	
	if eDamageType == GameLib.CodeEnumDamageType.Heal or eDamageType == GameLib.CodeEnumDamageType.HealShields then
		local iHD = tonumber(self.userSettings.incomingHealDisable)
		if  iHD == 1 then
			return
		end
	else	
		local iDD = tonumber(self.userSettings.incomingDamageDisable)
		if  iDD == 1 then
			return
		end
	end

	local bShowFloater = true
	local tTextOption = self:GetDefaultTextOption()
	local tTextOptionAbsorb = self:GetDefaultTextOption()

	tTextOption.arFrames = {}
	tTextOptionAbsorb.arFrames = {}

	local nStallTime = .4

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then --absorption is its own separate type
		tTextOptionAbsorb.nColor = 0xf8f3d7
		tTextOptionAbsorb.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal --Vertical--Horizontal  --IgnoreCollision
		tTextOptionAbsorb.eLocation = self.userSettings.sCombatTextAnchor
		tTextOptionAbsorb.fOffset = -0.4
		tTextOptionAbsorb.fOffsetDirection = 180--125

		-- scale and movement
		tTextOptionAbsorb.arFrames =
		{
			[1] = {fScale = 1.1,	fTime = 0,									fVelocityDirection = 0,		fVelocityMagnitude = 0,},
			[2] = {fScale = 0.7,	fTime = 0.05,				fAlpha = 1.0,},
			[3] = {fScale = 0.7,	fTime = .2 + nStallTime,	fAlpha = 1.0,	fVelocityDirection = 180,	fVelocityMagnitude = 3,},
			[4] = {fScale = 0.7,	fTime = .45 + nStallTime,	fAlpha = 0.2,	fVelocityDirection = 180,},
		}
	end
	local nTotalDamage = nDamage
	local iSDD = tonumber(self.userSettings.incomingShieldDamageDisable)
	if type(nShieldDamaged) == "number" and nShieldDamaged > 0 then
		if iSDD == 1 then
			nTotalDamage = nDamage + nShieldDamaged
			--nTotalDamage = nDamage
		else
			nTotalDamage = nDamage.."("..nShieldDamaged..")" --Shield Damage in "()"
		end

	end

	local bHeal = eDamageType == GameLib.CodeEnumDamageType.Heal or eDamageType == GameLib.CodeEnumDamageType.HealShields
	local nBaseColor = 0xff6d6d
	local nHighlightColor = 0xff6d6d
	local fMaxSize = 0.8
	local nOffsetDirection = 180
	local fOffsetAmount = 0
	local fMaxDuration = .55
	local eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
	local flashSizeMultiplier = 1.75
	

	local newDamage = nDamage

	if eDamageType == GameLib.CodeEnumDamageType.Heal then -- healing params
		if nDamage < tonumber(self.userSettings.incomingHealMinimumShown) then return end-- healing below threshold, dump
		-- heal value greater than minimum, continue processing
			fMaxSize = self.userSettings.incomingHealFontSize
			fMaxDuration = self.userSettings.incomingHealDuration
			tTextOption.strFontFace = self.userSettings.incomingHealFont
			nBaseColor = "0x"..self.userSettings.incomingHealFontColor --Default: 0xb0ff6a
			nHighlightColor = nBaseColor --Default: 0xb0ff6a
			fOffsetAmount = 1
			
		if bCritical then
			fMaxSize = self.userSettings.incomingCritHealFontSize --Default: 1.2
			nBaseColor = "0x"..self.userSettings.incomingCritHealFontColor	--Default 0xc6ff94
			nHighlightColor = nBaseColor --Default: 0xc6ff94
			fMaxDuration = self.userSettings.incomingCritHealDuration -- Default: .75
			flashSizeMultiplier = self.userSettings.incomingCritHealFlash
			newDamage = nDamage.."  "..self.userSettings.CriticalHitMarker
		end

	elseif eDamageType == GameLib.CodeEnumDamageType.HealShields then -- healing shields params
		nBaseColor = 0x6afff3
		fOffsetAmount = -0.5
		nHighlightColor = 0x6afff3

		if bCritical then
			fMaxSize = 1.2
			nBaseColor = 0xa6fff8
			nHighlightColor = 0xFFFFFF
			fMaxDuration = .75
		end

	else -- regular old damage (player)
		fOffsetAmount = 0
		fMaxSize = self.userSettings.incomingDamageFontSize --Default: 0.8
		fMaxDuration = self.userSettings.incomingDamageDuration --Default: 0.55
		nBaseColor = "0x"..self.userSettings.incomingDamageFontColor --Default: 0xf8f3d7
		tTextOption.strFontFace = self.userSettings.incomingDamageFont
		nHighlightColor = nBaseColor
		if bCritical then
			fMaxSize = self.userSettings.incomingCritDamageFontSize --Default: 1.2
			nBaseColor = "0x"..self.userSettings.incomingCritDamageFontColor --Default: 0xffab3d
			--nHighlightColor = 0xFFFFFF
			fMaxDuration = self.userSettings.incomingCritDamageDuration --Default: .75
			flashSizeMultiplier = self.userSettings.incomingCritDamageFlash -- Default: 0.75
			nTotalDamage = nTotalDamage.."  "..self.userSettings.CriticalHitMarker
			nHighlightColor = nBaseColor
			tTextOption.strFontFace = self.userSettings.incomingCritDamageFont
		end
	end
	
	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then -- secondary "if" so we don't see absorption and "0"
		CombatFloater.ShowTextFloater( unitPlayer, String_GetWeaselString(Apollo.GetString("FloatText_Absorbed"), nAbsorptionAmount), tTextOptionAbsorb )
	end

	local sI = tonumber(self.userSettings.splitIncoming)
	local mI = tonumber(self.userSettings.mergeIncoming)

	if  sI == 1 then
		local velocityDirection = 0
		local swapI = tonumber(self.userSettings.swapIncoming)
		if bHeal == true then 

			--tTextOption.fOffsetDirection = nOffset
			tTextOption.fOffset = math.random(1, 1)--/100
			tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
			tTextOption.eLocation = self.userSettings.sCombatTextAnchor
			--tTextOption.fOffset = 4.0 -- GOTCHA: Different
			if swapI == 1 then
				tTextOption.fOffsetDirection = 90
				velocityDirection = 90
			else
				tTextOption.fOffsetDirection = 270
				velocityDirection = 270
			end
			
			else
			--tTextOption.fOffsetDirection = nOffset
			tTextOption.fOffset = math.random(1, 1)--/100
			tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
			tTextOption.eLocation = self.userSettings.sCombatTextAnchor
			--tTextOption.fOffset = 4.0 -- GOTCHA: Different
			if swapI == 1 then
				tTextOption.fOffsetDirection = 270
				velocityDirection = 270
			else
				tTextOption.fOffsetDirection = 90
				velocityDirection = 90
			end
		end
	elseif mI == 1 then 
		local velocityDirection = 0
		local iMI = tonumber(self.userSettings.invertMergeIncoming)
		if bHeal == true then 

			--tTextOption.fOffsetDirection = nOffset
			tTextOption.fOffset = math.random(2, 2)
			tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
			tTextOption.eLocation = self.userSettings.sCombatTextAnchor
			--tTextOption.fOffset = 4.0 -- GOTCHA: Different
			
			if iMI == 1 then
				tTextOption.fOffsetDirection = 90
				velocityDirection = 0
			else
				tTextOption.fOffsetDirection = 90
				velocityDirection = 180
			end
			
		else
			--tTextOption.fOffsetDirection = nOffset
			tTextOption.fOffset = math.random(2, 2)
			tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
			tTextOption.eLocation = self.userSettings.sCombatTextAnchor
			--tTextOption.fOffset = 4 -- GOTCHA: Different

			if iMI == 1 then
				tTextOption.fOffsetDirection = 90
				velocityDirection = 0
			else
				tTextOption.fOffsetDirection = 90
				velocityDirection = 180
			end
		end
		
		tTextOption.arFrames =
			{
			[1] = {fScale = fMaxSize * flashSizeMultiplier * 0.5, nColor = nBaseColor, fTime = 0,			fAlpha = 0,		fVelocityDirection = velocityDirection,	fVelocityMagnitude = 5,},-- Default 0.8},
			[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = velocityDirection,	fVelocityMagnitude = .2, nColor = nBaseColor},
			[3] = {fTime = 0.5,			fAlpha = 1.0,	fVelocityDirection = velocityDirection,	fVelocityMagnitude = .2},
			[4] = {fTime = 1.0,	},
			[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= velocityDirection,	fVelocityMagnitude 	= 15,},
			[6] = {fTime = 1.3 + fMaxDuration * 0.1,			fAlpha 	= 0.0,},
			}

	else
		tTextOptionAbsorb.fOffset = fOffsetAmount
		tTextOption.eCollisionMode = eCollisionMode
		tTextOption.eLocation = self.userSettings.sCombatTextAnchor

		-- scale and movement
		tTextOption.arFrames =
		{
		[1] = {fScale = fMaxSize * flashSizeMultiplier,	fTime = 0,											nColor = nHighlightColor,	fVelocityDirection = 180,		fVelocityMagnitude = 0,},
		[2] = {fScale = fMaxSize * 1.5,					fTime = 0.05,										nColor = nHighlightColor,	fVelocityDirection = 180,		fVelocityMagnitude = 2,},
		[3] = {fScale = fMaxSize,						fTime = 0.1,					fAlpha = 1.0,		nColor = nBaseColor,},
		[4] = {											fTime = 0.3 + nStallTime,		fAlpha = 1.0,									fVelocityDirection = 180,		fVelocityMagnitude = 3,},
		[5] = {											fTime = 0.65 + fMaxDuration,	fAlpha = 0.2,									fVelocityDirection = 180,},
		}
	end
	
	if bCritical == true then
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
	end
		
	if nDamage > tonumber(self.userSettings.incomingHealMinimumShown) and bHeal then
		CombatFloater.ShowTextFloater( unitPlayer, "+"..newDamage, tTextOption )
	elseif nDamage > 0 then
		CombatFloater.ShowTextFloater( unitPlayer, nTotalDamage, tTextOption )
	end
end

------------------------------------------------------------------
function YetAnotherSCT:OnCombatLogCCState(tEventArgs)
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end

	-- removal of a CC state does not display floater text
	if tEventArgs.bRemoved or tEventArgs.bHideFloater then
		return
	end

	local nOffsetState = tEventArgs.eState
	if tEventArgs.eResult == nil then
		return
	end -- totally invalid

	if GameLib.IsControlledUnit( tEventArgs.unitTarget ) then
		-- Route to the player function
		self:OnCombatLogCCStatePlayer(tEventArgs)
		return
	end

	local arCCFormat =  --Removing an entry from this table means no floater is shown for that state.
	{
		[Unit.CodeEnumCCState.Stun] 			= 0xffe691, -- stun
		[Unit.CodeEnumCCState.Sleep] 			= 0xffe691, -- sleep
		[Unit.CodeEnumCCState.Root] 			= 0xffe691, -- root
		[Unit.CodeEnumCCState.Disarm] 			= 0xffe691, -- disarm
		[Unit.CodeEnumCCState.Silence] 			= 0xffe691, -- silence
		[Unit.CodeEnumCCState.Polymorph] 		= 0xffe691, -- polymorph
		[Unit.CodeEnumCCState.Fear] 			= 0xffe691, -- fear
		[Unit.CodeEnumCCState.Hold] 			= 0xffe691, -- hold
		[Unit.CodeEnumCCState.Knockdown] 		= 0xffe691, -- knockdown
		[Unit.CodeEnumCCState.Disorient] 		= 0xffe691,
		[Unit.CodeEnumCCState.Disable] 			= 0xffe691,
		[Unit.CodeEnumCCState.Taunt] 			= 0xffe691,
		[Unit.CodeEnumCCState.DeTaunt] 			= 0xffe691,
		[Unit.CodeEnumCCState.Blind] 			= 0xffe691,
		[Unit.CodeEnumCCState.Knockback] 		= 0xffe691,
		[Unit.CodeEnumCCState.Pushback ] 		= 0xffe691,
		[Unit.CodeEnumCCState.Pull] 			= 0xffe691,
		[Unit.CodeEnumCCState.PositionSwitch] 	= 0xffe691,
		[Unit.CodeEnumCCState.Tether] 			= 0xffe691,
		[Unit.CodeEnumCCState.Snare] 			= 0xffe691,
		[Unit.CodeEnumCCState.Interrupt] 		= 0xffe691,
		[Unit.CodeEnumCCState.Daze] 			= 0xffe691,
		[Unit.CodeEnumCCState.Subdue] 			= 0xffe691,
	}

	local tTextOption = self:GetDefaultTextOption()
	local strMessage = ""
	
	tTextOption.strFontFace = self.userSettings.ccStateFont
	tTextOption.fScale = 1.0	--Default 1.0
	tTextOption.fDuration = 2 --Default: 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical --IgnoreCollision --Horizontal
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = 1
	tTextOption.fOffsetDirection = 0
	local fMaxSize = self.userSettings.ccStateEnemyFontSize
	local fMaxDuration = self.userSettings.ccStateEnemyFontDuration
	tTextOption.arFrames={}
	
	local bUseCCFormat = false -- use CC formatting vs. message formatting

	if tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Ok then -- CC applied
		strMessage = tEventArgs.strState
		if arCCFormat[nOffsetState] ~= nil then -- make sure it's one we want to show
			bUseCCFormat = true
		else
			return
		end
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_Immune then
		strMessage = Apollo.GetString("FloatText_Immune")
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InfiniteInterruptArmor then
		strMessage = Apollo.GetString("FloatText_InfInterruptArmor")
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InterruptArmorReduced then -- use with interruptArmorHit
		strMessage = String_GetWeaselString(Apollo.GetString("FloatText_InterruptArmor"), tEventArgs.nInterruptArmorHit)
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.DiminishingReturns_TriggerCap and tEventArgs.strTriggerCapCategory ~= nil then
		strMessage = Apollo.GetString("FloatText_CC_DiminishingReturns_TriggerCap").." "..tEventArgs.strTriggerCapCategory
	else -- all invalid messages
		return
	end

	if not bUseCCFormat then -- CC didn't take
		tTextOption.nColor = 0xb0b0b0

		tTextOption.arFrames =
		{
			[1] = {fScale = 1.0,	fTime = 0,		fAlpha = 0.0},
			[2] = {fScale = 0.7,	fTime = 0.1,	fAlpha = 0.8},
			[3] = {fScale = 0.7,	fTime = 0.9,	fAlpha = 0.8,	fVelocityDirection = 0},
			[4] = {fScale = 1.0,	fTime = 1.0,	fAlpha = 0.0,	fVelocityDirection = 0},
		}
	else -- CC applied
		local textColor = "0x"..self.userSettings.ccStateEnemyFontColor
		tTextOption.arFrames =
		{
			[1] = {fScale = fMaxSize,	fTime = 0,		fAlpha = 1.0,	nColor = 0xFFFFFF,},
			[2] = {fScale = fMaxSize,	fTime = 0.15,	fAlpha = 1.0,},
			[3] = {						fTime = 0.5,					nColor = textColor,}, --Default: arCCFormat[nOffsetState]
			[4] = {fScale = fMaxSize,	fTime = 1.1,	fAlpha = 1.0,										fVelocityDirection = 0,	fVelocityMagnitude = 5,},
			[5] = {						fTime = 1.3 + fMaxDuration,	fAlpha = 0.0,							fVelocityDirection = 0,},
		}
	end

	CombatFloater.ShowTextFloater( tEventArgs.unitTarget, strMessage, tTextOption )
end

------------------------------------------------------------------
function YetAnotherSCT:OnCombatLogCCStatePlayer(tEventArgs)
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end

	-- removal of a CC state does not display floater text
	if tEventArgs.bRemoved or tEventArgs.bHideFloater then
		return
	end

	local arCCFormatPlayer =
    --Removing an entry from this table means no floater is shown for that state.
	{
		[Unit.CodeEnumCCState.Stun] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Sleep] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Root] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Disarm] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Silence] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Polymorph] 		= 0xff2b2b,
		[Unit.CodeEnumCCState.Fear] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Hold] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Knockdown] 		= 0xff2b2b,
		[Unit.CodeEnumCCState.Disorient] 		= 0xff2b2b,
		[Unit.CodeEnumCCState.Disable] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Taunt] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.DeTaunt] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Blind] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Knockback] 		= 0xff2b2b,
		[Unit.CodeEnumCCState.Pushback] 		= 0xff2b2b,
		[Unit.CodeEnumCCState.Pull] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.PositionSwitch] 	= 0xff2b2b,
		[Unit.CodeEnumCCState.Tether] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Snare] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Interrupt] 		= 0xff2b2b,
		[Unit.CodeEnumCCState.Daze] 			= 0xff2b2b,
		[Unit.CodeEnumCCState.Subdue] 			= 0xff2b2b,
	}

	local nOffsetState = tEventArgs.eState

	local tTextOption = self:GetDefaultTextOption()
	local strMessage = ""

	tTextOption.strFontFace = self.userSettings.ccStateFont
	tTextOption.fScale = 1.0 --Default: 1.0
	tTextOption.fDuration = self.userSettings.ccStatePlayerFontDuration --Default: 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
	tTextOption.eLocation = self.userSettings.sCombatTextAnchor
	tTextOption.fOffset = -0.2
	tTextOption.fOffsetDirection = 0
	local fMaxSize = self.userSettings.ccStatePlayerFontSize
	local fMaxDuration = self.userSettings.ccStateEnemyFontDuration
	tTextOption.arFrames={}
		
	local bUseCCFormat = false -- use CC formatting vs. message formatting

	if tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Ok then -- CC applied
		strMessage = tEventArgs.strState
		if arCCFormatPlayer[nOffsetState] ~= nil then -- make sure it's one we want to show
			bUseCCFormat = true
		else
			return
		end
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_Immune then
		strMessage = Apollo.GetString("FloatText_Immune")
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InfiniteInterruptArmor then
		strMessage = Apollo.GetString("FloatText_InfInterruptArmor")
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InterruptArmorReduced then -- use with interruptArmorHit
		strMessage = String_GetWeaselString(Apollo.GetString("FloatText_InterruptArmor"), tEventArgs.nInterruptArmorHit)
	else -- all invalid messages
		return
	end

	if not bUseCCFormat then -- CC didn't take
		tTextOption.nColor = 0xd8f8f8
		tTextOption.arFrames =
		{
			[1] = {fScale = 1.0,	fTime = 0,		fAlpha = 0.0,},
			[2] = {fScale = 0.7,	fTime = 0.1,	fAlpha = 0.8,},
			[3] = {fScale = 0.7,	fTime = 0.9,	fAlpha = 0.8,	fVelocityDirection = 180,	fVelocityMagnitude = 3,},
			[4] = {fScale = 0.7,	fTime = 1.0,	fAlpha = 0.0,	fVelocityDirection = 180,},
		}
	else -- CC applied
		local textColor = "0x"..self.userSettings.ccStatePlayerFontColor
		--tTextOption.nColor = arCCFormatPlayer[nOffsetState]
		tTextOption.arFrames =
		{
			[1] = {fScale = fMaxSize,	fTime = 0,		nColor = 0xFFFFFF,},
			[2] = {fScale = fMaxSize,	fTime = 0.05,	nColor = textColor,	fAlpha = 1.0,}, --Default: arCCFormatPlayer[nOffsetState]
			[3]	= {					fTime = 0.35,	nColor = 0xFFFFFF,},
			[4] = {					fTime = 0.7,	nColor = textColor,}, --Default: arCCFormatPlayer[nOffsetState]
			[5] = {					fTime = 1.05,	nColor = 0xFFFFFF,},
			[6] = {fScale = fMaxSize,	fTime = 1.4,	nColor = textColor,	fAlpha = 1.0,	fVelocityDirection = 180,	fVelocityMagnitude = 3,}, --Default: arCCFormatPlayer[nOffsetState]
			[7] = {fScale = fMaxSize,	fTime = 1.55 + fMaxDuration,												fAlpha = 0.2,	fVelocityDirection = 180,},
		}
	end

	CombatFloater.ShowTextFloater( tEventArgs.unitTarget, strMessage, tTextOption )
end

------------------------------------------------------------------
-- send show text request to message manager with a delay in milliseconds
function YetAnotherSCT:RequestShowTextFloater( eMessageType, unitTarget, strText, tTextOption, fDelay, tContent ) -- addtn'l parameters for XP/rep
	local tParams =
	{
		unitTarget 	= unitTarget,
		strText 	= strText,
		tTextOption = TableUtil:Copy( tTextOption ),
		tContent 	= tContent,
	}

	if not fDelay or fDelay == 0 then -- just display if no delay
		Event_FireGenericEvent("Float_RequestShowTextFloater", eMessageType, tParams, tContent )
	else
		tParams.nTime = os.time() + fDelay
		tParams.eMessageType = eMessageType

		-- insert the text in the delayed queue in order of how fast they'll need to be shown
		local nInsert = 0
		for key, value in pairs(self.tDelayedFloatTextQueue:GetItems()) do
			if value.nTime > tParams.nTime then
				nInsert = key
				break
			end
		end
		if nInsert > 0 then
			self.tDelayedFloatTextQueue:InsertAbsolute( nInsert, tParams )
		else
			self.tDelayedFloatTextQueue:Push( tParams )
		end
		self.iTimerIndex = self.iTimerIndex + 1
		if self.iTimerIndex > 9999999 then
			self.iTimerIndex = 1
		end

		Apollo.CreateTimer("DelayedFloatTextTimer".. self.iTimerIndex, fDelay, false) -- create the timer to show the text
		Apollo.RegisterTimerHandler("DelayedFloatTextTimer"..self.iTimerIndex, "OnDelayedFloatTextTimer", self)
	end
end

------------------------------------------------------------------
function YetAnotherSCT:OnDelayedFloatTextTimer()
	local tParams = self.tDelayedFloatTextQueue:Pop()
	Event_FireGenericEvent("Float_RequestShowTextFloater", tParams.eMessageType, tParams, tParams.tContent) -- TODO: Event!!!!
end

---------------------------------------------------------------------------------------------------
-- SettingsForm Functions
---------------------------------------------------------------------------------------------------

function YetAnotherSCT:Button_Ok( wndHandler, wndControl, eMouseButton )
	self.wndMain:Show(false)
	--Save Outgoing Damage Values
	self.userSettings.outgoingDamageMinimumShown = self.wndMain:FindChild("ODamageMinimumShown"):GetText()
	self.userSettings.outgoingDamageFont = self.wndMain:FindChild("ODamageFont_CB"):GetSelectedText()
	self.userSettings.outgoingCritDamageFont = self.wndMain:FindChild("ODamageCritFont_CB"):GetSelectedText()
	self.userSettings.outgoingDamageFontSize = self.wndMain:FindChild("ODamageTextSize"):GetText()
	self.userSettings.outgoingCritDamageFontSize = self.wndMain:FindChild("ODamageCritTextSize"):GetText()
	self.userSettings.outgoingDamageDuration = self.wndMain:FindChild("ODamageTextDuration"):GetText()
	self.userSettings.outgoingCritDamageDuration = self.wndMain:FindChild("ODamageCritTextDuration"):GetText()
	self.userSettings.outgoingCritDamageFlash =  self.wndMain:FindChild("ODamageFlashTextSize"):GetText()
	self.userSettings.outgoingDamageFontColor = self:HSV_To_Hex(outgoingDamageColorAsCColor)
	self.userSettings.outgoingCritDamageFontColor = self:HSV_To_Hex(outgoingCritColorAsCColor)
	-- Save Outgoing Heal Values
	self.userSettings.outgoingHealMinimumShown = self.wndMain:FindChild("OHealMinimumShown"):GetText()
	self.userSettings.outgoingHealFont = self.wndMain:FindChild("OHealFont_CB"):GetSelectedText()
	self.userSettings.outgoingCritHealFont = self.wndMain:FindChild("OHealCritFont_CB"):GetSelectedText()
	self.userSettings.outgoingHealFontSize = self.wndMain:FindChild("OHealTextSize"):GetText()
	self.userSettings.outgoingCritHealFontSize = self.wndMain:FindChild("OHealCritTextSize"):GetText()
	self.userSettings.outgoingHealDuration = self.wndMain:FindChild("OHealTextDuration"):GetText()
	self.userSettings.outgoingCritHealDuration = self.wndMain:FindChild("OHealCritTextDuration"):GetText()
	self.userSettings.outgoingCritHealFlash =  self.wndMain:FindChild("OHealFlashTextSize"):GetText()
	self.userSettings.outgoingHealFontColor = self:HSV_To_Hex(outgoingHealColorAsCColor)
	self.userSettings.outgoingCritHealFontColor = self:HSV_To_Hex(outgoingCritHealColorAsCColor)
	-- Save Incoming Damage Values
	self.userSettings.incomingDamageFont = self.wndMain:FindChild("IDamageFont_CB"):GetSelectedText()
	self.userSettings.incomingCritDamageFont = self.wndMain:FindChild("IDamageCritFont_CB"):GetSelectedText()
	self.userSettings.incomingDamageFontSize = self.wndMain:FindChild("IDamageTextSize"):GetText()
	self.userSettings.incomingCritDamageFontSize = self.wndMain:FindChild("IDamageCritTextSize"):GetText()
	self.userSettings.incomingDamageDuration = self.wndMain:FindChild("IDamageTextDuration"):GetText()
	self.userSettings.incomingCritDamageDuration = self.wndMain:FindChild("IDamageCritTextDuration"):GetText()
	self.userSettings.incomingCritDamageFlash =  self.wndMain:FindChild("IDamageFlashTextSize"):GetText()
	self.userSettings.incomingDamageFontColor = self:HSV_To_Hex(incomingDamageColorAsCColor)
	self.userSettings.incomingCritDamageFontColor = self:HSV_To_Hex(incomingCritColorAsCColor)
	-- Save Incoming Heal Values
	self.userSettings.incomingHealMinimumShown = self.wndMain:FindChild("IHealMinimumShown"):GetText()
	self.userSettings.incomingHealFont = self.wndMain:FindChild("IHealFont_CB"):GetSelectedText()
	self.userSettings.incomingCritHealFont = self.wndMain:FindChild("IHealCritFont_CB"):GetSelectedText()
	self.userSettings.incomingHealFontSize = self.wndMain:FindChild("IHealTextSize"):GetText()
	self.userSettings.incomingCritHealFontSize = self.wndMain:FindChild("IHealCritTextSize"):GetText()
	self.userSettings.incomingHealDuration = self.wndMain:FindChild("IHealTextDuration"):GetText()
	self.userSettings.incomingCritHealDuration = self.wndMain:FindChild("IHealCritTextDuration"):GetText()
	self.userSettings.incomingCritHealFlash =  self.wndMain:FindChild("IHealFlashTextSize"):GetText()
	self.userSettings.incomingHealFontColor = self:HSV_To_Hex(incomingHealColorAsCColor)
	self.userSettings.incomingCritHealFontColor = self:HSV_To_Hex(incomingCritHealColorAsCColor)
	--Save General
	self.userSettings.ccStateFont = self.wndMain:FindChild("CCStateFont_CB"):GetSelectedText()
	self.userSettings.ccStatePlayerFontSize = self.wndMain:FindChild("CCStatePlayerTextSize"):GetText()
	self.userSettings.ccStateEnemyFontSize = self.wndMain:FindChild("CCStateEnemyTextSize"):GetText()
	self.userSettings.ccStatePlayerFontDuration = self.wndMain:FindChild("CCStatePlayerTextDuration"):GetText()
	self.userSettings.ccStateEnemyFontDuration = self.wndMain:FindChild("CCStateEnemyTextDuration"):GetText()
	self.userSettings.ccStatePlayerFontColor = self:HSV_To_Hex(ccStatePlayerColorAsCColor)
	self.userSettings.ccStateEnemyFontColor = self:HSV_To_Hex(ccStateEnemyColorAsCColor)
	self.userSettings.CriticalHitMarker = self.wndMain:FindChild("CriticalHitMarker"):GetText()
	
	isShown = 0
end

function YetAnotherSCT:Button_Close( wndHandler, wndControl, eMouseButton )
	self.wndMain:Show(false)
	isShown = 0
end

---------------------------------------------------------------------------------------------------
-- SettingsList Functions
---------------------------------------------------------------------------------------------------
--Damage
function YetAnotherSCT:OutgoingDamgeFontChange( wndHandler, wndControl )
	self.userSettings.outgoingDamageFont = self.wndMain:FindChild("ODamageFont_CB"):GetSelectedText()
	self.wndMain:FindChild("ODTF"):SetFont(self.userSettings.outgoingDamageFont)
end

function YetAnotherSCT:OutgoingCritDamageFontChange( wndHandler, wndControl )
	self.userSettings.outgoingCritDamageFont = self.wndMain:FindChild("ODamageCritFont_CB"):GetSelectedText()
	self.wndMain:FindChild("ODCTF"):SetFont(self.userSettings.outgoingCritDamageFont)
end

function YetAnotherSCT:OutgoingDamageFontColor( wndHandler, wndControl, eMouseButton )
	local function NormalColorCallBack(color)
		if color == nil then
			Print("nil")
		else
			self.wndMain:FindChild("ODTF"):SetTextColor(color)
		end
	end
	ColorPicker.AdjustCColor(outgoingDamageColorAsCColor, false, NormalColorCallBack, outgoingDamageColorAsCColor)
end

function YetAnotherSCT:OutgoingCritFontColor( wndHandler, wndControl, eMouseButton )
	local function CritColorCallBack(color)
		if color == nil then
			Print("nil")
		else
			self.wndMain:FindChild("ODCTF"):SetTextColor(color)
		end
	end
	ColorPicker.AdjustCColor(outgoingCritColorAsCColor, false, CritColorCallBack, outgoingCritColorAsCColor)
end

local YetAnotherSCTInst = YetAnotherSCT:new()
YetAnotherSCTInst:Init()

--Heal
function YetAnotherSCT:OutgoingHealingFontChange( wndHandler, wndControl )
	self.userSettings.outgoingHealFont = self.wndMain:FindChild("OHealFont_CB"):GetSelectedText()
	self.wndMain:FindChild("OHTF"):SetFont(self.userSettings.outgoingHealFont)
end

function YetAnotherSCT:OutgoingCritHealingFontChange( wndHandler, wndControl )
	self.userSettings.outgoingCritHealFont = self.wndMain:FindChild("OHealCritFont_CB"):GetSelectedText()
	self.wndMain:FindChild("OHCTF"):SetFont(self.userSettings.outgoingCritHealFont)
end

function YetAnotherSCT:OnHealingFontColor( wndHandler, wndControl, eMouseButton )
	local function NormalColorCallBack(color)
		if color == nil then
			Print("nil")
		else
			self.wndMain:FindChild("OHTF"):SetTextColor(color)
		end
	end
	ColorPicker.AdjustCColor(outgoingHealColorAsCColor , false, NormalColorCallBack, outgoingHealColorAsCColor)
end

function YetAnotherSCT:OutgoingCritHealingColor( wndHandler, wndControl, eMouseButton )
	local function CritColorCallBack(color)
		if color == nil then
			Print("nil")
		else
			self.wndMain:FindChild("OHCTF"):SetTextColor(color)
		end
	end
	ColorPicker.AdjustCColor(outgoingCritHealColorAsCColor, false, CritColorCallBack, outgoingCritHealColorAsCColor)
end

--Incoming Damage
function YetAnotherSCT:IncomingDamageFontColor( wndHandler, wndControl, eMouseButton )
	local function NormalColorCallBack(color)
		if color == nil then
			Print("nil")
		else
			self.wndMain:FindChild("IDTF"):SetTextColor(color)
		end
	end
	ColorPicker.AdjustCColor(incomingDamageColorAsCColor, false, NormalColorCallBack, incomingDamageColorAsCColor)
end

function YetAnotherSCT:IncomingCritFontColor( wndHandler, wndControl, eMouseButton )
	local function CritColorCallBack(color)
		if color == nil then
			Print("nil")
		else
			self.wndMain:FindChild("IDCTF"):SetTextColor(color)
		end
	end
	ColorPicker.AdjustCColor(incomingCritColorAsCColor, false, CritColorCallBack, incomingCritColorAsCColor)
end

function YetAnotherSCT:IncomingDamageFontChange( wndHandler, wndControl )
	self.userSettings.incomingDamageFont = self.wndMain:FindChild("IDamageFont_CB"):GetSelectedText()
	self.wndMain:FindChild("IDTF"):SetFont(self.userSettings.incomingDamageFont)
end

function YetAnotherSCT:IncomingCritDamageFontChange( wndHandler, wndControl )
	self.userSettings.incomingCritDamageFont = self.wndMain:FindChild("IDamageCritFont_CB"):GetSelectedText()
	self.wndMain:FindChild("IDCTF"):SetFont(self.userSettings.incomingCritDamageFont)
end
-- Incoming Heal
function YetAnotherSCT:IncomingHealingFontColor( wndHandler, wndControl, eMouseButton )
	local function NormalColorCallBack(color)
		if color == nil then
			Print("nil")
		else
			self.wndMain:FindChild("IHTF"):SetTextColor(color)
		end
	end
	ColorPicker.AdjustCColor(incomingHealColorAsCColor , false, NormalColorCallBack, incomingHealColorAsCColor)
end

function YetAnotherSCT:IncomingCritHealingFontColor( wndHandler, wndControl, eMouseButton )
	local function CritColorCallBack(color)
		if color == nil then
			Print("nil")
		else
			self.wndMain:FindChild("IHCTF"):SetTextColor(color)
		end
	end
	ColorPicker.AdjustCColor(incomingCritHealColorAsCColor, false, CritColorCallBack, incomingCritHealColorAsCColor)
end

function YetAnotherSCT:IncomingHealingFontChange( wndHandler, wndControl )
	self.userSettings.incomingHealFont = self.wndMain:FindChild("IHealFont_CB"):GetSelectedText()
	self.wndMain:FindChild("IHTF"):SetFont(self.userSettings.incomingHealFont)
end

function YetAnotherSCT:IncomingCritHealingFontChange( wndHandler, wndControl )
	self.userSettings.incomingCritHealFont = self.wndMain:FindChild("IHealCritFont_CB"):GetSelectedText()
	self.wndMain:FindChild("IHCTF"):SetFont(self.userSettings.incomingCritHealFont)
end

--Color Converter
function YetAnotherSCT:Hex_To_CColor(hex)
	r = string.sub(hex, 1, 2)
	rnumber = tonumber(r, 16)/255
	g = string.sub(hex, 3, 4)
	gnumber = tonumber(g, 16)/255
	b = string.sub(hex, 5, 6)
	bnumber = tonumber(b, 16)/255
return CColor.new(rnumber, gnumber, bnumber, 1)
end

function YetAnotherSCT:HSV_To_Hex(color)
	r = math.floor(color.r*255 + .5)
	g = math.floor(color.g*255 + .5)
	b = math.floor(color.b*255 + .5)
	return string.format("%02X%02X%02X", r, g, b)
end

function YetAnotherSCT:DEC_To_Hex(dec)
	return string.format("%02X", dec)
end

-- General

function YetAnotherSCT:CCStatePlayerColor( wndHandler, wndControl, eMouseButton )
	local function ColorCallBack(color)
		if color == nil then
			Print("nil")
		else
			self.wndMain:FindChild("label_102"):SetTextColor(color)
		end
	end
	ColorPicker.AdjustCColor(ccStatePlayerColorAsCColor, false, ColorCallBack, ccStatePlayerColorAsCColor)
end

function YetAnotherSCT:CCStateEnemyColor( wndHandler, wndControl, eMouseButton )
		local function ColorCallBack(color)
		if color == nil then
			Print("nil")
		else
			self.wndMain:FindChild("label_103"):SetTextColor(color)
		end
	end
	ColorPicker.AdjustCColor(ccStateEnemyColorAsCColor, false, ColorCallBack, ccStateEnemyColorAsCColor)
end

function YetAnotherSCT:CCStateFontChange( wndHandler, wndControl )
	self.userSettings.ccStateFont = self.wndMain:FindChild("CCStateFont_CB"):GetSelectedText()
	self.wndMain:FindChild("CCStateTextTF"):SetFont(self.userSettings.ccStateFont)
end

function YetAnotherSCT:FloaterOffsetAdjustment(PlayerY, TargetY)
	local MaxFloaterVertical = (Apollo.GetDisplaySize().nHeight/4)
	if TargetY <= 1 then 
		return CombatFloater.CodeEnumFloaterLocation.Bottom
	elseif TargetY < MaxFloaterVertical and TargetY > 1 then
		return CombatFloater.CodeEnumFloaterLocation.Chest
	else
		return CombatFloater.CodeEnumFloaterLocation.Top
	end
end

function YetAnotherSCT:SplitIncomingCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.splitIncoming = 1
end

function YetAnotherSCT:SplitIncomingUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.splitIncoming = 0
end

function YetAnotherSCT:SplitOutgoingCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.splitOutgoing = 1
end

function YetAnotherSCT:SplitOutgoingUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.splitOutgoing = 0
end

function YetAnotherSCT:MergeIncomingCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.mergeIncoming = 1
end

function YetAnotherSCT:MergeIncomingUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.mergeIncoming = 0
end

function YetAnotherSCT:MergeOutgoingCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.mergeOutgoing = 1
end

function YetAnotherSCT:MergeOutgoingUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.mergeOutgoing = 0
end

function YetAnotherSCT:HideSpellCastCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.hideSpellCastFail = 1
end

function YetAnotherSCT:HideSpellCastUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.hideSpellCastFail = 0
end

function YetAnotherSCT:OnDisableOutgoingDamageCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.outgoingDamageDisable = 1
end

function YetAnotherSCT:OnDisableOutgoingDamageUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.outgoingDamageDisable = 0
end

function YetAnotherSCT:OnDisableOutgoingHealingCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.outgoingHealDisable = 1
end

function YetAnotherSCT:OnDisableOutgoingHealingUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.outgoingHealDisable = 0
end

function YetAnotherSCT:OnDisableIncomingDamageCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.incomingDamageDisable = 1
end

function YetAnotherSCT:OnDisableIncomingDamageUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.incomingDamageDisable = 0
end

function YetAnotherSCT:OnDisableIncomingHealingCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.incomingHealDisable = 1
end

function YetAnotherSCT:OnDisableIncomingHealingUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.incomingHealDisable = 0
end

function YetAnotherSCT:OnSwapIncomingCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.swapIncoming = 1
end

function YetAnotherSCT:OnSwapIncomingUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.swapIncoming = 0
end

function YetAnotherSCT:OnSwapOutgoingCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.swapOutgoing = 1
end

function YetAnotherSCT:OnSwapOutgoingUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.swapOutgoing = 0
end

function YetAnotherSCT:OnInvertMergeIncomingCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.invertMergeIncoming = 1
end

function YetAnotherSCT:OnInvertMergeIncomingUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.invertMergeIncoming = 0
end

function YetAnotherSCT:OnInvertMergeOutgoingCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.invertMergeOutgoing = 1
end

function YetAnotherSCT:OnInvertMergeOutgoingUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.invertMergeOutgoing = 0
end

function YetAnotherSCT:OnDisableOutgoingShieldDamageCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.outgoingShieldDamageDisable = 1
end

function YetAnotherSCT:OnDisableOutgoingShieldDamageUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.outgoingShieldDamageDisable = 0
end

function YetAnotherSCT:OnDisableIncomingShieldDamageCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.incomingShieldDamageDisable = 1
end

function YetAnotherSCT:OnDisableIncomingShieldDamageUnCheck( wndHandler, wndControl, eMouseButton )
	self.userSettings.incomingShieldDamageDisable = 0
end

---------------------------------------------------------------------------------------------------
-- Register Packages
---------------------------------------------------------------------------------------------------
Apollo.RegisterPackage(YetAnotherSCT,"YetAnotherSCT",1,{})

