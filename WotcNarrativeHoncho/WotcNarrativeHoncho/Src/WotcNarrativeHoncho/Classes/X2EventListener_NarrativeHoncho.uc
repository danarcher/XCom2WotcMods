class X2EventListener_NarrativeHoncho
    extends X2EventListener
    config(NarrativeHoncho_Settings);

`define NHLOG(message) `log(`message,, 'NarrativeHoncho');

enum ELayer
{
    eLayer_Strategy,
    eLayer_Tactical
};

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    //check if highlander exists and is at least version 1.9, before adding template
    if (IsCHHLMinVersionInstalled(1,9))
    {
        Templates.AddItem(CreateStrategyTemplate());
        Templates.AddItem(CreateTacticalTemplate());
    }
    else
    {
        `NHLOG("X2WOTCCommunityHighlander is missing or is an old version! Please install the latest version and relaunch the game.");
    }

    return Templates;
}

static function CHEventListenerTemplate CreateStrategyTemplate()
{
    local CHEventListenerTemplate Template;

    `CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'NarrativeHoncho_OnAddConversationStrategy');
    Template.RegisterInTactical = false;
    Template.RegisterInStrategy = true;
    Template.AddCHEvent('AddConversation', OnAddConversationStrategy, ELD_Immediate);

    return Template;
}

static function CHEventListenerTemplate CreateTacticalTemplate()
{
    local CHEventListenerTemplate Template;

    `CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'NarrativeHoncho_OnAddConversationTactical');
    Template.RegisterInTactical = true;
    Template.RegisterInStrategy = false;
    Template.AddCHEvent('AddConversation', OnAddConversationTactical, ELD_Immediate);

    return Template;
}

static function EventListenerReturn OnAddConversationStrategy(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    OnAddConversation(eLayer_Strategy, EventData, EventSource, GameState, Event, CallbackData);
    return ELR_NoInterrupt;
}

static function EventListenerReturn OnAddConversationTactical(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    OnAddConversation(eLayer_Tactical, EventData, EventSource, GameState, Event, CallbackData);
    return ELR_NoInterrupt;
}

static function OnAddConversation(ELayer Layer, Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComLWTuple Tuple;
    local XComNarrativeMoment Moment;
    local NarrativeHoncho_Settings Settings;
    local NarrativeToSkip ToSkip;
    local string CuePath, CueName;
    local int i;

    Tuple = XComLWTuple(EventData);
    Settings = new class'NarrativeHoncho_Settings';
    Moment = XComNarrativeMoment(Tuple.Data[1].o);

    if (Tuple == none || Tuple.Id != 'AddConversationOverride' || CuePath == "None")
    {
        return;
    }

    SplitSoundCue(string(Tuple.Data[2].n), CuePath, CueName);

    if (Settings.LogNarrativeInfo)
    {
        `NHLOG("SoundPath:" @ CuePath @ "CueText:" @ CueName @ "MomentType:" @ Moment.eType @ "bUISound:" @ Tuple.Data[4].b @ "FadeSpeed:" @ Tuple.Data[5].f);
    }

    // Do not block cinematic or tentpole narratives.
    // Blocking cinematics can cause the camera to suddenly move to another room when the callback occurs, with no indication of why.
    // The descriptions of each Narrative Moment Type can be found in the 'XComNarrativeMoment' class.
    switch (Moment.eType)
    {
        case eNarrMoment_Tentpole:
        case eNarrMoment_Bink:
        case eNarrMoment_Matinee:
        case eNarrMoment_MatineeModal:
            return;
        default:
            break;
    }

    if (Layer == eLayer_Strategy && Settings.NoStrategyNarrativesAtAll ||
        Layer == eLayer_Tactical && Settings.NoTacticalNarrativesAtAll)
    {
        if (Settings.LogNarrativeInfo)
        {
            `NHLOG("Narrative excluded. Reason: all " $ Layer $ " narratives blocked");
        }

        Tuple.Data[0].b = false;
        return;
    }

    if (Settings.NarrativesToSkip.Length > 0)
    {
        for (i = 0; i < Settings.NarrativesToSkip.Length; ++i)
        {
            ToSkip = Settings.NarrativesToSkip[i];
            if (InStr(CueName, ToSkip.Exclude) != INDEX_NONE &&
                (ToSkip.SoundPath == "" || InStr(CuePath, ToSkip.SoundPath) != INDEX_NONE) &&
                (ToSkip.Include == "" || InStr(CueName, ToSkip.Include) == INDEX_NONE))
            {
                if (Settings.LogNarrativeInfo)
                {
                    `NHLOG("Narrative excluded. Reason: Custom narrative setting");
                }
                Tuple.Data[0].b = false;
                return;
            }
        }
    }

    if (Layer == eLayer_Strategy)
    {
        if (Settings.NoNarrativesInGeoscape && `HQPRES.StrategyMap2D != none)
        {
            if (Settings.LogNarrativeInfo)
            {
                `NHLOG("Narrative excluded. Reason: Geoscape narrative");
            }
            Tuple.Data[0].b = false;
            return;
        }

        if (Settings.BradfordStrategyNarratives != "All" &&
            InStr(CuePath,"SoundSpeechStrategyCentral") != INDEX_NONE &&
            (Settings.BradfordStrategyNarratives != "Ambient Only" ||
             (Moment.AmbientCriteriaTypeName == '' &&
              Moment.AmbientConditionTypeNames.Length == 0)))
        {
            if (Settings.LogNarrativeInfo)
            {
                `NHLOG("Narrative excluded. Reason: Bradford narrative");
            }
            Tuple.Data[0].b = false;
            return;
        }

        // Stop Shen/Tygan greetings if there's already a narrative playing.
        if (Settings.NoGreetingsWhenNarrativePlaying &&
            (InStr(CueName,"Shen_Greeting") != INDEX_NONE ||
             InStr(CueName,"Tygan_Greeting") != INDEX_NONE))
        {
            Moment.bDontPlayIfNarrativePlaying = true;
            Tuple.Data[1].o = Moment;
            return;
        }
    }

    return;
}

static function SplitSoundCue(string Cue, out string CuePath, out string CueName)
{
    local array<string> Parts;

    // Split e.g. SoundSpeechStrategyCentral.S_GP_Doom_Rising_Central_Cue at '.'
    ParseStringIntoArray(Cue, Parts, ".", true);
    CuePath = Parts[0];
    CueName = Parts[1];
}

static function bool IsCHHLMinVersionInstalled(int iMajor, int iMinor)
{
    local X2StrategyElementTemplate VersionTemplate;

    VersionTemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('CHXComGameVersion');
    if (VersionTemplate == none)
    {
        return false;
    }
    else
    {
        // This is crash-inducing if the highlander is not installed.
        return CHXComGameVersionTemplate(VersionTemplate).MajorVersion > iMajor ||  (CHXComGameVersionTemplate(VersionTemplate).MajorVersion == iMajor && CHXComGameVersionTemplate(VersionTemplate).MinorVersion >= iMinor);
    }
}
