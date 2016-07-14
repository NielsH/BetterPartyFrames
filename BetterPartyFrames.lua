-----------------------------------------------------------------------------------------------
-- Client Lua Script for GroupDisplayOptions
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "Unit"
require "GroupLib"
require "GameLib"
require "Tooltip"
require "PlayerPathLib"
require "ChatSystemLib"
require "MatchingGameLib"

local BetterPartyFrames = {}

local ktCategoryToSettingKeyPrefix =
{
	ConfigColorsGeneral			= "strColorGeneral_",
	ConfigColorsEngineer		= "strColorEngineer_",
	ConfigColorsEsper			= "strColorEsper_",
	ConfigColorsMedic			= "strColorMedic_",
	ConfigColorsSpellslinger	= "strColorSpellslinger_",
	ConfigColorsStalker			= "strColorStalker_",
	ConfigColorsWarrior			= "strColorWarrior_",
}

local ktClassIdToClassName =
{
	[GameLib.CodeEnumClass.Esper] 			= "Esper",
	[GameLib.CodeEnumClass.Medic] 			= "Medic",
	[GameLib.CodeEnumClass.Stalker] 		= "Stalker",
	[GameLib.CodeEnumClass.Warrior] 		= "Warrior",
	[GameLib.CodeEnumClass.Engineer] 		= "Engineer",
	[GameLib.CodeEnumClass.Spellslinger] 	= "Spellslinger",
}

local ktInvitePathIcons = -- NOTE: ID's are zero-indexed in CPP
{
	[PlayerPathLib.PlayerPathType_Soldier] 		= "Icon_Windows_UI_CRB_Soldier",
	[PlayerPathLib.PlayerPathType_Settler] 		= "Icon_Windows_UI_CRB_Colonist",
	[PlayerPathLib.PlayerPathType_Scientist] 	= "Icon_Windows_UI_CRB_Scientist",
	[PlayerPathLib.PlayerPathType_Explorer] 	= "Icon_Windows_UI_CRB_Explorer"
}

local ktSmallInvitePathIcons = -- NOTE: ID's are zero-indexed in CPP
{
	[PlayerPathLib.PlayerPathType_Soldier] 		= "Icon_Windows_UI_CRB_Soldier_Small",
	[PlayerPathLib.PlayerPathType_Settler] 		= "Icon_Windows_UI_CRB_Colonist_Small",
	[PlayerPathLib.PlayerPathType_Scientist] 	= "Icon_Windows_UI_CRB_Scientist_Small",
	[PlayerPathLib.PlayerPathType_Explorer] 	= "Icon_Windows_UI_CRB_Explorer_Small"
}

local ktInviteClassIcons =
{
	[GameLib.CodeEnumClass.Warrior] 			= "Icon_Windows_UI_CRB_Warrior",
	[GameLib.CodeEnumClass.Engineer] 			= "Icon_Windows_UI_CRB_Engineer",
	[GameLib.CodeEnumClass.Esper]				= "Icon_Windows_UI_CRB_Esper",
	[GameLib.CodeEnumClass.Medic]				= "Icon_Windows_UI_CRB_Medic",
	[GameLib.CodeEnumClass.Stalker] 			= "Icon_Windows_UI_CRB_Stalker",
	[GameLib.CodeEnumClass.Spellslinger]	 	= "Icon_Windows_UI_CRB_Spellslinger"
}

local karMessageIconString =
{
	"MessageIcon_Sent",
	"MessageIcon_Deny",
	"MessageIcon_Accept",
	"MessageIcon_Joined",
	"MessageIcon_Left",
	"MessageIcon_Promoted",
	"MessageIcon_Kicked",
	"MessageIcon_Disbanded",
	"MessageIcon_Error"
}

local ktMessageIcon =
{
	Sent 		= 1,
	Deny 		= 2,
	Accept 		= 3,
	Joined 		= 4,
	Left 		= 5,
	Promoted 	= 6,
	Kicked 		= 7,
	Disbanded 	= 8,
	Error 		= 9
}

