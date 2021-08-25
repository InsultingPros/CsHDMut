class W_HealingProjectile extends HealingProjectile;


simulated function PostBeginPlay()
{
  super.PostBeginPlay();

  if (((Role < ROLE_Authority) && Instigator != none) && Level.GetLocalPlayerController() == Instigator.Controller)
  {
    bHidden = true;
    SetPhysics(PHYS_None);
  }
}


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
  if (((Role < ROLE_Authority) && Instigator != none) && Level.GetLocalPlayerController() == Instigator.Controller)
  {
    return;
  }

  if (((Other == none) || Other == Instigator) || Other.Base == Instigator)
  {
    return;
  }

  if (Role == ROLE_Authority)
  {
    if (KFHumanPawn(Other) != none)
    {
      HitHealTarget(HitLocation, -vector(Rotation));
    }
  }
  else
  {
    if (KFHumanPawn(Other) != none)
    {
      bHidden = true;
      SetPhysics(PHYS_None);
      return;
    }
  }
  Explode(HitLocation, -vector(Rotation));
}


simulated function HitHealTarget(Vector HitLocation, Vector HitNormal)
{
  if (((Role < ROLE_Authority) && Instigator != none) && Level.GetLocalPlayerController() == Instigator.Controller)
  {
    return;
  }
  super.HitHealTarget(HitLocation, HitNormal);
}


singular simulated function HitWall(Vector HitNormal, Actor Wall)
{
  if (((Role < ROLE_Authority) && Instigator != none) && Level.GetLocalPlayerController() == Instigator.Controller)
  {
    return;
  }
  super.HitWall(HitNormal, Wall);
}


simulated function Explode(Vector HitLocation, Vector HitNormal)
{
  if (((Role < ROLE_Authority) && Instigator != none) && Level.GetLocalPlayerController() == Instigator.Controller)
  {
    return;
  }
  super.Explode(HitLocation, HitNormal);
}