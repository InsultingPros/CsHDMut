class W_MK23Pistol extends MK23Pistol;


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
  FireModeClass(0)=class'W_MK23Fire'
  PickupClass=class'W_MK23Pickup'
}