class GUI_BuyMenuTab extends KFTab_BuyMenu;


function ShowPanel(bool bShow)
{
  super(GUITabPanel).ShowPanel(bShow);
  bClosed = false;

  if (KFPlayerController(PlayerOwner()) != none)
  {
    KFPlayerController(PlayerOwner()).bDoTraderUpdate = true;
  }
  InvSelect.SetPosition(InvBG.WinLeft + (7.0 / float(Controller.ResX)), InvBG.WinTop + (55.0 / float(Controller.ResY)), InvBG.WinWidth - (15.0 / float(Controller.ResX)), InvBG.WinHeight - (45.0 / float(Controller.ResY)), true);
  SaleSelect.SetPosition(SaleBG.WinLeft + (7.0 / float(Controller.ResX)), SaleBG.WinTop + (55.0 / float(Controller.ResY)), SaleBG.WinWidth - (15.0 / float(Controller.ResX)), SaleBG.WinHeight - (63.0 / float(Controller.ResY)), true);
}


defaultproperties
{
  Begin Object Class=GUI_BuyMenuInvListBox Name=InventoryBox
    OnCreateComponent=InventoryBox.InternalOnCreateComponent
    WinTop=0.070841
    WinLeft=0.000108
    WinWidth=0.328204
    WinHeight=0.521856
  End Object
  InvSelect=GUI_BuyMenuInvListBox'CsHDMut.GUI_BuyMenuTab.InventoryBox'

  Begin Object Class=GUI_BuyMenuSaleListBox Name=SaleBox
    OnCreateComponent=SaleBox.InternalOnCreateComponent
    WinTop=0.064312
    WinLeft=0.672632
    WinWidth=0.325857
    WinHeight=0.674039
  End Object
  SaleSelect=GUI_BuyMenuSaleListBox'CsHDMut.GUI_BuyMenuTab.SaleBox'
}