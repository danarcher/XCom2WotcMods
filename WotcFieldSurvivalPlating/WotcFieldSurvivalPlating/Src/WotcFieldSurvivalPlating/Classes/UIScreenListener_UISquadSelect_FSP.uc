class UIScreenListener_UISquadSelect_FSP
    extends UIScreenListener
    config(FieldSurvivalPlating);

`define FSPLOG(message) `LOG(`message,, 'FieldSurvivalPlating')

var UIText WarningText;

event OnInit(UIScreen Screen)
{
    local Object This;

    // We have to listen to all screens, to avoid dependencies on mods which may
    // override UISquadSelect. So here we have to check the screen.
    if (IsTargetScreen(Screen))
    {
        This = self;
        `FSPLOG("Screen listener found UISquadSelect");
        `XEVENTMGR.RegisterForEvent(This, 'rjSquadSelect_UpdateData', OnUpdateData, ELD_OnStateSubmitted);

        WarningText = Screen.Spawn(class'UIText', Screen).InitText('Warning');
        WarningText.AnchorTopCenter();
        WarningText.SetPosition(-90, 80); // Align below "Launch" button
        WarningText.ResizeToText = true;
        WarningText.Hide();

        // Initial update
        CheckSquadPlating();
    }
    else
    {
        `FSPLOG("Screen listener ignoring " $ Screen.Class.Name);
    }
}

event OnRemoved(UIScreen Screen)
{
    local Object This;
    if (IsTargetScreen(Screen))
    {
        This = self;
        `FSPLOG("Screen listener removed from UISquadSelect");
        `XEVENTMGR.UnRegisterFromEvent(This, 'rjSquadSelect_UpdateData');
    }
}

function bool IsTargetScreen(UIScreen Screen)
{
    return UISquadSelect(Screen) != none;
}

function EventListenerReturn OnUpdateData(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
    CheckSquadPlating();
    return ELR_NoInterrupt;
}

function CheckSquadPlating()
{
    local StateObjectReference UnitRef;
    local XComGameState_Unit Unit;
    local name PlatingName, PriorityName;
    local int WarningCount;
    local string Message;

    // Find the best plating available.
    PlatingName = '';
    foreach class'FieldSurvivalPlating'.default.SOLDIER_PLATING_PRIORITY(PriorityName)
    {
        if (`XCOMHQ.HasItemByName(PriorityName))
        {
            PlatingName = PriorityName;
        }
    }
    `FSPLOG("Best plating is '" $ PlatingName $ "'");

    // Check soldiers have the best plating.
    if (PlatingName != '')
    {
        foreach `XCOMHQ.Squad(UnitRef)
        {
            if (UnitRef.ObjectID != 0)
            {
                Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
                if (Unit.IsSoldier() &&
                    !Unit.IsRobotic() &&
                    !Unit.HasItemOfTemplateType(PlatingName))
                {
                    `FSPLOG("Soldier " $ Unit.GetFullName() $ " does not have the best plating");
                    WarningCount += 1;
                }
            }
        }
    }

    `FSPLOG(WarningCount $ " soldiers are under-equipped");
    if (WarningCount > 0)
    {
        WarningText.Show();
        Message = class'UIUtilities_Text'.static.GetColoredText(class'FieldSurvivalPlating'.default.SquadSelectNoSoldierPlatingWarning, eUIState_Warning2, 30);
        `FSPLOG("Displaying message '" $ Message $ "'");
        WarningText.SetHTMLText(Message);
    }
    else
    {
        WarningText.Hide();
    }
}

defaultproperties
{
    ScreenClass = none
}
