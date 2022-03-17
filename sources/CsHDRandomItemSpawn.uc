class CsHDRandomItemSpawn extends KFRandomItemSpawn;


simulated function PostBeginPlay()
{
  local byte i;

  for (i = 0; i < ArrayCount(default.PickupClasses); i++)
  {
    default.PickupClasses[i] = class'CsHDMut'.static.GetPickupReplacement(default.PickupClasses[i]);

    if (class<KFWeaponPickup>(default.PickupClasses[i]) != none)
    {
      default.PickupWeight[i] = int(class<KFWeaponPickup>(default.PickupClasses[i]).default.Weight);
    }
  }
  super.PostBeginPlay();
}


defaultproperties
{
  PickupClasses[1]=class'KFMod.BullpupPickup'
  PickupClasses[2]=class'KFMod.DeaglePickup'
  PickupClasses[3]=class'KFMod.WinchesterPickup'
  PickupClasses[4]=class'KFMod.Vest'
}