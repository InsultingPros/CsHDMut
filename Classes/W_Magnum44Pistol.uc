class W_Magnum44Pistol extends Magnum44Pistol;


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
  FireModeClass(0)=class'W_Magnum44Fire'
  PickupClass=class'W_Magnum44Pickup'
}