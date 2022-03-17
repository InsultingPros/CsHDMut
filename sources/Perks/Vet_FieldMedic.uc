class Vet_FieldMedic extends KFVetFieldMedic
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
  if (KFPRI.ClientVeteranSkillLevel >= 5)
  {
    P.ShieldStrength = 100.0;
  }

  if (KFPRI.ClientVeteranSkillLevel == 6)
  {
    KFHumanPawn(P).CreateInventoryVeterancy("CsHDMut.W_MP7MMedicGun", default.StartingWeaponSellPriceLevel6);
  }
}