class FieldSurvivalPlatingAbility extends X2Ability
    dependson(XComGameStateContext_Ability)
    dependson(FieldSurvivalPlating)
    config(GameCore);

`define FSPLOG(message) `LOG(`message,, 'FieldSurvivalPlating')

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    local FSPPlatingInfo Info;

    foreach class'FieldSurvivalPlating'.default.PLATING(Info)
    {
        if (Info.Ability != '')
        {
            `FSPLOG("Creating ability template " $ Info.Ability);
            Templates.AddItem(CreatePlatingAbility(
                Info.Ability,
                Info.HP,
                Info.HPRegen,
                Info.HPRegenMax,
                Info.Shield,
                Info.ShieldRegen,
                Info.ShieldRegenMax,
                Info.ArmorChance,
                Info.ArmorAmount));
        }
    }

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
