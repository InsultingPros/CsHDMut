class W_MP5MFire extends MP5MFire;


// COPY-PASTE CODE BELOW FOR ALL USUAL FIRE CLASSES!!!
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
    class'WeaponUtility'.static.DoTraceClient(self, StartTrace, R);

    super(WeaponFire).ShakeView();
}