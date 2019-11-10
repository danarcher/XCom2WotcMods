class X2DownloadableContentInfo_RebalancedRecovery extends X2DownloadableContentInfo;

// From X2StrategyGameRulesetDataStructures.uc:
//
// struct native WoundSeverity
// {
//     var float MinHealthPercent;
//     var float MaxHealthPercent;
//     var int   MinPointsToHeal;
//     var int   MaxPointsToHeal;
//     var int   Difficulty;
// };
//
// struct native WoundLengths
// {
//     var array<int> WoundStateLengths;
// };

exec function RebalancedRecoveryDump()
{
    local array<WoundSeverity> WoundSeverities;
    local array<WoundHealthPercents> WoundStates;
    local array<float> HealSoldierProject_TimeScalar;
    local WoundSeverity WoundSeverity;
    local WoundHealthPercents WoundState;
    local int i, j;
    local string s;

    WoundSeverities = class'X2StrategyGameRulesetDataStructures'.default.WoundSeverities;
    WoundStates = class'X2StrategyGameRulesetDataStructures'.default.WoundStates;
    HealSoldierProject_TimeScalar = class'X2StrategyGameRulesetDataStructures'.default.HealSoldierProject_TimeScalar;

    WriteToConsole("Wound Severities:");
    for (i = 0; i < WoundSeverities.Length; ++i)
    {
        WoundSeverity = WoundSeverities[i];
        WriteToConsole("" $ i $ ": " $ WoundSeverity.MinHealthPercent $ "%-" $ WoundSeverity.MaxHealthPercent $ "% = " $ WoundSeverity.MinPointsToHeal $ "-" $ WoundSeverity.MaxPointsToHeal $ " (" $ WoundSeverity.Difficulty $ ")");
    }
    WriteToConsole("Wound States:");
    for (i = 0; i < WoundStates.Length; ++i)
    {
        WoundState = WoundStates[i];
        s = "" $ i $ ":";
        for (j = 0; j < WoundState.WoundStateHealthPercents.Length; ++j)
        {
            s = s $ j $ "=" $ WoundState.WoundStateHealthPercents[j] $ " ";
        }
        WriteToConsole(s);
    }
    WriteToConsole("HealSoldierProject_TimeScalar:");
    s = "";
    for (i = 0; i < HealSoldierProject_TimeScalar.Length; ++i)
    {
        s = s $ i $ ":" $ HealSoldierProject_TimeScalar[i] $ " ";
    }
    WriteToConsole(s);
}

static function WriteToConsole(string message)
{
    class'Helpers'.static.OutputMsg(message);
}
