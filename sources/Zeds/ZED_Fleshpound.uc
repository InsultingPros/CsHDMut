class ZED_Fleshpound extends ZombieFleshPound_STANDARD;


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
    local int OldHealth;
    local Vector X, Y, Z;

    GetAxes(Rotation, X, Y, Z);

    if (LastDamagedTime < Level.TimeSeconds)
        TwoSecondDamageTotal = 0;
    LastDamagedTime = Level.TimeSeconds + 2.0;
    OldHealth = Health;

    if (DamageType != class'DamTypeFrag' && DamageType != class'DamTypeLAW'
        && DamageType != class'DamTypePipeBomb' && DamageType != class'DamTypeM79Grenade'
        && DamageType != class'DamTypeM32Grenade' && DamageType != class'DamTypeM203Grenade'
        && DamageType != class'DamTypeMedicNade' && DamageType != class'DamTypeSPGrenade'
        && DamageType != class'DamTypeSealSquealExplosion' && DamageType != class'DamTypeSeekerSixRocket')
    {
        if (bIsHeadshot && class<KFWeaponDamageType>(DamageType) != none && class<KFWeaponDamageType>(DamageType).default.HeadShotDamageMult >= 1.50)
            Damage *= 0.750;
        else if (Level.Game.GameDifficulty >= 5.0 && bIsHeadshot && (class<DamTypeCrossbow>(DamageType) != none || class<DamTypeCrossbowHeadShot>(DamageType) != none))
            Damage *= 0.350;
        else
            Damage *= 0.50;
    }
    else if (DamageType == class'DamTypeFrag' || DamageType == class'DamTypePipeBomb' || DamageType == class'DamTypeMedicNade')
        Damage *= 2.0;
    else if (DamageType == class'DamTypeM79Grenade' || DamageType == class'DamTypeM32Grenade'
             || DamageType == class'DamTypeM203Grenade' || DamageType == class'DamTypeSPGrenade'
             || DamageType == class'DamTypeSealSquealExplosion' || DamageType == class'DamTypeSeekerSixRocket')
        Damage *= 1.250;

    if (Damage >= Health)
        PostNetReceive();

    if (DamageType == class'DamTypeVomit')
        Damage = 0;
    else if(DamageType == class'DamTypeBlowerThrower')
        Damage *= 0.250;

    class'ZedUtility'.static.TakeDamageClientSrv(self, Damage, instigatedBy, HitLocation, Momentum, DamageType, bIsHeadshot);

    TwoSecondDamageTotal += (OldHealth - Health);
    if (!bDecapitated && TwoSecondDamageTotal > RageDamageThreshold && !bChargingPlayer && !bZapped && (!(bCrispified && bBurnified) || bFrustrated))
        StartCharging();
}