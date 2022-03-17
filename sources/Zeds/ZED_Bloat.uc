class ZED_Bloat extends ZombieBloat_STANDARD;


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


simulated function ToggleAuxCollision(bool newbCollision)
{
    if (MyExtCollision != none)
        super.ToggleAuxCollision(newbCollision);
}


function TakeDamageClient(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional bool bIsHeadshot)
{
    if (DamageType == class'DamTypeVomit')
        return;
    else if (DamageType == class'DamTypeBurned')
        Damage *= 1.50;
    else if (DamageType == class'DamTypeBlowerThrower')
        Damage *= 0.250;

    class'ZedUtility'.static.TakeDamageClientSrv(self, Damage, instigatedBy, HitLocation, Momentum, DamageType, bIsHeadshot);
}