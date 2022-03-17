class W_Single extends Single;


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
  FireModeClass(0)=class'W_SingleFire'
  PickupClass=class'W_SinglePickup'
}