class FSKDLCInfo extends X2DownloadableContentInfo config(FieldSurvivalKits);

var config array<name> SoldierTemplates;
var config bool HideSedateIfUnavailable;

static event OnPostTemplatesCreated()
{
    UpdateCharacterTemplates();
    UpdateAbilityTemplates();
}

static function UpdateCharacterTemplates()
{
    local X2CharacterTemplateManager    CharManager;
    local X2CharacterTemplate           CharTemplate;
    local name                          CharacterName;
    local array<X2DataTemplate>     DifficultyTemplates;
    local X2DataTemplate            DifficultyTemplate;

    CharManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
    foreach default.SoldierTemplates(CharacterName)
    {
        CharManager.FindDataTemplateAllDifficulties(CharacterName, DifficultyTemplates);

        foreach DifficultyTemplates(DifficultyTemplate)
        {
            CharTemplate = X2CharacterTemplate(DifficultyTemplate);
            if (CharTemplate != none &&
                CharTemplate.Abilities.Find('FieldSurvivalKit') == INDEX_NONE)
            {
                CharTemplate.Abilities.AddItem('FieldSurvivalKit');
            }
        }
    }
}

static function UpdateAbilityTemplates()
{
    local X2AbilityTemplateManager AbilityManager;
    local X2AbilityTemplate        Template;

    AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
    Template = AbilityManager.FindAbilityTemplate('Sedate');
    if (Template != none && default.HideSedateIfUnavailable)
    {
        // Only show Sedate if we can sedate someone.
        Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
    }
}
