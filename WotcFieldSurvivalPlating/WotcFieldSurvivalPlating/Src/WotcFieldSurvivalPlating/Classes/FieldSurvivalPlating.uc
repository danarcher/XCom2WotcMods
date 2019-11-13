class FieldSurvivalPlating extends X2Item config(FieldSurvivalPlating);

`define FSPLOG(message) `LOG(`message,, 'FieldSurvivalPlating')

struct native FSPPlatingInfo
{
    // The plating ability and associated stats.
    var name Ability;
    var int HP;
    var int HPRegen;
    var int HPRegenMax;
    var int Shield;
    var int ShieldRegen;
    var int ShieldRegenMax;
    var int ArmorChance;
    var int ArmorAmount;

    // If we're modifying an existing armor template, name it.
    var name ModifyArmorTemplate;

    // If we're creating a new item type, name it and fully specify the new
    // schematic which creates it.
    var name Item;
    var string Image;
    var int Tier;
    var name Schematic;
    var name BaseItem;
    var name TechName;
    var int Engineering;
    var int Supplies;
    var int Alloys;
    var int Elerium;
    var name ArtifactName;
    var int ArtifactCount;
};

var config array<FSPPlatingInfo> PLATING;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    local FSPPlatingInfo Info;

    `FSPLOG(default.PLATING.Length $ " plating entries found.");

    foreach default.PLATING(Info)
    {
        if (Info.Item != '')
        {
            `FSPLOG("Creating item template " $ Info.Item);
            Templates.AddItem(CreatePlating(Info.Item, Info.Ability, Info.Image, Info.HP, Info.Shield, Info.ArmorAmount, Info.Tier, Info.Schematic, Info.BaseItem));
        }
        if (Info.Schematic != '')
        {
            `FSPLOG("Creating schematic " $ Info.Schematic);
            Templates.AddItem(CreateSchematic(Info.Schematic, Info.Item, Info.TechName, Info.Image, Info.Engineering, Info.Supplies, Info.Alloys, Info.Elerium, Info.ArtifactName, Info.ArtifactCount));
        }
    }

    return Templates;
}

static function X2DataTemplate CreatePlating(name ItemName, name AbilityName, string Image, int HP, int Shield, int Armor, int Tier, name Schematic, name BaseItem)
{
    local X2EquipmentTemplate Template;

    `CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, ItemName);
    Template.ItemCat = 'defense';
    Template.InventorySlot = eInvSlot_Utility;
    Template.strImage = Image;
    Template.EquipSound = "StrategyUI_Vest_Equip";

    Template.Abilities.AddItem(AbilityName);

    Template.bInfiniteItem = true;
    if (Tier == 0)
    {
        Template.StartingItem = true;
    }
    Template.CanBeBuilt = false;
    Template.TradingPostValue = 0;
    Template.PointsToComplete = 0;
    Template.Tier = Tier;

    Template.CreatorTemplateName = Schematic; // The schematic which creates this item
    Template.BaseItem = BaseItem; // Which item this will be upgraded from

    if (HP > 0)
    {
        Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, HP);
    }
    if (Shield > 0)
    {
        Template.SetUIStatMarkup("Ablative HP", eStat_ShieldHP, Shield);
    }
    if (Armor > 0)
    {
        Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, Armor);
    }

    return Template;
}

static function X2DataTemplate CreateSchematic(name SchematicName, name ItemName, name TechName, string Image, int Engineering, int Supplies, int Alloys, int Elerium, name ArtifactName, int ArtifactCount)
{
    local X2SchematicTemplate Template;
    local ArtifactCost Resources, Artifacts;

    `CREATE_X2TEMPLATE(class'X2SchematicTemplate', Template, SchematicName);

    Template.ItemCat = 'armor';
    Template.strImage = "img:///UILibrary_FieldSurvivalPlating." $ Image;
    Template.PointsToComplete = 0;
    Template.Tier = 1;
    Template.OnBuiltFn = UpgradeItems;

    // Reference Item
    Template.ReferenceItemTemplate = ItemName;
    Template.HideIfPurchased = ItemName;

    // Requirements
    Template.Requirements.RequiredTechs.AddItem(TechName);
    Template.Requirements.RequiredEngineeringScore = Engineering;
    Template.Requirements.bVisibleIfPersonnelGatesNotMet = true;

    // Cost
    if (Supplies > 0)
    {
        Resources.ItemTemplateName = 'Supplies';
        Resources.Quantity = Supplies;
        Template.Cost.ResourceCosts.AddItem(Resources);
    }

    if (Alloys > 0)
    {
        Resources.ItemTemplateName = 'AlienAlloy';
        Resources.Quantity = Alloys;
        Template.Cost.ResourceCosts.AddItem(Resources);
    }

    if (Elerium > 0)
    {
        Resources.ItemTemplateName = 'EleriumDust';
        Resources.Quantity = Elerium;
        Template.Cost.ResourceCosts.AddItem(Resources);
    }


    if (ArtifactCount > 0)
    {
        Artifacts.ItemTemplateName = ArtifactName;
        Artifacts.Quantity = ArtifactCount;
        Template.Cost.ArtifactCosts.AddItem(Artifacts);
    }

    return Template;
}

static function UpgradeItems(XComGameState NewGameState, XComGameState_Item ItemState)
{
    class'XComGameState_HeadquartersXCom'.static.UpgradeItems(NewGameState, ItemState.GetMyTemplateName());
}
