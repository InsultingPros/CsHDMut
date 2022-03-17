class ZedUtility extends object
    abstract;


// spawn extended zed collision on client side for projector tracing (e.g., laser sights)
// NOTE: No special destroy code is needed. EZCollision is already destroyed on any zed that has it (not role-dependent).
final static function SpawnClientExtendedZCollision(KFMonster M)
{
    if (M.Role < ROLE_Authority)
    {
        if (M.bUseExtendedCollision && M.MyExtCollision == none)
        {
            M.MyExtCollision = M.spawn(class'ExtendedZCollision', M);
            M.MyExtCollision.SetCollisionSize(M.ColRadius, M.ColHeight);

            M.MyExtCollision.bHardAttach = true;
            M.MyExtCollision.SetLocation(M.Location + (M.ColOffset >> M.Rotation));
            M.MyExtCollision.SetPhysics(PHYS_None);
            M.MyExtCollision.SetBase(M);
            M.SavedExtCollision = M.MyExtCollision.bCollideActors;
        }
    }
}


final static function bool IsHeadshotClient(KFMonster KFM, Vector loc, Vector ray, optional float AdditionalScale)
{
    local Coords C;
    local Vector HeadLoc, M, diff;
    local float t, DotMM, Distance, adjustedScale;

    if (KFM.HeadBone == 'None')
    {
        return false;
    }
    C = KFM.GetBoneCoords(KFM.HeadBone);
    adjustedScale = 1.0 + (FClamp(AdditionalScale, 0.0, 1.0) * (FMax(1.0, KFM.OnlineHeadshotScale) - 1.0));
    HeadLoc = C.Origin + (((KFM.HeadHeight * KFM.HeadScale) * adjustedScale) * C.XAxis);
    M = (2.0 * (KFM.CollisionHeight + KFM.CollisionRadius)) * ray;
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

    return Distance < ((KFM.HeadRadius * KFM.HeadScale) * adjustedScale);
}


