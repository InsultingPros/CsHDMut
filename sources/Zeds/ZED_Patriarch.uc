class ZED_Patriarch extends ZombieBoss_STANDARD;


simulated function PostBeginPlay()
{
    super.PostBeginPlay();

    class'ZedUtility'.static.SpawnClientExtendedZCollision(self);
}


simulated function bool IsHeadshotClient(Vector loc, Vector ray, optional float AdditionalScale)
{
    return class'ZedUtility'.static.IsHeadshotClient(self, loc, ray, AdditionalScale);
}

function TakeDamageClient(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
{
    local KFPlayerReplicationInfo KFPRI;
    local float DamagerDistSq, UsedPipeBombDamScale;
    local KFHumanPawn P;
    local int NumPlayersSurrounding;
    local bool bDidRadialAttack;

    // End:0x148
    if(((Level.TimeSeconds - LastMeleeExploitCheckTime) > 1.0) && (class<DamTypeMelee>(DamageType) != none) || class<KFProjectileWeaponDamageType>(DamageType) != none)
    {
        LastMeleeExploitCheckTime = Level.TimeSeconds;
        NumLumberJacks = 0;
        NumNinjas = 0;
        // End:0x147
        foreach DynamicActors(class'KFHumanPawn', P)
        {
            // End:0x146
            if(VSize(P.Location - Location) < float(150))
            {
                ++ NumPlayersSurrounding;
                // End:0x11B
                if((P != none) && P.Weapon != none)
                {
                    // End:0xFB
                    if((Axe(P.Weapon) != none) || Chainsaw(P.Weapon) != none)
                    {
                        ++ NumLumberJacks;
                    }
                    // End:0x11B
                    else
                    {
                        // End:0x11B
                        if(Katana(P.Weapon) != none)
                        {
                            ++ NumNinjas;
                        }
                    }
                }
                // End:0x146
                if(!bDidRadialAttack && NumPlayersSurrounding >= 3)
                {
                    bDidRadialAttack = true;
                    GotoState('RadialAttack');
                    // End:0x147
                    break;
                }
            }
        }
    }
    // End:0x172
    if((class<DamTypeCrossbow>(DamageType) == none) && class<DamTypeCrossbowHeadShot>(DamageType) == none)
    {
        bOnlyDamagedByCrossbow = false;
    }
    // End:0x1CD
    if(class<DamTypePipeBomb>(DamageType) != none)
    {
        UsedPipeBombDamScale = FMax(0.0, 1.0 - PipeBombDamageScale);
        PipeBombDamageScale += 0.0750;
        // End:0x1C1
        if(PipeBombDamageScale > 1.0)
        {
            PipeBombDamageScale = 1.0;
        }
        Damage *= UsedPipeBombDamScale;
    }
    LastDamagedBy = instigatedBy;
    LastDamagedByType = DamageType;
    HitMomentum = int(VSize(Momentum));
    LastHitLocation = HitLocation;
    LastMomentum = Momentum;
    // End:0x247
    if((KFPawn(instigatedBy) != none) && instigatedBy.PlayerReplicationInfo != none)
    {
        KFPRI = KFPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo);
    }
    // End:0x25C
    if(bZapped)
    {
        Damage *= ZappedDamageMod;
    }
    // End:0x37C
    if((class<KFWeaponDamageType>(DamageType) != none) && class<KFWeaponDamageType>(DamageType).default.bDealBurningDamage)
    {
        // End:0x2F9
        if((BurnDown <= 0) || Damage > LastBurnDamage)
        {
            LastBurnDamage = Damage;
            // End:0x2EE
            if(((class<DamTypeTrenchgun>(DamageType) != none) || class<DamTypeFlareRevolver>(DamageType) != none) || class<DamTypeMAC10MPInc>(DamageType) != none)
            {
                FireDamageClass = DamageType;
            }
            // End:0x2F9
            else
            {
                FireDamageClass = class'DamTypeFlamethrower';
            }
        }
        // End:0x315
        if(class<DamTypeMAC10MPInc>(DamageType) == none)
        {
            Damage *= 1.50;
        }
        // End:0x37C
        if(BurnDown <= 0)
        {
            // End:0x375
            if((HeatAmount > 4) || Damage >= 15)
            {
                bBurnified = true;
                BurnDown = 10;
                SetGroundSpeed(GroundSpeed * 0.80);
                BurnInstigator = instigatedBy;
                SetTimer(1.0, false);
            }
            // End:0x37C
            else
            {
                ++ HeatAmount;
            }
        }
    }
    // End:0x3D5
    if((KFPRI != none) && KFPRI.ClientVeteranSkill != none)
    {
        Damage = KFPRI.ClientVeteranSkill.static.AddDamage(KFPRI, self, KFPawn(instigatedBy), Damage, DamageType);
    }
    // End:0x44C
    if(((DamageType != none) && LastDamagedBy.IsPlayerPawn()) && LastDamagedBy.Controller != none)
    {
        // End:0x44C
        if(KFMonsterController(Controller) != none)
        {
            KFMonsterController(Controller).AddKillAssistant(LastDamagedBy.Controller, FMin(float(Health), float(Damage)));
        }
    }
    // End:0x586
    if(((bDecapitated || bIsHeadshot) && class<DamTypeBurned>(DamageType) == none) && class<DamTypeFlamethrower>(DamageType) == none)
    {
        // End:0x4AE
        if(class<KFWeaponDamageType>(DamageType) != none)
        {
            Damage *= class<KFWeaponDamageType>(DamageType).default.HeadShotDamageMult;
        }
        // End:0x51E
        if(((class<DamTypeMelee>(DamageType) == none) && KFPRI != none) && KFPRI.ClientVeteranSkill != none)
        {
            Damage = int(float(Damage) * KFPRI.ClientVeteranSkill.static.GetHeadShotDamMulti(KFPRI, KFPawn(instigatedBy), DamageType));
        }
        LastDamageAmount = Damage;
        // End:0x586
        if(!bDecapitated && bIsHeadshot)
        {
            PlaySound(soundgroup'Impact_Skull', 0, 2.0, true, 500.0);
            HeadHealth -= float(LastDamageAmount);
            // End:0x586
            if((HeadHealth <= float(0)) || Damage > Health)
            {
                RemoveHead();
            }
        }
    }
    // End:0x644
    if(((((((((((Health - Damage) > 0) && DamageType != class'DamTypeFrag') && DamageType != class'DamTypePipeBomb') && DamageType != class'DamTypeM79Grenade') && DamageType != class'DamTypeM32Grenade') && DamageType != class'DamTypeM203Grenade') && DamageType != class'DamTypeDwarfAxe') && DamageType != class'DamTypeSPGrenade') && DamageType != class'DamTypeSealSquealExplosion') && DamageType != class'DamTypeSeekerSixRocket')
    {
        Momentum = vect(0.0, 0.0, 0.0);
    }
    // End:0x6AA
    if(class<DamTypeVomit>(DamageType) != none)
    {
        BileCount = 7;
        BileInstigator = instigatedBy;
        LastBileDamagedByType = class<DamTypeVomit>(DamageType);
        // End:0x6AA
        if(NextBileTime < Level.TimeSeconds)
        {
            NextBileTime = Level.TimeSeconds + BileFrequency;
        }
    }
    TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
    // End:0x6F5
    if((Level.TimeSeconds - LastDamageTime) > float(10))
    {
        ChargeDamage = 0.0;
    }
    // End:0x717
    else
    {
        LastDamageTime = Level.TimeSeconds;
        ChargeDamage += float(Damage);
    }
    // End:0x7A7
    if((ShouldChargeFromDamage()) && ChargeDamage > float(200))
    {
        // End:0x7A7
        if(instigatedBy != none)
        {
            DamagerDistSq = VSizeSquared(Location - instigatedBy.Location);
            // End:0x7A7
            if(DamagerDistSq < float(700 * 700))
            {
                SetAnimAction('Transition');
                ChargeDamage = 0.0;
                LastForceChargeTime = Level.TimeSeconds;
                GotoState('Charging');
                return;
            }
        }
    }
    // End:0x7F6
    if((((((Health <= 0) || SyringeCount == 3) || IsInState('Escaping')) || IsInState('KnockDown')) || IsInState('RadialAttack')) || bDidRadialAttack)
    {
        return;
    }
    // End:0x8AA
    if((((SyringeCount == 0) && Health < HealingLevels[0]) || (SyringeCount == 1) && Health < HealingLevels[1]) || (SyringeCount == 2) && Health < HealingLevels[2])
    {
        bShotAnim = true;
        Acceleration = vect(0.0, 0.0, 0.0);
        SetAnimAction('KnockDown');
        HandleWaitForAnim('KnockDown');
        KFMonsterController(Controller).bUseFreezeHack = true;
        GotoState('KnockDown');
    }
    //return;
}

