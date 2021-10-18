class X2DownloadableContentInfo_FieldSurvivalPlating
    extends X2DownloadableContentInfo
    dependson(FieldSurvivalPlating)
    config(FieldSurvivalPlating);

`define FSPLOG(message) `LOG(`message,, 'FieldSurvivalPlating')

var config array<name> ARMOR_ADD_UTILITY_SLOT;

static event OnLoadedSavedGame()
{
    UpdateStorage();
}

static event InstallNewCampaign(XComGameState StartState)
{
}

static event OnPostTemplatesCreated()
{
    AddUtilitySlots();
    AugmentArmor();
}

static function UpdateStorage()
{
    local XComGameState NewGameState;
    local XComGameStateHistory History;
    local XComGameState_HeadquartersXCom XComHQ;
    local X2ItemTemplateManager ItemTemplateMgr;
    local bool bAddedAnyItem;

    History = `XCOMHISTORY;
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating HQ storage to add items");
    XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
    XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
    NewGameState.AddStateObject(XComHQ);
    ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

    bAddedAnyItem = false;

    if (AddItemToStorage('FSPCeramicPlating', ItemTemplateMgr, XComHQ, NewGameState))
    {
        bAddedAnyItem = true;
    }

    if (bAddedAnyItem)
    {
        History.AddGameStateToHistory(NewGameState);
    }
    else
    {
        History.CleanupPendingGameState(NewGameState);
    }
}

static function bool AddItemToStorage(name ItemTemplateName, X2ItemTemplateManager ItemTemplateMgr, XComGameState_HeadquartersXCom XComHQ, XComGameState NewGameState)
{
    local X2ItemTemplate ItemTemplate;
    local XComGameState_Item NewItemState;

    ItemTemplate = ItemTemplateMgr.FindItemTemplate(ItemTemplateName);
    if (ItemTemplate != none)
    {
        if (!XComHQ.HasItem(ItemTemplate))
        {
            NewItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
            NewGameState.AddStateObject(NewItemState);
            XComHQ.AddItemToHQInventory(NewItemState);
            return true;
        }
    }
    return false;
}

static function AddUtilitySlots()
{
    local X2ItemTemplateManager ItemManager;
    local name ArmorName;
    local X2ArmorTemplate Armor;

    ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
    foreach default.ARMOR_ADD_UTILITY_SLOT(ArmorName)
    {
        Armor = X2ArmorTemplate(ItemManager.FindItemTemplate(ArmorName));
        if (Armor != none)
        {
            if (Armor.bAddsUtilitySlot != true)
            {
                Armor.bAddsUtilitySlot = true;
                `FSPLOG("Added a utility slot to " $ ArmorName $ ".");
            }
            else
            {
                `FSPLOG("Armor template " $ ArmorName $ " already has a utility slot.");
            }
        }
        else
        {
            `FSPLOG("Armor template " $ ArmorName $ " not found.");
        }
    }
}

static function AugmentArmor()
{
    local X2ItemTemplateManager ItemManager;
    local FSPPlatingInfo Info;
    local X2ArmorTemplate Template;
    local name AdditionalAbility;

    ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

    foreach class'FieldSurvivalPlating'.default.PLATING(Info)
    {
        if (Info.ModifyArmorTemplate != '')
        {
            `FSPLOG("Modifying armor template " $ Info.ModifyArmorTemplate);
            Template = X2ArmorTemplate(ItemManager.FindItemTemplate(Info.ModifyArmorTemplate));
            if (Template != none)
            {
                if (Info.Ability != '')
                {
                    Template.Abilities.AddItem(Info.Ability);
                    if (Info.Shield > 0)
                    {
                        // TODO: Fix HP and armor stat markup to base plus ability mod!
                        Template.SetUIStatMarkup("Ablative HP", eStat_ShieldHP, Info.Shield);
                    }
                }
                foreach Info.AdditionalAbilities(AdditionalAbility)
                {
                    Template.Abilities.AddItem(AdditionalAbility);
                }
            }
            else
            {
                // Red screens aren't visible yet!
                `FSPLOG("Armor template " $ Info.ModifyArmorTemplate $ " not found!");
            }
        }
    }
}
