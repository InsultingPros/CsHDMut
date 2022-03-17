class GUI_BuyMenuSaleList extends KFBuyMenuSaleList;


function int PopulateBuyables()
{
  local class<KFVeterancyTypes> PlayerVeterancy;
  local KFPlayerReplicationInfo PRI;
  local GUIBuyable ForSaleBuyable;
  local class<KFWeaponPickup> WP;
  local int CurrentIndex, i, j, DualDivider;

  if (KFLR == none)
  {
    return 0;
  }
  PRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);

  if ((PRI != none) && PRI.ClientVeteranSkill != none)
  {
    PlayerVeterancy = PRI.ClientVeteranSkill;
  }
  else
  {
    PlayerVeterancy = class'KFVeterancyTypes';
  
  }

  for (j = 0; j < KFLR.ItemForSale.Length; j++)
  {
    if ((((class<KFWeaponPickup>(KFLR.ItemForSale[j]) == none) || class<KFWeapon>(KFLR.ItemForSale[j].default.InventoryType) == none) || class<KFWeapon>(KFLR.ItemForSale[j].default.InventoryType).default.bKFNeverThrow) || IsInInventory(KFLR.ItemForSale[j]))
    {
      continue;
    }

    DualDivider = 1;
    WP = class<KFWeaponPickup>(KFLR.ItemForSale[j]);

    if (class'Utility'.static.IsSingleHandgun(WP.default.InventoryType))
    {
      if (IsInInventory(class'Utility'.static.DualPickupOf(WP)))
      {
        continue;
      }
    }
    else
    {
      if (class'Utility'.static.IsDualHandguns(WP.default.InventoryType))
      {
        if (IsInInventory(class'Utility'.static.SinglePickupOf(WP)))
        {
          DualDivider = 2;
        }
      }
    }

    if (CurrentIndex >= ForSaleBuyables.Length)
    {
      ForSaleBuyable = new class'GUIBuyable';
      ForSaleBuyables[ForSaleBuyables.Length] = ForSaleBuyable;
    }
    else
    {
      ForSaleBuyable = ForSaleBuyables[CurrentIndex];
    }
    ++ CurrentIndex;
    ForSaleBuyable.ItemName = WP.default.ItemName;
    ForSaleBuyable.ItemDescription = WP.default.Description;
    ForSaleBuyable.ItemCategorie = KFLR.EquipmentCategories[i].EquipmentCategoryName;
    ForSaleBuyable.ItemImage = class<KFWeapon>(WP.default.InventoryType).default.TraderInfoTexture;
    ForSaleBuyable.ItemAmmoClass = class<KFWeapon>(WP.default.InventoryType).default.FireModeClass[0].default.AmmoClass;
    ForSaleBuyable.ItemWeaponClass = class<KFWeapon>(WP.default.InventoryType);
    ForSaleBuyable.ItemPickupClass = WP;
    ForSaleBuyable.ItemCost = float(int((float(WP.default.cost) * PlayerVeterancy.static.GetCostScaling(PRI, WP)) / float(DualDivider)));
    ForSaleBuyable.ItemAmmoCost = 0.0;
    ForSaleBuyable.ItemFillAmmoCost = 0.0;

    if (DualDivider == 2)
    {
      ForSaleBuyable.ItemWeight = float(Min(0, int(WP.default.Weight - class'Utility'.static.SinglePickupOf(WP).default.Weight)));
    }
    else
    {
      ForSaleBuyable.ItemWeight = WP.default.Weight;
    }

    ForSaleBuyable.ItemPower = float(WP.default.PowerValue);
    ForSaleBuyable.ItemRange = float(WP.default.RangeValue);
    ForSaleBuyable.ItemSpeed = float(WP.default.SpeedValue);
    ForSaleBuyable.ItemAmmoCurrent = 0.0;
    ForSaleBuyable.ItemAmmoMax = 0.0;
    ForSaleBuyable.ItemPerkIndex = WP.default.CorrespondingPerkIndex;
    ForSaleBuyable.bSaleList = true;
  }
  return CurrentIndex;
}