# Descarga nombres oficiales (EN / ES) e iconos de hechizos y objetos desde la base de datos
# de Wowhead para WoW: Forever y genera data/wowhead-forever-db.js
# Incluye unicamente el libro clasico + las habilidades y raciales EXCLUSIVAS de WoW: Forever (sin SoD).
# Uso: powershell -ExecutionPolicy Bypass -File tools\fetch-wowhead.ps1

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Net.Http
[System.Net.ServicePointManager]::DefaultConnectionLimit = 32

$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root 'data'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$spells = [ordered]@{
  warrior = @(
    # Exclusivas de WoW: Forever (Victory Rush, Spearing Strike, Weaponmaster, Bloodthrill)
    402927, 1310222, 1290261, 1289682,
    # Classic Arms / Fury / Protection
    78, 100, 772, 6343, 1715, 7384, 694, 20230, 12328, 12294, 2457,
    6673, 1160, 845, 5308, 5246, 1464, 1161, 20252, 1680, 18499, 6552, 1719, 12323, 12292, 23881, 2458,
    2687, 7386, 72, 6572, 2565, 676, 355, 871, 12975, 12809, 23922, 71,
    # General / Ranged
    6603, 3018, 2480, 7918, 7919, 2764
  )
  paladin = @(
    # Exclusivas de WoW: Forever (Holy Strike, Seal of Fury, Templar's Bulwark, Improved Holy Strike)
    679, 1311649, 1311015, 1310902,
    # Classic Holy / Protection / Retribution
    635, 19750, 633, 1152, 4987, 7328, 26573, 879, 2812, 2878, 10326, 5502,
    19742, 25894, 19977, 25890, 20165, 20166, 21084, 20216, 20473, 24275, 13819, 23214,
    465, 19746, 19876, 19888, 19891, 498, 642, 1022, 1044, 6940, 1038, 25895,
    20217, 25898, 20911, 25899, 853, 25780, 20164, 19752, 20925,
    19740, 25782, 7294, 20218, 21082, 20375, 20271, 20066
  )
  hunter = @(
    # Exclusivas de WoW: Forever (Sniper Shot, Summon Hawk, Strider Kick, Lacerate, Lone Wolf, Trickster's Dance)
    1310687, 1293241, 1317257, 24118, 1310684, 1310612,
    # Classic Marksmanship / Beast Mastery / Survival
    75, 1130, 3044, 5116, 1978, 3043, 3034, 2643, 20736, 1510, 3045, 1543, 19801, 19434, 19503, 19506,
    13163, 13165, 5118, 13159, 13161, 20043, 883, 2641, 136, 982, 6991, 1515, 1462, 1513, 6197, 1002, 19577, 19574,
    2973, 2974, 1495, 781, 5384, 1499, 13809, 13795, 13813, 19263, 19306, 19386, 23989,
    1494, 19883, 19884, 19885, 19880, 19878, 19882, 19879,
    # Hunter Pet Abilities
    2649, 1742, 23109, 23145, 7371, 17253, 16827, 24423, 24604, 24844, 24640, 26064, 26090, 24450
  )
  rogue = @(
    # Exclusivas de WoW: Forever (Mutilate, Restless Blades)
    1310707, 1241797,
    # Classic Assassination / Combat / Subtlety
    2098, 5171, 8647, 703, 8676, 1943, 1833, 408, 14177,
    1752, 53, 1776, 5277, 2983, 1766, 1966, 14251, 13877, 13750,
    1784, 921, 6770, 1725, 1856, 2094, 2836, 1842, 1804, 1860, 14278, 16511, 14185, 14183,
    # Ranged
    2480, 7918, 7919, 2764
  )
  priest = @(
    # Exclusivas de WoW: Forever (Penance, Prayer of Mending, Binding Heal, Shadow Word: Death)
    1240720, 1240826, 1240770, 1309595,
    # Classic Discipline / Holy / Shadow & Priest Racials
    1243, 21562, 17, 588, 527, 8129, 9484, 1706, 14752, 27681, 14751, 10060, 10797, 2651, 13896,
    2050, 2054, 2060, 2061, 139, 596, 2006, 528, 552, 585, 14914, 15237, 724, 19236, 6346,
    589, 8092, 8122, 586, 2096, 453, 605, 976, 27683, 15407, 15487, 15286, 15473, 2652, 2944, 9035, 18137, 5019
  )
  shaman = @(
    # Exclusivas de WoW: Forever (Lava Burst, Riptide, Water Shield, Totemic Recall, Totemic Projection, Call of the Elements/Ancestors/Spirits, Fire Nova, Maelstrom Weapon)
    1326047, 1239242, 408510, 36936, 437009, 66842, 66843, 66844, 8349, 408498,
    # Classic Elemental / Enhancement / Restoration & Totems
    403, 421, 8042, 8050, 8056, 370, 2484, 5730, 3599, 1535, 8190, 16166,
    8017, 8024, 8033, 8232, 324, 2645, 556, 6196, 131, 546,
    8071, 8075, 8177, 8512, 8835, 8227, 8181, 8184, 10595, 15107, 6495, 17364,
    331, 8004, 1064, 2008, 20608, 526, 2870, 5394, 5675, 8143, 8166, 8170, 25908, 16190, 16188
  )
  mage = @(
    # Exclusivas de WoW: Forever (Frost Blast, Arcane Wrath, Arcane Blast, Missile Barrage, Ice Lance, Frostfire Bolt, Summon Arcane Elemental)
    1326053, 1326079, 1239696, 1326083, 1312002, 1237312, 1326099,
    # Classic Arcane / Fire / Frost
    5143, 1449, 1459, 23028, 118, 28272, 28271, 2139, 1953, 12051, 1463, 475, 130, 1008, 604, 2855, 6117,
    5504, 587, 759, 3552, 10053, 10054, 12043, 12042,
    3561, 3562, 3565, 3567, 3563, 3566, 10059, 11416, 11419, 11417, 11418, 11420,
    133, 2136, 2948, 2120, 543, 11366, 11113, 11129,
    116, 122, 120, 10, 168, 7302, 6143, 11958, 12472, 11426, 5019
  )
  warlock = @(
    # Exclusivas de WoW: Forever (Incinerate, Bane of Havoc, Bane of Agony, Bane of Doom, Unstable Affliction, Haunt)
    1293812, 1225228, 980, 603, 1242971, 1293693,
    # Classic Affliction / Demonology / Destruction
    172, 702, 704, 1714, 1490, 17862, 18223, 18288, 1454, 689, 1120, 5138, 5782, 5484, 6789, 18265, 18220,
    687, 706, 688, 697, 712, 691, 1122, 18540, 1098, 710, 755, 5697, 132, 126, 5500, 6229, 698,
    6201, 693, 2362, 6366, 5784, 23161, 18708, 18788, 19028, 20707,
    686, 348, 5676, 5740, 1949, 6353, 17877, 17962, 5019,
    # Demon Pet Abilities (Felhunter, Succubus, Voidwalker, Imp)
    19244, 19505, 19480, 6358, 6360, 7814, 7870, 7812, 17735, 3716, 17767, 3110, 6307, 2947, 4511
  )
  druid = @(
    # Exclusivas de WoW: Forever (Primal Bite, Lacerate, Berserk, Wild Growth, Eclipse)
    407995, 1235827, 417141, 1238214, 1286115,
    # Classic Balance / Feral / Restoration
    5176, 8921, 2912, 339, 16689, 467, 770, 2637, 2908, 16914, 22812, 18960, 16864, 24858,
    5487, 9634, 768, 783, 1066, 6807, 779, 99, 6795, 5229, 5211, 5209, 22842, 16979, 16857,
    1082, 1822, 5221, 1079, 22568, 5215, 6785, 9005, 8998, 5217, 1850, 5225,
    5185, 774, 8936, 740, 20484, 1126, 21849, 8946, 2893, 2782, 29166, 5570, 17116, 18562
  )
}

