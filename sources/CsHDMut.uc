class CsHDMut extends Mutator
  config(CsHDMut);


// struct that stores what a specific zed should be replaced with
struct SZedPair
{
  var string oldClass;
  var string newClass;
};
// array that stores all the replacement pairs
var array<SZedPair> replacementArray;
var array<string> replCaps;

struct SPickupPair
{
  var class<Pickup> PickupClass;
  var class<Pickup> Replacement;
};

var array<SPickupPair> W_Array;
// headshot hitzone scale
var config float AdditionalScale;


struct FixMeshStruct
{
  var class<KFMonster> M;
  var Mesh Mesh;
  var array<Material> Skins;
};
var array<FixMeshStruct> MeshInfoSTD;	


// ADDITION!!!
enum ESpecialEventType
{
  ET_None,
  ET_SummerSideshow,
  ET_HillbillyHorror,
  ET_TwistedChristmas
};

var ESpecialEventType SpecialEventType;

//=============================================================================
//                                  DEBUG
//=============================================================================

var private bool bDebug;


final private function dlog(string s)
{
  if (bDebug)
    log("> CSHDMut: " $ s);
}


//=============================================================================
//                                  STARTUP
//=============================================================================

// all zed replacement code was copy-pasted from Scary Ghost:
// https://github.com/scaryghost/SuperZombieMut/blob/master/Classes/SuperZombieMut.uc
event PostBeginPlay()
{
  local int i,k;
  local KFGameType KF;
  local array<String> mcCaps;

  super.PostBeginPlay();

  KF = KFGameType(Level.Game);
  if (KF == none)
  {
    log("KFGameType not found, terminating!", self.name);
    Destroy();
    return;
  }

  if (KF.MonsterCollection == class'KFGameType'.default.MonsterCollection)
  {
    KF.MonsterCollection = class'CsHDMonstersCollection';
  }

  for (i = 0; i < KF.MonsterCollection.default.MonsterClasses.Length; i++)
  {
    mcCaps[mcCaps.Length] = caps(KF.MonsterCollection.default.MonsterClasses[i].MClassName);
  }

  for (i = 0; i < replacementArray.Length; i++)
  {
    replCaps[replCaps.Length]= Caps(replacementArray[i].oldClass);
  }

  // Replace all instances of the old specimens with the new ones 
  for (i = 0; i < mcCaps.Length; i++)
  {
    for (k = 0; k < replCaps.Length; k++)
    {
      if (InStr(mcCaps[i], replCaps[k]) != -1)
      {
        log("> Replacing" @ KF.MonsterCollection.default.MonsterClasses[i].MClassName @ "with" @ replacementArray[k].newClass, self.name);
        KF.MonsterCollection.default.MonsterClasses[i].MClassName = replacementArray[k].newClass;
      }
    }
  }

  // Replace the special squad arrays
  replaceSpecialSquad(KF.MonsterCollection.default.ShortSpecialSquads);
  replaceSpecialSquad(KF.MonsterCollection.default.NormalSpecialSquads);
  replaceSpecialSquad(KF.MonsterCollection.default.LongSpecialSquads);
  replaceSpecialSquad(KF.MonsterCollection.default.FinalSquads);   

  // replace boss class
  KF.MonsterCollection.default.EndGameBossClass = string(class'ZED_Patriarch');
  // replace fallback class
  KF.MonsterCollection.default.FallbackMonsterClass = string(class'ZED_Stalker');

  // shut down default event system
  for (i = 0; i < KF.SpecialEventMonsterCollections.Length; i++)
  {
    KF.SpecialEventMonsterCollections[i] = KF.MonsterCollection;
  }

  // add our controller class
  if (!ClassIsChildOf(KF.PlayerControllerClass, class'CsHDPlayerController'))
  {
    KF.PlayerControllerClass = class'CsHDPlayerController';
    KF.PlayerControllerClassName = string(class'CsHDPlayerController');
  }

  // start the timer and modify pickups
  SetTimer(0.10, false);   
}