final static function TakeDamageClient(KFMonster M, int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
{
    local Vector hitRay, HitNormal, shotDir, PushLinVel, PushAngVel;
    local name HitBone;
    local float HitBoneDist;

    if (M.bFrozenBody || M.bRubbery)
        return;

    if (M.Physics == PHYS_KarmaRagDoll)
    {
        if (M.bDeRes)
            return;

        if (DamageType.default.bThrowRagdoll)
        {
            shotDir = Normal(Momentum);
            PushLinVel = (M.RagDeathVel * shotDir) + vect(0.0, 0.0, 250.0);
            PushAngVel = Normal(shotDir Cross vect(0.0, 0.0, 1.0)) * -18000;
            M.KSetSkelVel(PushLinVel, PushAngVel);
        }
        else
        {
            if (DamageType.default.bRagdollBullet)
            {
                if (Momentum == vect(0.0, 0.0, 0.0))
                    Momentum = HitLocation - instigatedBy.Location;

                if (FRand() < 0.650)
                {
                    if (M.Velocity.Z <= 0.0)
                    {
                        PushLinVel = vect(0.0, 0.0, 40.0);
                    }
                    PushAngVel = Normal(Normal(Momentum) Cross vect(0.0, 0.0, 1.0)) * -8000;
                    PushAngVel.X *= 0.50;
                    PushAngVel.Y *= 0.50;
                    PushAngVel.Z *= 4.0;
                    M.KSetSkelVel(PushLinVel, PushAngVel);
                }
                PushLinVel = M.RagShootStrength * Normal(Momentum);
                M.KAddImpulse(PushLinVel, HitLocation);

                if ((M.LifeSpan > 0.0) && M.LifeSpan < (M.DeResTime + 2.0))
                {
                    M.LifeSpan += 0.20;
                }
            }
            else
            {
                PushLinVel = M.RagShootStrength * Normal(Momentum);
                M.KAddImpulse(PushLinVel, HitLocation);
            }
        }
    }

    if (Damage > 0)
    {
        M.Health -= Damage;

        if (bIsHeadshot)
            M.RemoveHead();

        hitRay = vect(0.0, 0.0, 0.0);

        if (instigatedBy != none)
            hitRay = Normal((HitLocation - instigatedBy.Location) + (vect(0.0, 0.0, 1.0) * instigatedBy.EyeHeight));

        M.CalcHitLoc(HitLocation, hitRay, HitBone, HitBoneDist);

        if (instigatedBy != none)
            HitNormal = Normal((Normal(instigatedBy.Location - HitLocation) + (VRand() * 0.20)) + vect(0.0, 0.0, 2.80));
        else
            HitNormal = Normal((vect(0.0, 0.0, 1.0) + (VRand() * 0.20)) + vect(0.0, 0.0, 2.80));

        M.PlayHit(float(Damage), instigatedBy, HitLocation, DamageType, Momentum);
        M.DoDamageFX(HitBone, Damage, DamageType, rotator(HitNormal));
    }

    if (((DamageType.default.DamageOverlayMaterial != none) && M.Level.DetailMode != 0) && !M.Level.bDropDetail)
    {
        M.SetOverlayMaterial(DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true);
    }
}


final static function TakeDamageClientSrv(KFMonster M, int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
{
    local KFPlayerReplicationInfo KFPRI;

    M.LastDamagedBy = instigatedBy;
    M.LastDamagedByType = DamageType;
    M.HitMomentum = int(VSize(Momentum));
    M.LastHitLocation = HitLocation;
    M.LastMomentum = Momentum;

    if (KFPawn(instigatedBy) != none && instigatedBy.PlayerReplicationInfo != none)
        KFPRI = KFPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo);

    if (M.bZapped)
        Damage *= M.ZappedDamageMod;

    if (class<KFWeaponDamageType>(DamageType) != none && class<KFWeaponDamageType>(DamageType).default.bDealBurningDamage)
    {
        if (M.BurnDown <= 0 || Damage > M.LastBurnDamage)
        {
            M.LastBurnDamage = Damage;
            if (class<DamTypeTrenchgun>(DamageType) != none || class<DamTypeFlareRevolver>(DamageType) != none
                || class<DamTypeMAC10MPInc>(DamageType) != none)
                M.FireDamageClass = DamageType;
            else
                M.FireDamageClass = class'DamTypeFlamethrower';
        }

        if (class<DamTypeMAC10MPInc>(DamageType) == none)
            Damage *= 1.50;

        // End:0x1AF
        if (M.BurnDown <= 0)
        {
            if (M.HeatAmount > 4 || Damage >= 15)
            {
                M.bBurnified = true;
                M.BurnDown = 10;
                M.SetGroundSpeed(M.GroundSpeed * 0.80);
                M.BurnInstigator = instigatedBy;
                M.SetTimer(1.0, false);
            }
            else
                M.HeatAmount++;
        }
    }

    if (KFPRI != none && KFPRI.ClientVeteranSkill != none)
        Damage = KFPRI.ClientVeteranSkill.static.AddDamage(KFPRI, M, KFPawn(instigatedBy), Damage, DamageType);


    if (DamageType != none && M.LastDamagedBy.IsPlayerPawn() && M.LastDamagedBy.Controller != none && KFMonsterController(M.Controller) != none)
        KFMonsterController(M.Controller).AddKillAssistant(M.LastDamagedBy.Controller, FMin(float(M.Health), float(Damage)));


    if (((M.bDecapitated || bIsHeadshot) && class<DamTypeBurned>(DamageType) == none) && class<DamTypeFlamethrower>(DamageType) == none)
    {
        if (class<KFWeaponDamageType>(DamageType) != none)
            Damage *= class<KFWeaponDamageType>(DamageType).default.HeadShotDamageMult;

        if (class<DamTypeMelee>(DamageType) == none && KFPRI != none && KFPRI.ClientVeteranSkill != none)
        {
            Damage = int(float(Damage) * KFPRI.ClientVeteranSkill.static.GetHeadShotDamMulti(KFPRI, KFPawn(instigatedBy), DamageType));
        }
        M.LastDamageAmount = Damage;

        if (!M.bDecapitated && bIsHeadshot)
        {
            M.PlaySound(soundgroup'Impact_Skull', 0, 2.0, true, 500.0);
            M.HeadHealth -= float(M.LastDamageAmount);

            if (M.HeadHealth <= 0.0 || Damage > M.Health)
                M.RemoveHead();
        }
    }

    if (M.Health - Damage > 0
        && DamageType != class'DamTypeFrag' && DamageType != class'DamTypePipeBomb'
        && DamageType != class'DamTypeM79Grenade' && DamageType != class'DamTypeM32Grenade'
        && DamageType != class'DamTypeM203Grenade' && DamageType != class'DamTypeDwarfAxe'
        && DamageType != class'DamTypeSPGrenade' && DamageType != class'DamTypeSealSquealExplosion'
        && DamageType != class'DamTypeSeekerSixRocket')
    {
        Momentum = vect(0.0, 0.0, 0.0);
    }

    if (class<DamTypeVomit>(DamageType) != none)
    {
        M.BileCount = 7;
        M.BileInstigator = instigatedBy;
        M.LastBileDamagedByType = class<DamTypeVomit>(DamageType);

        if (M.NextBileTime < M.Level.TimeSeconds)
            M.NextBileTime = M.Level.TimeSeconds + M.BileFrequency;
    }

    M.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
}