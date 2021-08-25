class ZED_Bloat extends ZombieBloat_STANDARD;


simulated function PostBeginPlay()
{
    local Vector AttachPos;

    super(KFMonster).PostBeginPlay();
    // End:0xBE
    if(Role < ROLE_Authority)
    {
        // End:0xBE
        if(bUseExtendedCollision && MyExtCollision == none)
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
    //return;    
}

simulated function bool IsHeadshotClient(Vector loc, Vector ray, optional float AdditionalScale)
{
    local Coords C;
    local Vector HeadLoc, M, diff;
    local float t, DotMM, Distance, adjustedScale;

    // End:0x11
    if(HeadBone == 'None')
    {
        return false;
    }
    C = GetBoneCoords(HeadBone);
    adjustedScale = 1.0 + (FClamp(AdditionalScale, 0.0, 1.0) * (FMax(1.0, OnlineHeadshotScale) - 1.0));
    HeadLoc = C.Origin + (((HeadHeight * HeadScale) * adjustedScale) * C.XAxis);
    M = (2.0 * (CollisionHeight + CollisionRadius)) * ray;
    diff = HeadLoc - loc;
    t = M Dot diff;
    // End:0x121
    if(t > float(0))
    {
        DotMM = M Dot M;
        // End:0x115
        if(t < DotMM)
        {
            diff -= ((t / DotMM) * M);
        }
        // End:0x121
        else
        {
            diff -= M;
        }
    }
    Distance = Sqrt(diff Dot diff);
    return Distance < ((HeadRadius * HeadScale) * adjustedScale);
    //return;    
}

function TakeDamageClient(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
{
    local KFPlayerReplicationInfo KFPRI;

    // End:0x14
    if(DamageType == class'DamTypeVomit')
    {
        return;
    }
    // End:0x4D
    else
    {
        // End:0x32
        if(DamageType == class'DamTypeBurned')
        {
            Damage *= 1.50;
        }
        // End:0x4D
        else
        {
            // End:0x4D
            if(DamageType == class'DamTypeBlowerThrower')
            {
                Damage *= 0.250;
            }
        }
    }
    LastDamagedBy = instigatedBy;
    LastDamagedByType = DamageType;
    HitMomentum = int(VSize(Momentum));
    LastHitLocation = HitLocation;
    LastMomentum = Momentum;
    // End:0xC7
    if((KFPawn(instigatedBy) != none) && instigatedBy.PlayerReplicationInfo != none)
    {
        KFPRI = KFPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo);
    }
    // End:0xDC
    if(bZapped)
    {
        Damage *= ZappedDamageMod;
    }
    // End:0x1FC
    if((class<KFWeaponDamageType>(DamageType) != none) && class<KFWeaponDamageType>(DamageType).default.bDealBurningDamage)
    {
        // End:0x179
        if((BurnDown <= 0) || Damage > LastBurnDamage)
        {
            LastBurnDamage = Damage;
            // End:0x16E
            if(((class<DamTypeTrenchgun>(DamageType) != none) || class<DamTypeFlareRevolver>(DamageType) != none) || class<DamTypeMAC10MPInc>(DamageType) != none)
            {
                FireDamageClass = DamageType;
            }
            // End:0x179
            else
            {
                FireDamageClass = class'DamTypeFlamethrower';
            }
        }
        // End:0x195
        if(class<DamTypeMAC10MPInc>(DamageType) == none)
        {
            Damage *= 1.50;
        }
        // End:0x1FC
        if(BurnDown <= 0)
        {
            // End:0x1F5
            if((HeatAmount > 4) || Damage >= 15)
            {
                bBurnified = true;
                BurnDown = 10;
                SetGroundSpeed(GroundSpeed * 0.80);
                BurnInstigator = instigatedBy;
                SetTimer(1.0, false);
            }
            // End:0x1FC
            else
            {
                ++ HeatAmount;
            }
        }
    }
    // End:0x255
    if((KFPRI != none) && KFPRI.ClientVeteranSkill != none)
    {
        Damage = KFPRI.ClientVeteranSkill.static.AddDamage(KFPRI, self, KFPawn(instigatedBy), Damage, DamageType);
    }
    // End:0x2CC
    if(((DamageType != none) && LastDamagedBy.IsPlayerPawn()) && LastDamagedBy.Controller != none)
    {
        // End:0x2CC
        if(KFMonsterController(Controller) != none)
        {
            KFMonsterController(Controller).AddKillAssistant(LastDamagedBy.Controller, FMin(float(Health), float(Damage)));
        }
    }
    // End:0x406
    if(((bDecapitated || bIsHeadshot) && class<DamTypeBurned>(DamageType) == none) && class<DamTypeFlamethrower>(DamageType) == none)
    {
        // End:0x32E
        if(class<KFWeaponDamageType>(DamageType) != none)
        {
            Damage *= class<KFWeaponDamageType>(DamageType).default.HeadShotDamageMult;
        }
        // End:0x39E
        if(((class<DamTypeMelee>(DamageType) == none) && KFPRI != none) && KFPRI.ClientVeteranSkill != none)
        {
            Damage = int(float(Damage) * KFPRI.ClientVeteranSkill.static.GetHeadShotDamMulti(KFPRI, KFPawn(instigatedBy), DamageType));
        }
        LastDamageAmount = Damage;
        // End:0x406
        if(!bDecapitated && bIsHeadshot)
        {
            PlaySound(soundgroup'Impact_Skull', 0, 2.0, true, 500.0);
            HeadHealth -= float(LastDamageAmount);
            // End:0x406
            if((HeadHealth <= float(0)) || Damage > Health)
            {
                RemoveHead();
            }
        }
    }
    // End:0x4C4
    if(((((((((((Health - Damage) > 0) && DamageType != class'DamTypeFrag') && DamageType != class'DamTypePipeBomb') && DamageType != class'DamTypeM79Grenade') && DamageType != class'DamTypeM32Grenade') && DamageType != class'DamTypeM203Grenade') && DamageType != class'DamTypeDwarfAxe') && DamageType != class'DamTypeSPGrenade') && DamageType != class'DamTypeSealSquealExplosion') && DamageType != class'DamTypeSeekerSixRocket')
    {
        Momentum = vect(0.0, 0.0, 0.0);
    }
    // End:0x52A
    if(class<DamTypeVomit>(DamageType) != none)
    {
        BileCount = 7;
        BileInstigator = instigatedBy;
        LastBileDamagedByType = class<DamTypeVomit>(DamageType);
        // End:0x52A
        if(NextBileTime < Level.TimeSeconds)
        {
            NextBileTime = Level.TimeSeconds + BileFrequency;
        }
    }
    TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
    //return;    
}

simulated function ToggleAuxCollision(bool newbCollision)
{
    // End:0x17
    if(MyExtCollision != none)
    {
        super(KFMonster).ToggleAuxCollision(newbCollision);
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
