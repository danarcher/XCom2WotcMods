class X2DownloadableContentInfo_FieldSurvivalConsciousness
    extends X2DownloadableContentInfo
    config(FieldSurvivalConsciousness);

var config array<name> SoldierTemplates;

static event OnLoadedSavedGame() {}
static event InstallNewCampaign(XComGameState StartState) {}

static event OnPostTemplatesCreated()
{
    UpdateCharacterTemplates();
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
                CharTemplate.Abilities.Find('FSCStayConscious') == INDEX_NONE)
            {
                CharTemplate.Abilities.AddItem('FSCStayConscious');
            }
        }
    }
}