//=============================================================================
//                                  LOGIC
//=============================================================================

simulated function Timer()
{
  super(Actor).Timer();
  ModifyLevelRules();
}


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
  local byte i;

  if ((KFWeaponPickup(Other) != none) && Left(string(Other.class), 6) ~= "KFMod.")
  {
    for (i = 0; i < default.W_Array.Length; i++)
    {
      if (default.W_Array[i].PickupClass == Other.class)
      {
        ReplaceWith(Other, string(default.W_Array[i].Replacement));
        return false;
      }
    }
  }
  else
  {
    if (Other.class == class'KFRandomItemSpawn')
    {
      ReplaceWith(Other, "CsHDMut.CsHDRandomItemSpawn");
      return false;
    }
    else
    {
      if (Other.class == class'CsHDReplicationInfo')
      {
        CsHDReplicationInfo(Other).AdditionalScale = AdditionalScale;
      }
    }
  }
  return true;
}


// attempt to load required mesh / combiner, aka custom event system without event zed classes
// https://github.com/OperatsiyaY/MonsterConfig/blob/master/classes/MonsterConfig.uc#L368
simulated function LoadZedAssets(KFMonster M)
{
  local Mesh tMesh;
  local array<Material> tSkins;
  local int i;

  if (M.Mesh == none)
  {
    tMesh = GetDefaultMesh(M.Class);
    M.UpdateDefaultMesh(tMesh);
    M.static.UpdateDefaultMesh(tMesh);
    M.Class.static.UpdateDefaultMesh(tMesh);
    M.LinkMesh(tMesh);
  }
  if (M.Skins[0] == none)
  {
    GetDefaultSkins(M.Class, tSkins);
    for (i = 0; i < tSkins.Length; i++)
    {
      M.Skins[i] = tSkins[i];
      M.default.Skins[i] = tSkins[i];
    }
  }
}


simulated function GetDefaultSkins(class<KFMonster> KCM, out array<Material> Skins)
{
  local int i, j;

  if (KCM == none)
    return;

  for (i = 0; i < MeshInfoSTD.Length; i++)
  {
    if (ClassIsChildOf(KCM, MeshInfoSTD[i].M))
    {
      for (j = 0; j < MeshInfoSTD[i].Skins.Length; j++)
      {
        Skins[Skins.length] = MeshInfoSTD[i].Skins[j];
      }
    }
  }
}


simulated function Mesh GetDefaultMesh(class<KFMonster> KCM)
{
  // local int i;

  if (KCM == none)
    return none;

  // if (KCM.Default.Mesh != none)
  // 	return KCM.Default.Mesh;
  if (SpecialEventType == ET_None)
  {
    if (class<ZombieBloatBase>(KCM) != none)
      return Mesh'Bloat_Freak';
    else if (class<ZombieBossBase>(KCM) != none)
      return Mesh'Patriarch_Freak';
    else if (class<ZombieClotBase>(KCM) != none)
      return Mesh'CLOT_Freak';
    else if (class<ZombieCrawlerBase>(KCM) != none)
      return Mesh'Crawler_Freak';
    else if (class<ZombieFleshPoundBase>(KCM) != none)
      return Mesh'FleshPound_Freak';
    else if (class<ZombieGorefastBase>(KCM) != none)
      return Mesh'GoreFast_Freak';
    else if (class<ZombieHuskBase>(KCM) != none)
      return Mesh'Burns_Freak';
    else if (class<ZombieScrakeBase>(KCM) != none)
      return Mesh'Scrake_Freak';
    else if (class<ZombieSirenBase>(KCM) != none)
      return Mesh'Siren_Freak';
    else if (class<ZombieStalkerBase>(KCM) != none)
      return Mesh'Stalker_Freak';
  }

  return none;
}


//=============================================================================
//                          REPLACING ZEDS n PICKUPS
//=============================================================================

