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


state ZombieDying
{
ignores BreathTimer, Died, RangedAttack;

    simulated function TakeDamageClient(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
    {
        class'ZedUtility'.static.TakeDamageClient(self, Damage, instigatedBy, HitLocation, Momentum, DamageType, bIsHeadshot);
    }
}


function TakeDamageClient(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
{
    local float DamagerDistSq, UsedPipeBombDamScale;
    local KFHumanPawn P;
    local int NumPlayersSurrounding;
    local bool bDidRadialAttack;

    if (((Level.TimeSeconds - LastMeleeExploitCheckTime) > 1.0) && (class<DamTypeMelee>(DamageType) != none) || class<KFProjectileWeaponDamageType>(DamageType) != none)
    {
        LastMeleeExploitCheckTime = Level.TimeSeconds;
        NumLumberJacks = 0;
        NumNinjas = 0;

        foreach DynamicActors(class'KFHumanPawn', P)
        {
            if (VSize(P.Location - Location) < 150)
            {
                NumPlayersSurrounding++;
                if (P != none && P.Weapon != none)
                {
                    if (Axe(P.Weapon) != none || Chainsaw(P.Weapon) != none)
                        NumLumberJacks++;
                    else if(Katana(P.Weapon) != none)
                        NumNinjas++;
                }

                if (!bDidRadialAttack && NumPlayersSurrounding >= 3)
                {
                    bDidRadialAttack = true;
                    GotoState('RadialAttack');
                    break;
                }
            }
        }
    }

    if (class<DamTypeCrossbow>(DamageType) == none && class<DamTypeCrossbowHeadShot>(DamageType) == none)
        bOnlyDamagedByCrossbow = false;

    if (class<DamTypePipeBomb>(DamageType) != none)
    {
        UsedPipeBombDamScale = FMax(0.0, 1.0 - PipeBombDamageScale);
        PipeBombDamageScale += 0.0750;
        if (PipeBombDamageScale > 1.0)
            PipeBombDamageScale = 1.0;
        Damage *= UsedPipeBombDamScale;
    }

    class'ZedUtility'.static.TakeDamageClientSrv(self, Damage, instigatedBy, HitLocation, Momentum, DamageType, bIsHeadshot);

    if (Level.TimeSeconds - LastDamageTime > 10)
        ChargeDamage = 0.0;
    else
    {
        LastDamageTime = Level.TimeSeconds;
        ChargeDamage += float(Damage);
    }

    if (ShouldChargeFromDamage() && ChargeDamage > 200)
    {
        if (instigatedBy != none)
        {
            DamagerDistSq = VSizeSquared(Location - instigatedBy.Location);
            if (DamagerDistSq < 700 * 700)
            {
                SetAnimAction('Transition');
                ChargeDamage = 0.0;
                LastForceChargeTime = Level.TimeSeconds;
                GotoState('Charging');
                return;
            }
        }
    }

    if (Health <= 0 || SyringeCount == 3 || IsInState('Escaping') || IsInState('KnockDown')
        || IsInState('RadialAttack') || bDidRadialAttack)
    {
        return;
    }

    if ((SyringeCount == 0 && Health < HealingLevels[0]) || (SyringeCount == 1 && Health < HealingLevels[1]) || (SyringeCount == 2 && Health < HealingLevels[2]))
    {
        bShotAnim = true;
        Acceleration = vect(0.0, 0.0, 0.0);
        SetAnimAction('KnockDown');
        HandleWaitForAnim('KnockDown');
        KFMonsterController(Controller).bUseFreezeHack = true;
        GotoState('KnockDown');
    }
}


state FireChaingun
{
    function TakeDamageClient(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
    {
        local float EnemyDistSq, DamagerDistSq;

        global.TakeDamageClient(Damage, instigatedBy, HitLocation, Momentum, DamageType, bIsHeadshot);

        if (instigatedBy != none)
        {
            DamagerDistSq = VSizeSquared(Location - instigatedBy.Location);

            if ((ChargeDamage > 200 && DamagerDistSq < (500 * 500)) || DamagerDistSq < (100 * 100))
            {
                SetAnimAction('Transition');
                GotoState('Charging');
                return;
            }
        }

        if (Controller.Enemy != none && instigatedBy != none && instigatedBy != Controller.Enemy)
        {
            EnemyDistSq = VSizeSquared(Location - Controller.Enemy.Location);
            DamagerDistSq = VSizeSquared(Location - instigatedBy.Location);
        }

        if (instigatedBy != none && (DamagerDistSq < EnemyDistSq || Controller.Enemy == none))
        {
            MonsterController(Controller).ChangeEnemy(instigatedBy, Controller.CanSee(instigatedBy));
            Controller.Target = instigatedBy;
            Controller.Focus = instigatedBy;

            if (DamagerDistSq < (500 * 500))
            {
                SetAnimAction('Transition');
                GotoState('Charging');
            }
        }
    }
    // stop;
}