# Sistema de 2 raciales activas por raza en WoW: Forever (incluyendo la nueva raza Skyborne)
$racials = [ordered]@{
  human    = @(1259718, 20600)
  dwarf    = @(20594, 2481)
  nightelf = @(20580, 1259799)
  gnome    = @(20589, 1259817)
  orc      = @(20572)
  undead   = @(7744, 20577, 1260201)
  tauren   = @(20549, 1259918)
  troll    = @(20554)
  skyborne = @(1259416, 1259705, 1259686)
}

$items = [ordered]@{
  trinkets    = @(18854, 18834, 21180, 20130, 22954, 19950, 12930, 19379, 18473, 13965, 11815, 19395, 19949)
  consumables = @(13446, 13444, 3928, 1710, 929, 5634, 3387, 13455, 14530, 14529, 9421, 6948, 20008, 13442, 12662, 20520, 5512)
  engineering = @(4390, 15993, 10646, 18641, 16040, 4388, 10586, 10720, 10562)
  weaponswap  = @(19019, 1203, 18168, 12784, 17182, 2129, 19334, 19363, 18832, 17066)
}

$client = New-Object System.Net.Http.HttpClient
$client.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
$client.Timeout = [TimeSpan]::FromSeconds(12)

function Fetch-Batch([string]$type, [int[]]$ids) {
  $uniqueIds = @($ids | Select-Object -Unique)
  $results = @()
  $batchSize = 25

  for ($i = 0; $i -lt $uniqueIds.Count; $i += $batchSize) {
    $slice = $uniqueIds[$i..([Math]::Min($i + $batchSize - 1, $uniqueIds.Count - 1))]
    $tasksEn = @{}
    $tasksEs = @{}
    foreach ($id in $slice) {
      $tasksEn[$id] = $client.GetStringAsync("https://nether.wowhead.com/forever/tooltip/$type/$($id)?locale=0")
      $tasksEs[$id] = $client.GetStringAsync("https://nether.wowhead.com/forever/tooltip/$type/$($id)?locale=6")
    }
    try {
      [System.Threading.Tasks.Task]::WaitAll(@($tasksEn.Values) + @($tasksEs.Values), 10000) | Out-Null
    } catch {}

    foreach ($id in $slice) {
      $tEn = $tasksEn[$id]
      $tEs = $tasksEs[$id]
      if ($tEn.Status -eq 'RanToCompletion' -and $tEs.Status -eq 'RanToCompletion' -and $tEn.Result -and $tEs.Result) {
        try {
          $jEn = $tEn.Result | ConvertFrom-Json
          $jEs = $tEs.Result | ConvertFrom-Json
          if ($jEn.name -and $jEs.name -and -not $jEn.name.StartsWith('[') -and -not $jEs.name.StartsWith('[')) {
            $results += [ordered]@{
              id   = $id
              en   = $jEn.name
              es   = $jEs.name
              icon = $jEn.icon
            }
          }
        } catch {}
      }
    }
  }
  return $results
}

