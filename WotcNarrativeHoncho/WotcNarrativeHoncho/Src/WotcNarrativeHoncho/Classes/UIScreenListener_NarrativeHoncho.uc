class UIScreenListener_NarrativeHoncho extends UIScreenListener;

`define NHLOG(message) `log(`message,, 'NarrativeHoncho');

var bool bAlreadyInSkyrangerOrAvenger;
var bool bNarrativeAlreadyDisabled;

event OnInit(UIScreen Screen)
{
    local NarrativeHoncho_Settings settings;

    if (MCM_API(Screen) != none || UIShell(Screen) != none)
    {
        settings = new class'NarrativeHoncho_Settings';
        settings.OnInit(Screen);
    }

    // We can't use the Highlander's X2EventListener AddConversation event to
    // control post-mission narratives, since these X2EventListeners run far too
    // late. Post-mission narratives play in the Skyranger during the seamless
    // load of the strategy game from tactical. Hence tactical has been
    // destroyed, and strategy isn't fully loaded yet, so our strategy mode
    // X2EventListeners haven't been registered yet.
    //
    // Even with the Highlander, the only recourse we have is to use the
    // cheat manager narrative disablement flag, with caution, since leaving
    // this on breaks things.
    //
    // We use our screen listener to break into the loading process early:
    // UIMessageMgr is loaded everywhere by the presentation layer, prior to
    // HUDs. We can tell if we're not in tactical by checking for HQPRES,
    // though this doesn't tell us whether we're transitioning, or properly in
    // strategy mode, so we have to work this out via how many times we're
    // called (once for the transition, then once again for strategy mode).
    //
    // If for some reason we only get one UIMessageMgr instantiation
    // with HQPRES valid, That's fine, since we undo our blocking once the
    // Avenger HUD spawns.
    if (UIMessageMgr(Screen) != none && `HQPRES != none)
    {
        // In the Skyranger returning to the Avenger, or back at the Avenger.
        // Disable narratives if we don't want post-mission narratives.
        if (!bAlreadyInSkyrangerOrAvenger)
        {
            `NHLOG("Just entered Skyranger/Avenger");
            bAlreadyInSkyrangerOrAvenger = true;
            HandlePostMissionNarratives(true);
        }
        else
        {
            `NHLOG("Already in Skyranger/Avenger");
        }
    }
    if (UIAvengerHUD(Screen) != none)
    {
        // Definitely back at the Avenger. Re-enable narratives if we disabled
        // them to block post-mission narratives.
        HandlePostMissionNarratives(false);
        bAlreadyInSkyrangerOrAvenger = false;
    }
}

function HandlePostMissionNarratives(bool Start)
{
    local NarrativeHoncho_Settings settings;
    local XComCheatManager CheatManager;

    settings = new class'NarrativeHoncho_Settings';
    if (settings.NoPostMissionNarratives)
    {
        CheatManager = XComCheatManager(`XCOMGRI.GetALocalPlayerController().CheatManager);
        if (Start)
        {
            bNarrativeAlreadyDisabled = CheatManager.bNarrativeDisabled;
            CheatManager.bNarrativeDisabled = true;
            `NHLOG("Disabling post-mission narratives (bNarrativeDisabled was " $ bNarrativeAlreadyDisabled $ ")");
        }
        else
        {
            `NHLOG("Post-mission complete (restoring bNarrativeDisabled to " $ bNarrativeAlreadyDisabled $ ")");
            CheatManager.bNarrativeDisabled = bNarrativeAlreadyDisabled;
        }
    }
}

defaultproperties
{
    ScreenClass = none;
}
