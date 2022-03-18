class WeaponUtility extends object
    abstract;


final static function CsHDReplicationInfo GetCsHDRI(KFFire F)
{
    if (F.Instigator != none && CsHDPlayerController(F.Instigator.Controller) != none)
        return CsHDPlayerController(F.Instigator.Controller).CsHDRI;

    return none;
}


// trace for usual, non-penetrating weapons
final static function DoTraceClient(KFFire F, Vector Start, Rotator Dir)
{
    local CsHDReplicationInfo CsHDRI;
    local Vector X, Y, Z, End, HitLoc, HitNorm, ArcEnd, HitLocDiff;
    local Actor Other;
    local array<int> HitPoints;
    local KFPawn HitPawn;
    local KFMonster ZED;
    local bool bIsHeadshot;

    if (CsHDRI == none)
    {
        CsHDRI = GetCsHDRI(F);
        if (CsHDRI == none)
            return;
    }
    F.MaxRange();
    F.Weapon.GetViewAxes(X, Y, Z);

    if (F.Weapon.WeaponCentered())
        ArcEnd = (F.Instigator.Location + (F.Weapon.EffectOffset.X * X)) + ((1.50 * F.Weapon.EffectOffset.Z) * Z);
    else
        ArcEnd = (((F.Instigator.Location + F.Instigator.CalcDrawOffset(F.Weapon)) + (F.Weapon.EffectOffset.X * X)) + ((F.Weapon.hand * F.Weapon.EffectOffset.Y) * Y)) + (F.Weapon.EffectOffset.Z * Z);

    X = vector(Dir);
    End = Start + (F.TraceRange * X);
    Other = F.Instigator.HitPointTrace(HitLoc, HitNorm, End, HitPoints, Start,, 1);

    if (((Other != none) && Other != F.Instigator) && Other.Base != F.Instigator)
    {
        if (!Other.bWorldGeometry)
        {
            HitLocDiff = HitLoc - Other.Location;

            if ((!Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume')) && !Other.IsA('ExtendedZCollision'))
                CsHDRI.ServerUpdateHit(F.Weapon.ThirdPersonActor, Other, HitLoc, HitNorm, HitLocDiff);

            HitPawn = KFPawn(Other);

            if (HitPawn != none)
            {
                if (!HitPawn.bDeleteMe)
                    CsHDRI.ServerDamagePawn(HitPawn, F.DamageMax, F.Instigator, HitLocDiff, F.Momentum * X, F.DamageType, HitPoints);
            }
            else
            {
                if (ExtendedZCollision(Other) != none)
                    ZED = KFMonster(Other.Base);
                else
                    ZED = KFMonster(Other);

                if (ZED != none)
                {
                    bIsHeadshot = CsHDRI.IsHeadshotClient(ZED, HitLoc, Normal(F.Momentum * X));
                    CsHDRI.ServerDealDamage(ZED, F.DamageMax, F.Instigator, HitLocDiff, F.Momentum * X, F.DamageType, bIsHeadshot);
                }
                else
                    CsHDRI.ServerDealDamage(Other, F.DamageMax, F.Instigator, HitLocDiff, F.Momentum * X, F.DamageType);
            }
        }
        else
        {
            HitLoc = HitLoc + (2.0 * HitNorm);
            CsHDRI.ServerUpdateHit(F.Weapon.ThirdPersonActor, Other, HitLoc, HitNorm);
        }
    }
    else
    {
        HitLoc = End;
        HitNorm = Normal(Start - End);
    }
}


// Trace for penetrating weapons (mostly pistols, aye)
final static function DoTraceClientPen(KFFire F, Vector Start, Rotator Dir, byte penCount, float penDamReduction)
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
        CsHDRI = GetCsHDRI(F);
        if (CsHDRI == none)
            return;
    }
    F.MaxRange();
    F.Weapon.GetViewAxes(X, Y, Z);

    if (F.Weapon.WeaponCentered())
        ArcEnd = (F.Instigator.Location + (F.Weapon.EffectOffset.X * X)) + ((1.50 * F.Weapon.EffectOffset.Z) * Z);
    else
        ArcEnd = (((F.Instigator.Location + F.Instigator.CalcDrawOffset(F.Weapon)) + (F.Weapon.EffectOffset.X * X)) + ((F.Weapon.hand * F.Weapon.EffectOffset.Y) * Y)) + (F.Weapon.EffectOffset.Z * Z);

    X = vector(Dir);
    End = Start + (F.TraceRange * X);
    hitdamage = float(F.DamageMax);

    while (HitCount++ < penCount)
    {
        DamageActor = none;
        Other = F.Instigator.HitPointTrace(HitLoc, HitNorm, End, HitPoints, Start,, 1);

        if (Other == none)
            break;
        else
        {
            if (Other == F.Instigator || Other.Base == F.Instigator)
            {
                IgnoreActors[IgnoreActors.Length] = Other;
                Other.SetCollision(false);
                Start = HitLoc;
                continue;
            }
        }
        if (ExtendedZCollision(Other) != none && Other.Owner != none)
        {
            IgnoreActors[IgnoreActors.Length] = Other;
            IgnoreActors[IgnoreActors.Length] = Other.Owner;
            Other.SetCollision(false);
            Other.Owner.SetCollision(false);
            DamageActor = Pawn(Other.Owner);
        }

        if (!Other.bWorldGeometry && Other != F.Level)
        {
            HitLocDiff = HitLoc - Other.Location;
            HitPawn = KFPawn(Other);

            if (HitPawn != none)
            {
                if (!HitPawn.bDeleteMe)
                    CsHDRI.ServerDamagePawn(HitPawn, int(hitdamage), F.Instigator, HitLocDiff, F.Momentum * X, F.DamageType, HitPoints);

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
                        DamageActor = Other;
                }

                if (KFMonster(DamageActor) != none)
                {
                    bIsHeadshot = CsHDRI.IsHeadshotClient(DamageActor, HitLoc, Normal(F.Momentum * X));
                    CsHDRI.ServerDealDamage(DamageActor, int(hitdamage), F.Instigator, HitLocDiff, F.Momentum * X, F.DamageType, bIsHeadshot);
                }
                else
                    CsHDRI.ServerDealDamage(Other, int(hitdamage), F.Instigator, HitLocDiff, F.Momentum * X, F.DamageType);
            }

            if (Pawn(DamageActor) == none)
                break;
            hitdamage *= penDamReduction;
            Start = HitLoc;
            continue;
        }

        if (HitScanBlockingVolume(Other) == none)
        {
            CsHDRI.ServerUpdateHit(F.Weapon.ThirdPersonActor, Other, HitLoc, HitNorm);
            break;
        }
    }

    if (IgnoreActors.Length > 0)
    {
        for (i = 0; i < IgnoreActors.Length; i++)
        {
            // check for non actors to prevent log spam!
            if (IgnoreActors[i] != none)
                IgnoreActors[i].SetCollision(true);
        }
    }
}