$db = [ordered]@{
  source    = 'https://www.wowhead.com/forever'
  generated = (Get-Date).ToString('s')
  classes   = [ordered]@{}
  races     = [ordered]@{}
  items     = [ordered]@{}
}

foreach ($k in $spells.Keys) {
  $list = @(Fetch-Batch 'spell' $spells[$k])
  $db.classes[$k] = $list
  Write-Host ("Clase {0,-10}: {1} hechizos descargados" -f $k, $list.Count)
}

foreach ($k in $racials.Keys) {
  $list = @(Fetch-Batch 'spell' $racials[$k])
  $db.races[$k] = $list
  Write-Host ("Raza  {0,-10}: {1} raciales descargadas" -f $k, $list.Count)
}

foreach ($k in $items.Keys) {
  $list = @(Fetch-Batch 'item' $items[$k])
  $db.items[$k] = $list
  Write-Host ("Items {0,-10}: {1} objetos descargados" -f $k, $list.Count)
}

$client.Dispose()

$js = "// Generado automaticamente por tools/fetch-wowhead.ps1 desde Wowhead (WoW: Forever)`n" +
      "window.WOWHEAD_FOREVER_DB = " + ($db | ConvertTo-Json -Depth 6) + ";`n"
[System.IO.File]::WriteAllText((Join-Path $outDir 'wowhead-forever-db.js'), $js, (New-Object System.Text.UTF8Encoding $false))
Write-Host "OK -> data/wowhead-forever-db.js"
