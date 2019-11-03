class X2Ability_FieldSurvivalConsciousness
    extends X2Ability
    config(FieldSurvivalConsciousness);

`define BPE_TickNever_LastForever 1, true, false, false, eGameRule_TacticalGameStart

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(AddStayConscious());

    return Templates;
}

static function X2AbilityTemplate AddStayConscious()
{
    local X2AbilityTemplate Template;
    local X2Effect_DamageImmunity ImmunityEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'FSCStayConscious');
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_immunities";
    Template.Hostility = eHostility_Neutral;
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;
    Template.bCrossClassEligible = true;
    Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;

    ImmunityEffect = new class'X2Effect_DamageImmunity';
    ImmunityEffect.ImmuneTypes.AddItem('Unconscious');

    ImmunityEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage);
    ImmunityEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    Template.AddTargetEffect(ImmunityEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}