// Replaces the zombies in the given squadArray
final private function replaceSpecialSquad(out array<KFMonstersCollection.SpecialSquad> squadArray)
{
  local int i, j, k;

  for (j = 0; j < squadArray.Length; j++)
  {
    for (i = 0; i < squadArray[j].ZedClass.Length; i++)
    {
      for (k = 0; k < replacementArray.Length; k++)
      {
        if (InStr(Caps(squadArray[j].ZedClass[i]), replCaps[k]) != -1)
        {
          squadArray[j].ZedClass[i] = replacementArray[k].newClass;
        }
      }
    }
  }
}


final private function ModifyPickupArray(out array< class<Pickup> > PickupArray)
{
  local byte i;

  for (i = 0; i < PickupArray.Length; i++)
  {
    if (PickupArray[i] != none)
    {
      PickupArray[i] = GetPickupReplacement(PickupArray[i]);
    }
  }
}


final static function class<Pickup> GetPickupReplacement(class<Pickup> PickupClass)
{
  local byte i;

  if (PickupClass != none)
  {
    for (i = 0; i < default.W_Array.Length; i++)
    {
      if (default.W_Array[i].PickupClass == PickupClass)
      {
        return default.W_Array[i].Replacement;
      }
    }
  }
  return none;
}


simulated function ModifyLevelRules()
{
  local KFLevelRules LR;

  foreach DynamicActors(class'KFLevelRules', LR)
  {
    if (LR != none)
    {
      ModifyPickupArray(LR.MediItemForSale);
      ModifyPickupArray(LR.SuppItemForSale);
      ModifyPickupArray(LR.ShrpItemForSale);
      ModifyPickupArray(LR.CommItemForSale);
      ModifyPickupArray(LR.BersItemForSale);
      ModifyPickupArray(LR.FireItemForSale);
      ModifyPickupArray(LR.DemoItemForSale);
      ModifyPickupArray(LR.NeutItemForSale);
    }
  }
}


//=============================================================================
//                              MUTATOR INFO
//=============================================================================

static function FillPlayInfo(PlayInfo PlayInfo)
{
  super(Info).FillPlayInfo(PlayInfo);
  PlayInfo.AddSetting(default.FriendlyName, "additionalScale", "Additional scale", 0, 1, "Text", "3;0.00:1.00");
}


static event string GetDescriptionText(string Property)
{
  switch (Property)
  {
    case "additionalScale":
      return "Additional scale of specimen head hitboxes, ranging from the original size to the increased size of the server-side approximation.";
    default:
      return super(Info).GetDescriptionText(Property);
  }
}


//=============================================================================
//                              DEFAULTPROPERTIES
//=============================================================================

