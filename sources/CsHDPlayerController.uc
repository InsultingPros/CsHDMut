class CsHDPlayerController extends KFPlayerController
  config(User)
  dependson(CsHDMut);


var CsHDReplicationInfo CsHDRI;
var string BuyMenuClassName;


replication
{
  reliable if (bNetInitial && Role == ROLE_Authority)
    CsHDRI;
}


event PostBeginPlay()
{
  super.PostBeginPlay();
  
  if (((Role == ROLE_Authority) && !bDeleteMe) && bIsPlayer)
  {
    CsHDRI = spawn(class'CsHDReplicationInfo', self);
  }
}


simulated event Destroyed()
{
  if (Role == ROLE_Authority)
  {
    if (CsHDRI != none)
    {
      CsHDRI.Destroyed();
    }
  }

  super(PlayerController).Destroyed();
}


function SetPawnClass(string inClass, string InCharacter)
{
  PawnClass = default.PawnClass;
  InCharacter = class'KFGameType'.static.GetValidCharacter(InCharacter);
  PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(InCharacter);
  PlayerReplicationInfo.SetCharacterName(InCharacter);
}


function SelectVeterancy(class<KFVeterancyTypes> VetSkill, optional bool bForceChange)
{
  local KFPlayerReplicationInfo PRI;

  if (((VetSkill == none) || KFPlayerReplicationInfo(PlayerReplicationInfo) == none) || KFSteamStatsAndAchievements(SteamStatsAndAchievements) == none)
  {
    return;
  }
  SetSelectedVeterancy(VetSkill);
  PRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

  if (KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress && !ClassIsChildOf(PRI.ClientVeteranSkill, VetSkill))
  {
    bChangedVeterancyThisWave = false;
    ClientMessage(Repl(YouWillBecomePerkString, "%Perk%", VetSkill.default.VeterancyName));
  }

  else
  {
    if (!bChangedVeterancyThisWave || bForceChange)
    {
      if (!ClassIsChildOf(PRI.ClientVeteranSkill, VetSkill))
      {
        ClientMessage(Repl(YouAreNowPerkString, "%Perk%", VetSkill.default.VeterancyName));

        if (GameReplicationInfo.bMatchHasBegun)
        {
          bChangedVeterancyThisWave = true;
        }
      }
      PRI.ClientVeteranSkill = class'Utility'.static.GetVetReplacement(VetSkill);
      PRI.ClientVeteranSkillLevel = KFSteamStatsAndAchievements(SteamStatsAndAchievements).PerkHighestLevelAvailable(VetSkill.default.PerkIndex);

      if (KFHumanPawn(Pawn) != none)
      {
        KFHumanPawn(Pawn).VeterancyChanged();
      }
    }
    else
    {
      ClientMessage(PerkChangeOncePerWaveString);
    }
  }
}


function ShowBuyMenu(string wlTag, float maxweight)
{
  StopForceFeedback();
  ClientOpenMenu(BuyMenuClassName,, wlTag, string(maxweight));
}


simulated function PreloadFireModeAssets(class<WeaponFire> FClass)
{
  local class<Projectile> pClass;

  if ((FClass == none) || FClass == class'NoFire')
  {
    return;
  }

  if (class<KFFire>(FClass) != none)
  {
    class<KFFire>(FClass).static.PreloadAssets(Level);
  }
  else if (class<KFShotgunFire>(FClass) != none)
  {
    class<KFShotgunFire>(FClass).static.PreloadAssets(Level);
  }
  else if (class<KFMeleeFire>(FClass) != none)
  {
    class<KFMeleeFire>(FClass).static.PreloadAssets();
  }

  pClass = FClass.default.ProjectileClass;

  if (pClass == none)
  {
    return;
  }

  if ((class<CrossbuzzsawBlade>(pClass) != none) && class<CrossbuzzsawBlade>(pClass).default.StaticMeshRef != "")
  {
    class<CrossbuzzsawBlade>(pClass).static.PreloadAssets();
  }
  else if ((class<HealingProjectile>(pClass) != none) && class<HealingProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<HealingProjectile>(pClass).static.PreloadAssets();
  }
  else if ((class<LAWProj>(pClass) != none) && class<LAWProj>(pClass).default.StaticMeshRef != "")
  {
    class<LAWProj>(pClass).static.PreloadAssets();
  }
  else if ((class<M79GrenadeProjectile>(pClass) != none) && class<M79GrenadeProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<M79GrenadeProjectile>(pClass).static.PreloadAssets();
  }
  else if ((class<SealSquealProjectile>(pClass) != none) && class<SealSquealProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<SealSquealProjectile>(pClass).static.PreloadAssets();
  }
  else if ((class<SPGrenadeProjectile>(pClass) != none) && class<SPGrenadeProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<SPGrenadeProjectile>(pClass).static.PreloadAssets();
  }
  else if ((class<NailGunProjectile>(pClass) != none) && class<NailGunProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<NailGunProjectile>(pClass).static.PreloadAssets();
  }
  else if ((class<TrenchgunBullet>(pClass) != none) && class<TrenchgunBullet>(pClass).default.StaticMeshRef != "")
  {
    class<TrenchgunBullet>(pClass).static.PreloadAssets();
  }
  else if ((class<CrossbowArrow>(pClass) != none) && class<CrossbowArrow>(pClass).default.MeshRef != "")
  {
    class<CrossbowArrow>(pClass).static.PreloadAssets();
  }
  else if (class<M99Bullet>(pClass) != none)
  {
    class<M99Bullet>(pClass).static.PreloadAssets();
  }
  else if ((class<PipeBombProjectile>(pClass) != none) && class<PipeBombProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<PipeBombProjectile>(pClass).static.PreloadAssets();
  }
}


