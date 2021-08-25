class Vet_Commando extends KFVetCommando
  abstract;


static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
  if ((class<KFWeaponPickup>(Item) != none) && class<KFWeaponPickup>(Item).default.CorrespondingPerkIndex == default.PerkIndex)
  {
    return 0.90 - (0.10 * float(KFPRI.ClientVeteranSkillLevel));
  }
  return super.GetCostScaling(KFPRI, Item);
}


static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
  if (KFPRI.ClientVeteranSkillLevel == 5)
  {
    KFHumanPawn(P).CreateInventoryVeterancy("CsHDMut.W_Bullpup", default.StartingWeaponSellPriceLevel5);
  }
  else
  {
    if (KFPRI.ClientVeteranSkillLevel == 6)
    {
      KFHumanPawn(P).CreateInventoryVeterancy("CsHDMut.W_AK47AssaultRifle", default.StartingWeaponSellPriceLevel6);
    }
  }
}