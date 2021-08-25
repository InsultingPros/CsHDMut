class W_GoldenAK47AssaultRifle extends W_AK47AssaultRifle;


defaultproperties
{
  TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Gold_AK47'
  SkinRefs(0)="KF_Weapons_Gold_T.Weapons.Gold_AK47_cmb"
  HudImageRef="KillingFloor2HUD.WeaponSelect.Gold_AK47_unselected"
  SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Gold_AK47"
  FireModeClass(0)=Class'CsHDMut.W_GoldenAK47Fire'
  Description="Take a classic AK. Gold plate every visible piece of metal. Engrave the wood for good measure. Serious blingski."
  PickupClass=Class'CsHDMut.W_GoldenAK47Pickup'
  AttachmentClass=Class'KFMod.GoldenAK47Attachment'
}