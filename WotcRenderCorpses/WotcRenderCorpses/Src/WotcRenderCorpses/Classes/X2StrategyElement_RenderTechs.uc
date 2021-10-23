class X2StrategyElement_RenderTechs extends X2StrategyElement config(RenderTechs);

`define RCLOG(message) `LOG(`message,, 'WotcRenderCorpses')

struct native RenderTech
{
    var name Name;
    var int PointsToComplete;
    var name RenderItem;
    var int RenderQuantity;
    var name RewardResource;
    var int RewardQuantity;
    var int RewardCores;
};

var config array<RenderTech> RENDER_TECH;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Techs;
    local RenderTech Tech;

    foreach default.RENDER_TECH(Tech)
    {
        Techs.AddItem(CreateRenderTemplate(Tech));
    }

    return Techs;
}

static function X2DataTemplate CreateRenderTemplate(RenderTech Tech)
{
    local X2TechTemplate Template;
    local ArtifactCost Artifacts;

    `CREATE_X2TEMPLATE(class'X2TechTemplate', Template, Tech.Name);
    Template.PointsToComplete = Tech.PointsToComplete;
    Template.RepeatPointsIncrease = 0;
    Template.bRepeatable = true;
    Template.strImage = "img:///UILibrary_StrategyImages.ScienceIcons.IC_Elerium";
    Template.SortingTier = 10;
    Template.ResearchCompletedFn = RenderTechCompleted;

    Template.Requirements.RequiredTechs.AddItem('AlienBiotech');
    Template.Requirements.RequiredItems.AddItem(Tech.RenderItem);

    Artifacts.ItemTemplateName = Tech.RenderItem;
    Artifacts.Quantity = Tech.RenderQuantity;
    Template.Cost.ArtifactCosts.AddItem(Artifacts);

    `RCLOG("Adding tech template " $ Template.DataName);
    return Template;
}

static function RenderTechCompleted(XComGameState NewGameState, XComGameState_Tech TechState)
{
    local XComGameStateHistory History;
    local XComGameState_HeadquartersXCom XComHQ;
    local int TechID;
    local RenderTech Tech;

    History = `XCOMHISTORY;

    foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
    {
        break;
    }

    if(XComHQ == none)
    {
        XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
        XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
    }

    foreach default.RENDER_TECH(Tech)
    {
        if (TechState.GetMyTemplateName() == Tech.Name)
        {
            TechID = TechState.ObjectID;
            TechState = XComGameState_Tech(NewGameState.GetGameStateForObjectID(TechID));

            if(TechState == none)
            {
                TechState = XComGameState_Tech(NewGameState.ModifyStateObject(class'XComGameState_Tech', TechID));
            }

            XComHQ.AddResource(NewGameState, Tech.RewardResource, Tech.RewardQuantity);
            if (Tech.RewardCores > 0)
            {
                XComHQ.AddResource(NewGameState, 'EleriumCore', Tech.RewardCores);
            }
        }
    }
}