defaultproperties
{
  bDebug=True

  GroupName="KFCsHDMut"
  FriendlyName="CsHDMut 0.5.0"
  Description="Client-side hit detection."
  bAlwaysRelevant=True
  RemoteRole=ROLE_SimulatedProxy
  bAddToServerPackages=True

  replacementArray(0)=(oldClass="KFChar.ZombieClot_STANDARD",newClass="CsHDMut.ZED_Clot")
  replacementArray(1)=(oldClass="KFChar.ZombieGoreFast_STANDARD",newClass="CsHDMut.ZED_Gorefast")
  replacementArray(2)=(oldClass="KFChar.ZombieBloat_STANDARD",newClass="CsHDMut.ZED_Bloat")
  replacementArray(3)=(oldClass="KFChar.ZombieCrawler_STANDARD",newClass="CsHDMut.ZED_Crawler")
  replacementArray(4)=(oldClass="KFChar.ZombieStalker_STANDARD",newClass="CsHDMut.ZED_Stalker")
  replacementArray(5)=(oldClass="KFChar.ZombieSiren_STANDARD",newClass="CsHDMut.ZED_Siren")
  replacementArray(6)=(oldClass="KFChar.ZombieHusk_STANDARD",newClass="CsHDMut.ZED_Husk")
  replacementArray(7)=(oldClass="KFChar.ZombieScrake_STANDARD",newClass="CsHDMut.ZED_Scrake")
  replacementArray(8)=(oldClass="KFChar.ZombieFleshPound_STANDARD",newClass="CsHDMut.ZED_Fleshpound")
  replacementArray(9)=(oldClass="KFChar.ZombieBoss_STANDARD",newClass="CsHDMut.ZED_Patriarch")

  W_Array(0)=(PickupClass=class'KFMod.MP7MPickup',Replacement=class'CsHDMut.W_MP7MPickup')
  W_Array(1)=(PickupClass=class'KFMod.MP5MPickup',Replacement=class'CsHDMut.W_MP5MPickup')
  W_Array(2)=(PickupClass=class'KFMod.CamoMP5MPickup',Replacement=class'CsHDMut.W_CamoMP5MPickup')
  W_Array(3)=(PickupClass=class'KFMod.M7A3MPickup',Replacement=class'CsHDMut.W_M7A3MPickup')
  W_Array(4)=(PickupClass=class'KFMod.KrissMPickup',Replacement=class'CsHDMut.W_KrissMPickup')
  W_Array(5)=(PickupClass=class'KFMod.SinglePickup',Replacement=class'CsHDMut.W_SinglePickup')
  W_Array(6)=(PickupClass=class'KFMod.DualiesPickup',Replacement=class'CsHDMut.W_DualiesPickup')
  W_Array(7)=(PickupClass=class'KFMod.WinchesterPickup',Replacement=class'CsHDMut.W_WinchesterPickup')
  W_Array(8)=(PickupClass=class'KFMod.Magnum44Pickup',Replacement=class'CsHDMut.W_Magnum44Pickup')
  W_Array(9)=(PickupClass=class'KFMod.DeaglePickup',Replacement=class'CsHDMut.W_DeaglePickup')
  W_Array(10)=(PickupClass=class'KFMod.GoldenDeaglePickup',Replacement=class'CsHDMut.W_GoldenDeaglePickup')
  W_Array(11)=(PickupClass=class'KFMod.MK23Pickup',Replacement=class'CsHDMut.W_MK23Pickup')
  W_Array(12)=(PickupClass=class'KFMod.Dual44MagnumPickup',Replacement=class'CsHDMut.W_Dual44MagnumPickup')
  W_Array(13)=(PickupClass=class'KFMod.DualMK23Pickup',Replacement=class'CsHDMut.W_DualMK23Pickup')
  W_Array(14)=(PickupClass=class'KFMod.DualDeaglePickup',Replacement=class'CsHDMut.W_DualDeaglePickup')
  W_Array(15)=(PickupClass=class'KFMod.GoldenDualDeaglePickup',Replacement=class'CsHDMut.W_GoldenDualDeaglePickup')
  W_Array(16)=(PickupClass=class'KFMod.SPSniperPickup',Replacement=class'CsHDMut.W_SPSniperPickup')
  W_Array(17)=(PickupClass=class'KFMod.M14EBRPickup',Replacement=class'CsHDMut.W_M14EBRPickup')
  W_Array(18)=(PickupClass=class'KFMod.BullpupPickup',Replacement=class'CsHDMut.W_BullpupPickup')
  W_Array(19)=(PickupClass=class'KFMod.ThompsonPickup',Replacement=class'CsHDMut.W_ThompsonPickup')
  W_Array(20)=(PickupClass=class'KFMod.SPThompsonPickup',Replacement=class'CsHDMut.W_SPThompsonPickup')
  W_Array(21)=(PickupClass=class'KFMod.ThompsonDrumPickup',Replacement=class'CsHDMut.W_ThompsonDrumPickup')
  W_Array(22)=(PickupClass=class'KFMod.AK47Pickup',Replacement=class'CsHDMut.W_AK47Pickup')
  W_Array(23)=(PickupClass=class'KFMod.GoldenAK47pickup',Replacement=class'CsHDMut.W_GoldenAK47Pickup')
  W_Array(24)=(PickupClass=class'KFMod.M4Pickup',Replacement=class'CsHDMut.W_M4Pickup')
  W_Array(25)=(PickupClass=class'KFMod.CamoM4Pickup',Replacement=class'CsHDMut.W_CamoM4Pickup')
  W_Array(26)=(PickupClass=class'KFMod.MKb42Pickup',Replacement=class'CsHDMut.W_MKb42Pickup')
  W_Array(27)=(PickupClass=class'KFMod.SCARMK17Pickup',Replacement=class'CsHDMut.W_SCARMK17Pickup')
  W_Array(28)=(PickupClass=class'KFMod.FNFAL_ACOG_Pickup',Replacement=class'CsHDMut.W_FNFAL_ACOG_Pickup')
  W_Array(29)=(PickupClass=class'KFMod.SyringePickup',Replacement=class'CsHDMut.W_SyringePickup')

  MeshInfoSTD(0)=(M=Class'KFChar.ZombieClot',Mesh=SkeletalMesh'KF_Freaks_Trip.CLOT_Freak',Skins=(Combiner'KF_Specimens_Trip_T.clot_cmb'))
  MeshInfoSTD(1)=(M=Class'KFChar.ZombieGorefast',Mesh=SkeletalMesh'KF_Freaks_Trip.GoreFast_Freak',Skins=(Combiner'KF_Specimens_Trip_T.gorefast_cmb'))
  MeshInfoSTD(2)=(M=Class'KFChar.ZombieCrawler',Mesh=SkeletalMesh'KF_Freaks_Trip.Crawler_Freak',Skins=(Combiner'KF_Specimens_Trip_T.crawler_cmb'))
  MeshInfoSTD(3)=(M=Class'KFChar.ZombieBloat',Mesh=SkeletalMesh'KF_Freaks_Trip.Bloat_Freak',Skins=(Combiner'KF_Specimens_Trip_T.bloat_cmb'))
  MeshInfoSTD(4)=(M=Class'KFChar.ZombieStalker',Mesh=SkeletalMesh'KF_Freaks_Trip.Stalker_Freak',Skins=(Shader'KF_Specimens_Trip_T.stalker_invisible',Shader'KF_Specimens_Trip_T.stalker_invisible'))
  MeshInfoSTD(5)=(M=Class'KFChar.ZombieSiren',Mesh=SkeletalMesh'KF_Freaks_Trip.Siren_Freak',Skins=(FinalBlend'KF_Specimens_Trip_T.siren_hair_fb',Combiner'KF_Specimens_Trip_T.siren_cmb'))
  MeshInfoSTD(6)=(M=Class'KFChar.ZombieHusk',Mesh=SkeletalMesh'KF_Freaks2_Trip.Burns_Freak',Skins=(Texture'KF_Specimens_Trip_T_Two.burns.burns_tatters',Shader'KF_Specimens_Trip_T_Two.burns.burns_shdr'))
  MeshInfoSTD(7)=(M=Class'KFChar.ZombieScrake',Mesh=SkeletalMesh'KF_Freaks_Trip.Scrake_Freak',Skins=(Shader'KF_Specimens_Trip_T.scrake_FB',TexPanner'KF_Specimens_Trip_T.scrake_saw_panner'))
  MeshInfoSTD(8)=(M=Class'KFChar.ZombieFleshPound',Mesh=SkeletalMesh'KF_Freaks_Trip.FleshPound_Freak',Skins=(Combiner'KF_Specimens_Trip_T.fleshpound_cmb',Shader'KFCharacters.FPAmberBloomShader'))
  MeshInfoSTD(9)=(M=Class'KFChar.ZombieBoss',Mesh=SkeletalMesh'KF_Freaks_Trip.Patriarch_Freak',Skins=(Combiner'KF_Specimens_Trip_T.gatling_cmb',Combiner'KF_Specimens_Trip_T.patriarch_cmb'))
}