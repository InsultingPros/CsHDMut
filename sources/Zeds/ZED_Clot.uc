class ZED_Clot extends ZombieClot_STANDARD;


simulated function PostBeginPlay()
{
  local Vector AttachPos;

  super(KFMonster).PostBeginPlay();

  if (Role < ROLE_Authority)
  {
    if (bUseExtendedCollision && MyExtCollision == none)
    {
      MyExtCollision = Spawn(class'ExtendedZCollision', self);
      MyExtCollision.SetCollisionSize(ColRadius, ColHeight);
      MyExtCollision.bHardAttach = true;
      AttachPos = Location + (ColOffset >> Rotation);
      MyExtCollision.SetLocation(AttachPos);
      MyExtCollision.SetPhysics(0);
      MyExtCollision.SetBase(self);
      SavedExtCollision = MyExtCollision.bCollideActors;
    }
  }
}


simulated function bool IsHeadshotClient(Vector loc, Vector ray, optional float AdditionalScale)
{
  local Coords C;
  local Vector HeadLoc, M, diff;
  local float t, DotMM, Distance, adjustedScale;

  if (HeadBone == 'None')
  {
    return false;
  }
  C = GetBoneCoords(HeadBone);
  adjustedScale = 1.0 + (FClamp(AdditionalScale, 0.0, 1.0) * (FMax(1.0, OnlineHeadshotScale) - 1.0));
  HeadLoc = C.Origin + (((HeadHeight * HeadScale) * adjustedScale) * C.XAxis);
  M = (2.0 * (CollisionHeight + CollisionRadius)) * ray;
  diff = HeadLoc - loc;
  t = M Dot diff;

  if (t > 0)
  {
    DotMM = M Dot M;

    if (t < DotMM)
    {
      diff -= ((t / DotMM) * M);
    }
    else
    {
      diff -= M;
    }
  }
  Distance = Sqrt(diff Dot diff);
  return Distance < ((HeadRadius * HeadScale) * adjustedScale);
}


function TakeDamageClient(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
{
  local KFPlayerReplicationInfo KFPRI;

  LastDamagedBy = instigatedBy;
  LastDamagedByType = DamageType;
  HitMomentum = int(VSize(Momentum));
  LastHitLocation = HitLocation;
  LastMomentum = Momentum;

  if ((KFPawn(instigatedBy) != none) && instigatedBy.PlayerReplicationInfo != none)
  {
    KFPRI = KFPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo);
  }

  if (bZapped)
  {
    Damage *= ZappedDamageMod;
  }

  if ((class<KFWeaponDamageType>(DamageType) != none) && class<KFWeaponDamageType>(DamageType).default.bDealBurningDamage)
  {
    if ((BurnDown <= 0) || Damage > LastBurnDamage)
    {
      LastBurnDamage = Damage;

      if (((class<DamTypeTrenchgun>(DamageType) != none) || class<DamTypeFlareRevolver>(DamageType) != none) || class<DamTypeMAC10MPInc>(DamageType) != none)
      {
        FireDamageClass = DamageType;
      }
      else
      {
        FireDamageClass = class'DamTypeFlamethrower';
      }
    }

    if (class<DamTypeMAC10MPInc>(DamageType) == none)
    {
      Damage *= 1.50;
    }

    if (BurnDown <= 0)
    {
      if ((HeatAmount > 4) || Damage >= 15)
      {
        bBurnified = true;
        BurnDown = 10;
        SetGroundSpeed(GroundSpeed * 0.80);
        BurnInstigator = instigatedBy;
        SetTimer(1.0, false);
      }

      else
      {
        ++ HeatAmount;
      }
    }
  }

  if ((KFPRI != none) && KFPRI.ClientVeteranSkill != none)
  {
    Damage = KFPRI.ClientVeteranSkill.static.AddDamage(KFPRI, self, KFPawn(instigatedBy), Damage, DamageType);
  }

  if (((DamageType != none) && LastDamagedBy.IsPlayerPawn()) && LastDamagedBy.Controller != none)
  {
    if (KFMonsterController(Controller) != none)
    {
      KFMonsterController(Controller).AddKillAssistant(LastDamagedBy.Controller, FMin(float(Health), float(Damage)));
    }
  }

  if (((bDecapitated || bIsHeadshot) && class<DamTypeBurned>(DamageType) == none) && class<DamTypeFlamethrower>(DamageType) == none)
  {
    if (class<KFWeaponDamageType>(DamageType) != none)
    {
      Damage *= class<KFWeaponDamageType>(DamageType).default.HeadShotDamageMult;
    }

    if (((class<DamTypeMelee>(DamageType) == none) && KFPRI != none) && KFPRI.ClientVeteranSkill != none)
    {
      Damage = int(float(Damage) * KFPRI.ClientVeteranSkill.static.GetHeadShotDamMulti(KFPRI, KFPawn(instigatedBy), DamageType));
    }
    LastDamageAmount = Damage;

    if (!bDecapitated && bIsHeadshot)
    {
      PlaySound(soundgroup'Impact_Skull', 0, 2.0, true, 500.0);
      HeadHealth -= float(LastDamageAmount);

      if ((HeadHealth <= float(0)) || Damage > Health)
      {
        RemoveHead();
      }
    }
  }

  if (((((((((((Health - Damage) > 0) && DamageType != class'DamTypeFrag') && DamageType != class'DamTypePipeBomb') && DamageType != class'DamTypeM79Grenade') && DamageType != class'DamTypeM32Grenade') && DamageType != class'DamTypeM203Grenade') && DamageType != class'DamTypeDwarfAxe') && DamageType != class'DamTypeSPGrenade') && DamageType != class'DamTypeSealSquealExplosion') && DamageType != class'DamTypeSeekerSixRocket')
  {
    Momentum = vect(0.0, 0.0, 0.0);
  }

  if (class<DamTypeVomit>(DamageType) != none)
  {
    BileCount = 7;
    BileInstigator = instigatedBy;
    LastBileDamagedByType = class<DamTypeVomit>(DamageType);

    if (NextBileTime < Level.TimeSeconds)
    {
      NextBileTime = Level.TimeSeconds + BileFrequency;
    }
  }
  TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
}


