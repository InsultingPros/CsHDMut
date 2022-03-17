class W_Deagle extends Deagle;


simulated function bool PutDown()
{
  if (Instigator.PendingWeapon.Class == class'Utility'.static.DualVariantOf(Class))
  {
    bIsReloading = false;
  }
  return super(KFWeapon).PutDown();
}


defaultproperties
{
  FireModeClass(0)=class'W_DeagleFire'
  PickupClass=class'W_DeaglePickup'
}