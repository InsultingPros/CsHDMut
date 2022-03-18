class W_GoldenDualDeagleFire extends GoldenDualDeagleFire;


// COPY-PASTE CODE BELOW FOR ALL PENETRATING PISTOLS!!!
var byte penCount;
var float penDamReduction;


function DoFireEffect()
{
    Instigator.MakeNoise(1.0);
}


function ShakeView()
{
    local Vector StartTrace;
    local Rotator R, Aim;

    StartTrace = Instigator.Location + Instigator.EyePosition();
    Aim = AdjustAim(StartTrace, aimerror);
    R = rotator(vector(Aim) + ((VRand() * FRand()) * Spread));
    class'WeaponUtility'.static.DoTraceClientPen(self, StartTrace, R, penCount, penDamReduction);

    super(WeaponFire).ShakeView();
}


defaultproperties
{
    penCount=5
    penDamReduction=0.50
    AmmoClass=Class'KFMod.GoldenDeagleAmmo'
}