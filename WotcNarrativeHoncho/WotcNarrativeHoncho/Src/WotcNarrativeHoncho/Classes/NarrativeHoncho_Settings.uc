class NarrativeHoncho_Settings
    extends Object
    config(NarrativeHoncho_Settings)
    dependson(NarrativeHoncho_Settings_Defaults);

var config int ConfigVersion;

var config string BradfordStrategyNarratives;
var localized string strBradfordStrategyNarratives;
var localized string strBradfordStrategyNarrativesTooltip;
var MCM_API_Dropdown BradfordStrategyNarratives_Dropdown;

var config bool NoGreetingsWhenNarrativePlaying;
var localized string strNoGreetingsWhenNarrativePlaying;
var localized string strNoGreetingsWhenNarrativePlayingTooltip;
var MCM_API_Checkbox NoGreetingsWhenNarrativePlaying_Checkbox;

var config bool NoNarrativesInGeoscape;
var localized string strNoNarrativesInGeoscape;
var localized string strNoNarrativesInGeoscapeTooltip;
var MCM_API_Checkbox NoNarrativesInGeoscape_Checkbox;

var config bool NoStrategyNarrativesAtAll;
var localized string strNoStrategyNarrativesAtAll;
var localized string strNoStrategyNarrativesAtAllTooltip;
var MCM_API_Checkbox NoStrategyNarrativesAtAll_Checkbox;

var config bool NoTacticalNarrativesAtAll;
var localized string strNoTacticalNarrativesAtAll;
var localized string strNoTacticalNarrativesAtAllTooltip;
var MCM_API_Checkbox NoTacticalNarrativesAtAll_Checkbox;

var config bool NoPostMissionNarratives;
var localized string strNoPostMissionNarratives;
var localized string strNoPostMissionNarrativesTooltip;
var MCM_API_Checkbox NoPostMissionNarratives_Checkbox;

var config bool LogNarrativeInfo;
var localized string strLogNarrativeInfo;
var localized string strLogNarrativeInfoTooltip;
var MCM_API_Checkbox LogNarrativeInfo_Checkbox;

//settings retrieved only via the NarrativeHoncho_Settings_Defaults.ini. Can't manage arrays in MCM!
var config array<NarrativeToSkip> NarrativesToSkip;

`include(WotcNarrativeHoncho/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(WotcNarrativeHoncho/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
`MCM_CH_VersionChecker(class'NarrativeHoncho_Settings_Defaults'.default.ConfigVersion, ConfigVersion)

