class CsHDHumanPawn extends KFHumanPawn;


simulated function PostBeginPlay()
{
  super(KFPawn).PostBeginPlay();

  if (Role < ROLE_Authority)
  {
    if (AuxCollisionCylinder == none)
    {
      AuxCollisionCylinder = spawn(class'KFBulletWhipAttachment', self);
      AuxCollisionCylinder.bHardAttach = true;
      AuxCollisionCylinder.SetLocation(Location);
      AuxCollisionCylinder.SetPhysics(0);
      AuxCollisionCylinder.SetBase(self);
    }
    SavedAuxCollision = AuxCollisionCylinder.bCollideActors;
  }
}


function ServerBuyWeapon(class<Weapon> WClass, float ItemWeight)
{
  local Inventory Inv;
  local float Price;

  if ((!CanBuyNow() || class<KFWeapon>(WClass) == none) || class<KFWeaponPickup>(WClass.default.PickupClass) == none)
  {
    return;
  }
  Price = float(class<KFWeaponPickup>(WClass.default.PickupClass).default.cost);

  if (KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
  {
    Price *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), WClass.default.PickupClass);
  }

  for (Inv = Inventory; Inv != none; Inv = Inv.Inventory)
  {
    if (Inv.Class == WClass)
    {
      return;
    }
  }

  if (class'Utility'.static.IsDualHandguns(WClass))
  {
    for (Inv = Inventory; Inv != none; Inv = Inv.Inventory)
    {
      if (Inv.Class == class'Utility'.static.SingleVariantOf(WClass))
      {
        Price /= float(2);
        break;
      }
    }
  }

  if (!CanCarry(ItemWeight))
  {
    return;
  }

  if (PlayerReplicationInfo.Score < Price)
  {
    return;
  }
  Inv = spawn(WClass);

  if (Inv != none)
  {
    if (KFGameType(Level.Game) != none)
    {
      KFGameType(Level.Game).WeaponSpawned(Inv);
    }
    KFWeapon(Inv).UpdateMagCapacity(PlayerReplicationInfo);
    KFWeapon(Inv).FillToInitialAmmo();
    KFWeapon(Inv).SellValue = int(Price * 0.750);
    Inv.GiveTo(self);
    PlayerReplicationInfo.Score -= Price;
    ClientForceChangeWeapon(Inv);
  }
  SetTraderUpdate();
}


function ServerSellWeapon(class<Weapon> WClass)
{
  local Inventory Inv;
  local KFWeapon NewSingle;
  local float Price;

  if ((!CanBuyNow() || class<KFWeapon>(WClass) == none) || class<KFWeaponPickup>(WClass.default.PickupClass) == none)
  {
    SetTraderUpdate();
    return;
  }

  for (Inv = Inventory; Inv != none; Inv = Inv.Inventory)
  {
    if (Inv.Class == WClass)
    {
      if ((KFWeapon(Inv) != none) && KFWeapon(Inv).SellValue != -1)
      {
        Price = float(KFWeapon(Inv).SellValue);
      }
      else
      {
        Price = float(int(float(class<KFWeaponPickup>(WClass.default.PickupClass).default.cost) * 0.750));

        if (KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
        {
          Price *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), WClass.default.PickupClass);
        }
      }

      if (class'Utility'.static.IsDualHandguns(Inv.Class))
      {
        NewSingle = Spawn(class'Utility'.static.SingleVariantOf(Inv.Class));
        NewSingle.GiveTo(self);
        Price /= float(2);
        NewSingle.SellValue = int(Price);
      }

      if ((Inv == Weapon) || Inv == PendingWeapon)
      {
        ClientCurrentWeaponSold();
      }
      PlayerReplicationInfo.Score += Price;
      Inv.Destroyed();
      Inv.Destroy();
      SetTraderUpdate();

      if (KFGameType(Level.Game) != none)
      {
        KFGameType(Level.Game).WeaponDestroyed(WClass);
      }
      return;
    }
  }
}


defaultproperties
{
  RequiredEquipment[1]="CsHDMut.W_Single"
  RequiredEquipment[3]="CsHDMut.W_Syringe"
}