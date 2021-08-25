class GUI_BuyMenuInvList extends KFBuyMenuInvList;


function UpdateMyBuyables()
{
  local class<KFVeterancyTypes> PlayerVeterancy;
  local class<KFWeaponPickup> myPickUp, MyPrimaryPickup;
  local GUIBuyable MyBuyable, KnifeBuyable, FragBuyable, SecondaryAmmoBuyable;
  local KFLevelRules LR;
  local KFPlayerReplicationInfo PRI;
  local Inventory Inv;
  local KFWeapon W;
  local float CurAmmo, MaxAmmo;
  local int DualDivider, NumInvItems;

  if (PlayerOwner().Pawn.Inventory == none)
  {
    return;
  }

  foreach PlayerOwner().DynamicActors(class'KFLevelRules', LR)
  {
    break;
  }    

  if (LR == none)
  {
    return;
  }
  AutoFillCost = 0.0;
  MyBuyables.Remove(0, MyBuyables.Length);
  PRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);

  if ((PRI != none) && PRI.ClientVeteranSkill != none)
  {
    PlayerVeterancy = PRI.ClientVeteranSkill;
  }
  else
  {
    PlayerVeterancy = class'KFVeterancyTypes';
  }

  for (Inv = PlayerOwner().Pawn.Inventory; Inv != none; Inv = Inv.Inventory)
  {
    if ((!Inv.IsA('KFWeapon') || Inv.IsA('Welder')) || Inv.IsA('Syringe'))
    {
      // WTF IS THIS? Maybe a `continue`?
    }
    else
    {
      if (class'Utility'.static.IsDualHandguns(Inv.Class))
      {
        DualDivider = 2;
      }
      else
      {
        DualDivider = 1;
      }

      W = KFWeapon(Inv);
      myPickUp = class<KFWeaponPickup>(W.default.PickupClass);
      if (myPickUp != none)
      {
        W.GetAmmoCount(MaxAmmo, CurAmmo);
        MyBuyable = new class'GUIBuyable';

        if (W.bHasSecondaryAmmo)
        {
          MyPrimaryPickup = myPickUp.default.PrimaryWeaponPickup;
          MyBuyable.ItemName = myPickUp.default.ItemShortName;
          MyBuyable.ItemDescription = W.default.Description;
          MyBuyable.ItemCategorie = LR.EquipmentCategories[myPickUp.default.EquipmentCategoryID].EquipmentCategoryName;
          MyBuyable.ItemImage = W.default.TraderInfoTexture;
          MyBuyable.ItemWeaponClass = W.Class;
          MyBuyable.ItemAmmoClass = W.default.FireModeClass[0].default.AmmoClass;
          MyBuyable.ItemPickupClass = MyPrimaryPickup;
          MyBuyable.ItemCost = (float(myPickUp.default.cost) * PlayerVeterancy.static.GetCostScaling(PRI, myPickUp)) / float(DualDivider);
          MyBuyable.ItemAmmoCost = (float(MyPrimaryPickup.default.AmmoCost) * PlayerVeterancy.static.GetAmmoCostScaling(PRI, MyPrimaryPickup)) * PlayerVeterancy.static.GetMagCapacityMod(PRI, W);
          MyBuyable.ItemFillAmmoCost = float(int(((MaxAmmo - CurAmmo) * float(MyPrimaryPickup.default.AmmoCost)) / float(W.default.MagCapacity))) * PlayerVeterancy.static.GetAmmoCostScaling(PRI, MyPrimaryPickup);
          MyBuyable.ItemWeight = W.Weight;
          MyBuyable.ItemPower = float(myPickUp.default.PowerValue);
          MyBuyable.ItemRange = float(myPickUp.default.RangeValue);
          MyBuyable.ItemSpeed = float(myPickUp.default.SpeedValue);
          MyBuyable.ItemAmmoCurrent = CurAmmo;
          MyBuyable.ItemAmmoMax = MaxAmmo;
          MyBuyable.bMelee = KFMeleeGun(Inv) != none;
          MyBuyable.bSaleList = false;
          MyBuyable.ItemPerkIndex = myPickUp.default.CorrespondingPerkIndex;

          if ((W != none) && W.SellValue != -1)
          {
            MyBuyable.ItemSellValue = W.SellValue;
          }
          else
          {
            MyBuyable.ItemSellValue = int(MyBuyable.ItemCost * 0.750);
          }

          if (!MyBuyable.bMelee && int(MaxAmmo) > int(CurAmmo))
          {
            AutoFillCost += MyBuyable.ItemFillAmmoCost;
          }
          MyBuyable.bSellable = !W.default.bKFNeverThrow;
          MyBuyables.Insert(0, 1);
          MyBuyables[0] = MyBuyable;
          ++ NumInvItems;
          W.GetSecondaryAmmoCount(MaxAmmo, CurAmmo);
          MyBuyable = new class'GUIBuyable';
          MyBuyable.ItemName = myPickUp.default.SecondaryAmmoShortName;
          MyBuyable.ItemDescription = W.default.Description;
          MyBuyable.ItemCategorie = LR.EquipmentCategories[myPickUp.default.EquipmentCategoryID].EquipmentCategoryName;
          MyBuyable.ItemImage = W.default.TraderInfoTexture;
          MyBuyable.ItemWeaponClass = W.Class;
          MyBuyable.ItemAmmoClass = W.default.FireModeClass[1].default.AmmoClass;
          MyBuyable.ItemPickupClass = myPickUp;
          MyBuyable.ItemCost = (float(myPickUp.default.cost) * PlayerVeterancy.static.GetCostScaling(PRI, myPickUp)) / float(DualDivider);
          MyBuyable.ItemAmmoCost = (float(myPickUp.default.AmmoCost) * PlayerVeterancy.static.GetAmmoCostScaling(PRI, myPickUp)) * PlayerVeterancy.static.GetMagCapacityMod(PRI, W);
          MyBuyable.ItemFillAmmoCost = float(int((MaxAmmo - CurAmmo) * float(myPickUp.default.AmmoCost))) * PlayerVeterancy.static.GetAmmoCostScaling(PRI, myPickUp);
          MyBuyable.ItemWeight = W.Weight;
          MyBuyable.ItemPower = float(myPickUp.default.PowerValue);
          MyBuyable.ItemRange = float(myPickUp.default.RangeValue);
          MyBuyable.ItemSpeed = float(myPickUp.default.SpeedValue);
          MyBuyable.ItemAmmoCurrent = CurAmmo;
          MyBuyable.ItemAmmoMax = MaxAmmo;
          MyBuyable.bMelee = KFMeleeGun(Inv) != none;
          MyBuyable.bSaleList = false;
          MyBuyable.ItemPerkIndex = myPickUp.default.CorrespondingPerkIndex;

          if ((W != none) && W.SellValue != -1)
          {
            MyBuyable.ItemSellValue = W.SellValue;
          }
          else
          {
            MyBuyable.ItemSellValue = int(MyBuyable.ItemCost * 0.750);
          }

          if (!MyBuyable.bMelee && int(MaxAmmo) > int(CurAmmo))
          {
            AutoFillCost += MyBuyable.ItemFillAmmoCost;
          }
        }
        else
        {
          MyBuyable.ItemName = myPickUp.default.ItemShortName;
          MyBuyable.ItemDescription = W.default.Description;
          MyBuyable.ItemCategorie = LR.EquipmentCategories[myPickUp.default.EquipmentCategoryID].EquipmentCategoryName;
          MyBuyable.ItemImage = W.default.TraderInfoTexture;
          MyBuyable.ItemWeaponClass = W.Class;
          MyBuyable.ItemAmmoClass = W.default.FireModeClass[0].default.AmmoClass;
          MyBuyable.ItemPickupClass = myPickUp;
          MyBuyable.ItemCost = (float(myPickUp.default.cost) * PlayerVeterancy.static.GetCostScaling(PRI, myPickUp)) / float(DualDivider);
          MyBuyable.ItemAmmoCost = (float(myPickUp.default.AmmoCost) * PlayerVeterancy.static.GetAmmoCostScaling(PRI, myPickUp)) * PlayerVeterancy.static.GetMagCapacityMod(PRI, W);

          if (myPickUp == class'HuskGunPickup')
          {
            MyBuyable.ItemFillAmmoCost = float(int(((MaxAmmo - CurAmmo) * float(myPickUp.default.AmmoCost)) / float(myPickUp.default.BuyClipSize))) * PlayerVeterancy.static.GetAmmoCostScaling(PRI, myPickUp);
          }
          else
          {
            MyBuyable.ItemFillAmmoCost = float(int(((MaxAmmo - CurAmmo) * float(myPickUp.default.AmmoCost)) / float(W.default.MagCapacity))) * PlayerVeterancy.static.GetAmmoCostScaling(PRI, myPickUp);
          }
          MyBuyable.ItemWeight = W.Weight;
          MyBuyable.ItemPower = float(myPickUp.default.PowerValue);
          MyBuyable.ItemRange = float(myPickUp.default.RangeValue);
          MyBuyable.ItemSpeed = float(myPickUp.default.SpeedValue);
          MyBuyable.ItemAmmoCurrent = CurAmmo;
          MyBuyable.ItemAmmoMax = MaxAmmo;
          MyBuyable.bMelee = KFMeleeGun(Inv) != none;
          MyBuyable.bSaleList = false;
          MyBuyable.ItemPerkIndex = myPickUp.default.CorrespondingPerkIndex;

          if ((W != none) && W.SellValue != -1)
          {
            MyBuyable.ItemSellValue = W.SellValue;
          }
          else
          {
            MyBuyable.ItemSellValue = int(MyBuyable.ItemCost * 0.750);
          }
          if (!MyBuyable.bMelee && int(MaxAmmo) > int(CurAmmo))
          {
            AutoFillCost += MyBuyable.ItemFillAmmoCost;
          }
        }

        if (W.bHasSecondaryAmmo)
        {
          MyBuyable.bSellable = false;
          SecondaryAmmoBuyable = MyBuyable;
        }
        else
        {
          if (Inv.IsA('knife'))
          {
            MyBuyable.bSellable = false;
            KnifeBuyable = MyBuyable;
          }
          else
          {
            if(Inv.IsA('Frag'))
            {
              MyBuyable.bSellable = false;
              FragBuyable = MyBuyable;
            }
            else
            {
              if (NumInvItems < 7)
              {
                MyBuyable.bSellable = !W.default.bKFNeverThrow;
                MyBuyables.Insert(0, 1);
                MyBuyables[0] = MyBuyable;
                ++ NumInvItems;
              }
            }
          }
        }
      }
    }
  }

  MyBuyable = new class'GUIBuyable';
  MyBuyable.ItemName = class'BuyableVest'.default.ItemName;
  MyBuyable.ItemDescription = class'BuyableVest'.default.ItemDescription;
  MyBuyable.ItemCategorie = "";
  MyBuyable.ItemImage = class'BuyableVest'.default.ItemImage;
  MyBuyable.ItemAmmoCurrent = PlayerOwner().Pawn.ShieldStrength;
  MyBuyable.ItemAmmoMax = 100.0;
  MyBuyable.ItemCost = float(int(class'BuyableVest'.default.ItemCost * PlayerVeterancy.static.GetCostScaling(KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo), class'Vest')));
  MyBuyable.ItemAmmoCost = MyBuyable.ItemCost / float(100);
  MyBuyable.ItemFillAmmoCost = float(int((100.0 - MyBuyable.ItemAmmoCurrent) * MyBuyable.ItemAmmoCost));
  MyBuyable.bIsVest = true;
  MyBuyable.bMelee = false;
  MyBuyable.bSaleList = false;
  MyBuyable.bSellable = false;
  MyBuyable.ItemPerkIndex = byte(class'BuyableVest'.default.CorrespondingPerkIndex);
  MyBuyables[7] = none;

  if (SecondaryAmmoBuyable != none)
  {
    MyBuyables[8] = SecondaryAmmoBuyable;
  }
  else
  {
    MyBuyables[8] = KnifeBuyable;
  }
  MyBuyables[9] = FragBuyable;
  MyBuyables[10] = MyBuyable;
  UpdateList();
}