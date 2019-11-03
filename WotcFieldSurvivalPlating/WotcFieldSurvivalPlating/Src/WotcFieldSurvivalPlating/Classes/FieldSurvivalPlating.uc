class FieldSurvivalPlating extends X2Item config(FieldSurvivalPlating);

var config int CERAMIC_HP;
var config int CERAMIC_SHIELD;
var config int CERAMIC_HP_REGEN;
var config int CERAMIC_HP_REGEN_MAX;
var config int CERAMIC_SHIELD_REGEN;
var config int CERAMIC_SHIELD_REGEN_MAX;
var config int CERAMIC_ARMOR_CHANCE;
var config int CERAMIC_ARMOR_AMOUNT;

var config int ALLOY_HP;
var config int ALLOY_SHIELD;
var config int ALLOY_HP_REGEN;
var config int ALLOY_HP_REGEN_MAX;
var config int ALLOY_SHIELD_REGEN;
var config int ALLOY_SHIELD_REGEN_MAX;
var config int ALLOY_ARMOR_CHANCE;
var config int ALLOY_ARMOR_AMOUNT;

var config int CHITIN_HP;
var config int CHITIN_SHIELD;
var config int CHITIN_HP_REGEN;
var config int CHITIN_HP_REGEN_MAX;
var config int CHITIN_SHIELD_REGEN;
var config int CHITIN_SHIELD_REGEN_MAX;
var config int CHITIN_ARMOR_CHANCE;
var config int CHITIN_ARMOR_AMOUNT;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(CreatePlating('FSPCeramicPlating', 'FSPCeramicPlatingBonus', "Inv_Plating_1", default.CERAMIC_HP, default.CERAMIC_SHIELD, default.CERAMIC_ARMOR_AMOUNT, 0, '', ''));
    Templates.AddItem(CreatePlating('FSPAlloyPlating', 'FSPAlloyPlatingBonus', "Inv_Plating_2", default.ALLOY_HP, default.ALLOY_SHIELD, default.ALLOY_ARMOR_AMOUNT, 1, 'FSPAlloyPlating_Schematic', 'FSPCeramicPlating'));
    Templates.AddItem(CreatePlating('FSPChitinPlating', 'FSPChitinPlatingBonus', "Inv_Plating_3", default.CHITIN_HP, default.CHITIN_SHIELD, default.CHITIN_ARMOR_AMOUNT, 2, 'FSPChitinPlating_Schematic', 'FSPAlloyPlating'));

    Templates.AddItem(CreateSchematic('FSPAlloyPlating_Schematic', 'FSPAlloyPlating', 'PlatedArmor', "Inv_Plating_2", 10, 75, 15, 3, 'CorpseAdventTrooper', 3));
    Templates.AddItem(CreateSchematic('FSPChitinPlating_Schematic', 'FSPChitinPlating', 'PoweredArmor', "Inv_Plating_3", 20, 125, 30, 5, 'CorpseAdventTrooper', 6));

    return Templates;
}

static function X2DataTemplate CreatePlating(name ItemName, name AbilityName, string Image, int HP, int Shield, int Armor, int Tier, name Schematic, name BaseItem)
{
    local X2EquipmentTemplate Template;

    `CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, ItemName);
    Template.ItemCat = 'defense';
    Template.InventorySlot = eInvSlot_Utility;
    Template.strImage = "img:///UILibrary_FieldSurvivalPlating." $ Image;
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
