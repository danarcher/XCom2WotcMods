class UIScreenListener_UIArmory_MainMenu_FieldSurvivalUniforms
    extends UIScreenListener
    config(FieldSurvivalUniforms);

var config bool AFFECT_HAIR;
var config bool AFFECT_LOWER_FACE_PROP;
var config bool AFFECT_UPPER_FACE_PROP;
var config bool AFFECT_FACE_PAINT;
var config bool AFFECT_ATTITUDE;
var config bool AFFECT_TATTOO_TINT;
var config bool AFFECT_WEAPON_TINT;
var config bool AFFECT_WEAPON_PATTERN;
var config bool AFFECT_HELMET;
var config bool AFFECT_ARMOR;
var config bool AFFECT_ARMOR_TINT;
var config bool AFFECT_ARMOR_PATTERN;

var config name HAIR_FEMALE;
var config name HAIR_MALE;
var config name LOWER_FACE_PROP_FEMALE;
var config name LOWER_FACE_PROP_MALE;
var config name UPPER_FACE_PROP_FEMALE;
var config name UPPER_FACE_PROP_MALE;
var config name FACE_PAINT_FEMALE;
var config name FACE_PAINT_MALE;
var config name WEAPON_PATTERN_FEMALE;
var config name WEAPON_PATTERN_MALE;
var config name HELMET_FEMALE;
var config name HELMET_MALE;
var config name KEVLAR_ARMOR_FEMALE;
var config name KEVLAR_ARMOR_MALE;
var config name PLATED_ARMOR_FEMALE;
var config name PLATED_ARMOR_MALE;
var config name POWERED_ARMOR_FEMALE;
var config name POWERED_ARMOR_MALE;
var config name ARMOR_PATTERN_FEMALE;
var config name ARMOR_PATTERN_MALE;

var config int ATTITUDE_FEMALE;
var config int ATTITUDE_MALE;
var config int TATTOO_TINT_FEMALE;
var config int TATTOO_TINT_MALE;
var config int WEAPON_TINT_FEMALE;
var config int WEAPON_TINT_MALE;
var config int ARMOR_TINT_FEMALE;
var config int ARMOR_TINT_MALE;
var config int ARMOR_TINT_SECONDARY_FEMALE;
var config int ARMOR_TINT_SECONDARY_MALE;

var config array<name> EXCLUDE_SOLDIER_CLASSES;

var UIButton UniformOneButton;
var UIButton UniformAllButton;
var UIArmory_MainMenu ParentScreen;

event OnInit(UIScreen Screen)
{
    ParentScreen = UIArmory_MainMenu(Screen);
    AddFloatingButton();
}

event OnReceiveFocus(UIScreen Screen)
{
    ParentScreen = UIArmory_MainMenu(Screen);
    AddFloatingButton();
}

event OnRemoved(UIScreen Screen)
{
    ParentScreen = none;
}

function AddFloatingButton()
{
    UniformOneButton = ParentScreen.Spawn(class'UIButton', ParentScreen);
    UniformOneButton.InitButton('', "Set Soldier Uniform", ConfirmSetOneUniform, eUIButtonStyle_HOTLINK_BUTTON);
    UniformOneButton.SetResizeToText(false);
    UniformOneButton.SetFontSize(24);
    UniformOneButton.SetPosition(140, 40);
    UniformOneButton.SetSize(260, 36);
    UniformOneButton.Show();

    UniformAllButton = ParentScreen.Spawn(class'UIButton', ParentScreen);
    UniformAllButton.InitButton('', "Set ALL Uniforms", ConfirmSetAllUniforms, eUIButtonStyle_HOTLINK_BUTTON);
    UniformAllButton.SetResizeToText(false);
    UniformAllButton.SetFontSize(24);
    UniformAllButton.SetPosition(140, 80);
    UniformAllButton.SetSize(260, 36);
    UniformAllButton.Show();
}

