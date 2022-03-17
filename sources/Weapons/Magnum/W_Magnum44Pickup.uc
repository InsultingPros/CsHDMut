class W_Magnum44Pickup extends Magnum44Pickup;


// COPY-PASTE CODE BELOW FOR ALL DUAL VARIANT WEAPON PICKUP CLASSES!!!
function Inventory SpawnCopy(Pawn Other)
{
  local Inventory Inv;

  for (Inv = Other.Inventory; Inv != none; Inv = Inv.Inventory)
  {
    if (Inv.Class == InventoryType)
    {
      if (Inventory != none)
      {
        Inventory.Destroy();
      }
      InventoryType = class'Utility'.static.DualVariantOf(InventoryType);
      AmmoAmount[0] += KFWeapon(Inv).AmmoAmount(0);
      MagAmmoRemaining += KFWeapon(Inv).MagAmmoRemaining;
      Inv.Destroyed();
      Inv.Destroy();
      return super(Pickup).SpawnCopy(Other);
    }
  }
  InventoryType = default.InventoryType;
  return super(Pickup).SpawnCopy(Other);
}


defaultproperties
{
  InventoryType=class'W_Magnum44Pistol'
}