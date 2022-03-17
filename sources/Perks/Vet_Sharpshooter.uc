class Vet_Sharpshooter extends KFVetSharpshooter
  abstract;


static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
  if ((((class<KFWeaponPickup>(Item) != none) && class<KFWeaponPickup>(Item).default.CorrespondingPerkIndex == default.PerkIndex) && class<WinchesterPickup>(Item) == none) && class<CrossbowPickup>(Item) == none)
  {
    return 0.90 - (0.10 * float(KFPRI.ClientVeteranSkillLevel));
  }
  return super.GetCostScaling(KFPRI, Item);
}


static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
  if (KFPRI.ClientVeteranSkillLevel == 5)
  {
    KFHumanPawn(P).CreateInventoryVeterancy("CsHDMut.W_Winchester", default.StartingWeaponSellPriceLevel5);
  }
  else
  {
    if (KFPRI.ClientVeteranSkillLevel == 6)
    {
      KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Crossbow", default.StartingWeaponSellPriceLevel6);
    }
  }
}