simulated function ClientWeaponSpawned(class<Weapon> WClass, Inventory Inv)
{
  local class<KFWeapon> KFWClass;
  local class<KFWeaponAttachment> WAClass;

  KFWClass = class<KFWeapon>(WClass);

  if (KFWClass != none)
  {
    if (KFWClass.default.Mesh == none)
    {
      KFWClass.static.PreloadAssets(Inv);
    }
    WAClass = class<KFWeaponAttachment>(WClass.default.AttachmentClass);

    if ((WAClass != none) && WAClass.default.Mesh == none)
    {
      if (Inv != none)
      {
        WAClass.static.PreloadAssets(KFWeaponAttachment(Inv.ThirdPersonActor));
      }
      else
      {
        WAClass.static.PreloadAssets();
      }
    }
    PreloadFireModeAssets(KFWClass.default.FireModeClass[0]);
    PreloadFireModeAssets(KFWClass.default.FireModeClass[1]);
  }
}


simulated function UnloadFireModeAssets(class<WeaponFire> FClass)
{
  local class<Projectile> pClass;

  if ((FClass == none) || FClass == class'NoFire')
  {
    return;
  }

  if (class<KFFire>(FClass) != none)
  {
    class<KFFire>(FClass).static.UnloadAssets();
  }
  else if (class<KFShotgunFire>(FClass) != none)
  {
    class<KFShotgunFire>(FClass).static.UnloadAssets();
  }
  else if (class<KFMeleeFire>(FClass) != none)
  {
    class<KFMeleeFire>(FClass).static.UnloadAssets();
  }

  pClass = FClass.default.ProjectileClass;

  if ((pClass == none) || pClass.default.StaticMesh != none)
  {
    return;
  }

  if ((class<CrossbuzzsawBlade>(pClass) != none) && class<CrossbuzzsawBlade>(pClass).default.StaticMeshRef != "")
  {
    class<CrossbuzzsawBlade>(pClass).static.UnloadAssets();
  }
  else if ((class<HealingProjectile>(pClass) != none) && class<HealingProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<HealingProjectile>(pClass).static.UnloadAssets();
  }
  else if ((class<LAWProj>(pClass) != none) && class<LAWProj>(pClass).default.StaticMeshRef != "")
  {
    class<LAWProj>(pClass).static.UnloadAssets();
  }
  else if((class<M79GrenadeProjectile>(pClass) != none) && class<M79GrenadeProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<M79GrenadeProjectile>(pClass).static.UnloadAssets();
  }
  else if((class<SealSquealProjectile>(pClass) != none) && class<SealSquealProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<SealSquealProjectile>(pClass).static.UnloadAssets();
  }
  else if ((class<SPGrenadeProjectile>(pClass) != none) && class<SPGrenadeProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<SPGrenadeProjectile>(pClass).static.UnloadAssets();
  }
  else if ((class<NailGunProjectile>(pClass) != none) && class<NailGunProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<NailGunProjectile>(pClass).static.UnloadAssets();
  }
  else if ((class<TrenchgunBullet>(pClass) != none) && class<TrenchgunBullet>(pClass).default.StaticMeshRef != "")
  {
    class<TrenchgunBullet>(pClass).static.UnloadAssets();
  }
  else if ((class<CrossbowArrow>(pClass) != none) && class<CrossbowArrow>(pClass).default.MeshRef != "")
  {
    class<CrossbowArrow>(pClass).static.UnloadAssets();
  }
  else if (class<M99Bullet>(pClass) != none)
  {
    class<M99Bullet>(pClass).static.UnloadAssets();
  }
  else if ((class<PipeBombProjectile>(pClass) != none) && class<PipeBombProjectile>(pClass).default.StaticMeshRef != "")
  {
    class<PipeBombProjectile>(pClass).static.UnloadAssets();
  }
}


simulated function ClientWeaponDestroyed(class<Weapon> WClass)
{
  local class<KFWeapon> KFWClass;
  local class<KFWeaponAttachment> WAClass;

  KFWClass = class<KFWeapon>(WClass);

  if (((KFWClass != none) && KFWClass.default.MeshRef != "") && KFWClass.static.UnloadAssets())
  {
    UnloadFireModeAssets(KFWClass.default.FireModeClass[0]);
    UnloadFireModeAssets(KFWClass.default.FireModeClass[1]);
    WAClass = class<KFWeaponAttachment>(WClass.default.AttachmentClass);

    if ((WAClass != none) && WAClass.default.Mesh == none)
    {
      WAClass.static.UnloadAssets();
    }
  }
}


defaultproperties
{
  BuyMenuClassName="CsHDMut.GUI_BuyMenu"
  SelectedVeterancy=Class'KFMod.KFVetSharpshooter'
  PawnClass=class'CsHDHumanPawn'
}