class X2DownloadableContentInfo_WotcDebugCommands extends X2DownloadableContentInfo;

exec function AddFortressDoom()
{
    class'X2StrategyElement_DefaultAlienAI'.static.AddFortressDoom();
}

exec function NarrativeMoment(string Moment)
{
    `HQPRES.UINarrative(XComNarrativeMoment(`CONTENT.RequestGameArchetype(Moment)));
}

exec function FixDoom()
{
    local XComGameState NewGameState;
    local XComGameState_HeadquartersAlien AlienHQ;
    local XComGameState_MissionSite MissionState;
    local TDateTime CurrentTime;
    local int HoursToAdd;
    local int CurrentDoom, MaxDoom, ExcessDoom, RemoveDoom;
    local array<XComGameState_MissionSite> Facilities;
    local AlienFacilityBuildData FacilityData;

    // What, what, what time is it.
    CurrentTime = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();

    // We need to modify the alien HQ.
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Debug Commands: Fix Doom");
    AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
    AlienHQ = XComGameState_HeadquartersAlien(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));

    // We've seen everything.
    AlienHQ.bHasSeenDoomPopup = true;
    AlienHQ.bHasSeenDoomMeter = true;
    AlienHQ.bHasSeenDoomPopup = true;
    AlienHQ.bHasSeenFortress = true;
    AlienHQ.bHasSeenFacility = true;
    AlienHQ.bHasHeardFacilityWarningHalfway = true;
    AlienHQ.bHasHeardFacilityWarningAlmostDone = true;

    // Show me the fortress.
    AlienHQ.MakeFortressAvailable(NewGameState);

    // Clear pending doom/events.
    // Break out of "lose mode" if necessary, and reset the timer.
    // Stop throttling doom, and don't accelerate it either.
    AlienHQ.AIMode = "StartPhase";
    AlienHQ.bNeedsDoomPopup = false;
    AlienHQ.bThrottlingDoom = false;
    AlienHQ.bAcceleratingDoom = false;
    AlienHQ.DoomHoursToAddOnResume = 0;
    AlienHQ.FacilityHoursToAddOnResume = 0;
    AlienHQ.LoseTimerTimeRemaining = 0; // Zero means decidedly not zero.
    AlienHQ.PendingDoomData.Remove(0, AlienHQ.PendingDoomData.Length);
    AlienHQ.PendingDoomEntity.ObjectID = 0;
    AlienHQ.PendingDoomEvent = '';

    // Remove permanent, irreversable doom.
    AlienHQ.Doom = 0;

    // If we've enough doom for lose mode, back it up.
    CurrentDoom = AlienHQ.GetCurrentDoom();
    MaxDoom = AlienHQ.GetMaxDoom();
    if (CurrentDoom >= MaxDoom)
    {
        // Drop back to 2 pips from lose mode.
        ExcessDoom = (CurrentDoom - MaxDoom) + 2;

        // First try to remove excess doom from the fortress.
        foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_MissionSite', MissionState)
        {
            if (MissionState.Source == 'MissionSource_Final' && MissionState.Doom > 0 && ExcessDoom > 0)
            {
                MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));
                RemoveDoom = min(MissionState.Doom, ExcessDoom);
                MissionState.Doom -= RemoveDoom;
                ExcessDoom -= RemoveDoom;
            }
        }

        // Then try to remove excess doom from anywhere else.
        foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_MissionSite', MissionState)
        {
            if (MissionState.Source != 'MissionSource_Final' && MissionState.Doom > 0 && ExcessDoom > 0)
            {
                MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));
                RemoveDoom = min(MissionState.Doom, ExcessDoom);
                MissionState.Doom -= RemoveDoom;
                ExcessDoom -= RemoveDoom;
            }
        }
    }

    // Start generating fortress doom.
    AlienHQ.bGeneratingFortressDoom = true;
    AlienHQ.FortressDoomIntervalStartTime = CurrentTime;
    AlienHQ.FortressDoomIntervalEndTime = CurrentTime;
    HoursToAdd = AlienHQ.GetMinFortressDoomInterval() + `SYNC_RAND(AlienHQ.GetMaxFortressDoomInterval() - AlienHQ.GetMinFortressDoomInterval() + 1);
    class'X2StrategyGameRulesetDataStructures'.static.AddHours(AlienHQ.FortressDoomIntervalEndTime, HoursToAdd);
    AlienHQ.FortressDoomTimeRemaining = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(AlienHQ.FortressDoomIntervalEndTime, AlienHQ.FortressDoomIntervalStartTime);
    AlienHQ.CalculateNextFortressDoomToAdd();

    // Build facilities if we should be building them. Otherwise stop.
    Facilities = AlienHQ.GetValidFacilityDoomMissions();
    if (Facilities.Length < AlienHQ.GetMaxFacilities())
    {
        AlienHQ.bBuildingFacility = true;
        AlienHQ.FacilityBuildStartTime = CurrentTime;
        AlienHQ.FacilityBuildEndTime = CurrentTime;
        FacilityData = AlienHQ.GetMonthlyFacilityBuildData();
        HoursToAdd = ((FacilityData.MinBuildDays * 24) + `SYNC_RAND_STATIC((FacilityData.MaxBuildDays * 24) - (FacilityData.MinBuildDays * 24) + 1));
        class'X2StrategyGameRulesetDataStructures'.static.AddHours(AlienHQ.FacilityBuildEndTime, HoursToAdd);
        AlienHQ.FacilityBuildTimeRemaining = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(AlienHQ.FacilityBuildEndTime, AlienHQ.FacilityBuildStartTime);
    }
    else
    {
        AlienHQ.bBuildingFacility = false;
        AlienHQ.FacilityBuildEndTime.m_iYear = 9999;
    }

    // Start generating facility doom if we have facilities. Stop otherwise.
    if (Facilities.Length > 0)
    {
        AlienHQ.bGeneratingFacilityDoom = true;
        AlienHQ.FacilityDoomIntervalStartTime = CurrentTime;
        AlienHQ.FacilityDoomIntervalEndTime = CurrentTime;
        HoursToAdd = AlienHQ.GetFacilityDoomHours();
        class'X2StrategyGameRulesetDataStructures'.static.AddHours(AlienHQ.FacilityDoomIntervalEndTime, HoursToAdd);
        AlienHQ.FacilityDoomTimeRemaining = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(AlienHQ.FacilityDoomIntervalEndTime, AlienHQ.FacilityDoomIntervalStartTime);
        AlienHQ.CalculateNextFacilityDoomToAdd();
    }
    else
    {
        AlienHQ.bGeneratingFacilityDoom = false;
        AlienHQ.FacilityDoomIntervalEndTime.m_iYear = 9999;
    }

    // Make it so.
    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}