simulated function ConfirmSetOneUniform(UIButton kButton)
{
    local TDialogueBoxData kDialogData;
    kDialogData.eType = eDialog_Normal;
    kDialogData.strTitle = "Confirm Uniform";
    kDialogData.strText = "Replace soldier uniform? You can't undo this except by reloading a save.";
    kDialogData.strAccept = "REPLACE";
    kDialogData.strCancel = "CANCEL";
    kDialogData.fnCallbackEx = SetOneUniform;
    ParentScreen.Movie.Pres.UIRaiseDialog(kDialogData);
}

simulated function ConfirmSetAllUniforms(UIButton kButton)
{
    local TDialogueBoxData kDialogData;
    kDialogData.eType = eDialog_Warning;
    kDialogData.strTitle = "Confirm Uniform";
    kDialogData.strText = "Replace ALL soldiers' uniforms? You can't undo this except by reloading a save.";
    kDialogData.strAccept = "REPLACE ALL";
    kDialogData.strCancel = "CANCEL";
    kDialogData.fnCallbackEx = SetAllUniforms;
    ParentScreen.Movie.Pres.UIRaiseDialog(kDialogData);
}

simulated function SetOneUniform(name eAction, UICallbackData xUserData)
{
    local XComGameState_Unit Unit;
    local XComGameState NewGameState;

    if (eAction != 'eUIAction_Accept')
    {
        return;
    }

    Unit = ParentScreen.GetUnit();
    if (Unit == none)
    {
        return;
    }

    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Apply Uniform");

    SetSoldierUniform(Unit, NewGameState);

    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

    ParentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);

    ParentScreen.ReleasePawn(true);
    ParentScreen.CreateSoldierPawn();
}

simulated function SetAllUniforms(name eAction, UICallbackData xUserData)
{
    local XComGameState_HeadquartersXCom XComHQ;

    local array<XComGameState_Unit> Soldiers;
    local int iSoldier;

    local XComGameState NewGameState;

    if (eAction != 'eUIAction_Accept')
    {
        return;
    }

    XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
    Soldiers = XComHQ.GetSoldiers();

    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Apply Uniforms");

    for (iSoldier = 0; iSoldier < Soldiers.Length; iSoldier++)
    {
        SetSoldierUniform(Soldiers[iSoldier], NewGameState);
    }

    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

    ParentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);

    ParentScreen.ReleasePawn(true);
    ParentScreen.CreateSoldierPawn();
}

