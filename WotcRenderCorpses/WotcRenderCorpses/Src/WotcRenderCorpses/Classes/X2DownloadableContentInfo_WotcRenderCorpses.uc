class X2DownloadableContentInfo_WotcRenderCorpses extends X2DownloadableContentInfo
    dependson(X2StrategyElement_RenderTechs);

`define RCLOG(message) `LOG(`message,, 'WotcRenderCorpses')

static event OnLoadedSavedGameToStrategy()
{
    UpdateResearch();
}

static event OnLoadedSavedGame() {}

static event InstallNewCampaign(XComGameState StartState) {}

static function UpdateResearch()
{
    local RenderTech Tech;
    local X2TechTemplate Template;
    local X2StrategyElementTemplateManager TemplateManager;
    local XComGameState NewGameState;
    local bool Changes;

    TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Add missing render techs");

    foreach class'X2StrategyElement_RenderTechs'.default.RENDER_TECH(Tech)
    {
        if (!IsTechStateInHistory(Tech.Name))
        {
            Template = X2TechTemplate(TemplateManager.FindStrategyElementTemplate(Tech.Name));
            NewGameState.CreateNewStateObject(class'XComGameState_Tech', Template);
            Changes = true;
            `RCLOG("Adding missing tech state for " $ Tech.Name);
        }
    }

    if (Changes)
    {
        `XCOMHISTORY.AddGameStateToHistory(NewGameState);
        `RCLOG("Saving changes.");
    }
    else
    {
        `XCOMHISTORY.CleanupPendingGameState(NewGameState);
        `RCLOG("No missing techs were found.");
    }
}

static function bool IsTechStateInHistory(name TechName)
{
    local XComGameState_Tech    TechState;
    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Tech', TechState)
    {
        if (TechState.GetMyTemplateName() == TechName)
        {
            return true;
        }
    }
    return false;
}