local ktActionResultStrings =
{
	[GroupLib.ActionResult.LeaveFailed] 					= {strMsg = Apollo.GetString("Group_LeaveFailed"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.DisbandFailed]					= {strMsg = Apollo.GetString("Group_DisbandFailed"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.KickFailed] 						= {strMsg = Apollo.GetString("Group_KickFailed"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.PromoteFailed] 					= {strMsg = Apollo.GetString("Group_PromoteFailed"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.FlagsFailed] 					= {strMsg = Apollo.GetString("Group_FlagsFailed"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.MemberFlagsFailed] 				= {strMsg = Apollo.GetString("Group_MemberFlagsFailed"), 		strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.NotInGroup] 						= {strMsg = Apollo.GetString("Group_NotInGroup"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.ChangeSettingsFailed]			= {strMsg = Apollo.GetString("Group_SettingsFailed"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.MentoringInvalidMentor] 			= {strMsg = Apollo.GetString("Group_MentorInvalid"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.MentoringInvalidMentee] 			= {strMsg = Apollo.GetString("Group_MenteeInvalid"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.InvalidGroup] 					= {strMsg = Apollo.GetString("Group_InvalidGroup"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.MentoringSelf] 					= {strMsg = Apollo.GetString("Group_MentorSelf"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.ReadyCheckFailed] 				= {strMsg = Apollo.GetString("Group_ReadyCheckFailed"), 		strIcon = ktMessageIcon.Accept},
	[GroupLib.ActionResult.MentoringNotAllowed] 			= {strMsg = Apollo.GetString("Group_MentorDisabled"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.MarkingNotPermitted] 			= {strMsg = Apollo.GetString("Group_CantMark"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.InvalidMarkIndex] 				= {strMsg = Apollo.GetString("Group_InvalidMarkIndex"), 		strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.InvalidMarkTarget] 				= {strMsg = Apollo.GetString("Group_InvalidMarkTarget"), 		strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.MentoringInCombat] 				= {strMsg = Apollo.GetString("Group_MentoringInCombat"), 		strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.MentoringLowestLevel]			= {strMsg = Apollo.GetString("Group_LowestLevel"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.ActionResult.AlreadyInGroupInstance]			= {strMsg = Apollo.GetString("AlreadyInGroupInstance"), 		strIcon = ktMessageIcon.Error},
}

local ktInviteResultStrings =
{
	[GroupLib.Result.Sent] 					= {strMsg = Apollo.GetString("GroupInviteSent"), 				strIcon = ktMessageIcon.Sent},
	[GroupLib.Result.NoPermissions] 		= {strMsg = Apollo.GetString("GroupInviteNoPermission"), 		strIcon = ktMessageIcon.Error},
	[GroupLib.Result.PlayerNotFound]		= {strMsg = Apollo.GetString("GroupPlayerNotFound"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.Result.RealmNotFound] 		= {strMsg = Apollo.GetString("GroupRealmNotFound"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.Result.Grouped] 				= {strMsg = Apollo.GetString("GroupPlayerAlreadyGrouped"), 		strIcon = ktMessageIcon.Error},
	[GroupLib.Result.Pending] 				= {strMsg = Apollo.GetString("GroupInvitePending"), 			strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.ExpiredInviter] 		= {strMsg = Apollo.GetString("GroupInviteExpired"), 			strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.ExpiredInvitee] 		= {strMsg = Apollo.GetString("GroupYourInviteExpired"), 		strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.InvitedYou] 			= {strMsg = Apollo.GetString("CRB_GroupInviteAlreadyInvited"), 	strIcon = ktMessageIcon.Error},
	[GroupLib.Result.IsInvited] 			= {strMsg = Apollo.GetString("Group_AlreadyInvited"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.Result.NoInvitingSelf] 		= {strMsg = Apollo.GetString("Group_NoSelfInvite"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.Result.Full] 					= {strMsg = Apollo.GetString("Group_GroupFull"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.Result.RoleFull] 				= {strMsg = Apollo.GetString("Group_RoleFull"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.Result.Declined] 				= {strMsg = Apollo.GetString("GroupInviteDeclined"), 			strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.Accepted] 				= {strMsg = Apollo.GetString("Group_InviteAccepted"), 			strIcon = ktMessageIcon.Accept},
	[GroupLib.Result.NotAcceptingRequests] 	= {strMsg = Apollo.GetString("Group_NotAcceptingRequests"), 	strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.Busy]				 	= {strMsg = Apollo.GetString("Group_Busy"), 					strIcon = ktMessageIcon.Deny},
}

local ktJoinRequestResultStrings =
{
	[GroupLib.Result.Sent] 					= {strMsg = Apollo.GetString("GroupJoinRequestSent"), 				strIcon = ktMessageIcon.Sent},
	[GroupLib.Result.PlayerNotFound]		= {strMsg = Apollo.GetString("GroupPlayerNotFound"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.Result.RealmNotFound] 		= {strMsg = Apollo.GetString("GroupRealmNotFound"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.Result.Grouped] 				= {strMsg = Apollo.GetString("GroupJoinRequestGroup"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.Result.Pending] 				= {strMsg = Apollo.GetString("GroupJoinRequestPending"), 			strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.ExpiredInviter] 		= {strMsg = Apollo.GetString("GroupJoinRequestExpired"), 			strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.ExpiredInvitee] 		= {strMsg = Apollo.GetString("GroupYourJoinRequestExpired"), 		strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.InvitedYou] 			= {strMsg = Apollo.GetString("CRB_GroupJoinAlreadyRequested"), 		strIcon = ktMessageIcon.Error},
	[GroupLib.Result.NoInvitingSelf] 		= {strMsg = Apollo.GetString("Group_NoSelfJoinRequest"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.Result.Full] 					= {strMsg = Apollo.GetString("Group_GroupFull"), 					strIcon = ktMessageIcon.Error},
	[GroupLib.Result.Declined] 				= {strMsg = Apollo.GetString("GroupJoinRequestDenied"), 			strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.Accepted] 				= {strMsg = Apollo.GetString("Group_JoinRequestAccepted"), 			strIcon = ktMessageIcon.Accept},
	[GroupLib.Result.ServerControlled] 		= {strMsg = Apollo.GetString("Group_JoinRequest_ServerControlled"), strIcon = ktMessageIcon.Error},
	[GroupLib.Result.GroupNotFound] 		= {strMsg = Apollo.GetString("Group_JoinRequest_GroupNotFound"), 	strIcon = ktMessageIcon.Error},
	[GroupLib.Result.NotAcceptingRequests] 	= {strMsg = Apollo.GetString("Group_NotAcceptingRequests"), 		strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.Busy]				 	= {strMsg = Apollo.GetString("Group_Busy"), 						strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.SentToLeader]		 	= {strMsg = Apollo.GetString("Group_SentToLeader"), 				strIcon = ktMessageIcon.Sent},
	[GroupLib.Result.LeaderOffline]		 	= {strMsg = Apollo.GetString("Group_LeaderOffline"), 				strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.WrongFaction]		 	= {strMsg = Apollo.GetString("GroupWrongFaction"), 					strIcon = ktMessageIcon.Deny},
}

local ktReferralStrings =
{
	[GroupLib.Result.PlayerNotFound]		= {strMsg = Apollo.GetString("GroupPlayerNotFound"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.Result.RealmNotFound] 		= {strMsg = Apollo.GetString("GroupRealmNotFound"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.Result.Grouped] 				= {strMsg = Apollo.GetString("GroupPlayerAlreadyGrouped"), 			strIcon = ktMessageIcon.Error},
	[GroupLib.Result.Pending] 				= {strMsg = Apollo.GetString("GroupInvitePending"), 				strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.ExpiredInviter] 		= {strMsg = Apollo.GetString("GroupJoinRequestExpired"), 			strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.ExpiredInvitee] 		= {strMsg = Apollo.GetString("GroupYourJoinRequestExpired"), 		strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.InvitedYou] 			= {strMsg = Apollo.GetString("CRB_GroupJoinAlreadyRequested"), 		strIcon = ktMessageIcon.Error},
	[GroupLib.Result.NoInvitingSelf] 		= {strMsg = Apollo.GetString("Group_NoSelfInvite"), 				strIcon = ktMessageIcon.Error},
	[GroupLib.Result.Full] 					= {strMsg = Apollo.GetString("Group_GroupFull"), 					strIcon = ktMessageIcon.Error},
	[GroupLib.Result.NotAcceptingRequests] 	= {strMsg = Apollo.GetString("Group_NotAcceptingRequests"), 		strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.Busy]				 	= {strMsg = Apollo.GetString("Group_Busy"), 						strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.SentToLeader]		 	= {strMsg = Apollo.GetString("Group_SentToLeader"), 				strIcon = ktMessageIcon.Sent},
	[GroupLib.Result.LeaderOffline]		 	= {strMsg = Apollo.GetString("Group_LeaderOffline"), 				strIcon = ktMessageIcon.Deny},
	[GroupLib.Result.Declined]		 		= {strMsg = Apollo.GetString("GroupInviteRequestDeclined"), 		strIcon = ktMessageIcon.Deny},
}

local ktGroupLeftResultStrings =
{
	[GroupLib.RemoveReason.Kicked] 			= {strMsg = Apollo.GetString("Group_Kicked"), 			strIcon = ktMessageIcon.Kicked},
	[GroupLib.RemoveReason.VoteKicked] 		= {strMsg = Apollo.GetString("Group_Kicked"), 			strIcon = ktMessageIcon.Kicked},
	[GroupLib.RemoveReason.Left] 			= {strMsg = Apollo.GetString("InstancePartyLeave"), 	strIcon = ktMessageIcon.Left},
	[GroupLib.RemoveReason.Disband] 		= {strMsg = Apollo.GetString("GroupDisband"), 			strIcon = ktMessageIcon.Disbanded},
	[GroupLib.RemoveReason.RemovedByServer] = {strMsg = Apollo.GetString("Group_KickedByServer"), 	strIcon = ktMessageIcon.Left},
}

local ktLootRules =
{
	[GroupLib.LootRule.Master] 			= Apollo.GetString("Group_MasterLoot"),
	[GroupLib.LootRule.RoundRobin] 		= Apollo.GetString("Group_RoundRobin"),
	[GroupLib.LootRule.NeedBeforeGreed] = Apollo.GetString("Group_NeedBeforeGreed"),
	[GroupLib.LootRule.FreeForAll] 		= Apollo.GetString("Group_FFA")
}

local ktHarvestLootRules =
{
	[GroupLib.HarvestLootRule.FirstTagger] 		= Apollo.GetString("Group_FFA"),
	[GroupLib.HarvestLootRule.RoundRobin] 		= Apollo.GetString("Group_RoundRobin"),
}

local ktLootThreshold =
{
	[Item.CodeEnumItemQuality.Inferior] 		= Apollo.GetString("CRB_Inferior"),
	[Item.CodeEnumItemQuality.Average] 			= Apollo.GetString("CRB_Average"),
	[Item.CodeEnumItemQuality.Good] 			= Apollo.GetString("CRB_Good"),
	[Item.CodeEnumItemQuality.Excellent] 		= Apollo.GetString("CRB_Excellent"),
	[Item.CodeEnumItemQuality.Superb] 			= Apollo.GetString("CRB_Superb"),
	[Item.CodeEnumItemQuality.Legendary] 		= Apollo.GetString("CRB_Legendary"),
	[Item.CodeEnumItemQuality.Artifact]	 		= Apollo.GetString("CRB_Artifact")
}

local ktDifficulty =
{
	[GroupLib.Difficulty.Normal] 	= Apollo.GetString("CRB_Normal"),
	[GroupLib.Difficulty.Veteran] 	= Apollo.GetString("CRB_Veteran")
}

local kstrRaidMarkerToSprite =
{
	"Icon_Windows_UI_CRB_Marker_Bomb",
	"Icon_Windows_UI_CRB_Marker_Ghost",
	"Icon_Windows_UI_CRB_Marker_Mask",
	"Icon_Windows_UI_CRB_Marker_Octopus",
	"Icon_Windows_UI_CRB_Marker_Pig",
	"Icon_Windows_UI_CRB_Marker_Chicken",
	"Icon_Windows_UI_CRB_Marker_Toaster",
	"Icon_Windows_UI_CRB_Marker_UFO",
}

local kfMessageDuration = 3.000
local kfDelayDuration 	= 0.010
local knInviteTimeout 	= 29 -- how long until an invite times out (display only, minus one to give code time to start)
local knMentorTimeout 	= 29 -- how long until an invite times out (display only, minus one to give code time to start)
local knGroupMax 		= 5  -- max number of people in a group
local knInviteMax 		= knGroupMax - 1 -- how many people can be invited
local knSaveVersion 	= 1


-- Setting keys used by options, to be loaded in/saved during OnRestore and OnLoad events
local DefaultSettings = {
	-- Text-Overlay Settings
	ShowHP_K = true,
	ShowHP_Full = false,
	ShowHP_Pct = true,
	ShowShield_K = true,
	ShowShield_Pct = false,
	ShowAbsorb_K = true,
	LockFrame = false,
	TrackDebuffs = false,
	ShowLevel = false,
	ShowShieldBar = true,
	ShowAbsorbBar = true,
	ShowBarDesign_Bright = true,
	ShowBarDesign_Flat = false,
	MouseOverSelection = false,
	RememberPrevTarget = false,
	SemiTransparency = false,
	FullTransparency = false,
	DisableMentoring = false,
	CheckRange = false,
	MaxRange = 50,
	
	-- Custom settings via /bpf colors
	bClassSpecificBarColors = false,
	
	strColorGeneral_HPHealthy_Bright = "ff4bd634",
	strColorGeneral_HPDebuff_Bright = "ff720cb1",
	strColorGeneral_Shield_Bright = "ff3b9fd8",
	strColorGeneral_Absorb_Bright = "ffff8c00",
	
	strColorEngineer_HPHealthy_Bright = "ff4bd634",
	strColorEngineer_HPDebuff_Bright = "ff720cb1",
	strColorEngineer_Shield_Bright = "ff3b9fd8",
	strColorEngineer_Absorb_Bright = "ffff8c00",
	
	strColorEsper_HPHealthy_Bright = "ff4bd634",
	strColorEsper_HPDebuff_Bright = "ff720cb1",
	strColorEsper_Shield_Bright = "ff3b9fd8",
	strColorEsper_Absorb_Bright = "ffff8c00",
	
	strColorMedic_HPHealthy_Bright = "ff4bd634",
	strColorMedic_HPDebuff_Bright = "ff720cb1",
	strColorMedic_Shield_Bright = "ff3b9fd8",
	strColorMedic_Absorb_Bright = "ffff8c00",
	
	strColorSpellslinger_HPHealthy_Bright = "ff4bd634",
	strColorSpellslinger_HPDebuff_Bright = "ff720cb1",
	strColorSpellslinger_Shield_Bright = "ff3b9fd8",
	strColorSpellslinger_Absorb_Bright = "ffff8c00",
	
	strColorStalker_HPHealthy_Bright = "ff4bd634",
	strColorStalker_HPDebuff_Bright = "ff720cb1",
	strColorStalker_Shield_Bright = "ff3b9fd8",
	strColorStalker_Absorb_Bright = "ffff8c00",
	
	strColorWarrior_HPHealthy_Bright = "ff4bd634",
	strColorWarrior_HPDebuff_Bright = "ff720cb1",
	strColorWarrior_Shield_Bright = "ff3b9fd8",
	strColorWarrior_Absorb_Bright = "ffff8c00",
	
	strColorGeneral_HPHealthy_Flat = "ff26a614",
	strColorGeneral_HPDebuff_Flat = "ff8b008b",
	strColorGeneral_Shield_Flat = "ff2574a9",
	strColorGeneral_Absorb_Flat = "ffca7819",
	
	strColorEngineer_HPHealthy_Flat = "ff26a614",
	strColorEngineer_HPDebuff_Flat = "ff8b008b",
	strColorEngineer_Shield_Flat = "ff2574a9",
	strColorEngineer_Absorb_Flat = "ffca7819",
	
	strColorEsper_HPHealthy_Flat = "ff26a614",
	strColorEsper_HPDebuff_Flat = "ff8b008b",
	strColorEsper_Shield_Flat = "ff2574a9",
	strColorEsper_Absorb_Flat = "ffca7819",
	
	strColorMedic_HPHealthy_Flat = "ff26a614",
	strColorMedic_HPDebuff_Flat = "ff8b008b",
	strColorMedic_Shield_Flat = "ff2574a9",
	strColorMedic_Absorb_Flat = "ffca7819",
	
	strColorSpellslinger_HPHealthy_Flat = "ff26a614",
	strColorSpellslinger_HPDebuff_Flat = "ff8b008b",
	strColorSpellslinger_Shield_Flat = "ff2574a9",
	strColorSpellslinger_Absorb_Flat = "ffca7819",
	
	strColorStalker_HPHealthy_Flat = "ff26a614",
	strColorStalker_HPDebuff_Flat = "ff8b008b",
	strColorStalker_Shield_Flat = "ff2574a9",
	strColorStalker_Absorb_Flat = "ffca7819",
	
	strColorWarrior_HPHealthy_Flat = "ff26a614",
	strColorWarrior_HPDebuff_Flat = "ff8b008b",
	strColorWarrior_Shield_Flat = "ff2574a9",
	strColorWarrior_Absorb_Flat = "ffca7819",
	
	}

DefaultSettings.__index = DefaultSettings


---------------------------------------------------------------------------------------------------
-- BetterPartyFrames initialization
---------------------------------------------------------------------------------------------------
function BetterPartyFrames:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	o.GroupMemberCount 				= 0
	o.nGroupMemberClicked 			= nil
	o.tGroupUnits 					= {}

	return o
end

function BetterPartyFrames:Init()
	Apollo.RegisterAddon(self)
end

function BetterPartyFrames:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end

	local locInviteLocation = self.wndGroupInviteDialog and self.wndGroupInviteDialog:GetLocation() or self.locSavedInviteLoc
	local locMentorLocation = self.wndMentor and self.wndMentor:GetLocation() or self.locSavedMentorLoc

	local tSave =
	{
		tInviteLocation 			= locInviteLocation and locInviteLocation:ToTable() or nil,
		tMentorLocation 			= locMentorLocation and locMentorLocation:ToTable() or nil,
		bNeverShowRaidConvertNotice = self.bNeverShowRaidConvertNotice or false,
		fInviteTimerStart 			= self.fInviteTimerStartTime,
		strInviterName 				= self.strInviterName,
		fMentorTimerStart			= self.fMentorTimerStartTime,
		nSaveVersion 				= knSaveVersion,
	}
	
	self:copyTable(self.settings, tSave)

	return tSave
end

function BetterPartyFrames:OnRestore(eType, tSavedData)
	if not tSavedData or tSavedData.nSaveVersion ~= knSaveVersion then
		return
	end

	self.bNeverShowRaidConvertNotice = tSavedData.bNeverShowRaidConvertNotice or false

	if tSavedData.tInviteLocation then
		self.locSavedInviteLoc = WindowLocation.new(tSavedData.tInviteLocation)
	end

	if tSavedData.tMentorLocation then
		self.locSavedMentorLoc = WindowLocation.new(tSavedData.tMentorLocation)
	end

	if tSavedData.fInviteTimerStart then
		local tInviteData = GroupLib.GetInvite()
		if tInviteData and #tInviteData > 0 then
			self.fInviteTimerStartTime = tSavedData.fInviteTimerStart
			self.strInviterName = tSavedData.strInviterName or ""
		end
	end

	if tSavedData.fMentorTimerStart then
		local tMentorData = GroupLib.GetMentoringList()
		if tMentorData and #tMentorData > 0 then
			self.fMentorTimerStartTime = tSavedData.fMentorTimerStart
		end
	end
	
	self.settings = self:copyTable(tSavedData, self.settings)
end

---------------------------------------------------------------------------------------------------
-- BetterPartyFrames EventHandlers
---------------------------------------------------------------------------------------------------
function BetterPartyFrames:OnLoad()
	self.xmlOptionsDoc = XmlDoc.CreateFromFile("GroupDisplayOptions.xml")
	self.xmlDoc = XmlDoc.CreateFromFile("BetterPartyFrames.xml")
	Apollo.LoadSprites("BPF.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)
		
	-- Configures our forms
	self.wndConfig = Apollo.LoadForm(self.xmlDoc, "ConfigForm", nil, self)
	self.wndConfig:Show(false)
	self.wndConfigColors = Apollo.LoadForm(self.xmlDoc, "ConfigColorsForm", nil, self)
	self.wndConfigColors:Show(false)
	
	self.wndTargetFrame = self.wndConfigColors:FindChild("TargetFrame")
	
	self.wndConfigColorsGeneral = Apollo.LoadForm(self.xmlDoc, "ConfigColorsGeneral", self.wndTargetFrame, self)
	self.wndConfigColorsEngineer = Apollo.LoadForm(self.xmlDoc, "ConfigColorsEngineer", self.wndTargetFrame, self)
	self.wndConfigColorsEsper = Apollo.LoadForm(self.xmlDoc, "ConfigColorsEsper", self.wndTargetFrame, self)
	self.wndConfigColorsMedic = Apollo.LoadForm(self.xmlDoc, "ConfigColorsMedic", self.wndTargetFrame, self)
	self.wndConfigColorsSpellslinger = Apollo.LoadForm(self.xmlDoc, "ConfigColorsSpellslinger", self.wndTargetFrame, self)
	self.wndConfigColorsStalker = Apollo.LoadForm(self.xmlDoc, "ConfigColorsStalker", self.wndTargetFrame, self)
	self.wndConfigColorsWarrior = Apollo.LoadForm(self.xmlDoc, "ConfigColorsWarrior", self.wndTargetFrame, self)
	
	-- Register handler for slash-commands that opens configuration form
	Apollo.RegisterSlashCommand("bpf", "OnSlashCmd", self)
	self.settings = self.settings or {}
	setmetatable(self.settings, DefaultSettings)
	
end

function BetterPartyFrames:OnDocumentReady()
	if  self.xmlDoc == nil then
		return
	end
	Apollo.RegisterEventHandler("Group_Invited",			"OnGroupInvited", self)				-- ( name )
	Apollo.RegisterEventHandler("Group_Invite_Result",		"OnGroupInviteResult", self)		-- ( name, result )
	Apollo.RegisterEventHandler("Group_JoinRequest",		"OnGroupJoinRequest", self)			-- ( name )
	Apollo.RegisterEventHandler("Group_Referral",			"OnGroupReferral", self)			-- ( nMemberIndex, name )
	Apollo.RegisterEventHandler("Group_Request_Result",		"OnGroupRequestResult", self)		-- ( name, result, bIsJoin )
	Apollo.RegisterEventHandler("Group_Join",				"OnGroupJoin", self)				-- ()
	Apollo.RegisterEventHandler("Group_Add",				"OnGroupAdd", self)					-- ( name )
	Apollo.RegisterEventHandler("Group_Remove",				"OnGroupRemove", self)				-- ( name, reason )
	Apollo.RegisterEventHandler("Group_Left",				"OnGroupLeft", self)				-- ( reason )

	Apollo.RegisterEventHandler("Group_MemberFlagsChanged",	"OnGroupMemberFlags", self)			-- ( nMemberIndex, bIsFromPromotion, tChangedFlags)

	Apollo.RegisterEventHandler("Group_MemberPromoted",		"OnGroupMemberPromoted", self)		-- ( name, bSelf )
	Apollo.RegisterEventHandler("Group_Operation_Result",	"OnGroupOperationResult", self)		-- ( name, action )
	Apollo.RegisterEventHandler("Group_Updated",			"OnGroupUpdated", self)				-- ()
	Apollo.RegisterEventHandler("Group_FlagsChanged",		"OnGroupUpdated", self)				-- ()
	Apollo.RegisterEventHandler("Group_LootRulesChanged",	"OnGroupLootRulesChanged", self)	-- ()
	Apollo.RegisterEventHandler("Group_AcceptInvite",		"OnGroupAcceptInvite", self)		-- ()
	Apollo.RegisterEventHandler("Group_DeclineInvite",		"OnGroupDeclineInvite", self)		-- ()
	Apollo.RegisterEventHandler("Group_Mentor",				"OnGroupMentor", self)				-- ( tMemberList, bAlreadyMentoring )
	Apollo.RegisterEventHandler("Group_MentorLeftAOI",		"OnGroupMentorLeftAOI", self)		-- ( nTimeUntilMentoringDisabled, bClearUI )
	Apollo.RegisterEventHandler("LootRollUpdate",			"OnLootRollUpdate", self)			-- ()

	Apollo.RegisterEventHandler("Group_ReadyCheck",			"OnGroupReadyCheck", self)			-- ( nMemberIndex, strMessage )

	Apollo.RegisterEventHandler("RaidInfoResponse",			"OnRaidInfoResponse", self)			-- ( arRaidInfo )

	Apollo.RegisterEventHandler("MasterLootUpdate",			"OnMasterLootUpdate", 	self)

	Apollo.RegisterTimerHandler("InviteTimer", 				"OnInviteTimer", self)
	Apollo.RegisterTimerHandler("GroupMessageDelayTimer", 	"ProcessAlerts", self)
	Apollo.RegisterTimerHandler("GroupMessageTimer", 		"OnGroupMessageTimer", self)
	Apollo.RegisterTimerHandler("MentorTimer", 				"OnMentorTimer", self)
	Apollo.RegisterTimerHandler("MentorAOITimer", 			"OnMentorAOITimer", self)

	Apollo.RegisterTimerHandler("GroupUpdateTimer", 		"OnUpdateTimer", self)
	Apollo.CreateTimer("GroupUpdateTimer", 0.050, true)
	Apollo.StopTimer("GroupUpdateTimer")

	Apollo.RegisterEventHandler("GenericEvent_AttachWindow_GroupDisplayOptions", 	"AttachWindowGroupDisplayOptions", self)
	Apollo.RegisterEventHandler("GenericEvent_ShowConfirmLeaveDisband", 			"ShowConfirmLeaveDisband", self)
	
	Apollo.RegisterEventHandler("ChangeWorld", "OnChangeWorld", self)
		
	-- Required for saving frame location across sessions
	Apollo.RegisterEventHandler("WindowManagementReady", 	"OnWindowManagementReady", self)
	
	-- GeminiColor
	self.GeminiColor = Apollo.GetPackage("GeminiColor").tPackage
	
	self:RefreshSettings()	
	
	---------------------------------------------------------------------------------------------------
	-- BetterPartyFrames Member Variables
	---------------------------------------------------------------------------------------------------
	self.wndGroupHud 			= Apollo.LoadForm(self.xmlDoc, "GroupHud", "FixedHudStratum", self)
	self.wndGroupHud:Show(false, true)
	self.wndLeaveGroup 			= self.wndGroupHud:FindChild("GroupHudLeaveDialog")
	self.wndLeaveGroup:Show(false,true)
	self.wndGroupMessage 		= self.wndGroupHud:FindChild("GroupHudMessage")
	self.bMessagesQueued 		= false
	self.tMessageQueue 			= {nFirst = 0, nLast = -1}

	self.wndGroupPortraitContainer = self.wndGroupHud:FindChild("GroupPortraitContainer")

	self.wndGroupInviteDialog 	= Apollo.LoadForm(self.xmlDoc, "GroupInviteDialog", nil, self)
	self.wndGroupInviteDialog:Show(false, true)
	if self.locSavedInviteLoc then
		self.wndGroupInviteDialog:MoveToLocation(self.locSavedInviteLoc)
	end

	self.wndInviteMemberList 	= self.wndGroupInviteDialog:FindChild("InviteMemberList")
	self.nInviteTimer 			= knInviteTimeout

	self.eChatChannel 			= ChatSystemLib.ChatChannel_Party

	self.wndGroupInviteDialog:Show(false)
	if self.fInviteTimerStartTime then
		self:OnGroupInvited(self.strInviterName)
	end

	self.tGroupWndPortraits 	= {}

	self.eInstanceDifficulty 	= GroupLib.GetInstanceDifficulty()
	self.tLootRules	 			= GroupLib.GetLootRules()

	self.wndMentor 				= Apollo.LoadForm(self.xmlDoc, "GroupMentorDialog", nil, self)
	self.wndMentor:Show(false, true)
	if self.locSavedMentorLoc then
		self.wndMentor:MoveToLocation(self.locSavedMentorLoc)
	end

	if self.fMentorTimerStartTime then
		self:OnGroupMentor(GroupLib.GetMentoringList(), GameLib:GetPlayerUnit():IsMentoring(), false)
	end

	self.wndMentorAOI			= Apollo.LoadForm(self.xmlDoc, "GroupMentorLeftAoIDialog", nil, self)
	self.wndMentorAOI:Show(false, true)
	self.wndRequest				= Apollo.LoadForm(self.xmlDoc, "GroupRequestDialog", nil, self)
	self.wndRequest:Show(false, true)
	--self.unitGroupMemberClicked = nil


	self:OnGroupUpdated()
	
	---------------------------------------------------------------------------------------------------
	-- BetterPartyFrames Setup
	---------------------------------------------------------------------------------------------------

	for idx = 1, #karMessageIconString do
		self.wndGroupMessage:FindChild(karMessageIconString[idx]):Show(false)
	end

	self.wndRequest:Show(false)

	Event_FireGenericEvent("GenericEvent_InitializeGroupLeaderOptions", self.wndGroupHud:FindChild("GroupControlsBtn"))
	-- TEMP HACK: Try again in case this loads first
	Apollo.RegisterTimerHandler("GroupDisplayOptions_TEMP", "GroupDisplayOptions_TEMP", self)
	Apollo.CreateTimer("GroupDisplayOptions_TEMP", 3, false)
	Apollo.StartTimer("GroupDisplayOptions_TEMP")

	if GroupLib.InGroup() then
		if GroupLib.InRaid() then
			self:OnUpdateTimer()
		else
			Apollo.StartTimer("GroupUpdateTimer")
		end
	end
end

-- Sets the party frame location once windows are ready.
function BetterPartyFrames:OnWindowManagementReady()
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndGroupHud, strName = "BetterPartyFrames" })
	self:LockFrameHelper(self.settings.LockFrame)
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
	self:LoadBarsTexturesHelper(self.settings.ShowBarDesign_Bright, self.settings.ShowBarDesign_Flat)
end

function BetterPartyFrames:GroupDisplayOptions_TEMP()
	-- TEMP HACK: Try again in case this loads first
	Event_FireGenericEvent("GenericEvent_InitializeGroupLeaderOptions", self.wndGroupHud:FindChild("GroupControlsBtn"))
end

---------------------------------------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------------------------------------

function BetterPartyFrames:LoadPortrait(idx)
	local wndHud = Apollo.LoadForm(self.xmlDoc, "GroupPortraitHud", self.wndGroupPortraitContainer)

	self.tGroupWndPortraits[idx] =
	{
		idx 				= idx,
		wndHud 				= wndHud,
		wndLeader 			= wndHud:FindChild("Leader"),
		wndName 			= wndHud:FindChild("Name"),
		wndClass 			= wndHud:FindChild("Class"),
		wndHealth 			= wndHud:FindChild("Health"),
		wndShields 			= wndHud:FindChild("Shields"),
		wndMaxShields 		= wndHud:FindChild("MaxShields"),
		wndMaxAbsorb 		= wndHud:FindChild("MaxAbsorbBar"),
		wndLowHealthFlash	= wndHud:FindChild("LowHealthFlash"),
		wndPathIcon 		= wndHud:FindChild("PathIcon"),
		wndOffline			= wndHud:FindChild("Offline"),
		wndMark				= wndHud:FindChild("Mark"),
		wndHealthBG			= wndHud:FindChild("GroupPortraitHealthBG")
	}

	self.tGroupWndPortraits[idx].wndHud:Show(false)

	-- We apparently resize bars rather than set progress
	self:SetBarValue(self.tGroupWndPortraits[idx].wndHealth, 0, 100, 100)
	self:SetBarValue(self.tGroupWndPortraits[idx].wndShields, 0, 100, 100)

	if self.nFrameLeft == nil then
		self.nFrameLeft, self.nFrameTop, self.nFrameRight, self.nFrameBottom = self.tGroupWndPortraits[idx].wndHealth:GetAnchorOffsets()
		self.nShieldFrameLeft, self.nShieldFrameTop, self.nShieldFrameRight, self.nShieldFrameBottom = self.tGroupWndPortraits[idx].wndShields:GetAnchorOffsets()
		self.nMaxShieldFrameLeft, self.nMaxShieldFrameTop, self.nMaxShieldFrameRight, self.nMaxShieldFrameBottom = self.tGroupWndPortraits[idx].wndMaxShields:GetAnchorOffsets()
		self.nMaxAbsorbFrameLeft, self.nMaxAbsorbFrameTop, self.nMaxAbsorbFrameRight, self.nMaxAbsorbFrameBottom = self.tGroupWndPortraits[idx].wndMaxAbsorb:GetAnchorOffsets()
	end

	self.tGroupWndPortraits[idx].wndHud:SetData(idx)
	self.tGroupWndPortraits[idx].wndHud:FindChild("GroupPortraitBtn"):SetData(idx)

	self:HelperResizeGroupContents()
end

---------------------------------------------------------------------------------------------------
-- Recieved an Invitation
---------------------------------------------------------------------------------------------------
function BetterPartyFrames:OnGroupInvited(strInviterName) -- builds the invite when I recieve it
	if self.eChatChannel ~= nil then
		ChatSystemLib.PostOnChannel(self.eChatChannel, String_GetWeaselString(Apollo.GetString("GroupInvite"), strInviterName), "")
	end
	self.strInviterName = strInviterName

	self.wndInviteMemberList:DestroyChildren()

	local arInvite = GroupLib.GetInvite()
	for idx, tMemberInfo in ipairs(arInvite) do-- display group members in an invite
		if tMemberInfo ~= nil then
			local wndEntry = ""
			if tMemberInfo.bIsLeader then -- choose a frame
				wndEntry = Apollo.LoadForm(self.xmlDoc, "GroupInviteLeader", self.wndInviteMemberList, self)
			else
				wndEntry = Apollo.LoadForm(self.xmlDoc, "GroupInviteMember", self.wndInviteMemberList, self)
			end

			wndEntry:FindChild("InviteMemberLevel"):SetText(tMemberInfo.nLevel)
			wndEntry:FindChild("InviteMemberName"):SetText(tMemberInfo.strCharacterName)
			wndEntry:FindChild("InviteMemberPathIcon"):SetSprite(ktInvitePathIcons[tMemberInfo.ePathType])

			local strSpriteToUse = "CRB_GroupSprites:sprGrp_MFrameIcon_Axe"
			if ktInviteClassIcons[tMemberInfo.eClassId] then
				strSpriteToUse = ktInviteClassIcons[tMemberInfo.eClassId]
			end

			wndEntry:FindChild("InviteMemberClass"):SetSprite(strSpriteToUse)
		end
	end

	local nOpenSlots = knInviteMax - table.getn(arInvite) -- how many slots are open
	if nOpenSlots > 0 then -- make sure it's not running a negative
		for nBlankEntry = 1, nOpenSlots do -- populate the interface
			local wndBlankEntry = Apollo.LoadForm(self.xmlDoc, "GroupInviteBlank", self.wndInviteMemberList, self)
		end
	end
	self.wndInviteMemberList:ArrangeChildrenVert()

	if not self.fInviteTimerStartTime then
		self.fInviteTimerStartTime = os.clock()
	end

	self.fInviteTimerDelta = os.clock() - self.fInviteTimerStartTime
	self.wndGroupInviteDialog:FindChild("Timer"):SetText("")
	local strTime = string.format("%d:%02d", math.floor(self.fInviteTimerDelta / 60), math.ceil(30 - (self.fInviteTimerDelta % 60)))
	self.wndGroupInviteDialog:FindChild("Timer"):SetText(String_GetWeaselString(Apollo.GetString("Group_ExpiresTimer"), strTime))
	Apollo.CreateTimer("InviteTimer", 1.000, true)

	 self.wndGroupInviteDialog:Invoke(true)
	 Sound.Play(Sound.PlayUISocialPartyInviteSent)
end

function BetterPartyFrames:OnGroupJoinRequest(strInviterName) -- builds the invite when I recieve it
	-- undone need token passed as context

	--Apollo.DPF("BetterPartyFrames:OnGroupJoinRequest")

	-- a join message means that someone has requested to join our existing party
	local str = String_GetWeaselString(Apollo.GetString("GroupJoinRequest"), strInviterName)
	self.wndRequest:FindChild("Title"):SetText(str)
	self.wndRequest:Show(true)
	if self.eChatChannel ~= nil then
		ChatSystemLib.PostOnChannel(self.eChatChannel, str, "")
	end
end

function BetterPartyFrames:OnGroupReferral(nMemberIndex, strTarget) -- builds the invite when I receive it
	-- undone need token passed as context

	--Apollo.DPF("BetterPartyFrames:OnGroupReferral")

	-- a join message means that someone has requested to join our existing party
	local str = String_GetWeaselString(Apollo.GetString("GroupReferral"), strTarget)
	self.wndRequest:FindChild("Title"):SetText(str)
	self.wndRequest:Show(true)
	if self.eChatChannel ~= nil then
		ChatSystemLib.PostOnChannel(self.eChatChannel, str, "")
	end
end

function BetterPartyFrames:OnInviteTimer()

	self.fInviteTimerDelta = self.fInviteTimerDelta + 1
	if self.fInviteTimerDelta <= 31 then
		local strTime = string.format("%d:%02d", math.floor(self.fInviteTimerDelta / 60), math.ceil(30 - (self.fInviteTimerDelta % 60)))
		self.wndGroupInviteDialog:FindChild("Timer"):SetText(String_GetWeaselString(Apollo.GetString("Group_ExpiresTimer"), strTime))
	else
		self.wndGroupInviteDialog:FindChild("Timer"):SetText("X")
	end
end

function BetterPartyFrames:OnGroupInviteDialogAccept()
	GroupLib.AcceptInvite()
	self.wndGroupInviteDialog:Show(false)
	self.fInviteTimerStartTime = nil
	Apollo.StopTimer("InviteTimer")
	Sound.Play(Sound.PlayUISocialPartyInviteAccept)
end

function BetterPartyFrames:OnGroupInviteDialogDecline()
	GroupLib.DeclineInvite()
	self.wndGroupInviteDialog:Show(false)
	self.fInviteTimerStartTime = nil
	Apollo.StopTimer("InviteTimer")
	Sound.Play(Sound.PlayUISocialPartyInviteDecline)
end

function BetterPartyFrames:OnRaidInfoResponse(arRaidInfo)
	if #arRaidInfo == 0 then
		ChatSystemLib.PostOnChannel( ChatSystemLib.ChatChannel_System, Apollo.GetString("Command_UsageRaidInfoNone"), "" )
		return
	end

	for _, tRaidInfo in ipairs(arRaidInfo) do

		-- tRaidInfo.strWorldName can be nil
		-- tRaidInfo.strSavedInstanceId is a string with a large number
		-- tRaidInfo.nWorldId is the id of the instance
		-- tRaidInfo.strDateExpireUTC is string of the full date the lock resets.
		-- tRaidInfo.fDaysFromNow is relative time from now that the lock resets.

		local strMessage = String_GetWeaselString(Apollo.GetString("Command_UsageRaidInfo"), tRaidInfo.strWorldName or "", tRaidInfo.strSavedInstanceId, tRaidInfo.strDateExpireUTC )
		ChatSystemLib.PostOnChannel( ChatSystemLib.ChatChannel_System, strMessage, "" )
	end
end

function BetterPartyFrames:OnChangeWorld()
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
	self:LoadBarsTexturesHelper(self.settings.ShowBarDesign_Bright, self.settings.ShowBarDesign_Flat)
end

---------------------------------------------------------------------------------------------------
-- Group Formatting
---------------------------------------------------------------------------------------------------

function BetterPartyFrames:DestroyGroup()
	for idx, tMemberInfo in pairs(self.tGroupWndPortraits) do -- This is essentially self.wndGroupPortraitContainer:DestroyChildren()
		if tMemberInfo.wndHud and tMemberInfo.wndHud:IsValid() then
			tMemberInfo.wndHud:Destroy()
		end
		self.tGroupWndPortraits[idx] = nil
	end

	Apollo.StopTimer("GroupUpdateTimer")

	local nMemberCount = GroupLib.GetMemberCount()
	if nMemberCount <= 1 then
		return
	end

	Apollo.StartTimer("GroupUpdateTimer")

	self:OnGroupUpdated()
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
	self:LoadBarsTexturesHelper(self.settings.ShowBarDesign_Bright, self.settings.ShowBarDesign_Flat)
end

function BetterPartyFrames:PostChangeToChannel(nPrevValue, nNextValue, tDescriptionTable, strChangeString, strUnknownChangeString)
	if nPrevValue ~= nNextValue then
		if tDescriptionTable[nNextValue] ~= nil then
			if self.eChatChannel ~= nil then
				ChatSystemLib.PostOnChannel(self.eChatChannel, String_GetWeaselString(strChangeString, tDescriptionTable[nNextValue]), "") --lua placeholder string
			end
		else
			if self.eChatChannel ~= nil then
				ChatSystemLib.PostOnChannel(self.eChatChannel, strUnknownChangeString, "") --lua placeholder string
			end
		end
	end
end

function BetterPartyFrames:OnGroupUpdated()
	if GroupLib.InRaid() then
		return
	end

	for idx, tPortrait in pairs(self.tGroupWndPortraits) do
		tPortrait.wndHud:Show(false)
	end

	if GroupLib.InInstance() then
		self.eChatChannel = ChatSystemLib.ChatChannel_Instance;
	else
		self.eChatChannel = ChatSystemLib.ChatChannel_Party;
	end

	if self.bDisplayedRaid == nil and GroupLib.InRaid() then
		self.bDisplayedRaid = true
		if self.eChatChannel ~= nil then
			ChatSystemLib.PostOnChannel(self.eChatChannel, Apollo.GetString("Group_BecomeRaid"), "") --lua placeholder string
		end

		if self.wndRaidNotice and self.wndRaidNotice:IsValid() then
			self.wndRaidNotice:Destroy()
			self.wndRaidNotice = nil
		end

		if self.bNeverShowRaidConvertNotice == false then
			self.wndRaidNotice = Apollo.LoadForm(self.xmlOptionsDoc, "RaidConvertedForm", nil, self)
			self.wndRaidNotice:Show(true)
			self.wndRaidNotice:ToFront()
		end
	end

	self.eInstanceDifficulty = GroupLib.GetInstanceDifficulty()

	self:PostChangeToChannel(self.eInstanceDifficulty, GroupLib.GetInstanceDifficulty(), ktDifficulty, Apollo.GetString("Group_DifficultyChangedTo"), Apollo.GetString("Group_DifficultyChangedDefault"))

	-- Attach the portrait form to each hud slot.

	if GroupLib.InGroup() and GroupLib.GetMemberCount() == 0 then
		self.bDisplayedRaid = nil
		self:HelperResizeGroupContents()
		return
	end

	local unitMe = GameLib.GetPlayerUnit()
	if unitMe == nil then
		return
	end

	self.nGroupMemberCount = GroupLib.GetMemberCount()

	local nCount = 0
	if self.nGroupMemberCount > 0 then
		for idx = 1, self.nGroupMemberCount do
			local tMemberInfo = GroupLib.GetGroupMember(idx)
			if tMemberInfo ~= nil then
				if self.tGroupWndPortraits[idx] == nil then
					self:LoadPortrait(idx)
				end
				self.tGroupWndPortraits[idx].wndHud:Show(true)

				nCount = nCount + 1
			end
		end
	end

	if nCount == 0 then
		self:CloseGroupHUD()
	else
		self.wndGroupHud:FindChild("GroupControlsBtn"):Show(true)
		--self.wndGroupHud:FindChild("GroupBagBtn"):Show(true) -- TODO TEMP DISABLED
		self.wndGroupHud:Show(true)
	end

	self:HelperResizeGroupContents()
end

function BetterPartyFrames:OnGroupLootRulesChanged()
	if GroupLib.InRaid() then
		return
	end

	local tNewLootRules = GroupLib.GetLootRules()

	self:PostChangeToChannel(self.tLootRules.eNormalRule, tNewLootRules.eNormalRule, ktLootRules, Apollo.GetString("Group_LootChangedTo"), Apollo.GetString("Group_LootChangedDefault"))
	self:PostChangeToChannel(self.tLootRules.eThresholdRule, tNewLootRules.eThresholdRule, ktLootRules, Apollo.GetString("Group_ThresholdRuleChangedTo"), Apollo.GetString("Group_ThresholdRuleChangedDefault"))
	self:PostChangeToChannel(self.tLootRules.eThresholdQuality, tNewLootRules.eThresholdQuality, ktLootThreshold, Apollo.GetString("Group_ThresholdQualityChangedTo"), Apollo.GetString("Group_ThresholdQualityChangedDefault"))
	self:PostChangeToChannel(self.tLootRules.eHarvestRule, tNewLootRules.eHarvestRule, ktHarvestLootRules, Apollo.GetString("Group_HarvestLootChangedTo"), Apollo.GetString("Group_HarvestLootChangedDefault"))

	self.tLootRules = tNewLootRules
end

function BetterPartyFrames:OnGroupControlsCheck(wndHandler, wndControl)
	Event_FireGenericEvent("GenericEvent_UpdateGroupLeaderOptions")
end

function BetterPartyFrames:OnGroupPortraitClick(wndHandler, wndControl, eMouseButton)
	local tInfo = wndHandler:GetData()
	local nMemberIdx = tInfo[1]
	local strName = tInfo[2] -- In case they run out of range and we lose the unitMember

	local unitMember = GroupLib.GetUnitForGroupMember(nMemberIdx) --returns nil when the member is out of range among other reasons
	if nMemberIdx and unitMember then
		GameLib.SetTargetUnit(unitMember)
		
		if self.settings.RememberPrevTarget then
			self.PrevTarget = unitMember
		end

	end

	if eMouseButton == GameLib.CodeEnumInputMouse.Right then
		Event_FireGenericEvent("GenericEvent_NewContextMenuPlayerDetailed", wndHandler, strName, unitMember) -- unitMember is optional
	end
end

function BetterPartyFrames:OnGroupBagBtn()
	Event_FireGenericEvent("GenericEvent_ToggleGroupBag")
end

function BetterPartyFrames:OnMasterLootUpdate()
	local tMasterLoot = GameLib.GetMasterLoot()
	if tMasterLoot and #tMasterLoot > 0 then
		self.wndGroupHud:FindChild("GroupBagBtn"):Show(true)
		self.wndGroupHud:FindChild("GroupBagBtn"):Enable(true)
	else
		self.wndGroupHud:FindChild("GroupBagBtn"):Show(false)
		self.wndGroupHud:FindChild("GroupBagBtn"):Enable(false)
	end
end

---------------------------------------------------------------------------------------------------
-- Per Player Options Menu (Promote/Kick/etc.)
---------------------------------------------------------------------------------------------------

function BetterPartyFrames:OnKick()
	if self.nGroupMemberClicked == nil then
		return
	end
	GroupLib.Kick(self.nGroupMemberClicked, "")
end

function BetterPartyFrames:OnLocate()
	if self.nGroupMemberClicked == nil then
		return
	end
	local unitMember = GroupLib.GetUnitForGroupMember(self.nGroupMemberClicked)
	if unitMember then
		unitMember:ShowHintArrow()
	end
end

function BetterPartyFrames:OnPromote()
	if self.nGroupMemberClicked == nil then
		return
	end
	GroupLib.Promote(self.nGroupMemberClicked, "")
end

function BetterPartyFrames:ShowConfirmLeaveDisband(nType)
	self.wndLeaveGroup:FindChild("ConfirmLeaveBtn"):Show(false)
	self.wndLeaveGroup:FindChild("ConfirmDisbandBtn"):Show(false)
	if nType == 0 then --disband
		self.wndLeaveGroup:FindChild("LeaveText"):SetText(Apollo.GetString("CRB_Are_you_sure_you_want_to_disband_this_group"))
		self.wndLeaveGroup:FindChild("ConfirmDisbandBtn"):Show(true)
	else
		self.wndLeaveGroup:FindChild("LeaveText"):SetText(Apollo.GetString("CRB_Are_you_sure_you_want_to_leave_this_group"))
		self.wndLeaveGroup:FindChild("ConfirmLeaveBtn"):Show(true)
	end

	self.wndLeaveGroup:Show(true)
	self:HelperResizeGroupContents()
end

function BetterPartyFrames:OnLeaveGroup()
	self:ShowConfirmLeaveDisband(1)
end

function BetterPartyFrames:OnDisbandGroup()
	self:ShowConfirmLeaveDisband(0)
end

function BetterPartyFrames:OnConfirmLeave()
	GroupLib.LeaveGroup()
	self:DestroyGroup()
end

function BetterPartyFrames:OnConfirmDisband()
	if GroupLib.AmILeader() and not GroupLib.InInstance() then
		GroupLib.DisbandGroup()
		self:DestroyGroup()
	end
end

function BetterPartyFrames:OnCancelLeave()
	self.wndLeaveGroup:Show(false)
	self:HelperResizeGroupContents()
end

---------------------------------------------------------------------------------------------------
-- Format Members
---------------------------------------------------------------------------------------------------
function BetterPartyFrames:DrawMemberPortrait(tPortrait, tMemberInfo)
	if tPortrait == nil or tMemberInfo == nil then
		return
	end
	local unitMember = GroupLib.GetUnitForGroupMember(tPortrait.idx)

    local strName = tMemberInfo.strCharacterName
	if not tMemberInfo.bIsOnline then
        strName = String_GetWeaselString(Apollo.GetString("Group_OfflineMember"), strName)
	elseif not unitMember and not self.settings.CheckRange then
		strName = String_GetWeaselString(Apollo.GetString("Group_OutOfRangeMember"), strName)
    end

	if tMemberInfo.bTank then
		strName = String_GetWeaselString(Apollo.GetString("Group_TankTag"), strName)
	elseif tMemberInfo.bHealer then
		strName = String_GetWeaselString(Apollo.GetString("Group_HealerTag"), strName)
	elseif tMemberInfo.bDPS then
		strName = String_GetWeaselString(Apollo.GetString("Group_DPSTag"), strName)
	end

	self.tGroupWndPortraits[tPortrait.idx].wndHud:FindChild("GroupPortraitBtn"):SetData({ tPortrait.idx, tMemberInfo.strCharacterName })
	tPortrait.wndName:SetText(strName)
	tPortrait.wndLeader:Show(tMemberInfo.bIsLeader)
	tPortrait.wndClass:Show(tMemberInfo.bIsOnline)
	tPortrait.wndPathIcon:Show(tMemberInfo.bIsOnline)
	tPortrait.wndOffline:Show(not tMemberInfo.bIsOnline)
	tPortrait.wndHud:FindChild("DeadIndicator"):Show(bDead)
	tPortrait.wndHud:FindChild("GroupPortraitHealthBG"):Show(tMemberInfo.nHealth > 0)
	tPortrait.wndHud:FindChild("GroupDisabledFrame"):Show(false)
	tPortrait.wndHud:FindChild("GroupPortraitBtn"):Show(true)

	local unitTarget = GameLib.GetTargetUnit()
	tPortrait.wndHud:FindChild("GroupPortraitBtn"):SetCheck(unitTarget and unitTarget == unitMember) --tPortrait.unitMember

	local bDead = tMemberInfo.nHealth == 0 and tMemberInfo.nHealthMax ~= 0
	if bDead or not tMemberInfo.bIsOnline then
		tPortrait.wndName:SetTextColor(ApolloColor.new("ffb80000"))
	else
		tPortrait.wndName:SetTextColor(ApolloColor.new("ff7effb8"))
	end
	tPortrait.wndHud:FindChild("GroupPortraitArrangeVert"):ArrangeChildrenVert(1)

	self:HelperUpdateHealth(tPortrait, tMemberInfo)
	
	-- Change the HP Bar Color if required for debuff tracking
	local DebuffColorRequired = self:TrackDebuffsHelper(tMemberInfo)
	
	-- Update Bar Colors
	self:UpdateBarColors(tPortrait, tMemberInfo, DebuffColorRequired)
	
	-- Update level text-overlay
	self:UpdateLevelText(tPortrait, tMemberInfo)
	
	-- Update opacity if out of range
	self:CheckRangeHelper(tPortrait)

	-- Set the Path Icon
	local strPathSprite = ""
	if ktSmallInvitePathIcons[tMemberInfo.ePathType] then
		strPathSprite = ktSmallInvitePathIcons[tMemberInfo.ePathType]
	end
	tPortrait.wndPathIcon:SetSprite(strPathSprite)

	local strClassSprite = ""
	if ktInviteClassIcons[tMemberInfo.eClassId] then
		strClassSprite = ktInviteClassIcons[tMemberInfo.eClassId]
	end
	tPortrait.wndClass:SetSprite(strClassSprite)

	tPortrait.wndMark:Show(tMemberInfo.nMarkerId ~= 0)
	if tMemberInfo.nMarkerId ~= 0 then
		tPortrait.wndMark:SetSprite(kstrRaidMarkerToSprite[tMemberInfo.nMarkerId])
	end
end

function BetterPartyFrames:HelperUpdateHealth(tPortrait, tMemberInfo)
	local nHealthCurr 	= tMemberInfo.nHealth
	local nHealthMax 	= tMemberInfo.nHealthMax
	local nShieldCurr 	= tMemberInfo.nShield
	local nShieldMax	= tMemberInfo.nShieldMax
	local nAbsorbMax 	= tMemberInfo.nAbsorptionMax
	local nAbsorbCurr 	= 0
	if nAbsorbMax > 0 then
		nAbsorbCurr = tMemberInfo.nAbsorption
	end

	local nTotalMax = nHealthMax + nShieldMax + nAbsorbMax
	tPortrait.wndLowHealthFlash:Show(nHealthCurr ~= 0 and nHealthCurr / nHealthMax <= 0.25)

	-- Scaling
	local nPointHealthRight = self.nFrameRight * (nHealthCurr / nTotalMax)
	local nPointShieldRight = self.nFrameRight * ((nHealthCurr + nShieldMax) / nTotalMax)
	local nPointAbsorbRight = self.nFrameRight * ((nHealthCurr + nShieldMax + nAbsorbMax) / nTotalMax)

	if nShieldMax > 0 and nShieldMax / nTotalMax < 0.2 then
		local nMinShieldSize = 0.2 -- HARDCODE: Minimum shield bar length is 20% of total for formatting
		nPointHealthRight = self.nFrameRight * math.min(1 - nMinShieldSize, nHealthCurr / nTotalMax) -- Health is normal, but caps at 80%
		nPointShieldRight = self.nFrameRight * math.min(1, (nHealthCurr / nTotalMax) + nMinShieldSize) -- If not 1, the size is thus healthbar + hard minimum
	end
	

	-- Resize
	self:SetBarValue(tPortrait.wndShields, 0, nShieldCurr, nShieldMax) -- Only the Curr Shield really progress fills
	self:SetBarValue(tPortrait.wndMaxAbsorb:FindChild("CurrAbsorbBar"), 0, nAbsorbCurr, nAbsorbMax)
	self:SetBarValue(tPortrait.wndHealth, 0, nHealthCurr, nHealthMax) -- Custom, used to update HP bar with current HP.
	
	--[[
	-- Original CRB Code used for setting the dynamically size scaling HP/Shield/Absorb bar. We're not using that, so disabled.
	tPortrait.wndHealth:SetAnchorOffsets(self.nFrameLeft, self.nFrameTop, nPointHealthRight, self.nFrameBottom)
	tPortrait.wndMaxShields:SetAnchorOffsets(nPointHealthRight - 10, self.nMaxShieldFrameTop, nPointShieldRight + 6, self.nMaxShieldFrameBottom)
	tPortrait.wndMaxAbsorb:SetAnchorOffsets(nPointShieldRight - 14, self.nMaxAbsorbFrameTop, nPointAbsorbRight + 6, self.nMaxAbsorbFrameBottom)
	--]]

	-- Bars
	tPortrait.wndShields:Show(nHealthCurr > 0 and self.settings.ShowShieldBar)
	tPortrait.wndHealth:Show(nHealthCurr / nTotalMax > 0.01) -- TODO: Temp The sprite draws poorly this low.
	tPortrait.wndMaxShields:Show(nHealthCurr > 0 and self.settings.ShowShieldBar)-- and nShieldMax > 0) Temp while testing. The shield bar needs to be shown to show the seperation between Health-Shield
	tPortrait.wndMaxAbsorb:Show(nHealthCurr > 0 and self.settings.ShowAbsorbBar)-- and nAbsorbMax > 0) - Temp while testing, the Absorb bar needs to be shown to show the separation sprite between Shield-Absorb.

	-- Update HP/Shield/Absorb text
	self:UpdateHPText(nHealthCurr, nHealthMax, tPortrait)
	self:UpdateShieldText(nShieldCurr, nShieldMax, tPortrait)
	self:UpdateAbsorbText(nAbsorbCurr, tPortrait)
end

function BetterPartyFrames:UpdateHPText(nHealthCurr, nHealthMax, tPortrait)
	local strHealthPercentage = self:RoundPercentage(nHealthCurr, nHealthMax)
	local strHealthCurrRounded
	local strHealthMaxRounded

	if nHealthCurr < 1000 then
		strHealthCurrRounded = nHealthCurr
	else
		strHealthCurrRounded = self:RoundNumber(nHealthCurr)
	end
	
	if nHealthMax < 1000 then
		strHealthMaxRounded = nHealthMax
	else
		strHealthMaxRounded = self:RoundNumber(nHealthMax)
	end
	
	-- No text needs to be drawn if all HP Text options are disabled
	if not self.settings.ShowHP_Full and not self.settings.ShowHP_K and not self.settings.ShowHP_Pct then
		-- Update text to be empty, otherwise it will be stuck at the old value
		tPortrait.wndHealth:SetText(nil)
		return
	end
	
	-- Only ShowHP_Full selected
	if self.settings.ShowHP_Full and not self.settings.ShowHP_K and not self.settings.ShowHP_Pct then
		tPortrait.wndHealth:SetText(nHealthCurr.."/"..nHealthMax)
		return
	end
	
	-- ShowHP_Full + Pct
	if self.settings.ShowHP_Full and not self.settings.ShowHP_K and self.settings.ShowHP_Pct then
		tPortrait.wndHealth:SetText(nHealthCurr.."/"..nHealthMax.." ("..strHealthPercentage..")")
		return
	end
	
	-- Only ShowHP_K selected
	if not self.settings.ShowHP_Full and self.settings.ShowHP_K and not self.settings.ShowHP_Pct then
		tPortrait.wndHealth:SetText(strHealthCurrRounded.."/"..strHealthMaxRounded)
		return
	end
	
	-- ShowHP_K + Pct
	if not self.settings.ShowHP_Full and self.settings.ShowHP_K and self.settings.ShowHP_Pct then
		tPortrait.wndHealth:SetText(strHealthCurrRounded.."/"..strHealthMaxRounded.." ("..strHealthPercentage..")")
		return
	end
	
	-- Only Pct selected
	if not self.settings.ShowHP_Full and not self.settings.ShowHP_K and self.settings.ShowHP_Pct then
		tPortrait.wndHealth:SetText(strHealthPercentage)
		return
	end
end

function BetterPartyFrames:UpdateShieldText(nShieldCurr, nShieldMax, tPortrait)
	-- Only update text if we are showing the shield bar
	if not self.settings.ShowShieldBar then
		return
	end

	local strShieldPercentage = self:RoundPercentage(nShieldCurr, nShieldMax)
	local strShieldCurrRounded
	
	if nShieldCurr > 0 and nShieldMax > 0 then
		if nShieldCurr < 1000 then
			strShieldCurrRounded = nShieldCurr
		else
			strShieldCurrRounded = self:RoundNumber(nShieldCurr)
		end
	else
		tPortrait.wndShields:SetText(nil) -- empty to remove text when there is no shield
		return
	end

	-- No text needs to be drawn if all Shield Text options are disabled
	if not self.settings.ShowShield_K and not self.settings.ShowShield_Pct then
		-- Update text to be empty, otherwise it will be stuck at the old value
		tPortrait.wndShields:SetText(nil)
		return
	end
	
	-- Only Pct selected
	if not self.settings.ShowShield_K and self.settings.ShowShield_Pct then
		tPortrait.wndShields:SetText(strShieldPercentage)
		return
	end
	
	-- Only ShowShield_K selected
	if self.settings.ShowShield_K and not self.settings.ShowShield_Pct then
		tPortrait.wndShields:SetText(strShieldCurrRounded)
		return
	end
end

function BetterPartyFrames:UpdateAbsorbText(nAbsorbCurr, tPortrait)
	-- Only update text if we are showing the shield bar
	if not self.settings.ShowAbsorbBar then
		return
	end
	local strAbsorbCurrRounded

	if nAbsorbCurr > 0 then
		if nAbsorbCurr < 1000 then
			strAbsorbCurrRounded = nAbsorbCurr
		else
			strAbsorbCurrRounded = self:RoundNumber(nAbsorbCurr)
		end
	else
		strAbsorbCurrRounded = "" -- empty string to remove text when there is no absorb
	end
	
	-- No text needs to be drawn if all absorb text options are disabled
	if not self.settings.ShowAbsorb_K then
		tPortrait.wndMaxAbsorb:FindChild("CurrAbsorbBar"):SetText(nil)
		return
	end
	
	if self.settings.ShowAbsorb_K then
		tPortrait.wndMaxAbsorb:FindChild("CurrAbsorbBar"):SetText(strAbsorbCurrRounded)
		return
	end
end

function BetterPartyFrames:RoundNumber(n)
	local hundreds = math.floor(n / 100) % 10
	if hundreds == 0 then
		return ('%.0fK'):format(math.floor(n/1000))
	else
		return ('%.0f.%.0fK'):format(math.floor(n/1000), hundreds)
	end
end

function BetterPartyFrames:RoundPercentage(n, total)
	local hundreds = math.floor(n / total) % 10
	if hundreds == 0 then
		return ('%.1f%%'):format(n/total * 100)
	else
		return ('%.0f%%'):format(math.floor(n/total) * 100)
	end
end

function BetterPartyFrames:LockFrameHelper(bLock)
	-- If bLock == true, make not Moveable.
	self.wndGroupHud:SetStyle("Moveable", not bLock)
	return
end

function BetterPartyFrames:TrackDebuffsHelper(tMemberInfo)
	-- Only continue if we are required to TrackDebuffs according to the settings
	if not self.settings.TrackDebuffs then
		return false
	end
	
	local strCharacterName = tMemberInfo.strCharacterName
	local unitMember = GameLib.GetPlayerUnitByName(strCharacterName)
	
	-- Out of range
	if unitMember == nil then
		return false
	end
	
	local playerBuffs = unitMember:GetBuffs()
	local debuffs = playerBuffs['arHarmful']
    	
	-- If player has no debuffs, change the color to normal in case it was changed before.
	if next(debuffs) == nil then
		return false
	end
	
	-- Loop through all debuffs. Change HP bar color if class of splEffect equals 38, which means it is dispellable
	for key, value in pairs(debuffs) do
		if value['splEffect']:GetClass() == 38 then
			return true
		end
	end

	-- Reset to normal sprite if there were debuffs but none of them were dispellable.
	-- This might happen in cases where a player had a dispellable debuff -and- a non-dispellable debuff on him
	return false
end

function BetterPartyFrames:UpdateBarColors(tPortrait, tMemberInfo, DebuffColorRequired)
	local wndHP = tPortrait.wndHealth
	local wndShield = tPortrait.wndShields
	local wndAbsorb = tPortrait.wndMaxAbsorb:FindChild("CurrAbsorbBar")
	
	local HPHealthyColor
	local HPDebuffColor
	local ShieldBarColor
	local AbsorbBarColor
	
	if self.settings.bClassSpecificBarColors then
		local strClassKey = "strColor"..ktClassIdToClassName[tMemberInfo.eClassId]
		HPHealthyColor = self.settings[strClassKey.."_HPHealthy"..self:GetBarDesignSuffix()]
		HPDebuffColor = self.settings[strClassKey.."_HPDebuff"..self:GetBarDesignSuffix()]
		ShieldBarColor = self.settings[strClassKey.."_Shield"..self:GetBarDesignSuffix()]
		AbsorbBarColor = self.settings[strClassKey.."_Absorb"..self:GetBarDesignSuffix()]
	else
		HPHealthyColor = self.settings["strColorGeneral_HPHealthy"..self:GetBarDesignSuffix()]
		HPDebuffColor = self.settings["strColorGeneral_HPDebuff"..self:GetBarDesignSuffix()]
		ShieldBarColor = self.settings["strColorGeneral_Shield"..self:GetBarDesignSuffix()]
		AbsorbBarColor = self.settings["strColorGeneral_Absorb"..self:GetBarDesignSuffix()]
	end

	if DebuffColorRequired then
		if self.settings.ShowBarDesign_Bright then
			wndHP:SetFullSprite("BPF:ProgressBar")
		elseif self.settings.ShowBarDesign_Flat then
			wndHP:SetFullSprite("BasicSprites:WhiteFill")
		end
		wndHP:SetBarColor(HPDebuffColor)
	else
		if self.settings.ShowBarDesign_Bright then
			wndHP:SetFullSprite("BPF:ProgressBar")
		elseif self.settings.ShowBarDesign_Flat then
			wndHP:SetFullSprite("BasicSprites:WhiteFill")
		end
		wndHP:SetBarColor(HPHealthyColor)
	end
	
	wndShield:SetBarColor(ShieldBarColor)
	wndAbsorb:SetBarColor(AbsorbBarColor)
end

function BetterPartyFrames:UpdateLevelText(tPortrait, tMemberInfo)
	-- Remove level text, if any - and return if we're not required to show levels.
	if not self.settings.ShowLevel then
		tPortrait.wndHud:FindChild("Level"):SetText(nil)
		return
	else
		local level
		if tMemberInfo.nEffectiveLevel > 0 then
			level = tMemberInfo.nEffectiveLevel
		else
			level = tMemberInfo.nLevel
		end
		tPortrait.wndHud:FindChild("Level"):SetText(level)
		return
	end
end

function BetterPartyFrames:LoadBarsHelper(bShowShieldBar, bShowAbsorbBar)
	-- This function shows/Hides Shield + Absorb Bars depending on settings.
	local partyMembers = self.tGroupWndPortraits
	-- Loop through all the party members
	for key, value in pairs(partyMembers) do
		-- Hide/show shields/absorb depending on bool parameters.
		partyMembers[key].wndMaxShields:Show(bShowShieldBar)
		partyMembers[key].wndShields:Show(bShowShieldBar)
		partyMembers[key].wndMaxAbsorb:Show(bShowAbsorbBar)
		partyMembers[key].wndMaxAbsorb:FindChild("CurrAbsorbBar"):Show(bShowAbsorbBar)
		-- Set offsets dependent on bool parameters.
		if bShowShieldBar and bShowAbsorbBar and self.settings.ShowBarDesign_Bright and not self.settings.ShowBarDesign_Flat then
			partyMembers[key].wndHealth:SetAnchorOffsets(0, 4, 140, -3)
			partyMembers[key].wndMaxShields:SetAnchorOffsets(138, -2, 180, 2)
			partyMembers[key].wndShields:SetAnchorOffsets(2, 4, 43, -5)
			partyMembers[key].wndMaxAbsorb:SetAnchorOffsets(180, -2, 217, 2)
			partyMembers[key].wndMaxAbsorb:FindChild("CurrAbsorbBar"):SetAnchorOffsets(2, 4, 35, -5)
			partyMembers[key].wndMaxShields:SetSprite("ClientSprites:MiniMapMarkerTiny")
			partyMembers[key].wndMaxAbsorb:SetSprite("ClientSprites:MiniMapMarkerTiny")
		elseif bShowShieldBar and not bShowAbsorbBar and self.settings.ShowBarDesign_Bright and not self.settings.ShowBarDesign_Flat then
			partyMembers[key].wndHealth:SetAnchorOffsets(0, 4, 160, -3)
			partyMembers[key].wndMaxShields:SetAnchorOffsets(158, -2, 200, 2)
			partyMembers[key].wndShields:SetAnchorOffsets(2, 4, 56, -5)
			partyMembers[key].wndMaxShields:SetSprite("ClientSprites:MiniMapMarkerTiny")
			partyMembers[key].wndMaxAbsorb:SetSprite(nil)
		elseif not bShowShieldBar and bShowAbsorbBar and self.settings.ShowBarDesign_Bright and not self.settings.ShowBarDesign_Flat then
			partyMembers[key].wndHealth:SetAnchorOffsets(0, 4, 160, -3)
			partyMembers[key].wndMaxAbsorb:SetAnchorOffsets(158, -2, 200, 2)
			partyMembers[key].wndMaxAbsorb:FindChild("CurrAbsorbBar"):SetAnchorOffsets(2, 4, 56, -5)
			partyMembers[key].wndMaxShields:SetSprite(nil)
			partyMembers[key].wndMaxAbsorb:SetSprite("ClientSprites:MiniMapMarkerTiny")
		elseif not bShowShieldBar and not bShowAbsorbBar and self.settings.ShowBarDesign_Bright and not self.settings.ShowBarDesign_Flat then
			partyMembers[key].wndHealth:SetAnchorOffsets(0, 4, 214, -3)
			partyMembers[key].wndMaxShields:SetSprite(nil)
			partyMembers[key].wndMaxAbsorb:SetSprite(nil)
		-- Repeat the above, but now with flat design instead of Bright
		elseif bShowShieldBar and bShowAbsorbBar and not self.settings.ShowBarDesign_Bright and self.settings.ShowBarDesign_Flat then
			partyMembers[key].wndHealth:SetAnchorOffsets(0, 3, 140, -1)
			partyMembers[key].wndMaxShields:SetAnchorOffsets(138, -2, 180, 1)
			partyMembers[key].wndShields:SetAnchorOffsets(2, 5, 45, -2)
			partyMembers[key].wndMaxAbsorb:SetAnchorOffsets(180, -2, 219, 2)
			partyMembers[key].wndMaxAbsorb:FindChild("CurrAbsorbBar"):SetAnchorOffsets(3, 5, 37, -3)
			partyMembers[key].wndMaxShields:SetSprite("ClientSprites:MiniMapMarkerTiny")
			partyMembers[key].wndMaxAbsorb:SetSprite("ClientSprites:MiniMapMarkerTiny")
		elseif bShowShieldBar and not bShowAbsorbBar and not self.settings.ShowBarDesign_Bright and self.settings.ShowBarDesign_Flat then
			partyMembers[key].wndHealth:SetAnchorOffsets(0, 3, 160, -1)
			partyMembers[key].wndMaxShields:SetAnchorOffsets(158, -2, 200, 1)
			partyMembers[key].wndShields:SetAnchorOffsets(2, 5, 59, -2)
			partyMembers[key].wndMaxShields:SetSprite("ClientSprites:MiniMapMarkerTiny")
			partyMembers[key].wndMaxAbsorb:SetSprite(nil)
		elseif not bShowShieldBar and bShowAbsorbBar and not self.settings.ShowBarDesign_Bright and self.settings.ShowBarDesign_Flat then
			partyMembers[key].wndHealth:SetAnchorOffsets(0, 3, 160, -1)
			partyMembers[key].wndMaxAbsorb:SetAnchorOffsets(158, -2, 200, 1)
			partyMembers[key].wndMaxAbsorb:FindChild("CurrAbsorbBar"):SetAnchorOffsets(2, 5, 58, -2)
			partyMembers[key].wndMaxShields:SetSprite(nil)
			partyMembers[key].wndMaxAbsorb:SetSprite("ClientSprites:MiniMapMarkerTiny")
		elseif not bShowShieldBar and not bShowAbsorbBar and not self.settings.ShowBarDesign_Bright and self.settings.ShowBarDesign_Flat then
			partyMembers[key].wndHealth:SetAnchorOffsets(0, 3, 217, -1)
			partyMembers[key].wndMaxShields:SetSprite(nil)
			partyMembers[key].wndMaxAbsorb:SetSprite(nil)
		end
	end
end

function BetterPartyFrames:LoadBarsTexturesHelper(bBarDesign_Bright, bBarDesign_Flat)
	-- TODO -> Make better use of variables related to this all over the file (debuff tracking, etc) - currently quite a mess.
	-- This function applies the correct texture sprite and colors.
	local partyMembers = self.tGroupWndPortraits
	
	local HPBar_Sprite
	local HPBar_Color
	local ShieldBar_Sprite
	local ShieldBar_Color
	local AbsorbBar_Sprite
	local AbsorbBar_Color
	local flagsText
	local GroupPortraitHealthBG

	if bBarDesign_Bright and not bBarDesign_Flat then
		HPBar_Sprite = "BPF:ProgressBar"
		HPBar_Color = "ChannelCircle3"
		ShieldBar_Sprite = "BPF:ProgressBar"
		ShieldBar_Color = "DispositionFriendlyUnflagged"
		wndMaxShields_Offsets = {138, -2, 180, 2}
		AbsorbBar_Sprite = "BPF:ProgressBar"
		AbsorbBar_Color = "xkcdBrownyOrange"
		flagsText = {DT_CENTER = true, DT_BOTTOM = false, DT_VCENTER = true, DT_SINGLELINE = true,}
		GroupPortraitHealthBG = "kitIProgBar_Inlay_Base"
	else
		-- Assume flat, which it should always be the case.
		HPBar_Sprite = "BasicSprites:WhiteFill"
		HPBar_Color = "ff26a614"
		ShieldBar_Sprite = "BasicSprites:WhiteFill"
		ShieldBar_Color = "ff2574a9"
		AbsorbBar_Sprite = "BasicSprites:WhiteFill"
		AbsorbBar_Color = "xkcdDirtyOrange"
		flagsText = {DT_CENTER = true, DT_BOTTOM = false, DT_VCENTER = true, DT_SINGLELINE = true,}
		GroupPortraitHealthBG = "HologramSprites:HoloDlgMiddle"
	end
		
	-- Loop through all the party members
	for key, value in pairs(partyMembers) do
		-- Add sprites for background of hp/shield/absorb progress bars
		partyMembers[key].wndHealthBG:SetSprite(GroupPortraitHealthBG)

		partyMembers[key].wndHealth:SetFullSprite(HPBar_Sprite)
		partyMembers[key].wndHealth:SetBarColor(HPBar_Color)
		
		-- Set text flags
		for k, v in pairs(flagsText) do
			partyMembers[key].wndHealth:SetTextFlags(k, v)
		end
		
		partyMembers[key].wndShields:SetFullSprite(ShieldBar_Sprite)
		partyMembers[key].wndShields:SetBarColor(ShieldBar_Color)

		-- Set text flags
		for k, v in pairs(flagsText) do
			partyMembers[key].wndShields:SetTextFlags(k, v)
		end

		partyMembers[key].wndMaxAbsorb:FindChild("CurrAbsorbBar"):SetFullSprite(AbsorbBar_Sprite)
		partyMembers[key].wndMaxAbsorb:FindChild("CurrAbsorbBar"):SetBarColor(AbsorbBar_Color)
		
		-- Set text flags
		for k, v in pairs(flagsText) do
			partyMembers[key].wndMaxAbsorb:FindChild("CurrAbsorbBar"):SetTextFlags(k, v)
		end
		
		-- Only for full transparency
		if self.settings.FullTransparency and not self.settings.SemiTransparency then
			partyMembers[key].wndHud:FindChild("GroupPortraitBtn"):ChangeArt("")
		else
			partyMembers[key].wndHud:FindChild("GroupPortraitBtn"):ChangeArt("CRB_GroupFrame:sprGroup_Btn_Holo")
		end
	end
	-- Destroy all pixies regardless to prevent dupliactes
	self.wndGroupHud:FindChild("GroupControlsBtn"):DestroyAllPixies()
	self.wndGroupHud:DestroyAllPixies()

	if self.settings.SemiTransparency or self.settings.FullTransparency then
		self.wndGroupHud:FindChild("GroupControlsBtn"):ChangeArt("")
	else
		local tGroupControlsBtn = {
			strText = "",
			strFont = "Default",
			strSprite = "CRB_GroupFrame:sprGroup_Btn_OptionsNormal",
			bLine = false,
			cr = "White",
			crText = "White",
			loc = {
				fPoints = {0, 0.5, 0, 0.5},
				nOffsets = {13, -5, 28, 8},
			},
		}
		local tGroupHudA = {
			strText = "",
			strFont = "Default",
			strSprite = "sprGroup_HoloFrame",
			bLine = false,
			cr = "White",
			crText = "White",
			loc = {
				fPoints = { 0, 0, 1, 1},
				nOffsets = {0, 0, 0, 0},
			},
		}
		local tGroupHudB = {
			strText = "",
			strFont = "",
			strSprite = "",
			bLine = false,
			cr = "White",
			crText = "White",
			loc = {
				fPoints = {0, 0, 0, 0},
				nOffsets = {160, 3, 200, 43},
			},
		}
		self.wndGroupHud:AddPixie(tGroupHudA)
		self.wndGroupHud:AddPixie(tGroupHudB)
		self.wndGroupHud:FindChild("GroupControlsBtn"):AddPixie(tGroupControlsBtn)
		self.wndGroupHud:FindChild("GroupControlsBtn"):ChangeArt("BK3:btnHolo_Blue_Small")
	end
end

function BetterPartyFrames:CheckRangeHelper(tPortrait)
	local opacity
	if self.settings.CheckRange then
		local player = GameLib.GetPlayerUnit()
		if player == nil then return end
		
		local unit = GroupLib.GetUnitForGroupMember(tPortrait.idx)
			
		if unit ~= player and (unit == nil or not self:RangeCheck(unit, player, self.settings.MaxRange)) then
			opacity = 0.4
		else
			opacity = 1
		end
	end
		
	tPortrait.wndHealth:SetOpacity(opacity)
	tPortrait.wndShields:SetOpacity(opacity)
	tPortrait.wndMaxAbsorb:FindChild("CurrAbsorbBar"):SetOpacity(opacity)	
end

function BetterPartyFrames:RangeCheck(unit1, unit2, range)
	local v1 = unit1:GetPosition()
	local v2 = unit2:GetPosition()

	local dx, dy, dz = v1.x - v2.x, v1.y - v2.y, v1.z - v2.z

	return dx*dx + dy*dy + dz*dz <= range*range
end

function BetterPartyFrames:SetBarValue(wndBar, fMin, fValue, fMax)
	wndBar:SetMax(fMax)
	wndBar:SetFloor(fMin)
	wndBar:SetProgress(fValue)
end

function BetterPartyFrames:copyTable(from, to)
	if not from then return end
    to = to or {}
	for k,v in pairs(from) do
		to[k] = v
	end
    return to
end

function BetterPartyFrames:RefreshSettings()
	if self.settings.ShowHP_K ~= nil then
		self.wndConfig:FindChild("Button_ShowHP_K"):SetCheck(self.settings.ShowHP_K) end
	if self.settings.ShowHP_Full ~= nil then
		self.wndConfig:FindChild("Button_ShowHP_Full"):SetCheck(self.settings.ShowHP_Full) end
	if self.settings.ShowHP_Pct ~= nil then
		self.wndConfig:FindChild("Button_ShowHP_Pct"):SetCheck(self.settings.ShowHP_Pct) end
	if self.settings.ShowShield_K ~= nil then
		self.wndConfig:FindChild("Button_ShowShield_K"):SetCheck(self.settings.ShowShield_K) end
	if self.settings.ShowShield_Pct ~= nil then
		self.wndConfig:FindChild("Button_ShowShield_Pct"):SetCheck(self.settings.ShowShield_Pct) end
	if self.settings.ShowAbsorb_K ~= nil then
		self.wndConfig:FindChild("Button_ShowAbsorb_K"):SetCheck(self.settings.ShowAbsorb_K) end
	if self.settings.LockFrame ~= nil then
		self.wndConfig:FindChild("Button_LockFrame"):SetCheck(self.settings.LockFrame) end
	if self.settings.TrackDebuffs ~= nil then
		self.wndConfig:FindChild("Button_TrackDebuffs"):SetCheck(self.settings.TrackDebuffs) end
	if self.settings.ShowLevel ~= nil then
		self.wndConfig:FindChild("Button_ShowLevel"):SetCheck(self.settings.ShowLevel) end
	if self.settings.ShowShieldBar ~= nil then
		self.wndConfig:FindChild("Button_ShowShieldBar"):SetCheck(self.settings.ShowShieldBar) end
	if self.settings.ShowAbsorbBar ~= nil then
		self.wndConfig:FindChild("Button_ShowAbsorbBar"):SetCheck(self.settings.ShowAbsorbBar) end
	if self.settings.ShowBarDesign_Bright ~= nil then
		self.wndConfig:FindChild("Button_ShowBarDesign_Bright"):SetCheck(self.settings.ShowBarDesign_Bright) end
	if self.settings.ShowBarDesign_Flat ~= nil then
		self.wndConfig:FindChild("Button_ShowBarDesign_Flat"):SetCheck(self.settings.ShowBarDesign_Flat) end
	if self.settings.MouseOverSelection ~= nil then
		self.wndConfig:FindChild("Button_MouseOverSelection"):SetCheck(self.settings.MouseOverSelection) end
	if self.settings.RememberPrevTarget ~= nil then
		self.wndConfig:FindChild("Button_RememberPrevTarget"):SetCheck(self.settings.RememberPrevTarget) end
	if self.settings.SemiTransparency ~= nil then
		self.wndConfig:FindChild("Button_Semi_Transparency"):SetCheck(self.settings.SemiTransparency) end
	if self.settings.FullTransparency ~= nil then
		self.wndConfig:FindChild("Button_Full_Transparency"):SetCheck(self.settings.FullTransparency) end
	if self.settings.DisableMentoring ~= nil then
		self.wndConfig:FindChild("Button_DisableMentoring"):SetCheck(self.settings.DisableMentoring) end
	if self.settings.CheckRange ~= nil then
		self.wndConfig:FindChild("Button_CheckRange"):SetCheck(self.settings.CheckRange) end
	if self.settings.MaxRange ~= nil then
		self.wndConfig:FindChild("Label_MaxRangeDisplay"):SetText(string.format("%sm", math.floor(self.settings.MaxRange)))
		self.wndConfig:FindChild("Slider_MaxRange"):SetValue(self.settings.MaxRange)
	end
	
	-- Settings related to /bpf colors settings frame
	if self.settings.bClassSpecificBarColors ~= nil then
		self.wndConfigColorsGeneral:FindChild("Label_GeneralSettingsOuter:Button_ClassSpecific"):SetCheck(self.settings.bClassSpecificBarColors) end
	
	if self.settings.strColorGeneral_HPHealthy_Bright ~= nil then
		self.wndConfigColorsGeneral:FindChild("Label_ColorSettingsOuter_Bright:HPHealthy_Bright:ColorWindow"):SetBGColor(self.settings.strColorGeneral_HPHealthy_Bright) end
	if self.settings.strColorGeneral_HPDebuff_Bright ~= nil then
		self.wndConfigColorsGeneral:FindChild("Label_ColorSettingsOuter_Bright:HPDebuff_Bright:ColorWindow"):SetBGColor(self.settings.strColorGeneral_HPDebuff_Bright) end
	if self.settings.strColorGeneral_Shield_Bright ~= nil then
		self.wndConfigColorsGeneral:FindChild("Label_ColorSettingsOuter_Bright:Shield_Bright:ColorWindow"):SetBGColor(self.settings.strColorGeneral_Shield_Bright) end
	if self.settings.strColorGeneral_Absorb_Bright ~= nil then
		self.wndConfigColorsGeneral:FindChild("Label_ColorSettingsOuter_Bright:Absorb_Bright:ColorWindow"):SetBGColor(self.settings.strColorGeneral_Absorb_Bright) end
		
	if self.settings.strColorEngineer_HPHealthy_Bright ~= nil then
		self.wndConfigColorsEngineer:FindChild("Label_ColorSettingsOuter_Bright:HPHealthy_Bright:ColorWindow"):SetBGColor(self.settings.strColorEngineer_HPHealthy_Bright) end
	if self.settings.strColorEngineer_HPDebuff_Bright ~= nil then
		self.wndConfigColorsEngineer:FindChild("Label_ColorSettingsOuter_Bright:HPDebuff_Bright:ColorWindow"):SetBGColor(self.settings.strColorEngineer_HPDebuff_Bright) end
	if self.settings.strColorEngineer_Shield_Bright ~= nil then
		self.wndConfigColorsEngineer:FindChild("Label_ColorSettingsOuter_Bright:Shield_Bright:ColorWindow"):SetBGColor(self.settings.strColorEngineer_Shield_Bright) end
	if self.settings.strColorEngineer_Absorb_Bright ~= nil then
		self.wndConfigColorsEngineer:FindChild("Label_ColorSettingsOuter_Bright:Absorb_Bright:ColorWindow"):SetBGColor(self.settings.strColorEngineer_Absorb_Bright) end
		
	if self.settings.strColorEsper_HPHealthy_Bright ~= nil then
		self.wndConfigColorsEsper:FindChild("Label_ColorSettingsOuter_Bright:HPHealthy_Bright:ColorWindow"):SetBGColor(self.settings.strColorEsper_HPHealthy_Bright) end
	if self.settings.strColorEsper_HPDebuff_Bright ~= nil then
		self.wndConfigColorsEsper:FindChild("Label_ColorSettingsOuter_Bright:HPDebuff_Bright:ColorWindow"):SetBGColor(self.settings.strColorEsper_HPDebuff_Bright) end
	if self.settings.strColorEsper_Shield_Bright ~= nil then
		self.wndConfigColorsEsper:FindChild("Label_ColorSettingsOuter_Bright:Shield_Bright:ColorWindow"):SetBGColor(self.settings.strColorEsper_Shield_Bright) end
	if self.settings.strColorEsper_Absorb_Bright ~= nil then
		self.wndConfigColorsEsper:FindChild("Label_ColorSettingsOuter_Bright:Absorb_Bright:ColorWindow"):SetBGColor(self.settings.strColorEsper_Absorb_Bright) end
		
	if self.settings.strColorMedic_HPHealthy_Bright ~= nil then
		self.wndConfigColorsMedic:FindChild("Label_ColorSettingsOuter_Bright:HPHealthy_Bright:ColorWindow"):SetBGColor(self.settings.strColorMedic_HPHealthy_Bright) end
	if self.settings.strColorMedic_HPDebuff_Bright ~= nil then
		self.wndConfigColorsMedic:FindChild("Label_ColorSettingsOuter_Bright:HPDebuff_Bright:ColorWindow"):SetBGColor(self.settings.strColorMedic_HPDebuff_Bright) end
	if self.settings.strColorMedic_Shield_Bright ~= nil then
		self.wndConfigColorsMedic:FindChild("Label_ColorSettingsOuter_Bright:Shield_Bright:ColorWindow"):SetBGColor(self.settings.strColorMedic_Shield_Bright) end
	if self.settings.strColorMedic_Absorb_Bright ~= nil then
		self.wndConfigColorsMedic:FindChild("Label_ColorSettingsOuter_Bright:Absorb_Bright:ColorWindow"):SetBGColor(self.settings.strColorMedic_Absorb_Bright) end
		
	if self.settings.strColorSpellslinger_HPHealthy_Bright ~= nil then
		self.wndConfigColorsSpellslinger:FindChild("Label_ColorSettingsOuter_Bright:HPHealthy_Bright:ColorWindow"):SetBGColor(self.settings.strColorSpellslinger_HPHealthy_Bright) end
	if self.settings.strColorSpellslinger_HPDebuff_Bright ~= nil then
		self.wndConfigColorsSpellslinger:FindChild("Label_ColorSettingsOuter_Bright:HPDebuff_Bright:ColorWindow"):SetBGColor(self.settings.strColorSpellslinger_HPDebuff_Bright) end
	if self.settings.strColorSpellslinger_Shield_Bright ~= nil then
		self.wndConfigColorsSpellslinger:FindChild("Label_ColorSettingsOuter_Bright:Shield_Bright:ColorWindow"):SetBGColor(self.settings.strColorSpellslinger_Shield_Bright) end
	if self.settings.strColorSpellslinger_Absorb_Bright ~= nil then
		self.wndConfigColorsSpellslinger:FindChild("Label_ColorSettingsOuter_Bright:Absorb_Bright:ColorWindow"):SetBGColor(self.settings.strColorSpellslinger_Absorb_Bright) end
		
	if self.settings.strColorStalker_HPHealthy_Bright ~= nil then
		self.wndConfigColorsStalker:FindChild("Label_ColorSettingsOuter_Bright:HPHealthy_Bright:ColorWindow"):SetBGColor(self.settings.strColorStalker_HPHealthy_Bright) end
	if self.settings.strColorStalker_HPDebuff_Bright ~= nil then
		self.wndConfigColorsStalker:FindChild("Label_ColorSettingsOuter_Bright:HPDebuff_Bright:ColorWindow"):SetBGColor(self.settings.strColorStalker_HPDebuff_Bright) end
	if self.settings.strColorStalker_Shield_Bright ~= nil then
		self.wndConfigColorsStalker:FindChild("Label_ColorSettingsOuter_Bright:Shield_Bright:ColorWindow"):SetBGColor(self.settings.strColorStalker_Shield_Bright) end
	if self.settings.strColorStalker_Absorb_Bright ~= nil then
		self.wndConfigColorsStalker:FindChild("Label_ColorSettingsOuter_Bright:Absorb_Bright:ColorWindow"):SetBGColor(self.settings.strColorStalker_Absorb_Bright) end
		
	if self.settings.strColorWarrior_HPHealthy_Bright ~= nil then
		self.wndConfigColorsWarrior:FindChild("Label_ColorSettingsOuter_Bright:HPHealthy_Bright:ColorWindow"):SetBGColor(self.settings.strColorWarrior_HPHealthy_Bright) end
	if self.settings.strColorWarrior_HPDebuff_Bright ~= nil then
		self.wndConfigColorsWarrior:FindChild("Label_ColorSettingsOuter_Bright:HPDebuff_Bright:ColorWindow"):SetBGColor(self.settings.strColorWarrior_HPDebuff_Bright) end
	if self.settings.strColorWarrior_Shield_Bright ~= nil then
		self.wndConfigColorsWarrior:FindChild("Label_ColorSettingsOuter_Bright:Shield_Bright:ColorWindow"):SetBGColor(self.settings.strColorWarrior_Shield_Bright) end
	if self.settings.strColorWarrior_Absorb_Bright ~= nil then
		self.wndConfigColorsWarrior:FindChild("Label_ColorSettingsOuter_Bright:Absorb_Bright:ColorWindow"):SetBGColor(self.settings.strColorWarrior_Absorb_Bright) end
		
	if self.settings.strColorGeneral_HPHealthy_Flat ~= nil then
		self.wndConfigColorsGeneral:FindChild("Label_ColorSettingsOuter_Flat:HPHealthy_Flat:ColorWindow"):SetBGColor(self.settings.strColorGeneral_HPHealthy_Flat) end
	if self.settings.strColorGeneral_HPDebuff_Flat ~= nil then
		self.wndConfigColorsGeneral:FindChild("Label_ColorSettingsOuter_Flat:HPDebuff_Flat:ColorWindow"):SetBGColor(self.settings.strColorGeneral_HPDebuff_Flat) end
	if self.settings.strColorGeneral_Shield_Flat ~= nil then
		self.wndConfigColorsGeneral:FindChild("Label_ColorSettingsOuter_Flat:Shield_Flat:ColorWindow"):SetBGColor(self.settings.strColorGeneral_Shield_Flat) end
	if self.settings.strColorGeneral_Absorb_Flat ~= nil then
		self.wndConfigColorsGeneral:FindChild("Label_ColorSettingsOuter_Flat:Absorb_Flat:ColorWindow"):SetBGColor(self.settings.strColorGeneral_Absorb_Flat) end
		
	if self.settings.strColorEngineer_HPHealthy_Flat ~= nil then
		self.wndConfigColorsEngineer:FindChild("Label_ColorSettingsOuter_Flat:HPHealthy_Flat:ColorWindow"):SetBGColor(self.settings.strColorEngineer_HPHealthy_Flat) end
	if self.settings.strColorEngineer_HPDebuff_Flat ~= nil then
		self.wndConfigColorsEngineer:FindChild("Label_ColorSettingsOuter_Flat:HPDebuff_Flat:ColorWindow"):SetBGColor(self.settings.strColorEngineer_HPDebuff_Flat) end
	if self.settings.strColorEngineer_Shield_Flat ~= nil then
		self.wndConfigColorsEngineer:FindChild("Label_ColorSettingsOuter_Flat:Shield_Flat:ColorWindow"):SetBGColor(self.settings.strColorEngineer_Shield_Flat) end
	if self.settings.strColorEngineer_Absorb_Flat ~= nil then
		self.wndConfigColorsEngineer:FindChild("Label_ColorSettingsOuter_Flat:Absorb_Flat:ColorWindow"):SetBGColor(self.settings.strColorEngineer_Absorb_Flat) end
		
	if self.settings.strColorEsper_HPHealthy_Flat ~= nil then
		self.wndConfigColorsEsper:FindChild("Label_ColorSettingsOuter_Flat:HPHealthy_Flat:ColorWindow"):SetBGColor(self.settings.strColorEsper_HPHealthy_Flat) end
	if self.settings.strColorEsper_HPDebuff_Flat ~= nil then
		self.wndConfigColorsEsper:FindChild("Label_ColorSettingsOuter_Flat:HPDebuff_Flat:ColorWindow"):SetBGColor(self.settings.strColorEsper_HPDebuff_Flat) end
	if self.settings.strColorEsper_Shield_Flat ~= nil then
		self.wndConfigColorsEsper:FindChild("Label_ColorSettingsOuter_Flat:Shield_Flat:ColorWindow"):SetBGColor(self.settings.strColorEsper_Shield_Flat) end
	if self.settings.strColorEsper_Absorb_Flat ~= nil then
		self.wndConfigColorsEsper:FindChild("Label_ColorSettingsOuter_Flat:Absorb_Flat:ColorWindow"):SetBGColor(self.settings.strColorEsper_Absorb_Flat) end
		
	if self.settings.strColorMedic_HPHealthy_Flat ~= nil then
		self.wndConfigColorsMedic:FindChild("Label_ColorSettingsOuter_Flat:HPHealthy_Flat:ColorWindow"):SetBGColor(self.settings.strColorMedic_HPHealthy_Flat) end
	if self.settings.strColorMedic_HPDebuff_Flat ~= nil then
		self.wndConfigColorsMedic:FindChild("Label_ColorSettingsOuter_Flat:HPDebuff_Flat:ColorWindow"):SetBGColor(self.settings.strColorMedic_HPDebuff_Flat) end
	if self.settings.strColorMedic_Shield_Flat ~= nil then
		self.wndConfigColorsMedic:FindChild("Label_ColorSettingsOuter_Flat:Shield_Flat:ColorWindow"):SetBGColor(self.settings.strColorMedic_Shield_Flat) end
	if self.settings.strColorMedic_Absorb_Flat ~= nil then
		self.wndConfigColorsMedic:FindChild("Label_ColorSettingsOuter_Flat:Absorb_Flat:ColorWindow"):SetBGColor(self.settings.strColorMedic_Absorb_Flat) end
		
	if self.settings.strColorSpellslinger_HPHealthy_Flat ~= nil then
		self.wndConfigColorsSpellslinger:FindChild("Label_ColorSettingsOuter_Flat:HPHealthy_Flat:ColorWindow"):SetBGColor(self.settings.strColorSpellslinger_HPHealthy_Flat) end
	if self.settings.strColorSpellslinger_HPDebuff_Flat ~= nil then
		self.wndConfigColorsSpellslinger:FindChild("Label_ColorSettingsOuter_Flat:HPDebuff_Flat:ColorWindow"):SetBGColor(self.settings.strColorSpellslinger_HPDebuff_Flat) end
	if self.settings.strColorSpellslinger_Shield_Flat ~= nil then
		self.wndConfigColorsSpellslinger:FindChild("Label_ColorSettingsOuter_Flat:Shield_Flat:ColorWindow"):SetBGColor(self.settings.strColorSpellslinger_Shield_Flat) end
	if self.settings.strColorSpellslinger_Absorb_Flat ~= nil then
		self.wndConfigColorsSpellslinger:FindChild("Label_ColorSettingsOuter_Flat:Absorb_Flat:ColorWindow"):SetBGColor(self.settings.strColorSpellslinger_Absorb_Flat) end
		
	if self.settings.strColorStalker_HPHealthy_Flat ~= nil then
		self.wndConfigColorsStalker:FindChild("Label_ColorSettingsOuter_Flat:HPHealthy_Flat:ColorWindow"):SetBGColor(self.settings.strColorStalker_HPHealthy_Flat) end
	if self.settings.strColorStalker_HPDebuff_Flat ~= nil then
		self.wndConfigColorsStalker:FindChild("Label_ColorSettingsOuter_Flat:HPDebuff_Flat:ColorWindow"):SetBGColor(self.settings.strColorStalker_HPDebuff_Flat) end
	if self.settings.strColorStalker_Shield_Flat ~= nil then
		self.wndConfigColorsStalker:FindChild("Label_ColorSettingsOuter_Flat:Shield_Flat:ColorWindow"):SetBGColor(self.settings.strColorStalker_Shield_Flat) end
	if self.settings.strColorStalker_Absorb_Flat ~= nil then
		self.wndConfigColorsStalker:FindChild("Label_ColorSettingsOuter_Flat:Absorb_Flat:ColorWindow"):SetBGColor(self.settings.strColorStalker_Absorb_Flat) end
		
	if self.settings.strColorWarrior_HPHealthy_Flat ~= nil then
		self.wndConfigColorsWarrior:FindChild("Label_ColorSettingsOuter_Flat:HPHealthy_Flat:ColorWindow"):SetBGColor(self.settings.strColorWarrior_HPHealthy_Flat) end
	if self.settings.strColorWarrior_HPDebuff_Flat ~= nil then
		self.wndConfigColorsWarrior:FindChild("Label_ColorSettingsOuter_Flat:HPDebuff_Flat:ColorWindow"):SetBGColor(self.settings.strColorWarrior_HPDebuff_Flat) end
	if self.settings.strColorWarrior_Shield_Flat ~= nil then
		self.wndConfigColorsWarrior:FindChild("Label_ColorSettingsOuter_Flat:Shield_Flat:ColorWindow"):SetBGColor(self.settings.strColorWarrior_Shield_Flat) end
	if self.settings.strColorWarrior_Absorb_Flat ~= nil then
		self.wndConfigColorsWarrior:FindChild("Label_ColorSettingsOuter_Flat:Absorb_Flat:ColorWindow"):SetBGColor(self.settings.strColorWarrior_Absorb_Flat) end
end


---------------------------------------------------------------------------------------------------
-- OnUpdateTimer
---------------------------------------------------------------------------------------------------

function BetterPartyFrames:OnUpdateTimer(strVar, nValue)
	if GroupLib.InRaid() then -- TODO: Refactor, also free up memory
		if self.wndGroupHud and self.wndGroupHud:IsValid() and self.wndGroupHud:IsShown() then
			self.wndGroupHud:Show(false, true)
			Apollo.StopTimer("GroupUpdateTimer")
		end
		return
	end

	self.nGroupMemberCount = nMemberCount
	if self.nGroupMemberCount == 0 then
		if not self.wndLeaveGroup:IsShown() and not self.wndGroupMessage:IsShown() then
			self.wndGroupHud:Show(false, true)
		end
		return
	end

	self:OnMasterLootUpdate()
	self.wndGroupHud:FindChild("GroupWrongInstance"):Show(GroupLib.CanGotoGroupInstance())

	-- TODO: This should probably be moved to the other on frame timer
	local nMemberCount = GroupLib.GetMemberCount()
	if self.nGroupMemberCount ~= nMemberCount then
		self:OnGroupUpdated()
	end

	if self.nGroupMemberCount ~= nil then
		for idx = 1, self.nGroupMemberCount do
			local tMemberInfo = GroupLib.GetGroupMember(idx)
			if tMemberInfo ~= nil then
				if self.tGroupWndPortraits[idx] == nil then
					self:LoadPortrait(idx)
				end
				self:DrawMemberPortrait(self.tGroupWndPortraits[idx], tMemberInfo)
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Message Calls/Events/Signals
---------------------------------------------------------------------------------------------------

-- TODO: Refactor all below this

function BetterPartyFrames:OnGroupAdd(strMemberName) -- Someone else joined my group
	local strMsg = String_GetWeaselString(Apollo.GetString("GroupJoin"), strMemberName)
	self:AddToQueue(ktMessageIcon.Accept, strMsg)
	self:OnGroupUpdated()
	
	-- Update Bars to be loaded for new people in the group
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
	self:LoadBarsTexturesHelper(self.settings.ShowBarDesign_Bright, self.settings.ShowBarDesign_Flat)

end

function BetterPartyFrames:OnGroupJoin() -- I joined a group
	self:OnGroupUpdated()
	local strMsg = String_GetWeaselString(Apollo.GetString("GroupJoined"))
	self:AddToQueue(ktMessageIcon.Sent, strMsg)

	self.eInstanceDifficulty = GroupLib.GetInstanceDifficulty()
	self.eLootRules = GroupLib.GetLootRules()

	if GroupLib.InRaid() then
		self:OnUpdateTimer()
	else
		Apollo.StartTimer("GroupUpdateTimer")
	end
	
	-- Update Bars to be loaded for new people in the group
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
	self:LoadBarsTexturesHelper(self.settings.ShowBarDesign_Bright, self.settings.ShowBarDesign_Flat)

end

function BetterPartyFrames:OnGroupRemove(strMemberName, eReason) -- someone else left the group

	if eReason == GroupLib.RemoveReason.Kicked or eReason == GroupLib.RemoveReason.VoteKicked then
		local strMsg = String_GetWeaselString(Apollo.GetString("Group_KickedPlayer"), strMemberName)
		self:AddToQueue(ktMessageIcon.Kicked, strMsg)
	elseif 	eReason == GroupLib.RemoveReason.Left or eReason == GroupLib.RemoveReason.Disband or
			eReason == GroupLib.RemoveReason.RemovedByServer or eReason == GroupLib.RemoveReason.Disconnected then

		local strMsg = String_GetWeaselString(Apollo.GetString("GroupLeft"), strMemberName)
		self:AddToQueue(ktMessageIcon.Left, strMsg)
	end

	self:OnGroupUpdated()
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
	self:LoadBarsTexturesHelper(self.settings.ShowBarDesign_Bright, self.settings.ShowBarDesign_Flat)
end

function BetterPartyFrames:OnGroupMemberPromoted(strMemberName, bSelf) -- I've been promoted
	if bSelf then
		local strMsg = String_GetWeaselString(Apollo.GetString("GroupPromotePlayer"))
		self:AddToQueue(ktMessageIcon.Promoted, strMsg)
	else
		local strMsg = String_GetWeaselString(Apollo.GetString("GroupPromoteOther"),strMemberName)
		self:AddToQueue(ktMessageIcon.Promoted, strMsg)
	end
	self:OnGroupUpdated()
end

function BetterPartyFrames:OnGroupOperationResult(strMemberName, eResult)
	if ktActionResultStrings[eResult] then
		local strMsg = ktActionResultStrings[eResult].strMsg
		if string.find(ktActionResultStrings[eResult].strMsg, "%$1n") then
			strMsg = String_GetWeaselString(ktActionResultStrings[eResult].strMsg, strMemberName)
		end

		if GroupLib.InRaid() and eAction == GroupLib.ActionResult.FlagsFailed then
			strMsg = String_GetWeaselString(Apollo.GetString("Group_AppendInRaid"), strMsg)
		end

		self:AddToQueue(ktActionResultStrings[eResult].strIcon, strMsg)
	end
end

function BetterPartyFrames:OnGroupAcceptInvite() -- I've accepted an invitation
	self.wndGroupInviteDialog:Show(false)
end

function BetterPartyFrames:OnGroupDeclineInvite() -- I've declined an invitation
	self.wndGroupInviteDialog:Show(false)
end

function BetterPartyFrames:OnLootRollUpdate()
--[[
	local tLootRolls = GameLib.GetLootRolls()
	for idx, tLoot in ipairs(tLootRolls) do
		--GameLib.RollOnLoot(tLoot.lootId, true)
	end
]]--
end

function BetterPartyFrames:OnGroupLeft(eReason)
	local unitMe = GameLib.GetPlayerUnit()
	if unitMe == nil then
		return
    end

	local strMsg = ktGroupLeftResultStrings[eReason].strMsg

	if eReason == GroupLib.RemoveReason.Left and self.eChatChannel == ChatSystemLib.ChatChannel_Party then
		strMsg = Apollo.GetString("GroupLeave")
	end

	self:AddToQueue(ktGroupLeftResultStrings[eReason].strIcon, strMsg)

	self.wndRequest:Show(false)
	self.wndLeaveGroup:Show(false)

	self:DestroyGroup()
end

function BetterPartyFrames:OnGroupMemberFlags(nMemberIndex, bIsFromPromotion, tChangedFlags)
	local tMember = GroupLib.GetGroupMember(nMemberIndex)
	if tMember == nil then
		return
	end

	local bSelf = nMemberIndex == 1

	local bIsFromPromotionOrRaidAssistant = bIsFromPromotion or tChangedFlags.bRaidAssistant

	if tChangedFlags.bCanKick then
		local strMsg = ""
		local strPermission = Apollo.GetString("Group_KickPermission")

		if not bIsFromPromotionOrRaidAssistant then
			if tMember.bCanKick then
				strMsg = Apollo.GetString("Group_Enabled")
			else
				strMsg = Apollo.GetString("Group_Disabled")
			end

			if bSelf then
				strMsg = String_GetWeaselString(Apollo.GetString("Group_PermissionsChangedSelf"), strPermission, strMsg)
			elseif GroupLib.AmILeader() then
				strMsg = String_GetWeaselString(Apollo.GetString("Group_PermissionsChangedOther"), strMsg, tMember.strCharacterName, strPermission)
			end
			self:AddToQueue(ktMessageIcon.Promoted, strMsg)
		end
	end

	if tChangedFlags.bCanInvite and not bIsFromPromotionOrRaidAssistant then
		local strMsg = ""
		local strPermission = Apollo.GetString("Group_InvitePermission")

		if tMember.bCanInvite then
			strMsg = Apollo.GetString("Group_Enabled")
		else
			strMsg = Apollo.GetString("Group_Disabled")
		end

		if bSelf then
			strMsg = String_GetWeaselString(Apollo.GetString("Group_PermissionsChangedSelf"), strPermission, strMsg)
		elseif GroupLib.AmILeader() then
			strMsg = String_GetWeaselString(Apollo.GetString("Group_PermissionsChangedOther"), strMsg, tMember.strCharacterName, strPermission)
		end
		self:AddToQueue(ktMessageIcon.Promoted, strMsg)
	end


	if tChangedFlags.bDisconnected then
		if tMember.bDisconnected then
			local strMsg = String_GetWeaselString(Apollo.GetString("Group_CharacterDisconnected"), tMember.strCharacterName)
			self:AddToQueue(ktMessageIcon.Joined, strMsg)
		else
			local strMsg = String_GetWeaselString(Apollo.GetString("Group_CharacterConnected"), tMember.strCharacterName)
			self:AddToQueue(ktMessageIcon.Left, strMsg)
		end
		self:OnGroupUpdated()
	end

	if tChangedFlags.bMainTank and not bIsFromPromotion then
		local strRole = Apollo.GetString("Group_MainTank")
		local strMsg = ""

		if tMember.bMainTank then
			strMsg = Apollo.GetString("Group_GainsRole")
		else
			strMsg = Apollo.GetString("Group_LosesRole")
		end

		strMsg = String_GetWeaselString(strMsg, tMember.strCharacterName, strRole)
		if self.eChatChannel ~= nil then
			ChatSystemLib.PostOnChannel(self.eChatChannel, strMsg, "")
		end
	end

	if tChangedFlags.bMainAssist and not bIsFromPromotion then
		local strRole = Apollo.GetString("Group_MainAssist")
		local strMsg = ""

		if tMember.bMainAssist then
			strMsg = Apollo.GetString("Group_GainsRole")
		else
			strMsg = Apollo.GetString("Group_LosesRole")
		end

		strMsg = String_GetWeaselString(strMsg, tMember.strCharacterName, strRole)
		if self.eChatChannel ~= nil then
			ChatSystemLib.PostOnChannel(self.eChatChannel, strMsg, "")
		end
	end

	if tChangedFlags.bRaidAssistant and not bIsFromPromotion then
		local strRole = Apollo.GetString("Group_RaidAssist")
		local strMsg = ""

		if tMember.bRaidAssistant then
			strMsg = Apollo.GetString("Group_GainsRole")
		else
			strMsg = Apollo.GetString("Group_LosesRole")
		end

		strMsg = String_GetWeaselString(strMsg, tMember.strCharacterName, strRole)
		if self.eChatChannel ~= nil then
			ChatSystemLib.PostOnChannel(self.eChatChannel, strMsg, "")
		end
	end

	-- Fuck this spammy shit.. Why is this in the party frames addon anyways and not part of the addon that actually initiates the ready checks, like.. the raid frame addon???
	--[[
	if tChangedFlags.bReady then
		if tMember.bReady then
			-- Disabling "is ready message" to lower spam
			--local str = tMember.characterName .. " is now ready!"
			--ChatSystemLib.PostOnChannel( self.chatChannel, str, "" )
		else
			local strMsg = String_GetWeaselString(Apollo.GetString("Group_NoLongerReady"), tMember.strCharacterName)
			if self.eChatChannel ~= nil then
				ChatSystemLib.PostOnChannel( self.eChatChannel, strMsg, "" )
			end
		end
	end
	--]]

	if tChangedFlags.bRoleLocked then
		-- TODO: To lower spam, just show this message once
		if bSelf then
			local strMsg = ""

			if tMember.bRoleLocked then
				strMsg = Apollo.GetString("Group_RaidRoleLock")
			else
				strMsg = Apollo.GetString("Group_RaidRoleUnlock")
			end

			if self.eChatChannel ~= nil then
				ChatSystemLib.PostOnChannel(self.eChatChannel, strMsg, "")
			end
		end
	end

	if tChangedFlags.bCanMark then
		if not bIsFromPromotionOrRaidAssistant then
			local strMsg = ""

			if tMember.bCanMark then
				strMsg = String_GetWeaselString(Apollo.GetString("Group_CanMark"), tMember.strCharacterName)
			else
				strMsg = String_GetWeaselString(Apollo.GetString("Group_CanNotMark"), tMember.strCharacterName)
			end

			if self.eChatChannel ~= nil then
				ChatSystemLib.PostOnChannel(self.eChatChannel, strMsg, "")
			end
		end
	end

end


function BetterPartyFrames:OnGroupReadyCheck(nMemberIndex, strMessage)
	local tMember = GroupLib.GetGroupMember(nMemberIndex)

	local strName = ""
	if tMember then
		strName = tMember.strCharacterName
	end
	
	if self.eChatChannel ~= nil then
		ChatSystemLib.PostOnChannel( self.eChatChannel, String_GetWeaselString(Apollo.GetString("Group_ReadyCheckStarted"), strName, strMessage), "" )
	end
end


function BetterPartyFrames:OnGroupInviteResult(strCharacterName, eResult)

	Apollo.DPF("BetterPartyFrames:OnGroupInviteResult")

    local unitMe = GameLib.GetPlayerUnit()
    if unitMe == nil then
		return
    end

	if ktInviteResultStrings[eResult] then
		local strMsg = ktInviteResultStrings[eResult].strMsg

		if string.find(ktInviteResultStrings[eResult].strMsg, "%$1n") then
			strMsg = String_GetWeaselString(ktInviteResultStrings[eResult].strMsg, strCharacterName)
		end

		self:AddToQueue(ktInviteResultStrings[eResult].strIcon, strMsg)

		if eResult == GroupLib.Result.ExpiredInvitee then
			self.fInviteTimerStartTime = nil
			self.wndGroupInviteDialog:Show(false)
		end
	end
end

function BetterPartyFrames:OnGroupRequestResult(strCharacterName, eResult, bIsJoin)
	Apollo.DPF("BetterPartyFrames:OnGroupRequestResult")

    local unitMe = GameLib.GetPlayerUnit()
    if unitMe == nil then
		return
    end

	if bIsJoin then
		if ktJoinRequestResultStrings[eResult] then
			local strMsg = ktJoinRequestResultStrings[eResult].strMsg

			if string.find(ktJoinRequestResultStrings[eResult].strMsg, "%$1n") then
				strMsg = String_GetWeaselString(ktJoinRequestResultStrings[eResult].strMsg, strCharacterName)
			end

			self:AddToQueue(ktJoinRequestResultStrings[eResult].strIcon, strMsg)

			if eResult == GroupLib.Result.ExpiredInvitee then
				self.wndRequest:Show(false)
			end
		end
	else
		if ktReferralStrings[eResult] then
			local strMsg = ktReferralStrings[eResult].strMsg

			if string.find(ktReferralStrings[eResult].strMsg, "%$1n") then
				strMsg = String_GetWeaselString(ktReferralStrings[eResult].strMsg, strCharacterName)
			end

			self:AddToQueue(ktReferralStrings[eResult].strIcon, strMsg)

			if eResult == GroupLib.Result.ExpiredInvitee then
				self.wndRequest:Show(false)
			end
		end
	end
end

function BetterPartyFrames:CloseGroupHUD() -- see if the HUD can be closed
	if GroupLib.InGroup() and GroupLib.GetMemberCount() > 0 then
		return false
	end

	if self.bMessagesQueued == true then
		return false
	end

	self.wndGroupHud:Close()
end

---------------------------------------------------------------------------------------------------
-- Message Queue
---------------------------------------------------------------------------------------------------
function BetterPartyFrames:AddToQueue(nMessageIcon, strMessageText)
	local tMessageInfo = {nIcon = nMessageIcon, strText = strMessageText}
	local nLast = self.tMessageQueue.nLast + 1
	self.tMessageQueue.nLast = nLast
	self.tMessageQueue[nLast] = tMessageInfo

	if self.eChatChannel ~= nil then
		ChatSystemLib.PostOnChannel(self.eChatChannel, strMessageText, "")
	end

	if self.wndGroupMessage:IsVisible() == true then
		return
	else
		self:ProcessAlerts()
	end
end

function BetterPartyFrames:ProcessAlerts()
	self:ClearFields()

	local nFirst = self.tMessageQueue.nFirst
	if nFirst > self.tMessageQueue.nLast then
		self.bMessagesQueued = false -- no messages queued up
		self:HelperResizeGroupContents()
		self:CloseGroupHUD()
		return
	end
	self.bMessagesQueued = true -- messages queued up
	local tMessage = self.tMessageQueue[nFirst]
	self.tMessageQueue[nFirst] = nil
	self.tMessageQueue.nFirst = nFirst + 1

	self:DisplayAlert(tMessage.nIcon, tMessage.strText)
end

function BetterPartyFrames:DisplayAlert(nMessageIcon, strMessageText)
	if strMessageText == nil then
		self:ProcessAlerts()
		return
	end

	self.wndGroupMessage:FindChild(karMessageIconString[nMessageIcon]):Show(true)
	self.wndGroupMessage:FindChild("MessageText"):SetText(strMessageText)

	if not GroupLib.InGroup() then -- message when not grouped
		self.wndGroupHud:FindChild("GroupControlsBtn"):Show(false)
		--self.wndGroupHud:FindChild("GroupBagBtn"):Show(false) -- TODO TEMP DISABLED
		self.wndGroupHud:Show(true)
	end

	self.wndGroupMessage:Show(true)
	self:HelperResizeGroupContents()

	self.wndGroupMessage:FindChild("MessageBirthAnimation"):ToFront()
	self.wndGroupMessage:FindChild("MessageBirthAnimation"):SetSprite("sprWinAnim_BirthSmallTemp")

	Apollo.CreateTimer("GroupMessageTimer", kfMessageDuration, false)
end

---------------------------------------------------------------------------------------------------
function BetterPartyFrames:OnGroupMessageTimer()
	self.wndGroupMessage:FindChild("MessageBirthAnimation"):ToFront()
	self.wndGroupMessage:FindChild("MessageBirthAnimation"):SetSprite("sprWinAnim_BirthSmallTemp")

	self.wndGroupMessage:Show(false)
	self:HelperResizeGroupContents()
	Apollo.CreateTimer("GroupMessageDelayTimer", kfDelayDuration, false) -- routes back to process alerts
end

---------------------------------------------------------------------------------------------------
function BetterPartyFrames:ClearFields() --clear everything
	for idx =1, #karMessageIconString do
		self.wndGroupMessage:FindChild(karMessageIconString[idx]):Show(false)
	end
	self.wndGroupMessage:FindChild("MessageText"):SetText("")
	self.wndGroupMessage:FindChild("MessageBirthAnimation"):SetSprite("")
end

function BetterPartyFrames:OnGroupWrongInstance()
	GroupLib.GotoGroupInstance()
end

---------------------------------------------------------------------------------------------------
-- HELPER
---------------------------------------------------------------------------------------------------

function BetterPartyFrames:HelperResizeGroupContents()
	local nOnGoingHeight = 0
	for key, wndCurr in pairs(self.wndGroupPortraitContainer:GetChildren()) do
		if wndCurr:IsShown() then
			local nLeft, nTop, nRight, nBottom = wndCurr:GetAnchorOffsets()
			nOnGoingHeight = nOnGoingHeight + (nBottom - nTop)
		end
	end
	self.wndGroupPortraitContainer:ArrangeChildrenVert()
	self.wndGroupPortraitContainer:SetAnchorOffsets(0, 0, 0, nOnGoingHeight)

	if self.wndGroupMessage:IsShown() then
		local nLeft, nTop, nRight, nBottom = self.wndGroupMessage:GetAnchorOffsets()
		nOnGoingHeight = nOnGoingHeight + (nBottom - nTop)
	end

	if self.wndLeaveGroup:IsShown() then
		local nLeft, nTop, nRight, nBottom = self.wndLeaveGroup:GetAnchorOffsets()
		nOnGoingHeight = nOnGoingHeight + (nBottom - nTop)
	end

	self.wndGroupHud:FindChild("GroupArrangeVert"):ArrangeChildrenVert(0)

	local nLeft, nTop, nRight, nBottom = self.wndGroupHud:GetAnchorOffsets()
	self.wndGroupHud:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nOnGoingHeight + 47) -- TODO Hard coded formatting
end

---------------------------------------------------------------------------------------------------
-- MENTORING
---------------------------------------------------------------------------------------------------

function BetterPartyFrames:OnGroupMentor(tMemberList, bCurrentlyMentoring, bUpdateOnly)
	-- if this is just an update, only continue if the window is currently shown
	if not self.wndMentor:IsShown() and bUpdateOnly or self.settings.DisableMentoring then
		return
	end

	self.wndMentor:FindChild("MentorMemberList"):DestroyChildren()
	self.tMentorItems = {}

	-- display the passed-in data
	local nMemberCount = table.getn(tMemberList)
	for idx = 1, nMemberCount do
		if tMemberList[idx].unitMentee ~= nil then
			local wndEntry = Apollo.LoadForm(self.xmlDoc, "GroupMentorItem", self.wndMentor:FindChild("MentorMemberList"), self)
			wndEntry:FindChild("MentorMemberBtn"):SetData(tMemberList[idx].unitMentee)
			wndEntry:FindChild("MentorMemberLevel"):SetText(tMemberList[idx].tMemberInfo.nLevel)
			wndEntry:FindChild("MentorMemberName"):SetText(tMemberList[idx].tMemberInfo.strCharacterName)
			wndEntry:FindChild("MentorMemberPathIcon"):SetSprite(ktInvitePathIcons[tMemberList[idx].tMemberInfo.ePathType])

			local strClassSprite = ""
			if ktInviteClassIcons[tMemberList[idx].tMemberInfo.eClassId] then
				strClassSprite = ktInviteClassIcons[tMemberList[idx].tMemberInfo.eClassId]
			end

			wndEntry:FindChild("MentorMemberClass"):SetSprite(strClassSprite)

			self.tMentorItems[idx] = wndEntry
		end
	end

	-- fill in any blank entries
	local nOpenSlots = 4 - (nMemberCount - 1) -- window max less count minus one (the player, who isn't shown)
	if nOpenSlots > 0 then -- make sure it's not running a negative
		for nBlankEntry = 1, nOpenSlots do -- populate the interface
			local wndBlankEntry = Apollo.LoadForm(self.xmlDoc, "GroupInviteBlank", self.wndMentor:FindChild("MentorMemberList"), self)
		end
	end

	self.wndMentor:FindChild("MentorMemberList"):ArrangeChildrenVert()

	self.wndMentor:FindChild("MentorPlayerBtn"):Enable(false) -- never a case where this is enabled off the bat
	self.wndMentor:FindChild("CancelMentoringBtn"):Enable(bCurrentlyMentoring)

	if not self.fMentorTimerStartTime then
		self.fMentorTimerStartTime = os.clock()
	end

	self.fMentorTimerDiff = os.clock() - self.fMentorTimerStartTime


	local strTime = string.format("%d:%02d", math.floor((knMentorTimeout - self.fMentorTimerDiff) / 60), math.floor((knMentorTimeout - self.fMentorTimerDiff) % 60))
	self.wndMentor:FindChild("Timer"):SetText(String_GetWeaselString(Apollo.GetString("Group_ExpiresTimer"), strTime))
	self.wndMentor:FindChild("Timer"):SetData(knMentorTimeout)
	Apollo.CreateTimer("MentorTimer", 1.000, false)

	self.wndMentor:Show(true)
end

function BetterPartyFrames:OnToggleMentorItem(wndHandler, wndCtrl)
	-- this is the list item that has a player. We'll want to save this so the "Mentor Player" button can be activated
	local unitStudent = wndCtrl:GetData()

	if unitStudent == nil then -- no idea how that would happen but whatever
		return
	end

	for idx, wndCurr in pairs(self.tMentorItems) do
		local unitData = wndCurr:FindChild("MentorMemberBtn"):GetData()
		wndCurr:FindChild("MentorMemberBtn"):SetCheck(unitStudent == unitData)
	end

	self.wndMentor:FindChild("MentorPlayerBtn"):SetData(unitStudent)
	self.wndMentor:FindChild("MentorPlayerBtn"):Enable(true)
end

function BetterPartyFrames:OnMentorPlayerBtn(wndHandler, wndCtrl)
	-- this is the button for mentoring a player selected in the list
	local unitStudent = wndCtrl:GetData()

	if unitStudent == nil then
		return
	end

	GroupLib.AcceptMentoring(unitStudent)

	self.wndMentor:Show(false)
	self.fMentorTimerStartTime = nil
	Apollo.StopTimer("MentorTimer")
end

function BetterPartyFrames:OnCancelMentoringBtn(wndHandler, wndCtrl)
	-- this is the button for canceling the mentoring status of this player
	GroupLib.CancelMentoring()

	self.wndMentor:Show(false)
	self.fMentorTimerStartTime = nil
	Apollo.StopTimer("MentorTimer")
end

function BetterPartyFrames:OnMentorCloseBtn(wndHandler, wndCtrl)
	self.wndMentor:Show(false)
	self.fMentorTimerStartTime = nil
	Apollo.StopTimer("MentorTimer")

	GroupLib.CloseMentoringDialog()
end

function BetterPartyFrames:OnMentorTimer()
	-- This is the timer that's shown on the window

	self.fMentorTimerDiff = self.fMentorTimerDiff + 1
	if self.fMentorTimerDiff <= knMentorTimeout then
		local strTime = string.format("%d:%02d", math.floor((knMentorTimeout - self.fMentorTimerDiff) / 60), math.ceil((knMentorTimeout - self.fMentorTimerDiff) % 60))
		self.wndMentor:FindChild("Timer"):SetText(String_GetWeaselString(Apollo.GetString("Group_ExpiresTimer"), strTime))
		self.wndMentor:FindChild("Timer"):SetData(self.fMentorTimerDiff)
		Apollo.StartTimer("MentorTimer")
	else
		Event_FireGenericEvent("GenericEvent_SystemChannelMessage", Apollo.GetString("BetterPartyFrames_MentorWindowTimedOut"))
		self:OnMentorCloseBtn()
	end
end

function BetterPartyFrames:OnGroupMentorLeftAOI(nTimeUntilMentoringDisabled, bClearUI)
	if bClearUI then
		self.wndMentorAOI:Show(false)
		Apollo.StopTimer("MentorAOITimer")
		return
	end

	local strTime = string.format("%d:%02d", math.floor(nTimeUntilMentoringDisabled / 60), math.floor(nTimeUntilMentoringDisabled % 60))
	self.wndMentorAOI:FindChild("Timer"):SetText(String_GetWeaselString(Apollo.GetString("Group_ExpiresTimer"), strTime))
	self.wndMentorAOI:FindChild("Timer"):SetData(nTimeUntilMentoringDisabled)
	Apollo.CreateTimer("MentorAOITimer", 1.000, false)

	self.wndMentorAOI:Show(true)
end

function BetterPartyFrames:OnMentorAOICloseBtn()
	self.wndMentorAOI:Show(false)
	Apollo.StopTimer("MentorAOITimer")

	GroupLib.CloseMentoringAOIDialog()
end

function BetterPartyFrames:OnMentorAOITimer()
	-- This is the timer that's shown on the window
	local nTimerValue = self.wndMentorAOI:FindChild("Timer"):GetData()
	nTimerValue = nTimerValue - 1
	if nTimerValue >= 0 then
		local strTime = string.format("%d:%02d", math.floor(nTimerValue / 60), math.floor(nTimerValue % 60))
		self.wndMentorAOI:FindChild("Timer"):SetText(String_GetWeaselString(Apollo.GetString("Group_ExpiresTimer"), strTime))
		self.wndMentorAOI:FindChild("Timer"):SetData(nTimerValue)
		Apollo.CreateTimer("MentorAOITimer", 1.000, false)
	else
		self:OnMentorAOICloseBtn()
	end
end

function BetterPartyFrames:OnAcceptRequest()
	self.wndRequest:Show(false)
	GroupLib.AcceptRequest()
end

function BetterPartyFrames:OnDenyRequest()
	self.wndRequest:Show(false)
	GroupLib.DenyRequest()
end

---------------------------------------------------------------------------------------------------
-- RaidConvertedForm Functions
---------------------------------------------------------------------------------------------------

function BetterPartyFrames:OnRaidOkay( wndHandler, wndControl, eMouseButton )
	if self.wndRaidNotice and self.wndRaidNotice:IsValid() then
		local wndDoNotShowAgain = self.wndRaidNotice:FindChild("NeverShowAgainButton")
		if wndDoNotShowAgain:IsChecked() then
			self.bNeverShowRaidConvertNotice = true
		end

		self.wndRaidNotice:Destroy()
		self.wndRaidNotice = nil
	end
end

---------------------------------------------------------------------------------------------------
-- ConfigForm Functions
---------------------------------------------------------------------------------------------------

function BetterPartyFrames:OnConfigOn()
	self.wndConfig:Show(true)
	self:RefreshSettings()
end

function BetterPartyFrames:OnSaveButton()
	self.wndConfig:Show(false)
end

function BetterPartyFrames:Button_ShowHP_K( wndHandler, wndControl )
	self.settings.ShowHP_K = wndControl:IsChecked()
	if self.wndConfig:FindChild("Button_ShowHP_Full"):IsChecked() and wndControl:IsChecked() then
		self.settings.ShowHP_Full = false
		self.wndConfig:FindChild("Button_ShowHP_Full"):SetCheck(false)
	end
end

function BetterPartyFrames:Button_ShowHP_Full( wndHandler, wndControl )
	self.settings.ShowHP_Full = wndControl:IsChecked()
	if self.wndConfig:FindChild("Button_ShowHP_K"):IsChecked() and wndControl:IsChecked() then
		self.settings.ShowHP_K = false
		self.wndConfig:FindChild("Button_ShowHP_K"):SetCheck(false)
	end
end

function BetterPartyFrames:Button_ShowHP_Pct( wndHandler, wndControl )
	self.settings.ShowHP_Pct = wndControl:IsChecked()
end

function BetterPartyFrames:Button_ShowShield_K( wndHandler, wndControl )
	self.settings.ShowShield_K = wndControl:IsChecked()
	if self.wndConfig:FindChild("Button_ShowShield_Pct"):IsChecked() and wndControl:IsChecked() then
		self.settings.ShowShield_Pct = false
		self.wndConfig:FindChild("Button_ShowShield_Pct"):SetCheck(false)
	end
end

function BetterPartyFrames:Button_ShowShield_Pct( wndHandler, wndControl )
	self.settings.ShowShield_Pct = wndControl:IsChecked()
	if self.wndConfig:FindChild("Button_ShowShield_K"):IsChecked() and wndControl:IsChecked() then
		self.settings.ShowShield_K = false
		self.wndConfig:FindChild("Button_ShowShield_K"):SetCheck(false)
	end
end

function BetterPartyFrames:Button_ShowAbsorb_K( wndHandler, wndControl )
	self.settings.ShowAbsorb_K = wndControl:IsChecked()
end


function BetterPartyFrames:Button_LockFrame( wndHandler, wndControl )
	self.settings.LockFrame = wndControl:IsChecked()
	self:LockFrameHelper(self.settings.LockFrame)
end

function BetterPartyFrames:Button_TrackDebuffs( wndHandler, wndControl )
	self.settings.TrackDebuffs = wndControl:IsChecked()
end

function BetterPartyFrames:Button_ShowLevel( wndHandler, wndControl )
	self.settings.ShowLevel = wndControl:IsChecked()
end

function BetterPartyFrames:Button_ShowShieldBar( wndHandler, wndControl )
	self.settings.ShowShieldBar = wndControl:IsChecked()
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
end

function BetterPartyFrames:Button_ShowAbsorbBar( wndHandler, wndControl )
	self.settings.ShowAbsorbBar = wndControl:IsChecked()
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
end

function BetterPartyFrames:Button_ShowBarDesign_Bright( wndHandler, wndControl )
	self.settings.ShowBarDesign_Bright = wndControl:IsChecked()
	if self.wndConfig:FindChild("Button_ShowBarDesign_Flat"):IsChecked() and wndControl:IsChecked() then
		self.settings.ShowBarDesign_Flat = false
		self.wndConfig:FindChild("Button_ShowBarDesign_Flat"):SetCheck(false)
	-- We must have at least one Bar design checked.
	elseif not self.wndConfig:FindChild("Button_ShowBarDesign_Flat"):IsChecked() and not wndControl:IsChecked() then
		self.settings.ShowBarDesign_Flat = true
		self.wndConfig:FindChild("Button_ShowBarDesign_Flat"):SetCheck(true)
	end
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
	self:LoadBarsTexturesHelper(self.settings.ShowBarDesign_Bright, self.settings.ShowBarDesign_Flat)
end

function BetterPartyFrames:Button_ShowBarDesign_Flat( wndHandler, wndControl )
	self.settings.ShowBarDesign_Flat = wndControl:IsChecked()
	if self.wndConfig:FindChild("Button_ShowBarDesign_Bright"):IsChecked() and wndControl:IsChecked() then
		self.settings.ShowBarDesign_Bright = false
		self.wndConfig:FindChild("Button_ShowBarDesign_Bright"):SetCheck(false)
	-- We must have at least one Bar design checked.
	elseif not self.wndConfig:FindChild("Button_ShowBarDesign_Bright"):IsChecked() and not wndControl:IsChecked() then
		self.settings.ShowBarDesign_Bright = true
		self.wndConfig:FindChild("Button_ShowBarDesign_Bright"):SetCheck(true)
	end
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
	self:LoadBarsTexturesHelper(self.settings.ShowBarDesign_Bright, self.settings.ShowBarDesign_Flat)
end

function BetterPartyFrames:Button_MouseOverSelection( wndHandler, wndControl )
	self.settings.MouseOverSelection = wndControl:IsChecked()
	if not self.settings.MouseOverSelection then
		self.wndConfig:FindChild("Button_RememberPrevTarget"):SetCheck(false)
		self.settings.RememberPrevTarget = false
	end
end

function BetterPartyFrames:Button_RememberPrevTarget( wndHandler, wndControl )
	self.settings.RememberPrevTarget = wndControl:IsChecked()
	if not self.settings.MouseOverSelection and self.settings.RememberPrevTarget then
		self.wndConfig:FindChild("Button_MouseOverSelection"):SetCheck(true)
		self.settings.MouseOverSelection = true
	end
end

function BetterPartyFrames:Button_SetSemiTransparency( wndHandler, wndControl )
	self.settings.SemiTransparency = wndControl:IsChecked()
	if self.wndConfig:FindChild("Button_Full_Transparency"):IsChecked() and wndControl:IsChecked() then
		self.settings.FullTransparency = false
		self.wndConfig:FindChild("Button_Full_Transparency"):SetCheck(false)
	end
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
	self:LoadBarsTexturesHelper(self.settings.ShowBarDesign_Bright, self.settings.ShowBarDesign_Flat)
end

function BetterPartyFrames:Button_SetFullTransparency (wndHandler, wndControl)
	self.settings.FullTransparency = wndControl:IsChecked()
	if self.wndConfig:FindChild("Button_Semi_Transparency"):IsChecked() and wndControl:IsChecked() then
		self.settings.SemiTransparency = false
		self.wndConfig:FindChild("Button_Semi_Transparency"):SetCheck(false)
	end
	self:LoadBarsHelper(self.settings.ShowShieldBar, self.settings.ShowAbsorbBar)
	self:LoadBarsTexturesHelper(self.settings.ShowBarDesign_Bright, self.settings.ShowBarDesign_Flat)
end

function BetterPartyFrames:Button_DisableMentoring( wndHandler, wndControl, eMouseButton )
	self.settings.DisableMentoring = wndControl:IsChecked()
end

function BetterPartyFrames:Button_CheckRange( wndHandler, wndControl, eMouseButton )
	self.settings.CheckRange = wndControl:IsChecked()
end

function BetterPartyFrames:Slider_MaxRange( wndHandler, wndControl, fNewValue, fOldValue )
	if math.floor(fNewValue) == math.floor(fOldValue) then return end
	self.wndConfig:FindChild("Label_MaxRangeDisplay"):SetText(string.format("%sm", math.floor(fNewValue)))
	self.settings.MaxRange = math.floor(fNewValue)
end

---------------------------------------------------------------------------------------------------
-- GroupPortraitHud Functions
---------------------------------------------------------------------------------------------------

function BetterPartyFrames:GroupPortraitHud_OnMouseEnter( wndHandler, wndControl, x, y )
	if not wndControl or not self.settings.MouseOverSelection then
		return
	end
	
	if wndControl:GetName() == "GroupPortraitBtn" then
		if self.settings.RememberPrevTarget and not self.OldTargetSet then
			self.PrevTarget = GameLib.GetTargetUnit()
			self.OldTargetSet = true
		end
	
		-- Sometimes seems to happen to users where [1] does not exist and creates a lua error?
		local wndControlData = wndControl:GetData()
		if not wndControlData or type(wndControlData) ~= "table" or not wndControlData[1] then
			return
		end
		
		local idx = wndControlData[1]
		local unit = GroupLib.GetUnitForGroupMember(idx)
		if unit ~= nil then
			GameLib.SetTargetUnit(unit)
		end
	end	
end

function BetterPartyFrames:GroupPortraitHud_OnMouseExit( wndHandler, wndControl, x, y )
	if not wndHandler or not wndControl or not self.settings.MouseOverSelection or not self.settings.RememberPrevTarget or not self.OldTargetSet then
		return
	end
	if wndHandler == wndControl then
		GameLib.SetTargetUnit(self.PrevTarget)
		self.OldTargetSet = false
	end
end

---------------------------------------------------------------------------------------------------
-- ConfigColorsForm Functions
---------------------------------------------------------------------------------------------------

function BetterPartyFrames:Cprint(str)
	ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Command, str, "")
end

function BetterPartyFrames:OnSlashCmd(sCmd, sInput)
	local option = string.lower(sInput)
	if option == nil or option == "" then
		self:Cprint("Thanks for using BetterPartyFrames :)")
		self:Cprint("/bpf options - Options Menu")
		self:Cprint("/bpf colors - Customize Bar Colors")
	elseif option == "options" then
		self:OnConfigOn()
	elseif option == "colors" then
		self:OnConfigColorsOn()
	end
end

function BetterPartyFrames:GetBarDesignSuffix()
	if self.settings.ShowBarDesign_Bright then
		return "_Bright"
	elseif self.settings.ShowBarDesign_Flat then
		return "_Flat"
	end
end

function BetterPartyFrames:OnConfigColorsOn()
	self:RefreshSettings()
	self.wndConfigColors:Show(true)
end

function BetterPartyFrames:OnConfigColorsCloseButton( wndHandler, wndControl, eMouseButton )
	self.wndConfigColors:Show(false)
end

-- API for wndControl:IsChecked() updates too slowly so need separate uncheck handlers.. /sigh
function BetterPartyFrames:Button_ColorSettingsGeneralCheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsGeneral:Show(true)
end

function BetterPartyFrames:Button_ColorSettingsGeneralUncheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsGeneral:Show(false)
end

function BetterPartyFrames:Button_ColorSettingsEngineerCheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsEngineer:Show(true)
end

function BetterPartyFrames:Button_ColorSettingsEngineerUncheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsEngineer:Show(false)
end

function BetterPartyFrames:Button_ColorSettingsEsperCheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsEsper:Show(true)
end

function BetterPartyFrames:Button_ColorSettingsEsperUncheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsEsper:Show(false)
end

function BetterPartyFrames:Button_ColorSettingsMedicCheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsMedic:Show(true)
end

function BetterPartyFrames:Button_ColorSettingsMedicUncheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsMedic:Show(false)
end

function BetterPartyFrames:Button_ColorSettingsSpellslingerCheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsSpellslinger:Show(true)
end

function BetterPartyFrames:Button_ColorSettingsSpellslingerUncheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsSpellslinger:Show(false)
end

function BetterPartyFrames:Button_ColorSettingsStalkerCheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsStalker:Show(true)
end

function BetterPartyFrames:Button_ColorSettingsStalkerUncheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsStalker:Show(false)
end

function BetterPartyFrames:Button_ColorSettingsWarriorCheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsWarrior:Show(true)
end

function BetterPartyFrames:Button_ColorSettingsWarriorUncheck( wndHandler, wndControl, eMouseButton )
	self.wndConfigColorsWarrior:Show(false)
end

---------------------------------------------------------------------------------------------------
-- ConfigColorsGeneral Functions
---------------------------------------------------------------------------------------------------

function BetterPartyFrames:Button_ClassSpecificBarColors( wndHandler, wndControl, eMouseButton )
	self.settings.bClassSpecificBarColors = wndHandler:IsChecked()
end

function BetterPartyFrames:OnColorReset( wndHandler, wndControl, eMouseButton )
	if wndHandler ~= wndControl then return end
	local strCategory = wndControl:GetParent():GetParent():GetParent():GetName()
	local strIdentifier = wndControl:GetParent()
	local strCategorySettingKey = ktCategoryToSettingKeyPrefix[strCategory]..strIdentifier:GetName()
	strIdentifier:FindChild("ColorWindow"):SetBGColor(DefaultSettings[strCategorySettingKey])
	self.settings[strCategorySettingKey] = DefaultSettings[strCategorySettingKey]
end

function BetterPartyFrames:OnColorClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if wndHandler ~= wndControl or eMouseButton ~= GameLib.CodeEnumInputMouse.Left then return end
	local strCategory = wndControl:GetParent():GetParent():GetParent():GetName()
	local strIdentifier = wndControl:GetParent()
	local strCategorySettingKey = ktCategoryToSettingKeyPrefix[strCategory]..strIdentifier:GetName()
	self.GeminiColor:ShowColorPicker(self, {callback = "OnGeminiColor", bCustomColor = true, strInitialColor = self.settings[strCategorySettingKey]}, strCategory, strIdentifier, strCategorySettingKey)
end

function BetterPartyFrames:OnGeminiColor(strColor, strCategory, strIdentifier, strCategorySettingKey)
	strIdentifier:FindChild("ColorWindow"):SetBGColor(strColor)
	self.settings[strCategorySettingKey] = strColor
end

---------------------------------------------------------------------------------------------------
-- BetterPartyFrames instance
---------------------------------------------------------------------------------------------------
local GroupFrameInst = BetterPartyFrames:new()
BetterPartyFrames:Init()
