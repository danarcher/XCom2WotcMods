class FieldSurvivalPlatingAbility extends X2Ability
    dependson (XComGameStateContext_Ability) config(GameCore);

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(
        CreatePlatingAbility(
            'FSPCeramicPlatingBonus',
            class'FieldSurvivalPlating'.default.CERAMIC_HP,
            class'FieldSurvivalPlating'.default.CERAMIC_HP_REGEN,
            class'FieldSurvivalPlating'.default.CERAMIC_HP_REGEN_MAX,
            class'FieldSurvivalPlating'.default.CERAMIC_SHIELD,
            class'FieldSurvivalPlating'.default.CERAMIC_SHIELD_REGEN,
            class'FieldSurvivalPlating'.default.CERAMIC_SHIELD_REGEN_MAX,
            class'FieldSurvivalPlating'.default.CERAMIC_ARMOR_CHANCE,
            class'FieldSurvivalPlating'.default.CERAMIC_ARMOR_AMOUNT));

    Templates.AddItem(
        CreatePlatingAbility(
            'FSPAlloyPlatingBonus',
            class'FieldSurvivalPlating'.default.ALLOY_HP,
            class'FieldSurvivalPlating'.default.ALLOY_HP_REGEN,
            class'FieldSurvivalPlating'.default.ALLOY_HP_REGEN_MAX,
            class'FieldSurvivalPlating'.default.ALLOY_SHIELD,
            class'FieldSurvivalPlating'.default.ALLOY_SHIELD_REGEN,
            class'FieldSurvivalPlating'.default.ALLOY_SHIELD_REGEN_MAX,
            class'FieldSurvivalPlating'.default.ALLOY_ARMOR_CHANCE,
            class'FieldSurvivalPlating'.default.ALLOY_ARMOR_AMOUNT));

    Templates.AddItem(
        CreatePlatingAbility(
            'FSPChitinPlatingBonus',
            class'FieldSurvivalPlating'.default.CHITIN_HP,
            class'FieldSurvivalPlating'.default.CHITIN_HP_REGEN,
            class'FieldSurvivalPlating'.default.CHITIN_HP_REGEN_MAX,
            class'FieldSurvivalPlating'.default.CHITIN_SHIELD,
            class'FieldSurvivalPlating'.default.CHITIN_SHIELD_REGEN,
            class'FieldSurvivalPlating'.default.CHITIN_SHIELD_REGEN_MAX,
            class'FieldSurvivalPlating'.default.CHITIN_ARMOR_CHANCE,
            class'FieldSurvivalPlating'.default.CHITIN_ARMOR_AMOUNT));

    return Templates;
}

static function X2AbilityTemplate CreatePlatingAbility(name AbilityName, int HP, int HPRegen, int HPRegenMax, int Shield, int ShieldRegen, int ShieldRegenMax, int ArmorChance, int Armor)
{
    local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatChange;
    local X2Effect_Regeneration RegenEffect;
    local FieldSurvivalPlatingRegenEffect ShieldRegenEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, AbilityName);
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";

    Template.AbilitySourceName = 'eAbilitySource_Item';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.bDisplayInUITacticalText = false;

    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

    if (HP > 0 || Shield > 0 || Armor > 0)
    {
        StatChange = new class'X2Effect_PersistentStatChange';
        StatChange.BuildPersistentEffect(1, true, false, false);
        StatChange.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
        if (HP > 0)
        {
            StatChange.AddPersistentStatChange(eStat_HP, HP);
        }
        if (Shield > 0)
        {
            StatChange.AddPersistentStatChange(eStat_ShieldHP, Shield);
        }
        if (Armor > 0)
        {
            StatChange.AddPersistentStatChange(eStat_ArmorChance, ArmorChance);
            StatChange.AddPersistentStatChange(eStat_ArmorMitigation, Armor);
        }
        Template.AddTargetEffect(StatChange);
    }

    if (HPRegen > 0)
    {
        RegenEffect = new class'X2Effect_Regeneration';
        RegenEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
        RegenEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
        RegenEffect.HealAmount = HPRegen;
        RegenEffect.MaxHealAmount = HPRegenMax;
        RegenEffect.HealthRegeneratedName = 'FieldSurvivalPlatingHPRegenerated';
        Template.AddTargetEffect(RegenEffect);
    }

    if (ShieldRegen > 0)
    {
        ShieldRegenEffect = new class'FieldSurvivalPlatingRegenEffect';
        ShieldRegenEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
        ShieldRegenEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
        ShieldRegenEffect.HealAmount = ShieldRegen;
        ShieldRegenEffect.MaxHealAmount = ShieldRegenMax;
        ShieldRegenEffect.HealthRegeneratedName = 'FieldSurvivalPlatingShieldRegenerated';
        Template.AddTargetEffect(ShieldRegenEffect);
    }

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}