simulated function SetSoldierUniform(XComGameState_Unit Unit, XComGameState NewGameState)
{
    local name ClassName;
    local bool Female;

    local XComGameState_Item ItemState;
    local X2ArmorTemplate ArmorTemplate;
    local name ArmorName;

    local XComGameState_Item PrimaryWeapon;
    local XComGameState_Item SecondaryWeapon;

    ClassName = Unit.GetSoldierClassTemplateName();

    if (Unit.IsSoldier() &&
        Unit.IsAlive() &&
        default.EXCLUDE_SOLDIER_CLASSES.Find(ClassName) == INDEX_NONE)
    {
        Unit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));
        NewGameState.AddStateObject(Unit);

        if (ClassName != 'Spark')
        {
            ItemState = Unit.GetItemInSlot(eInvSlot_Armor);
            if (ItemState != none)
            {
                ArmorTemplate = X2ArmorTemplate(ItemState.GetMyTemplate());
                ArmorName = ArmorTemplate.DataName;
            }
            else
            {
                ArmorName = '';
            }

            Female = Unit.kAppearance.iGender == eGender_Female;

            if (default.AFFECT_HAIR)
            {
                Unit.kAppearance.nmHaircut = SelectName(Female, default.HAIR_FEMALE, default.HAIR_MALE);
            }

            SetAppearanceForArmor(Unit, ArmorName, Female);

            if (default.AFFECT_LOWER_FACE_PROP)
            {
                if (Unit.kAppearance.nmFacePropLower != 'Cigarette' &&
                    Unit.kAppearance.nmFacePropLower != 'Cigar')
                {
                    Unit.kAppearance.nmFacePropLower = SelectName(Female, default.LOWER_FACE_PROP_FEMALE, default.LOWER_FACE_PROP_MALE);
                }
            }

            if (default.AFFECT_UPPER_FACE_PROP)
            {
                if (Unit.kAppearance.nmFacePropUpper != 'Aviators_M' &&
                    Unit.kAppearance.nmFacePropUpper != 'Aviators_F' &&
                    Unit.kAppearance.nmFacePropUpper != 'PlainGlasses_M' &&
                    Unit.kAppearance.nmFacePropUpper != 'PlainGlasses_F' &&
                    Unit.kAppearance.nmFacePropUpper != 'Eyepatch_M' &&
                    Unit.kAppearance.nmFacePropUpper != 'Eyepatch_F')
                {
                    Unit.kAppearance.nmFacePropUpper = SelectName(Female, default.UPPER_FACE_PROP_FEMALE, default.UPPER_FACE_PROP_MALE);
                }
            }

            if (default.AFFECT_FACE_PAINT)
            {
                Unit.kAppearance.nmFacePaint = SelectName(Female, default.FACE_PAINT_FEMALE, default.FACE_PAINT_MALE);
            }

            if ((default.AFFECT_ATTITUDE && Unit.kAppearance.iAttitude == 3) ||
                (default.AFFECT_ATTITUDE && Unit.kAppearance.iAttitude == 5))
            {
                Unit.kAppearance.iAttitude = SelectInt(Female, default.ATTITUDE_FEMALE, default.ATTITUDE_MALE);
            }
        }

        if (default.AFFECT_TATTOO_TINT)
        {
            Unit.kAppearance.iTattooTint = SelectInt(Female, default.TATTOO_TINT_FEMALE, default.TATTOO_TINT_MALE);
        }

        if (default.AFFECT_WEAPON_TINT)
        {
            Unit.kAppearance.iWeaponTint = SelectInt(Female, default.WEAPON_TINT_FEMALE, default.WEAPON_TINT_MALE);
        }

        if (default.AFFECT_WEAPON_PATTERN)
        {
            Unit.kAppearance.nmWeaponPattern = SelectName(Female, default.WEAPON_PATTERN_FEMALE, default.WEAPON_PATTERN_MALE);
        }

        if (default.AFFECT_WEAPON_TINT || default.AFFECT_WEAPON_PATTERN)
        {
            PrimaryWeapon = Unit.GetItemInSlot(eInvSlot_PrimaryWeapon);
            if (PrimaryWeapon != none)
            {
                PrimaryWeapon = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', PrimaryWeapon.ObjectID));
                if (default.AFFECT_WEAPON_TINT)
                {
                    PrimaryWeapon.WeaponAppearance.iWeaponTint = Unit.kAppearance.iWeaponTint;
                }
                if (default.AFFECT_WEAPON_PATTERN)
                {
                    PrimaryWeapon.WeaponAppearance.nmWeaponPattern = Unit.kAppearance.nmWeaponPattern;
                }
                NewGameState.AddStateObject(PrimaryWeapon);
            }

            SecondaryWeapon = Unit.GetItemInSlot(eInvSlot_SecondaryWeapon);
            if (SecondaryWeapon != none)
            {
                SecondaryWeapon = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', SecondaryWeapon.ObjectID));
                if (default.AFFECT_WEAPON_TINT)
                {
                    SecondaryWeapon.WeaponAppearance.iWeaponTint = Unit.kAppearance.iWeaponTint;
                }
                if (default.AFFECT_WEAPON_PATTERN)
                {
                    SecondaryWeapon.WeaponAppearance.nmWeaponPattern = Unit.kAppearance.nmWeaponPattern;
                }
                NewGameState.AddStateObject(SecondaryWeapon);
            }
        }

        Unit.UpdatePersonalityTemplate();
        Unit.StoreAppearance();
    }
}

