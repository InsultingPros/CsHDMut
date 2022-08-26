// Source lives here: https://github.com/InsultingPros/CsHDMut
class CsHDMut extends Mutator
    config(CsHDMut);


// headshot hitzone scale
var config float AdditionalScale;

struct SWeaponPair
{
  var class<KFWeapon> replWeapon;
  var class<WeaponFire> replFire;
};
var array<SWeaponPair> W_Array;

// struct SPickupPair
// {
//   var class<Pickup> oldClass;
//   var class<Pickup> newClass;
// };
// var array<SPickupPair> W_Array;


//=============================================================================
//                                  STARTUP
//=============================================================================

event PostBeginPlay()
{
    local int i;
    local KFGameType KF;

    super.PostBeginPlay();

    KF = KFGameType(Level.Game);
    if (KF == none)
    {
      log("KFGameType not found, terminating!", self.name);
      Destroy();
      return;
    }

    // change vanilla monster collection
    if (KF.MonsterCollection == class'KFGameType'.default.MonsterCollection)
    {
      KF.MonsterCollection = class'CsHDMonstersCollection';
    }

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
  // ModifyLevelRules();
}

// change Fire class for choosen weapons
final private function replFireClass(KFWeapon W)
{
    local int i;

    log(">>> CsHDMut: WeaponUtility: replFireClass: we started!");
    for (i = 0; i < W_Array.Length; i++)
    {
        if (W.class == W_Array[i].replWeapon)
        {
            W.FireModeClass[0] = W_Array[i].replFire;
            log(">>> CsHDMut: WeaponUtility: replFireClass: replacing fire class for " $ W.class $ " to " $ default.W_Array[i].replFire);
        }
    }
}


simulated function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    // local byte i;

    // if (Other.class == class'KFRandomItemSpawn')
    // {
    //     ReplaceWith(Other, string(class'CsHDRandomItemSpawn'));
    //     return false;
    // }
    if (Other.class == class'CsHDReplicationInfo')
    {
        CsHDReplicationInfo(Other).AdditionalScale = AdditionalScale;
    }
    else if (KFWeapon(Other) != none)
    {
      log(">>> CsHDMut: CheckReplacement: weapon was not none! : " $ KFWeapon(Other));
      replFireClass(KFWeapon(Other));
    }
    // else if ((Pickup(Other) != none))
    // {
    //     for (i = 0; i < W_Array.Length; i++)
    //     {
    //         if (W_Array[i].oldClass == Other.class)
    //         {
    //             log(">>> CsHDMut: CheckReplacement: replacing pickup " $ KFWeaponPickup(Other).name $ " with " $ W_Array[i].newClass);
    //             ReplaceWith(Other, string(W_Array[i].newClass));
    //             return false;
    //         }
    //     }
    // }

    return true;
}


//=============================================================================
//                          REPLACING PICKUPS
//=============================================================================

// final private function ModifyPickupArray(out array< class<Pickup> > PickupArray)
// {
//   local byte i;

//   for (i = 0; i < PickupArray.Length; i++)
//   {
//     if (PickupArray[i] != none)
//     {
//       PickupArray[i] = GetPickupReplacement(PickupArray[i]);
//     }
//   }
// }


// final private function class<Pickup> GetPickupReplacement(class<Pickup> oldClass)
// {
//   local byte i;

//   if (oldClass != none)
//   {
//     for (i = 0; i < W_Array.Length; i++)
//     {
//       if (W_Array[i].oldClass == oldClass)
//       {
//         return W_Array[i].newClass;
//       }
//     }
//   }
//   return none;
// }


// simulated function ModifyLevelRules()
// {
//   local KFLevelRules LR;

