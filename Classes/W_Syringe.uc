class W_Syringe extends Syringe;


replication
{
  reliable if (Role < ROLE_Authority)
    ServerDoFire, ServerSetCachedHealee;
}


simulated function ServerDoFire()
{
  FireMode[0].ModeDoFire();
}

simulated function ServerSetCachedHealee(KFHumanPawn NewHealee)
{
  SyringeFire(FireMode[0]).CachedHealee = NewHealee;
}


defaultproperties
{
  FireModeClass(0)=class'W_SyringeFire'
  PickupClass=class'W_SyringePickup'
}