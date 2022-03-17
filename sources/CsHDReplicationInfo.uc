class CsHDReplicationInfo extends ReplicationInfo
  dependson(ZED_Clot)
  dependson(ZED_Gorefast)
  dependson(ZED_Bloat)
  dependson(ZED_Crawler)
  dependson(ZED_Stalker)
  dependson(ZED_Siren)
  dependson(ZED_Husk)
  dependson(ZED_Scrake)
  dependson(ZED_Fleshpound)
  dependson(ZED_Patriarch);


var float AdditionalScale;


replication
{
  reliable if (bNetInitial && Role == ROLE_Authority)
    AdditionalScale;

  reliable if (Role < ROLE_Authority)
    ServerDamagePawn, ServerDealDamage, ServerHealTarget, ServerUpdateHit;
}


simulated function ServerDamagePawn(KFPawn injured, int Damage, Pawn instigatedBy, Vector HitLocDiff, Vector Momentum, class<DamageType> DamageType, array<int> PointsHit)
{
  if (injured == none)
  {
    return;
  }
  injured.ProcessLocationalDamage(Damage, instigatedBy, injured.Location + HitLocDiff, Momentum, DamageType, PointsHit);
}


simulated function bool IsHeadshotClient(Actor other, Vector HitLoc, Vector ray)
{
  if (other == none || !other.IsA('KFMonster'))
    return false;

  if (other.IsA('ZED_Clot'))
    return ZED_Clot(other).IsHeadshotClient(HitLoc, ray, AdditionalScale);
  else if (other.IsA('ZED_Gorefast'))
    return ZED_Gorefast(other).IsHeadshotClient(HitLoc, ray, AdditionalScale);
  else if (other.IsA('ZED_Bloat'))
    return ZED_Bloat(other).IsHeadshotClient(HitLoc, ray, AdditionalScale);
  else if (other.IsA('ZED_Crawler'))
    return ZED_Crawler(other).IsHeadshotClient(HitLoc, ray, AdditionalScale);
  else if (other.IsA('ZED_Stalker'))
    return ZED_Stalker(other).IsHeadshotClient(HitLoc, ray, AdditionalScale);
  else if (other.IsA('ZED_Siren'))
    return ZED_Siren(other).IsHeadshotClient(HitLoc, ray, AdditionalScale);
  else if (other.IsA('ZED_Husk'))
    return ZED_Husk(other).IsHeadshotClient(HitLoc, ray, AdditionalScale);
  else if (other.IsA('ZED_Scrake'))
    return ZED_Scrake(other).IsHeadshotClient(HitLoc, ray, AdditionalScale);
  else if (other.IsA('ZED_Fleshpound'))
    return ZED_Fleshpound(other).IsHeadshotClient(HitLoc, ray, AdditionalScale);
  else if (other.IsA('ZED_Patriarch'))
    return ZED_Patriarch(other).IsHeadshotClient(HitLoc, ray, AdditionalScale);
  else
    return false;
}


