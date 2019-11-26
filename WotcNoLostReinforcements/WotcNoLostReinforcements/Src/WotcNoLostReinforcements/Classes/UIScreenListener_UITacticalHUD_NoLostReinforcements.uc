class UIScreenListener_UITacticalHUD_NoLostReinforcements
    extends UIScreenListener
    config(NoLostReinforcements);

event OnInit(UIScreen Screen)
{
    local Object This;

    This = self;
    `XEVENTMGR.RegisterForEvent(This, 'PlayerTurnEnded', OnPlayerTurnEnded, ELD_OnStateSubmitted);
}

function EventListenerReturn OnPlayerTurnEnded(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
    local XComGameState NewGameState;
    local XComGameState_BattleData BattleData;

    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("NoLostReinforcements Per Turn Reset");

    BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
    BattleData = XComGameState_BattleData(NewGameState.ModifyStateObject(class'XComGameState_BattleData', BattleData.ObjectID));

    // Belt, braces, and several obliging valets.
    if (BattleData.bLostSpawningDisabledViaKismet != true ||
        BattleData.LostMaxWaves != 0 ||
        BattleData.LostQueueStrength != 999 ||
        BattleData.LostLoudSoundThreshold != 999 ||
        BattleData.LostSpawningLevel != 999)
    {
        `LOG("NoLostReinforcements: Preventing Lost waves");
        BattleData.bLostSpawningDisabledViaKismet = true; // Disable wave spawns
        BattleData.LostMaxWaves = 0;                      // Zero waves allowed
        BattleData.LostQueueStrength = 999;               // We've had enough waves
        BattleData.LostLoudSoundThreshold = 999;          // No sound is loud enough
        BattleData.LostSpawningLevel = 999;               // Lost spawn in 999 turns

        `TACTICALRULES.SubmitGameState(NewGameState);
    }
    else
    {
        `LOG("NoLostReinforcements: Nothing to do");
        `XCOMHISTORY.CleanupPendingGameState(NewGameState);
    }

    return ELR_NoInterrupt;
}

defaultproperties
{
    ScreenClass = UITacticalHUD
}
