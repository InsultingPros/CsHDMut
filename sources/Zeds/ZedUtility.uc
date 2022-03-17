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