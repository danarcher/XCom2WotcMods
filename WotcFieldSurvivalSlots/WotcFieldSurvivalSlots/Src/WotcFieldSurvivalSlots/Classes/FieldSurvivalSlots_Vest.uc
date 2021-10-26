class FieldSurvivalSlots_Vest extends CHItemSlotSet;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.AddItem(CreateVestSlotTemplate());
	return Templates;
}

static function X2DataTemplate CreateVestSlotTemplate()
{
	local CHItemSlot Template;

	`CREATE_X2TEMPLATE(class'CHItemSlot', Template, 'FieldSurvivalSlots_Vest');
	Template.InvSlot = eInvSlot_Vest;
	Template.SlotCatMask = Template.SLOT_ARMOR | Template.SLOT_ITEM;
	Template.IsUserEquipSlot = true;
	Template.IsEquippedSlot = true;
	Template.BypassesUniqueRule = false;
	Template.IsMultiItemSlot = false;
	Template.IsSmallSlot = true;
	Template.CanAddItemToSlotFn = CanAddItemToSlot;
	Template.UnitHasSlotFn = UnitHasSlot;
	Template.GetPriorityFn = GetPriority;
	Template.ShowItemInLockerListFn = ShowItemInLockerList;
	Template.ValidateLoadoutFn = ValidateLoadout;
    Template.GetDisplayNameFn = GetDisplayName;
    Template.GetDisplayLetterFn = GetDisplayLetter;
	Template.GetSlotUnequipBehaviorFn = GetSlotUnequipBehavior;

	return Template;
}

static function bool CanAddItemToSlot(CHItemSlot Slot, XComGameState_Unit Unit, X2ItemTemplate Template, optional XComGameState CheckGameState, optional int Quantity = 1, optional XComGameState_Item ItemState)
{
	local string Unused;
	if (Slot.UnitHasSlot(Unit, Unused, CheckGameState) &&
        Unit.GetItemInSlot(Slot.InvSlot, CheckGameState) == none &&
        Template.ItemCat == 'defense')
    {
        return true;
    }
    return false;
}

static function bool UnitHasSlot(CHItemSlot Slot, XComGameState_Unit UnitState, out string LockedReason, optional XComGameState CheckGameState)
{
	if (UnitState.IsSoldier() && !UnitState.IsRobotic())
	{
		return true;
	}
	return false;
}

static function int GetPriority(CHItemSlot Slot, XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	return 120; // After ammo pocket at 110.
}

static function bool ShowItemInLockerList(CHItemSlot Slot, XComGameState_Unit Unit, XComGameState_Item ItemState, X2ItemTemplate ItemTemplate, XComGameState CheckGameState)
{
	return ItemTemplate.ItemCat == 'defense';
}

static function ValidateLoadout(CHItemSlot Slot, XComGameState_Unit Unit, XComGameState_HeadquartersXCom XComHQ, XComGameState NewGameState)
{
	local XComGameState_Item EquippedItem;
	local string Unused;
	local bool HasSlot;
	EquippedItem = Unit.GetItemInSlot(Slot.InvSlot, NewGameState);
	HasSlot = Slot.UnitHasSlot(Unit, Unused, NewGameState);
	if(EquippedItem != none && !HasSlot)
	{
        // Unequip.
		EquippedItem = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', EquippedItem.ObjectID));
		Unit.RemoveItemFromInventory(EquippedItem, NewGameState);
		XComHQ.PutItemInInventory(NewGameState, EquippedItem);
	}
}

static function string GetDisplayName(CHItemSlot Slot)
{
    return "VEST";
}

static function string GetDisplayLetter(CHItemSlot Slot)
{
    return "V";
}

static function ECHSlotUnequipBehavior GetSlotUnequipBehavior(CHItemSlot Slot, ECHSlotUnequipBehavior DefaultBehavior, XComGameState_Unit Unit, XComGameState_Item ItemState, optional XComGameState CheckGameState)
{
    return eCHSUB_AllowEmpty;
}
