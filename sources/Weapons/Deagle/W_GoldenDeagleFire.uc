class W_GoldenDeagleFire extends GoldenDeagleFire;


// COPY-PASTE CODE BELOW FOR ALL PENETRATING PISTOLS!!!
var byte penCount;
var float penDamReduction;


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
  local array<Actor> IgnoreActors;
  local Actor Other, DamageActor;
  local KFPawn HitPawn;
  local array<int> HitPoints;
  local byte HitCount, i;
  local float hitdamage;
  local bool bIsHeadshot;

  if (CsHDRI == none)
  {
    CsHDRI = GetCsHDRI();

    if (CsHDRI == none)
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
  hitdamage = float(DamageMax);

  while ((HitCount++) < penCount)
  {
    DamageActor = none;
    Other = Instigator.HitPointTrace(HitLoc, HitNorm, End, HitPoints, Start,, 1);

    if (Other == none)
    {
      break;
    }
    else
    {
      if ((Other == Instigator) || Other.Base == Instigator)
      {
        IgnoreActors[IgnoreActors.Length] = Other;
        Other.SetCollision(false);
        Start = HitLoc;
        continue;
      }
    }
    if ((ExtendedZCollision(Other) != none) && Other.Owner != none)
    {
      IgnoreActors[IgnoreActors.Length] = Other;
      IgnoreActors[IgnoreActors.Length] = Other.Owner;
      Other.SetCollision(false);
      Other.Owner.SetCollision(false);
      DamageActor = Pawn(Other.Owner);
    }

    if (!Other.bWorldGeometry && Other != Level)
    {
      HitLocDiff = HitLoc - Other.Location;
      HitPawn = KFPawn(Other);

      if (HitPawn != none)
      {
        if (!HitPawn.bDeleteMe)
        {
          CsHDRI.ServerDamagePawn(HitPawn, int(hitdamage), Instigator, HitLocDiff, Momentum * X, DamageType, HitPoints);
        }
        IgnoreActors[IgnoreActors.Length] = Other;
        IgnoreActors[IgnoreActors.Length] = HitPawn.AuxCollisionCylinder;
        Other.SetCollision(false);
        HitPawn.AuxCollisionCylinder.SetCollision(false);
        DamageActor = Other;
      }
      else
      {
        if (KFMonster(Other) != none)
        {
          IgnoreActors[IgnoreActors.Length] = Other;
          Other.SetCollision(false);
          DamageActor = Other;
        }
        else
        {
          if (DamageActor == none)
          {
            DamageActor = Other;
          }
        }

        if (KFMonster(DamageActor) != none)
        {
          bIsHeadshot = CsHDRI.IsHeadshotClient(DamageActor, HitLoc, Normal(Momentum * X));
          CsHDRI.ServerDealDamage(DamageActor, int(hitdamage), Instigator, HitLocDiff, Momentum * X, DamageType, bIsHeadshot);
        }
        else
        {
          CsHDRI.ServerDealDamage(Other, int(hitdamage), Instigator, HitLocDiff, Momentum * X, DamageType);
        }
      }

      if (Pawn(DamageActor) == none)
      {
        break;
      }
      hitdamage *= penDamReduction;
      Start = HitLoc;
      continue;
    }

    if (HitScanBlockingVolume(Other) == none)
    {
      CsHDRI.ServerUpdateHit(Weapon.ThirdPersonActor, Other, HitLoc, HitNorm);
      break;
    }
  }

  if (IgnoreActors.Length > 0)
  {
    for (i = 0; i < IgnoreActors.Length && IgnoreActors[i] != none; i++)
    {
      IgnoreActors[i].SetCollision(true);
    }
  }
}


defaultproperties
{
  penCount=5
  penDamReduction=0.50
  AmmoClass=Class'KFMod.GoldenDeagleAmmo'
}