simulated function SetAppearanceForArmor(XComGameState_Unit Unit, name ArmorName, bool Female)
{
    if (ArmorName == 'KevlarArmor')
    {
        if (default.AFFECT_ARMOR)
        {
            Unit.kAppearance.nmTorso = SelectName(Female, default.KEVLAR_ARMOR_FEMALE, default.KEVLAR_ARMOR_MALE);
            Unit.kAppearance.nmLegs = SelectName(Female, default.KEVLAR_ARMOR_FEMALE, default.KEVLAR_ARMOR_MALE);
            Unit.kAppearance.nmArms = SelectName(Female, default.KEVLAR_ARMOR_FEMALE, default.KEVLAR_ARMOR_MALE);
            Unit.kAppearance.nmLeftArm = SelectName(Female, default.KEVLAR_ARMOR_FEMALE, default.KEVLAR_ARMOR_MALE);
            Unit.kAppearance.nmRightArm = SelectName(Female, default.KEVLAR_ARMOR_FEMALE, default.KEVLAR_ARMOR_MALE);
        }
    }
    else if (ArmorName == 'MediumPlatedArmor')
    {
        if (default.AFFECT_ARMOR)
        {
            Unit.kAppearance.nmTorso = SelectName(Female, default.PLATED_ARMOR_FEMALE, default.PLATED_ARMOR_MALE);
            Unit.kAppearance.nmLegs = SelectName(Female, default.PLATED_ARMOR_FEMALE, default.PLATED_ARMOR_MALE);
            Unit.kAppearance.nmArms = SelectName(Female, default.PLATED_ARMOR_FEMALE, default.PLATED_ARMOR_MALE);
            Unit.kAppearance.nmLeftArm = SelectName(Female, default.PLATED_ARMOR_FEMALE, default.PLATED_ARMOR_MALE);
            Unit.kAppearance.nmRightArm = SelectName(Female, default.PLATED_ARMOR_FEMALE, default.PLATED_ARMOR_MALE);
        }
    }
    else if (ArmorName == 'MediumPoweredArmor')
    {
        if (default.AFFECT_ARMOR)
        {
            Unit.kAppearance.nmTorso = SelectName(Female, default.POWERED_ARMOR_FEMALE, default.POWERED_ARMOR_MALE);
            Unit.kAppearance.nmLegs = SelectName(Female, default.POWERED_ARMOR_FEMALE, default.POWERED_ARMOR_MALE);
            Unit.kAppearance.nmArms = SelectName(Female, default.POWERED_ARMOR_FEMALE, default.POWERED_ARMOR_MALE);
            Unit.kAppearance.nmLeftArm = SelectName(Female, default.POWERED_ARMOR_FEMALE, default.POWERED_ARMOR_MALE);
            Unit.kAppearance.nmRightArm = SelectName(Female, default.POWERED_ARMOR_FEMALE, default.POWERED_ARMOR_MALE);
        }
    }
    else
    {
        // Do not mess with special armors.
        return;
    }

    if (default.AFFECT_HELMET)
    {
        Unit.kAppearance.nmHelmet = SelectName(Female, default.HELMET_FEMALE, default.HELMET_MALE);
    }

    Unit.kAppearance.nmLeftArmDeco = '';
    Unit.kAppearance.nmRightArmDeco = '';

    Unit.kAppearance.iArmorDeco = 0;

    if (default.AFFECT_ARMOR_TINT)
    {
        Unit.kAppearance.iArmorTint = SelectInt(Female, default.ARMOR_TINT_FEMALE, default.ARMOR_TINT_MALE);
        Unit.kAppearance.iArmorTintSecondary = SelectInt(Female, default.ARMOR_TINT_SECONDARY_FEMALE, default.ARMOR_TINT_SECONDARY_MALE);
    }

    if (default.AFFECT_ARMOR_PATTERN)
    {
        Unit.kAppearance.nmPatterns = SelectName(Female, default.ARMOR_PATTERN_FEMALE, default.ARMOR_PATTERN_MALE);
    }
}

simulated function int SelectInt(bool Female, int FemaleVariant, int MaleVariant)
{
    if (Female)
    {
        return FemaleVariant;
    }
    return MaleVariant;
}

simulated function name SelectName(bool Female, name FemaleVariant, name MaleVariant)
{
    if (Female)
    {
        return FemaleVariant;
    }
    return MaleVariant;
}

defaultproperties
{
    ScreenClass = UIArmory_MainMenu;
}