event OnInit(UIScreen Screen)
{
    `MCM_API_Register(Screen, CreateUI);
    EnsureConfigExists();
}

function CreateUI(MCM_API_Instance ConfigAPI, int GameMode)
{
    // Build the settings UI
    local MCM_API_SettingsPage page;
    local MCM_API_SettingsGroup group;

    local array<string> BradfordStrategyNarrativesOptions;
    BradfordStrategyNarrativesOptions.AddItem("All");
    BradfordStrategyNarrativesOptions.AddItem("Ambient Only");
    BradfordStrategyNarrativesOptions.AddItem("None");

    LoadSavedSettings();

    page = ConfigAPI.NewSettingsPage("Narrative Honcho");
    page.SetPageTitle("Narrative Honcho");
    page.SetSaveHandler(SaveButtonClicked);
    Page.EnableResetButton(ResetButtonClicked);

    group = Page.AddGroup('StrategyLayer', "Strategy Layer");

    BradfordStrategyNarratives_Dropdown = group.AddDropdown('BradfordStrategyNarratives', strBradfordStrategyNarratives, strBradfordStrategyNarrativesTooltip, BradfordStrategyNarrativesOptions, BradfordStrategyNarratives, BradfordStrategyNarrativesSaveHandler);
    NoGreetingsWhenNarrativePlaying_Checkbox = group.AddCheckbox('NoGreetingsWhenNarrativePlaying', strNoGreetingsWhenNarrativePlaying, strNoGreetingsWhenNarrativePlayingTooltip, NoGreetingsWhenNarrativePlaying, SaveNoGreetingsWhenNarrativePlaying);
    NoNarrativesInGeoscape_Checkbox = group.AddCheckbox('NoNarrativesInGeoscape', strNoNarrativesInGeoscape, strNoNarrativesInGeoscapeTooltip, NoNarrativesInGeoscape, SaveNoNarrativesInGeoscape);
    NoStrategyNarrativesAtAll_Checkbox = group.AddCheckbox('NoStrategyNarrativesAtAll', strNoStrategyNarrativesAtAll, strNoStrategyNarrativesAtAllTooltip, NoStrategyNarrativesAtAll, SaveNoStrategyNarrativesAtAll);

    group = Page.AddGroup('TacticalLayer', "Tactical Layer");

    NoTacticalNarrativesAtAll_Checkbox = group.AddCheckbox('NoTacticalNarrativesAtAll', strNoTacticalNarrativesAtAll, strNoTacticalNarrativesAtAllTooltip, NoTacticalNarrativesAtAll, SaveNoTacticalNarrativesAtAll);

    group = Page.AddGroup('General', "General");

    NoPostMissionNarratives_Checkbox = group.AddCheckbox('NoPostMissionNarratives', strNoPostMissionNarratives, strNoPostMissionNarrativesTooltip, NoPostMissionNarratives, SaveNoPostMissionNarratives);
    LogNarrativeInfo_Checkbox = group.AddCheckbox('LogNarrativeInfo', strLogNarrativeInfo, strLogNarrativeInfoTooltip, LogNarrativeInfo, SaveLogNarrativeInfo);

    page.ShowSettings();
}

`MCM_API_BasicDropDownSaveHandler(BradfordStrategyNarrativesSaveHandler, BradfordStrategyNarratives)
`MCM_API_BasicCheckboxSaveHandler(SaveNoGreetingsWhenNarrativePlaying, NoGreetingsWhenNarrativePlaying)
`MCM_API_BasicCheckboxSaveHandler(SaveNoNarrativesInGeoscape, NoNarrativesInGeoscape)
`MCM_API_BasicCheckboxSaveHandler(SaveNoStrategyNarrativesAtAll, NoStrategyNarrativesAtAll)
`MCM_API_BasicCheckboxSaveHandler(SaveNoTacticalNarrativesAtAll, NoTacticalNarrativesAtAll)
`MCM_API_BasicCheckboxSaveHandler(SaveNoPostMissionNarratives, NoPostMissionNarratives)
`MCM_API_BasicCheckboxSaveHandler(SaveLogNarrativeInfo, LogNarrativeInfo)

function LoadSavedSettings()
{
    BradfordStrategyNarratives = `MCM_CH_GetValue(class'NarrativeHoncho_Settings_Defaults'.default.BradfordStrategyNarratives, BradfordStrategyNarratives);
    NoGreetingsWhenNarrativePlaying = `MCM_CH_GetValue(class'NarrativeHoncho_Settings_Defaults'.default.NoGreetingsWhenNarrativePlaying, NoGreetingsWhenNarrativePlaying);
    NoNarrativesInGeoscape = `MCM_CH_GetValue(class'NarrativeHoncho_Settings_Defaults'.default.NoNarrativesInGeoscape, NoNarrativesInGeoscape);
    NoStrategyNarrativesAtAll = `MCM_CH_GetValue(class'NarrativeHoncho_Settings_Defaults'.default.NoStrategyNarrativesAtAll, NoStrategyNarrativesAtAll);
    NoTacticalNarrativesAtAll = `MCM_CH_GetValue(class'NarrativeHoncho_Settings_Defaults'.default.NoTacticalNarrativesAtAll, NoTacticalNarrativesAtAll);
    NoPostMissionNarratives = `MCM_CH_GetValue(class'NarrativeHoncho_Settings_Defaults'.default.NoPostMissionNarratives, NoPostMissionNarratives);
    LogNarrativeInfo = `MCM_CH_GetValue(class'NarrativeHoncho_Settings_Defaults'.default.LogNarrativeInfo, LogNarrativeInfo);

    // Get the values not exposed to MCM from the default INI.
    NarrativesToSkip = class'NarrativeHoncho_Settings_Defaults'.default.NarrativesToSkip;
}

function LoadNonMCMSettings()
{
    NarrativesToSkip = class'NarrativeHoncho_Settings'.default.NarrativesToSkip;
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
    BradfordStrategyNarratives_Dropdown.SetValue(class'NarrativeHoncho_Settings_Defaults'.default.BradfordStrategyNarratives, true);
    NoGreetingsWhenNarrativePlaying_Checkbox.SetValue(class'NarrativeHoncho_Settings_Defaults'.default.NoGreetingsWhenNarrativePlaying, true);
    NoNarrativesInGeoscape_Checkbox.SetValue(class'NarrativeHoncho_Settings_Defaults'.default.NoNarrativesInGeoscape, true);
    NoStrategyNarrativesAtAll_Checkbox.SetValue(class'NarrativeHoncho_Settings_Defaults'.default.NoStrategyNarrativesAtAll, true);
    NoTacticalNarrativesAtAll_Checkbox.SetValue(class'NarrativeHoncho_Settings_Defaults'.default.NoTacticalNarrativesAtAll, true);
    NoPostMissionNarratives_Checkbox.SetValue(class'NarrativeHoncho_Settings_Defaults'.default.NoPostMissionNarratives, true);
    LogNarrativeInfo_Checkbox.SetValue(class'NarrativeHoncho_Settings_Defaults'.default.LogNarrativeInfo, true);
}

function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    self.ConfigVersion = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
}

function EnsureConfigExists()
{
    if (ConfigVersion == 0)
    {
        LoadSavedSettings();
        SaveButtonClicked(none);
    }
    else
    {
        LoadNonMCMSettings();
    }
}
