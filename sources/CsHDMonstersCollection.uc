class CsHDMonstersCollection extends KFMonstersCollection;


// just a copy-paste with edited zed class names
defaultproperties
{
    FallbackMonsterClass="CsHDMut.ZED_Stalker"
    EndGameBossClass="CsHDMut.ZED_Patriarch"

    MonsterClasses(0)=(MClassName="CsHDMut.ZED_Clot",Mid="A")
    MonsterClasses(1)=(MClassName="CsHDMut.ZED_Crawler",Mid="B")
    MonsterClasses(2)=(MClassName="CsHDMut.ZED_Gorefast",Mid="C")
    MonsterClasses(3)=(MClassName="CsHDMut.ZED_Stalker",Mid="D")
    MonsterClasses(4)=(MClassName="CsHDMut.ZED_Scrake",Mid="E")
    MonsterClasses(5)=(MClassName="CsHDMut.ZED_Fleshpound",Mid="F")
    MonsterClasses(6)=(MClassName="CsHDMut.ZED_Bloat",Mid="G")
    MonsterClasses(7)=(MClassName="CsHDMut.ZED_Siren",Mid="H")
    MonsterClasses(8)=(MClassName="CsHDMut.ZED_Husk",Mid="I")

    StandardMonsterClasses(0)=(MClassName="CsHDMut.ZED_Clot",Mid="A")
    StandardMonsterClasses(1)=(MClassName="CsHDMut.ZED_Crawler",Mid="B")
    StandardMonsterClasses(2)=(MClassName="CsHDMut.ZED_Gorefast",Mid="C")
    StandardMonsterClasses(3)=(MClassName="CsHDMut.ZED_Stalker",Mid="D")
    StandardMonsterClasses(4)=(MClassName="CsHDMut.ZED_Scrake",Mid="E")
    StandardMonsterClasses(5)=(MClassName="CsHDMut.ZED_Fleshpound",Mid="F")
    StandardMonsterClasses(6)=(MClassName="CsHDMut.ZED_Bloat",Mid="G")
    StandardMonsterClasses(7)=(MClassName="CsHDMut.ZED_Siren",Mid="H")
    StandardMonsterClasses(8)=(MClassName="CsHDMut.ZED_Husk",Mid="I")

    ShortSpecialSquads(2)=(ZedClass=("CsHDMut.ZED_Crawler","CsHDMut.ZED_Gorefast","CsHDMut.ZED_Stalker","CsHDMut.ZED_Scrake"),NumZeds=(2,2,1,1))
    ShortSpecialSquads(3)=(ZedClass=("CsHDMut.ZED_Bloat","CsHDMut.ZED_Siren","CsHDMut.ZED_Fleshpound"),NumZeds=(1,2,1))

    NormalSpecialSquads(3)=(ZedClass=("CsHDMut.ZED_Crawler","CsHDMut.ZED_Gorefast","CsHDMut.ZED_Stalker","CsHDMut.ZED_Scrake"),NumZeds=(2,2,1,1))
    NormalSpecialSquads(4)=(ZedClass=("CsHDMut.ZED_Fleshpound"),NumZeds=(1))
    NormalSpecialSquads(5)=(ZedClass=("CsHDMut.ZED_Bloat","CsHDMut.ZED_Siren","CsHDMut.ZED_Fleshpound"),NumZeds=(1,1,1))
    NormalSpecialSquads(6)=(ZedClass=("CsHDMut.ZED_Bloat","CsHDMut.ZED_Siren","CsHDMut.ZED_Fleshpound"),NumZeds=(1,1,2))

    LongSpecialSquads(4)=(ZedClass=("CsHDMut.ZED_Crawler","CsHDMut.ZED_Gorefast","CsHDMut.ZED_Stalker","CsHDMut.ZED_Scrake"),NumZeds=(2,2,1,1))
    LongSpecialSquads(6)=(ZedClass=("CsHDMut.ZED_Fleshpound"),NumZeds=(1))
    LongSpecialSquads(7)=(ZedClass=("CsHDMut.ZED_Bloat","CsHDMut.ZED_Siren","CsHDMut.ZED_Fleshpound"),NumZeds=(1,1,1))
    LongSpecialSquads(8)=(ZedClass=("CsHDMut.ZED_Bloat","CsHDMut.ZED_Siren","CsHDMut.ZED_Scrake","CsHDMut.ZED_Fleshpound"),NumZeds=(1,2,1,1))
    LongSpecialSquads(9)=(ZedClass=("CsHDMut.ZED_Bloat","CsHDMut.ZED_Siren","CsHDMut.ZED_Scrake","CsHDMut.ZED_Fleshpound"),NumZeds=(1,2,1,2))

    FinalSquads(0)=(ZedClass=("CsHDMut.ZED_Clot"),NumZeds=(4))
    FinalSquads(1)=(ZedClass=("CsHDMut.ZED_Clot","CsHDMut.ZED_Crawler"),NumZeds=(3,1))
    FinalSquads(2)=(ZedClass=("CsHDMut.ZED_Clot","CsHDMut.ZED_Stalker","CsHDMut.ZED_Crawler"),NumZeds=(3,1,1))
}