//   foreach DynamicActors(class'KFLevelRules', LR)
//   {
//     if (LR != none)
//     {
//       ModifyPickupArray(LR.MediItemForSale);
//       ModifyPickupArray(LR.SuppItemForSale);
//       ModifyPickupArray(LR.ShrpItemForSale);
//       ModifyPickupArray(LR.CommItemForSale);
//       ModifyPickupArray(LR.BersItemForSale);
//       ModifyPickupArray(LR.FireItemForSale);
//       ModifyPickupArray(LR.DemoItemForSale);
//       ModifyPickupArray(LR.NeutItemForSale);
//     }
//   }
// }


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
  GroupName="KFCsHDMut"
  FriendlyName="CsHDMut 0.5.0"
  Description="Client-side hit detection."
  bAlwaysRelevant=True
  RemoteRole=ROLE_SimulatedProxy
  bAddToServerPackages=True

  W_Array[0]=(replWeapon=class'Single',replFire=class'W_SingleFire')

  // W_Array(0)=(oldClass=class'KFMod.MP7MPickup',newClass=class'W_MP7MPickup')
  // W_Array(1)=(oldClass=class'KFMod.MP5MPickup',newClass=class'W_MP5MPickup')
  // W_Array(2)=(oldClass=class'KFMod.CamoMP5MPickup',newClass=class'W_CamoMP5MPickup')
  // W_Array(3)=(oldClass=class'KFMod.M7A3MPickup',newClass=class'W_M7A3MPickup')
  // W_Array(4)=(oldClass=class'KFMod.KrissMPickup',newClass=class'W_KrissMPickup')
  // // W_Array(5)=(oldClass=class'KFMod.SinglePickup',newClass=class'W_SinglePickup')
  // W_Array(6)=(oldClass=class'KFMod.DualiesPickup',newClass=class'W_DualiesPickup')
  // W_Array(7)=(oldClass=class'KFMod.WinchesterPickup',newClass=class'W_WinchesterPickup')
  // W_Array(8)=(oldClass=class'KFMod.Magnum44Pickup',newClass=class'W_Magnum44Pickup')
  // W_Array(9)=(oldClass=class'KFMod.DeaglePickup',newClass=class'W_DeaglePickup')
  // W_Array(10)=(oldClass=class'KFMod.GoldenDeaglePickup',newClass=class'W_GoldenDeaglePickup')
  // W_Array(11)=(oldClass=class'KFMod.MK23Pickup',newClass=class'W_MK23Pickup')
  // W_Array(12)=(oldClass=class'KFMod.Dual44MagnumPickup',newClass=class'W_Dual44MagnumPickup')
  // W_Array(13)=(oldClass=class'KFMod.DualMK23Pickup',newClass=class'W_DualMK23Pickup')
  // W_Array(14)=(oldClass=class'KFMod.DualDeaglePickup',newClass=class'W_DualDeaglePickup')
  // W_Array(15)=(oldClass=class'KFMod.GoldenDualDeaglePickup',newClass=class'W_GoldenDualDeaglePickup')
  // W_Array(16)=(oldClass=class'KFMod.SPSniperPickup',newClass=class'W_SPSniperPickup')
  // W_Array(17)=(oldClass=class'KFMod.M14EBRPickup',newClass=class'W_M14EBRPickup')
  // W_Array(18)=(oldClass=class'KFMod.BullpupPickup',newClass=class'W_BullpupPickup')
  // W_Array(19)=(oldClass=class'KFMod.ThompsonPickup',newClass=class'W_ThompsonPickup')
  // W_Array(20)=(oldClass=class'KFMod.SPThompsonPickup',newClass=class'W_SPThompsonPickup')
  // W_Array(21)=(oldClass=class'KFMod.ThompsonDrumPickup',newClass=class'W_ThompsonDrumPickup')
  // W_Array(22)=(oldClass=class'KFMod.AK47Pickup',newClass=class'W_AK47Pickup')
  // W_Array(23)=(oldClass=class'KFMod.GoldenAK47pickup',newClass=class'W_GoldenAK47Pickup')
  // W_Array(24)=(oldClass=class'KFMod.M4Pickup',newClass=class'W_M4Pickup')
  // W_Array(25)=(oldClass=class'KFMod.CamoM4Pickup',newClass=class'W_CamoM4Pickup')
  // W_Array(26)=(oldClass=class'KFMod.MKb42Pickup',newClass=class'W_MKb42Pickup')
  // W_Array(27)=(oldClass=class'KFMod.SCARMK17Pickup',newClass=class'W_SCARMK17Pickup')
  // W_Array(28)=(oldClass=class'KFMod.FNFAL_ACOG_Pickup',newClass=class'W_FNFAL_ACOG_Pickup')
  // W_Array(29)=(oldClass=class'KFMod.SyringePickup',newClass=class'W_SyringePickup')
}