state ZombieDying
{
    ignores BreathTimer, Died, RangedAttack;

    simulated function TakeDamageClient(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
    {
        local Vector hitRay, HitNormal, shotDir, PushLinVel, PushAngVel;

        local name HitBone;
        local float HitBoneDist;

        // End:0x16
        if(bFrozenBody || bRubbery)
        {
            return;
        }
        // End:0x203
        if(Physics == 14)
        {
            // End:0x31
            if(bDeRes)
            {
                return;
            }
            // End:0xA9
            if(DamageType.default.bThrowRagdoll)
            {
                shotDir = Normal(Momentum);
                PushLinVel = (RagDeathVel * shotDir) + vect(0.0, 0.0, 250.0);
                PushAngVel = Normal(shotDir Cross vect(0.0, 0.0, 1.0)) * float(-18000);
                KSetSkelVel(PushLinVel, PushAngVel);
            }
            // End:0x203
            else
            {
                // End:0x1DF
                if(DamageType.default.bRagdollBullet)
                {
                    // End:0xED
                    if(Momentum == vect(0.0, 0.0, 0.0))
                    {
                        Momentum = HitLocation - instigatedBy.Location;
                    }
                    // End:0x187
                    if(FRand() < 0.650)
                    {
                        // End:0x11E
                        if(Velocity.Z <= float(0))
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
                    // End:0x1DC
                    if((LifeSpan > float(0)) && LifeSpan < (DeResTime + 2.0))
                    {
                        LifeSpan += 0.20;
                    }
                }
                // End:0x203
                else
                {
                    PushLinVel = RagShootStrength * Normal(Momentum);
                    KAddImpulse(PushLinVel, HitLocation);
                }
            }
        }
        // End:0x350
        if(Damage > 0)
        {
            Health -= Damage;
            // End:0x229
            if(bIsHeadshot)
            {
                RemoveHead();
            }
            hitRay = vect(0.0, 0.0, 0.0);
            // End:0x283
            if(instigatedBy != none)
            {
                hitRay = Normal((HitLocation - instigatedBy.Location) + (vect(0.0, 0.0, 1.0) * instigatedBy.EyeHeight));
            }
            CalcHitLoc(HitLocation, hitRay, HitBone, HitBoneDist);
            // End:0x2E4
            if(instigatedBy != none)
            {
                HitNormal = Normal((Normal(instigatedBy.Location - HitLocation) + (VRand() * 0.20)) + vect(0.0, 0.0, 2.80));
            }
            // End:0x313
            else
            {
                HitNormal = Normal((vect(0.0, 0.0, 1.0) + (VRand() * 0.20)) + vect(0.0, 0.0, 2.80));
            }
            PlayHit(float(Damage), instigatedBy, HitLocation, DamageType, Momentum);
            DoDamageFX(HitBone, Damage, DamageType, rotator(HitNormal));
        }
        // End:0x3B8
        if(((DamageType.default.DamageOverlayMaterial != none) && Level.DetailMode != 0) && !Level.bDropDetail)
        {
            SetOverlayMaterial(DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true);
        }
        //return;
    }
    stop;
}

state FireChaingun
{
    function TakeDamageClient(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
    {
        local float EnemyDistSq, DamagerDistSq;

        global.TakeDamageClient(Damage, instigatedBy, HitLocation, Momentum, DamageType, bIsHeadshot);
        // End:0xA1
        if(instigatedBy != none)
        {
            DamagerDistSq = VSizeSquared(Location - instigatedBy.Location);
            // End:0xA1
            if(((ChargeDamage > float(200)) && DamagerDistSq < float(500 * 500)) || DamagerDistSq < float(100 * 100))
            {
                SetAnimAction('Transition');
                GotoState('Charging');
                return;
            }
        }
        // End:0x127
        if(((Controller.Enemy != none) && instigatedBy != none) && instigatedBy != Controller.Enemy)
        {
            EnemyDistSq = VSizeSquared(Location - Controller.Enemy.Location);
            DamagerDistSq = VSizeSquared(Location - instigatedBy.Location);
        }
        // End:0x1D5
        if((instigatedBy != none) && (DamagerDistSq < EnemyDistSq) || Controller.Enemy == none)
        {
            MonsterController(Controller).ChangeEnemy(instigatedBy, Controller.CanSee(instigatedBy));
            Controller.Target = instigatedBy;
            Controller.Focus = instigatedBy;
            // End:0x1D5
            if(DamagerDistSq < float(500 * 500))
            {
                SetAnimAction('Transition');
                GotoState('Charging');
            }
        }
        //return;
    }
    stop;
}
