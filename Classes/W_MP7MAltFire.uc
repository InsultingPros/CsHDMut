class W_MP7MAltFire extends MP7MAltFire;


// COPY-PASTE CODE BELOW FOR ALL PROJECTILE BASED FIRE CLASSES!!!
var class<Projectile> ClientProjectileClass;


function ShakeView()
{
  DoFireEffect();
  super(WeaponFire).ShakeView();
}


function CsHDReplicationInfo GetCsHDRI()
{
  if ((Instigator != none) && CsHDPlayerController(Instigator.Controller) != none)
  {
    return CsHDPlayerController(Instigator.Controller).CsHDRI;
  }
  return none;
}


function class<Projectile> GetDesiredProjectileClass()
{
  if (Level.NetMode == NM_Client)
  {
    return ClientProjectileClass;
  }
  return ProjectileClass;
}


defaultproperties
{
  ClientProjectileClass=class'W_MP7MHealingProjectile_CLIENT'
  ProjectileClass=class'W_MP7MHealingProjectile'
}