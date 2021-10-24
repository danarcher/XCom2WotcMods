class X2Effect_FSKRankBonusDamage extends X2Effect_Persistent config(FieldSurvivalKits);

var config array<int> TrainingBonusDamageAtRank;
var config int TrainingMaximumBonusPistol;
var config int TrainingMaximumBonusGrenade;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
    local X2Effect_ApplyWeaponDamage DamageEffect;
    local XComGameState_Item SourceItemStateObject;
    local X2WeaponTemplate WeaponTemplate;
    local XComGameState_Unit SourceUnit, TargetUnit;
    local int BonusDmg, Rank, RankDmg;

    if (!class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult) || CurrentDamage == 0)
        return 0;

    // only limit this when actually applying damage (not previewing)
    if( NewGameState != none )
    {
        //	only add the bonus damage when the damage effect is applying the weapon's base damage
        DamageEffect = X2Effect_ApplyWeaponDamage(class'X2Effect'.static.GetX2Effect(AppliedData.EffectRef));
        if( DamageEffect == none || DamageEffect.bIgnoreBaseDamage )
        {
            return 0;
        }
    }

    TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AppliedData.TargetStateObjectRef.ObjectID));
    if (TargetUnit.IsSoldier())
    {
        // Presume training versus Mind Control.
        return 0;
    }

    // Note we aren't limiting this further, so this applies to *all* damage which hits.
    BonusDmg = 0;
    RankDmg = 0;
    SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AppliedData.SourceStateObjectRef.ObjectID));
    Rank = SourceUnit.GetSoldierRank();
    while (Rank >= 0)
    {
        RankDmg += TrainingBonusDamageAtRank[Rank];
        Rank = Rank - 1;
    }
    BonusDmg += RankDmg;

    SourceItemStateObject = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(AppliedData.ItemStateObjectRef.ObjectID));
    if (SourceItemStateObject != none)
    {
        WeaponTemplate = X2WeaponTemplate(SourceItemStateObject.GetMyTemplate());
        if (WeaponTemplate != none && WeaponTemplate.ItemCat == 'weapon')
        {
            if (WeaponTemplate.WeaponCat == 'pistol' && BonusDmg > default.TrainingMaximumBonusPistol)
            {
                BonusDmg = TrainingMaximumBonusPistol;
            }
            else if (WeaponTemplate.WeaponCat == 'grenade' && BonusDmg > default.TrainingMaximumBonusGrenade)
            {
                BonusDmg = TrainingMaximumBonusGrenade;
            }
        }
    }

    return BonusDmg;
}

defaultproperties
{
    bDisplayInSpecialDamageMessageUI = false
}
