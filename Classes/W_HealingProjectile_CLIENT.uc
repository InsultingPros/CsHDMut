class W_HealingProjectile_CLIENT extends HealingProjectile;


simulated function CsHDReplicationInfo GetCsHDRI()
{
  if ((Instigator != none) && CsHDPlayerController(Instigator.Controller) != none)
  {
    return CsHDPlayerController(Instigator.Controller).CsHDRI;
  }
  return none;
}


simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
  local CsHDReplicationInfo CsHDRI;

  if (((Other == none) || Other == Instigator) || Other.Base == Instigator)
  {
    return;
  }

  CsHDRI = GetCsHDRI();
  if (CsHDRI != none)
  {
    CsHDRI.ServerHealTarget(Class, Other, Other.Location - HitLocation);
  }
  HitHealTarget(HitLocation, -vector(Rotation));
  Explode(HitLocation, -vector(Rotation));
}


defaultproperties
{
  RemoteRole=ROLE_Authority
}