simulated function ServerDealDamage(Actor other, int Damage, Pawn instigatedBy, Vector HitLocDiff, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
{
  if (other == none)
    return;

  if (other.IsA('KFMonster'))
  {
    if (other.IsA('ZED_Clot'))
      ZED_Clot(other).TakeDamageClient(Damage, instigatedBy, other.Location + HitLocDiff, Momentum, DamageType, bIsHeadshot);
    else if (other.IsA('ZED_Gorefast'))
      ZED_Gorefast(other).TakeDamageClient(Damage, instigatedBy, other.Location + HitLocDiff, Momentum, DamageType, bIsHeadshot);
    else if (other.IsA('ZED_Bloat'))
      ZED_Bloat(other).TakeDamageClient(Damage, instigatedBy, other.Location + HitLocDiff, Momentum, DamageType, bIsHeadshot);
    else if (other.IsA('ZED_Crawler'))
      ZED_Crawler(other).TakeDamageClient(Damage, instigatedBy, other.Location + HitLocDiff, Momentum, DamageType, bIsHeadshot);
    else if (other.IsA('ZED_Stalker'))
      ZED_Stalker(other).TakeDamageClient(Damage, instigatedBy, other.Location + HitLocDiff, Momentum, DamageType, bIsHeadshot);
    else if (other.IsA('ZED_Siren'))
      ZED_Siren(other).TakeDamageClient(Damage, instigatedBy, other.Location + HitLocDiff, Momentum, DamageType, bIsHeadshot);
    else if (other.IsA('ZED_Husk'))
      ZED_Husk(other).TakeDamageClient(Damage, instigatedBy, other.Location + HitLocDiff, Momentum, DamageType, bIsHeadshot);
    else if (other.IsA('ZED_Scrake'))
      ZED_Scrake(other).TakeDamageClient(Damage, instigatedBy, other.Location + HitLocDiff, Momentum, DamageType, bIsHeadshot);
    else if (other.IsA('ZED_Fleshpound'))
      ZED_Fleshpound(other).TakeDamageClient(Damage, instigatedBy, other.Location + HitLocDiff, Momentum, DamageType, bIsHeadshot);
    else if (other.IsA('ZED_Patriarch'))
      ZED_Patriarch(other).TakeDamageClient(Damage, instigatedBy, other.Location + HitLocDiff, Momentum, DamageType, bIsHeadshot);
  }
  else
  {
    other.TakeDamage(Damage, instigatedBy, other.Location + HitLocDiff, Momentum, DamageType);
  }
}


simulated function ServerUpdateHit(Actor TPActor, Actor HitActor, Vector ClientHitLoc, Vector HitNormal, optional Vector HitLocDiff)
{
  local KFWeaponAttachment WeapAttach;

  WeapAttach = KFWeaponAttachment(TPActor);

  if (WeapAttach != none)
  {
    if (HitLocDiff == vect(0.0, 0.0, 0.0))
    {
      WeapAttach.UpdateHit(HitActor, ClientHitLoc, HitNormal);
    }
    else
    {
      WeapAttach.UpdateHit(HitActor, HitActor.Location + HitLocDiff, HitNormal);
    }
  }
}


simulated function ServerHealTarget(class<HealingProjectile> Dart, Actor other, Vector HitLocDiff)
{
  local KFPlayerReplicationInfo PRI;
  local KFHumanPawn Healed;
  local float HealSum;
  local int MedicReward;

  Healed = KFHumanPawn(other);

  if (Healed == none)
  {
    return;
  }

  if ((((Controller(Owner) != none) && Healed.Health > 0) && float(Healed.Health) < Healed.HealthMax) && Healed.bCanBeHealed)
  {
    MedicReward = Dart.default.HealBoostAmount;
    PRI = KFPlayerReplicationInfo(Controller(Owner).PlayerReplicationInfo);

    if ((PRI != none) && PRI.ClientVeteranSkill != none)
    {
      MedicReward *= PRI.ClientVeteranSkill.static.GetHealPotency(PRI);
    }
    HealSum = float(MedicReward);

    if (((float(Healed.Health) + Healed.healthToGive) + float(MedicReward)) > Healed.HealthMax)
    {
      MedicReward = int(Healed.HealthMax - (float(Healed.Health) + Healed.healthToGive));

      if (MedicReward < 0)
      {
        MedicReward = 0;
      }
    }
    Healed.GiveHealth(int(HealSum), int(Healed.HealthMax));

    if (PRI != none)
    {
      MedicReward = int((FMin(float(MedicReward), Healed.HealthMax) / Healed.HealthMax) * float(60));
      PRI.ReceiveRewardForHealing(MedicReward, Healed);

      if (KFHumanPawn(Controller(Owner).Pawn) != none)
      {
        KFHumanPawn(Controller(Owner).Pawn).AlphaAmount = 255;
      }

      if (KFMedicGun(Controller(Owner).Pawn.Weapon) != none)
      {
        KFMedicGun(Controller(Owner).Pawn.Weapon).ClientSuccessfulHeal(Healed.GetPlayerName());
      }
    }
  }
}