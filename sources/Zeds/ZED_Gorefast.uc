class ZED_Gorefast extends ZombieGoreFast_STANDARD;


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
    class'ZedUtility'.static.TakeDamageClientSrv(self, Damage, instigatedBy, HitLocation, Momentum, DamageType, bIsHeadshot);
}