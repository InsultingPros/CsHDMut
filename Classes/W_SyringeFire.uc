class W_SyringeFire extends SyringeFire;


function AttemptHeal()
{
  local KFHumanPawn Healtarget;
  local string HealeeName;

  CachedHealee = none;

  if ((AllowFire()) && CanFindHealee())
  {
    ModeDoFire();
    W_Syringe(Weapon).ServerSetCachedHealee(CachedHealee);
    W_Syringe(Weapon).ServerDoFire();

    if ((CachedHealee.PlayerReplicationInfo != none) && CachedHealee.PlayerReplicationInfo.PlayerName != "")
    {
      HealeeName = CachedHealee.PlayerReplicationInfo.PlayerName;
    }
    else
    {
      HealeeName = CachedHealee.MenuName;
    }

    if (PlayerController(Instigator.Controller) != none)
    {
      PlayerController(Instigator.Controller).ClientMessage(W_Syringe(Weapon).SuccessfulHealMessage $ HealeeName, 'CriticalEvent');
    }
  }
  else
  {
    if (KFPlayerController(Instigator.Controller) != none)
    {
      if ((LastHealAttempt + HealAttemptDelay) < Level.TimeSeconds)
      {
        PlayerController(Instigator.Controller).ClientMessage(NoHealTargetMessage, 'CriticalEvent');
        LastHealAttempt = Level.TimeSeconds;
      }

      if ((Level.TimeSeconds - LastHealMessageTime) > HealMessageDelay)
      {
        foreach Instigator.VisibleCollidingActors(class'KFHumanPawn', Healtarget, 100.0)
        {
          if ((Healtarget != Instigator) && float(Healtarget.Health) < Healtarget.HealthMax)
          {
            PlayerController(Instigator.Controller).Speech('Auto', 5, "");
            LastHealMessageTime = Level.TimeSeconds;
            break;
          }
        }
      }
    }
  }
}


function Timer()
{
  if (CachedHealee != none)
  {
    super.Timer();
  }
}


event ModeDoFire()
{
  if (Instigator.IsLocallyControlled())
  {
    AttemptHeal();
  }
  else
  {
    super(SyringeAltFire).ModeDoFire();
  }
}