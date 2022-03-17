class W_GoldenDeagle extends GoldenDeagle;


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
  FireModeClass(0)=class'W_GoldenDeagleFire'
  PickupClass=class'W_GoldenDeaglePickup'
}