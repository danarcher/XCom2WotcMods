class FSKAbilities extends X2Ability config(FieldSurvivalKits) dependson(FSKTemporaryItemEffect);

var config int TrainingAimBoost;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(AddFieldSurvivalKit());
    Templates.AddItem(AddFieldSurvivalTraining());

    return Templates;
}

static function X2AbilityTemplate AddFieldSurvivalKit()
{
    local X2AbilityTemplate Template;
    local X2Effect_Persistent IconEffect;
    local FSKTemporaryItemEffect SmokeEffect;
    local ResearchConditional SmokeConditional;
    local FSKTemporaryItemEffect MedkitEffect;
    local ResearchConditional MedkitConditional;
    local FSKTemporaryItemEffect FlashEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'FieldSurvivalKit');

    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_expanded_storage";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;
    Template.bCrossClassEligible = false;

    IconEffect = new class'X2Effect_Persistent';
    IconEffect.BuildPersistentEffect(1, true, false);
    IconEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage);
    Template.AddTargetEffect(IconEffect);

    SmokeEffect = new class'FSKTemporaryItemEffect';
    SmokeEffect.EffectName = 'FSKSmokeGrenadeEffect';
    SmokeEffect.ItemName = 'SmokeGrenade';
    SmokeConditional.ResearchProjectName = 'AdvancedGrenades';
    SmokeConditional.ItemName = 'SmokeGrenadeMk2';
    SmokeEffect.ResearchOptionalItems.AddItem(SmokeConditional);
    SmokeEffect.AlternativeItemNames.AddItem('DenseSmokeGrenade');
    SmokeEffect.AlternativeItemNames.AddItem('DenseSmokeGrenadeMk2');
    SmokeEffect.ForceCheckAbilities.AddItem('LaunchGrenade');
    SmokeEffect.bIgnoreItemEquipRestrictions = true;
    SmokeEffect.BuildPersistentEffect(1, true, false);
    SmokeEffect.DuplicateResponse = eDupe_Ignore;
    Template.AddTargetEffect(SmokeEffect);

    MedkitEffect = new class'FSKTemporaryItemEffect';
    MedkitEffect.EffectName = 'FSKMedkitEffect';
    MedkitEffect.ItemName = 'Medikit';
    MedkitConditional.ResearchProjectName = 'BattlefieldMedicine';
    MedkitConditional.ItemName = 'NanoMedikit';
    MedkitEffect.ResearchOptionalItems.AddItem(MedkitConditional);
    MedkitEffect.bIgnoreItemEquipRestrictions = true;
    MedkitEffect.BuildPersistentEffect(1, true, false);
    MedkitEffect.DuplicateResponse = eDupe_Ignore;
    Template.AddTargetEffect(MedkitEffect);

    // In LWOTC, Sting grenade upgrades have a later PostBeginPlayTrigger with
    // priority minus 40, so this will be fine.
    FlashEffect = new class'FSKTemporaryItemEffect';
    FlashEffect.EffectName = 'FSKFlashbangGrenadeEffect';
    FlashEffect.ItemName = 'FlashbangGrenade';
    FlashEffect.ForceCheckAbilities.AddItem('LaunchGrenade');
    FlashEffect.bIgnoreItemEquipRestrictions = true;
    FlashEffect.BuildPersistentEffect(1, true, false);
    FlashEffect.DuplicateResponse = eDupe_Ignore;
    Template.AddTargetEffect(FlashEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate AddFieldSurvivalTraining()
{
    local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange IconEffect;
    local X2Effect_FSKRankBonusDamage BonusDamageEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'FieldSurvivalTraining');

    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_ambush";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;
    Template.bCrossClassEligible = false;

    IconEffect = new class'X2Effect_PersistentStatChange';
    IconEffect.BuildPersistentEffect(1, true, false);
    IconEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage);
    IconEffect.AddPersistentStatChange(eStat_Offense, default.TrainingAimBoost);
    Template.AddTargetEffect(IconEffect);

    BonusDamageEffect = new class'X2Effect_FSKRankBonusDamage';
    BonusDamageEffect.BuildPersistentEffect(1, true, false);
    //BonusDamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage);
    Template.AddTargetEffect(BonusDamageEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}
