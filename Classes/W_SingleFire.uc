class W_SingleFire extends SingleFire;


// COPY-PASTE CODE BELOW FOR ALL USUAL FIRE CLASSES!!!
function DoFireEffect()
{
  Instigator.MakeNoise(1.0);
}


function ShakeView()
{
  local Vector StartTrace;
  local Rotator R, Aim;

  StartTrace = Instigator.Location + Instigator.EyePosition();
  Aim = AdjustAim(StartTrace, aimerror);
  R = rotator(vector(Aim) + ((VRand() * FRand()) * Spread));
  DoTraceClient(StartTrace, R);
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


protected function DoTraceClient(Vector Start, Rotator Dir)
{
  local CsHDReplicationInfo CsHDRI;
  local Vector X, Y, Z, End, HitLoc, HitNorm, ArcEnd, HitLocDiff;
  local Actor Other;
  local array<int> HitPoints;
  local KFPawn HitPawn;
  local KFMonster ZED;
  local bool bIsHeadshot;

  if (CsHDRI == none)
  {
    CsHDRI = GetCsHDRI();
    if(CsHDRI == none)
    {
      return;
    }
  }
  MaxRange();
  Weapon.GetViewAxes(X, Y, Z);

  if (Weapon.WeaponCentered())
  {
    ArcEnd = (Instigator.Location + (Weapon.EffectOffset.X * X)) + ((1.50 * Weapon.EffectOffset.Z) * Z);
  }
  else
  {
    ArcEnd = (((Instigator.Location + Instigator.CalcDrawOffset(Weapon)) + (Weapon.EffectOffset.X * X)) + ((Weapon.hand * Weapon.EffectOffset.Y) * Y)) + (Weapon.EffectOffset.Z * Z);
  }
  X = vector(Dir);
  End = Start + (TraceRange * X);
  Other = Instigator.HitPointTrace(HitLoc, HitNorm, End, HitPoints, Start,, 1);

  if (((Other != none) && Other != Instigator) && Other.Base != Instigator)
  {
    if (!Other.bWorldGeometry)
    {
      HitLocDiff = HitLoc - Other.Location;

      if ((!Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume')) && !Other.IsA('ExtendedZCollision'))
      {
        CsHDRI.ServerUpdateHit(Weapon.ThirdPersonActor, Other, HitLoc, HitNorm, HitLocDiff);
      }
      HitPawn = KFPawn(Other);

      if (HitPawn != none)
      {
        if (!HitPawn.bDeleteMe)
        {
          CsHDRI.ServerDamagePawn(HitPawn, DamageMax, Instigator, HitLocDiff, Momentum * X, DamageType, HitPoints);
        }
      }
      else
      {
        if (ExtendedZCollision(Other) != none)
        {
          ZED = KFMonster(Other.Base);
        }
        else
        {
          ZED = KFMonster(Other);
        }
        if (ZED != none)
        {
          bIsHeadshot = CsHDRI.IsHeadshotClient(ZED, HitLoc, Normal(Momentum * X));
          CsHDRI.ServerDealDamage(ZED, DamageMax, Instigator, HitLocDiff, Momentum * X, DamageType, bIsHeadshot);
        }
        else
        {
          CsHDRI.ServerDealDamage(Other, DamageMax, Instigator, HitLocDiff, Momentum * X, DamageType);
        }
      }
    }
    else
    {
      HitLoc = HitLoc + (2.0 * HitNorm);
      CsHDRI.ServerUpdateHit(Weapon.ThirdPersonActor, Other, HitLoc, HitNorm);
    }
  }
  else
  {
    HitLoc = End;
    HitNorm = Normal(Start - End);
  }
}