state ZombieDying
{
  ignores BreathTimer, Died, RangedAttack;

  simulated function TakeDamageClient(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
  {
    local Vector hitRay, HitNormal, shotDir, PushLinVel, PushAngVel;
    local name HitBone;
    local float HitBoneDist;

    if (bFrozenBody || bRubbery)
    {
      return;
    }

    if (Physics == 14)
    {
      if (bDeRes)
      {
        return;
      }

      if (DamageType.default.bThrowRagdoll)
      {
        shotDir = Normal(Momentum);
        PushLinVel = (RagDeathVel * shotDir) + vect(0.0, 0.0, 250.0);
        PushAngVel = Normal(shotDir Cross vect(0.0, 0.0, 1.0)) * float(-18000);
        KSetSkelVel(PushLinVel, PushAngVel);
      }
      else
      {
        if (DamageType.default.bRagdollBullet)
        {
          if (Momentum == vect(0.0, 0.0, 0.0))
          {
            Momentum = HitLocation - instigatedBy.Location;
          }

          if (FRand() < 0.650)
          {
            if (Velocity.Z <= float(0))
            {
              PushLinVel = vect(0.0, 0.0, 40.0);
            }
            PushAngVel = Normal(Normal(Momentum) Cross vect(0.0, 0.0, 1.0)) * float(-8000);
            PushAngVel.X *= 0.50;
            PushAngVel.Y *= 0.50;
            PushAngVel.Z *= float(4);
            KSetSkelVel(PushLinVel, PushAngVel);
          }
          PushLinVel = RagShootStrength * Normal(Momentum);
          KAddImpulse(PushLinVel, HitLocation);

          if ((LifeSpan > float(0)) && LifeSpan < (DeResTime + 2.0))
          {
            LifeSpan += 0.20;
          }
        }
        else
        {
          PushLinVel = RagShootStrength * Normal(Momentum);
          KAddImpulse(PushLinVel, HitLocation);
        }
      }
    }

    if (Damage > 0)
    {
      Health -= Damage;

      if (bIsHeadshot)
      {
        RemoveHead();
      }
      hitRay = vect(0.0, 0.0, 0.0);

      if (instigatedBy != none)
      {
        hitRay = Normal((HitLocation - instigatedBy.Location) + (vect(0.0, 0.0, 1.0) * instigatedBy.EyeHeight));
      }
      CalcHitLoc(HitLocation, hitRay, HitBone, HitBoneDist);

      if (instigatedBy != none)
      {
        HitNormal = Normal((Normal(instigatedBy.Location - HitLocation) + (VRand() * 0.20)) + vect(0.0, 0.0, 2.80));
      }
      else
      {
        HitNormal = Normal((vect(0.0, 0.0, 1.0) + (VRand() * 0.20)) + vect(0.0, 0.0, 2.80));
      }
      PlayHit(float(Damage), instigatedBy, HitLocation, DamageType, Momentum);
      DoDamageFX(HitBone, Damage, DamageType, rotator(HitNormal));
    }

    if (((DamageType.default.DamageOverlayMaterial != none) && Level.DetailMode != 0) && !Level.bDropDetail)
    {
      SetOverlayMaterial(DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true);
    }    
  }
  // stop;    
}
