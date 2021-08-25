// contains static, utility functions used across all other classes
class Utility extends object;


// modified perk classes
var array< class<KFVeterancyTypes> > Vet_Array;


final static function class<KFWeapon> SingleVariantOf(class<Inventory> Inv)
{
  if (Inv == class'W_Dualies')
    return class'W_Single';
  else if (Inv == class'W_DualDeagle')
    return class'W_Deagle';
  else if (Inv == class'W_GoldenDualDeagle')
    return class'W_GoldenDeagle';
  else if (Inv == class'W_DualMK23Pistol')
    return class'W_MK23Pistol';
  else if (Inv == class'W_Dual44Magnum')
    return class'W_Magnum44Pistol';
  else if (Inv == class'DualFlareRevolver')
    return class'FlareRevolver';
  else
    return none;
}


final static function class<KFWeapon> DualVariantOf(class<Inventory> Inv)
{
  if (Inv == class'W_Single')
    return class'W_Dualies';
  else if (Inv == class'W_Deagle')
    return class'W_DualDeagle';
  else if (Inv == class'W_GoldenDeagle')
    return class'W_GoldenDualDeagle';
  else if (Inv == class'W_MK23Pistol')
    return class'W_DualMK23Pistol';
  else if (Inv == class'W_Magnum44Pistol')
    return class'W_Dual44Magnum';
  else if (Inv == class'FlareRevolver')
    return class'DualFlareRevolver';
  else
    return none;
}


final static function class<KFWeaponPickup> SinglePickupOf(class<KFWeaponPickup> WP)
{
  if (WP == class'W_DualiesPickup')
    return class'W_SinglePickup';
  else if (WP == class'W_DualDeaglePickup')
    return class'W_DeaglePickup';
  else if (WP == class'W_GoldenDualDeaglePickup')
    return class'W_GoldenDeaglePickup';
  else if (WP == class'W_DualMK23Pickup')
    return class'W_MK23Pickup';
  else if (WP == class'W_Dual44MagnumPickup')
    return class'W_Magnum44Pickup';
  else if (WP == class'DualFlareRevolverPickup')
    return class'FlareRevolverPickup';
  else
    return none;
}


final static function class<KFWeaponPickup> DualPickupOf(class<KFWeaponPickup> Sp)
{
  if (Sp == class'W_SinglePickup')
    return class'W_DualiesPickup';
  else if (Sp == class'W_DeaglePickup')
    return class'W_DualDeaglePickup';
  else if (Sp == class'W_GoldenDeaglePickup')
    return class'W_GoldenDualDeaglePickup';
  else if (Sp == class'W_MK23Pickup')
    return class'W_DualMK23Pickup';
  else if (Sp == class'W_Magnum44Pickup')
    return class'W_Dual44MagnumPickup';
  else if (Sp == class'FlareRevolverPickup')
    return class'DualFlareRevolverPickup';
  else
    return none;
}


final static function bool IsDualHandguns(class<Inventory> Inv)
{
  if (class<Dualies>(Inv) != none)
  {
    return true;
  }
  return false;
}


final static function bool IsSingleHandgun(class<Inventory> Inv)
{
  if (((((class<Single>(Inv) != none) || class<Deagle>(Inv) != none) || class<MK23Pistol>(Inv) != none) || class<Magnum44Pistol>(Inv) != none) || class<FlareRevolver>(Inv) != none)
  {
    return true;
  }
  return false;
}


// used in CsHDPlayerController -> SelectVeterancy
final static function class<KFVeterancyTypes> GetVetReplacement(class<KFVeterancyTypes> VetSkill)
{
  local byte i;

  for (i = 0; i < default.Vet_Array.Length; i++)
  {
    if (ClassIsChildOf(default.Vet_Array[i], VetSkill))
    {
      return default.Vet_Array[i];
    }
  }
  return VetSkill;
}


defaultproperties
{
  Vet_Array(0)=class'CsHDMut.Vet_FieldMedic'
  Vet_Array(1)=class'CsHDMut.Vet_SupportSpec'
  Vet_Array(2)=class'CsHDMut.Vet_Sharpshooter'
  Vet_Array(3)=class'CsHDMut.Vet_Commando'
  Vet_Array(4)=class'CsHDMut.Vet_Berserker'
  Vet_Array(5)=class'CsHDMut.Vet_Firebug'
  Vet_Array(6)=class'CsHDMut.Vet_Demolitions'
}