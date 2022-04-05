# ***Enumerator weaponFlags***

## ***Description***
constant table of weaponFlags with corresponding values required for engagement tasks

## ***Features***
- coverage of all weapon flags

## ***Globals***

---
### No Weapon
```lua
enum.weaponFlag.NoWeapon = 0
```
---
## Bombs
---
### LGB
```lua
enum.weaponFlag.LGB = 2
```
---
### TvGB
```lua
enum.weaponFlag.TvGB = 4
```
---
### SNSGB
```lua
enum.weaponFlag.SNSGB = 8
```
---
### Guided Bomb
```lua
enum.weaponFlag.GuidedBomb = 14 -- (LGB + TvGB + SNSGB)
```
---
### HEBomb
```lua
enum.weaponFlag.HEBomb = 16
```
---
### Penetrator
```lua
enum.weaponFlag.Penetrator = 32
```
---
### Napalm Bomb
```lua
enum.weaponFlag.NapalmBomb = 64
```
---
### FAE Bomb
```lua
enum.weaponFlag.FAEBomb = 128
```
---
### Cluster Bomb
```lua
enum.weaponFlag.ClusterBomb = 256
```
---
### Dispencer
```lua
enum.weaponFlag.Dispencer = 512
```
---
### Candle Bomb
```lua
enum.weaponFlag.CandleBomb = 1024
```
---
### Parachute Bomb
```lua
enum.weaponFlag.ParachuteBomb = 2147483648
```
---
### Any Unguided Bomb
```lua
enum.weaponFlag.AnyUnguidedBomb = 2147483648 -- (HeBomb + Penetrator + NapalmBomb + FAEBomb + ClusterBomb + Dispencer + CandleBomb + ParachuteBomb)
```
---
### Any Bomb
```lua
enum.weaponFlag.AnyBomb = 2147485694 -- (GuidedBomb + AnyUnguidedBomb)
```
---
## Rockets
---
### Light Rocket
```lua
enum.weaponFlag.LightRocket = 2048
```
---
### Marker Rocket
```lua
enum.weaponFlag.MarkerRocket = 4096
```
---
### Candle Rocket
```lua
enum.weaponFlag.CandleRocket = 8192
```
---
### Heavy Rocket
```lua
enum.weaponFlag.HeavyRocket = 16384
```
---
### Any Rocket
```lua
enum.weaponFlag.AnyRocket = 30720 -- (LightRocket + MarkerRocket + CandleRocket + HeavyRocket)
```
---
## Air to Ground Missiles
---
### Anti Radar Missile
```lua
enum.weaponFlag.AntiRadarMissile = 32768
```
---
### Anti Ship Missile
```lua
enum.weaponFlag.AntiShipMissile = 65536
```
---
### AntiTankMissile
```lua
enum.weaponFlag.AntiTankMissile = 131072
```
---
### Fire & Forget ASM
```lua
enum.weaponFlag.FireAndForgetASM = 262144
```
---
### Laser ASM
```lua
enum.weaponFlag.LaserASM = 524288
```
---
### Tele ASM
```lua
enum.weaponFlag.TeleASM = 1048576
```
---
### Cruise Missile
```lua
enum.weaponFlag.CruiseMissile = 2097152
```
---
### Cruise Missile
```lua
enum.weaponFlag.CruiseMissile = 2097152
```
---
### Anti Radar Missile2
```lua
enum.weaponFlag.AntiRadarMissile2 = 1073741824
```
---
### Guided ASM
```lua
enum.weaponFlag.GuidedASM = 1572864 -- (LaserASM + TeleASM)
```
---
### TacticalASM
```lua
enum.weaponFlag.GuidedASM = 1835008 -- (GuidedASM + FireAndForgetASM)
```
---
### Any ASM
```lua
enum.weaponFlag.AnyASM = 4161536 -- (AntiRadarMissile + AntiShipMissile + AntiTankMissile + FireAndForgetASM + GuidedASM + CruiseMissile)
```
---
## Air to Air Missiles
---
### Short Range Air to Air Missile
```lua
enum.weaponFlag.SRAAM = 4194304
```
---
### Medium Range Air to Air Missile
```lua
enum.weaponFlag.MRAAM = 8388608
```
---
### Long Range Air to Air Missile
```lua
enum.weaponFlag.LRAAM = 16777216
```
---
### InfraRed Air to Air Missile
```lua
enum.weaponFlag.IR_AAM = 33554432
```
---
### Semi-Active Radar Air to Air Missile
```lua
enum.weaponFlag.SAR_AAM = 67108864
```
---
### Active Radar Air to Air Missile
```lua
enum.weaponFlag.AR_AAM = 134217728
```
---
### Any Air to Air Missile
```lua
enum.weaponFlag.AnyAMM = 264241152 -- (IR_AAM + SAR_AAM + AR_AAM + SRAAM + MRAAM + LRAAM)
```
---
### AnyMissile
```lua
enum.weaponFlag.AnyMissile = 268402688 -- (ASM + AnyAAM)
```
---
### Any Autonomous Missile
```lua
enum.weaponFlag.AnyMissile = 36012032 -- (IR_AAM + AntiRadarMissile + AntiShipMissile + FireAndForgetASM + CruiseMissile)
```
---
## Guns
---
### Gun Pod
```lua
enum.weaponFlag.GUN_POD = 268435456
```
---
### Built In Cannon
```lua
enum.weaponFlag.BuiltInCannon = 536870912
```
---
### Cannons
```lua
enum.weaponFlag.Cannons = 805306368 -- (GUN_POD + BuiltInCannon)
```
---
## Torpedo
---
### Torpedo
```lua
enum.weaponFlag.Torpedo = 4294967296
```
---
### Combinations
---
### Any Air to Ground Weapon
```lua
enum.weaponFlag.AnyAGWeapon = 2956984318 -- (BuiltInCannon + GUN_POD + AnyBomb + AnyRocket + AnyASM)
```
---
### Any Air to Air Weapon
```lua
enum.weaponFlag.AnyAAWeapon = 264241152 -- (BuiltInCannon + GUN_POD + AnyAAM)
```
---
### Unguided Weapon
```lua
enum.weaponFlag.AnyAAWeapon = 2952822768 -- (Cannons + BuiltInCannon + GUN_POD + AnyUnguidedBomb + AnyRocket)
```
---
### Guided Weapon
```lua
enum.weaponFlag.AnyAAWeapon = 268402702 -- (GuidedBomb + AnyASM + AnyAAM)
```
---
### Any Weapon
```lua
enum.weaponFlag.AnyWeapon = 3221225470 -- (AnyBomb + AnyRocket + AnyMissile + Cannons)
```
---
### Marker Weapon
```lua
enum.weaponFlag.MarkerWeapon = 13312 -- (MarkerRocket + CandleRocket + CandleBomb)
```
---
### Arm Weapon
```lua
enum.weaponFlag.ArmWeapon = 3221212158 -- (AnyWeapon - MarkerWeapon)
```
---