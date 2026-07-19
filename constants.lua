local Export = T {};

---@class LocalizedString
---@field en string
---@field ja string

---@alias Element
---| '"Physical"'
---| '"Thunder"'
---| '"Ice"'
---| '"Fire"'
---| '"Wind"'
---| '"Water"'
---| '"Earth"'
---| '"Dark"'
---| '"Light"'
---| '"None"'

---@alias Skillchain
---| "Light"
---| "Darkness"
---| "Gravitation"
---| "Fragmentation"
---| "Distortion"
---| "Fusion"
---| "Compression"
---| "Liquefaction"
---| "Induration"
---| "Reverberation"
---| "Transfixion"
---| "Scission"
---| "Detonation"
---| "Impaction"
---| "Radiance"
---| "Umbra"

-- Map of element game IDs to their element string
---@type table<integer, Element>
Export.ElementIds = T {
    [-1] = "Physical", -- Physical instead of elemental
    [0] = "Fire",
    [1] = "Ice",
    [2] = "Air",
    [3] = "Earth",
    [4] = "Thunder",
    [5] = "Water",
    [6] = "Light",
    [7] = "Dark",
    [15] = "None", -- Non physical and non elemental (EG. formless strikes)
};

-- This is the integer sent in the packet for a skillchain. 0 = no skillchain.
---@type Skillchain[]
Export.SkillchainIds = T {
    [0] = "None",
    [1] = "Light",
    [2] = "Darkness",
    [3] = "Gravitation",
    [4] = "Fragmentation",
    [5] = "Distortion",
    [6] = "Fusion",
    [7] = "Compression",
    [8] = "Liquefaction",
    [9] = "Induration",
    [10] = "Reverberation",
    [11] = "Transfixion",
    [12] = "Scission",
    [13] = "Detonation",
    [14] = "Impaction",
    [15] = "Radiance",
    [16] = "Umbra",
}

---@type table<Skillchain, Element[]>
Export.SkillchainElements = T {
    Light = T { "Light", "Thunder", "Fire", "Wind" },
    Darkness = T { "Dark", "Ice", "Water", "Earth" },
    Gravitation = T { "Dark", "Earth" },
    Fragmentation = T { "Fire", "Wind" },
    Distortion = T { "Ice", "Water" },
    Fusion = T { "Light", "Fire" },
    Compression = T { "Dark" },
    Liquefaction = T { "Fire" },
    Induration = T { "Ice" },
    Reverberation = T { "Water" },
    Transfixion = T { "Light" },
    Scission = T { "Earth" },
    Detonation = T { "Wind" },
    Impaction = T { "Thunder" },
    Radiance = T { "Light", "Thunder", "Fire", "Wind" },
    Umbra = T { "Dark", "Ice", "Water", "Earth" },
};

---@type table<Skillchain, table<Skillchain, Skillchain>>
Export.ResonanceChains = T {
    Impaction = T {
        Liquefaction = "Liquefaction",
        Detonation = "Detonation",
    },
    Reverberation = T {
        Impaction = "Impaction",
        Induration = "Induration",
    },
    Induration = T {
        Impaction = "Impaction",
        Compression = "Compression",
        Reverberation = "Fragmentation",
    },
    Compression = T {
        Detonation = "Detonation",
        Transfixion = "Transfixion",
    },
    Scission = T {
        Liquefaction = "Liquefaction",
        Detonation = "Detonation",
        Reverberation = "Reverberation",
    },
    Detonation = T {
        Scission = "Scission",
        Compression = "Gravitation",
    },
    Transfixion = T {
        Compression = "Compression",
        Scission = "Distortion",
    },
    Distortion = T {
        Fusion = "Fusion",
        Gravitation = "Darkness",
    },
    Fusion = T {
        Gravitation = "Gravitation",
        Fragmentation = "Light",
    },
    Gravitation = T {
        Fragmentation = "Fragmentation",
        Distortion = "Darkness",
    },
    Fragmentation = T {
        Distortion = "Distortion",
        Fusion = "Light",
    },
    Light = T {
        Light = "Radiance",
    },
    Darkness = T {
        Darkness = "Umbra",
    }
}

---@alias Skill
---| '"None"'
---| '"HandToHand"'
---| '"Dagger"'
---| '"Sword"'
---| '"GreatSword"'
---| '"Axe"'
---| '"GreatAxe"'
---| '"Scythe"'
---| '"Polarm"'
---| '"Katana"'
---| '"GreatKatana"'
---| '"Club"'
---| '"Staff"'
---| '"AutomatonMelee"'
---| '"AutomatonRanged"'
---| '"AutomatonMagic"'
---| '"Archery"'
---| '"Marksmanship"'
---| '"Throwing"'
---| '"Guard"'
---| '"Evasion"'
---| '"Shield"'
---| '"Parry"'
---| '"Divine"'
---| '"Healing"'
---| '"Enhancing"'
---| '"Enfeebling"'
---| '"Elemental"'
---| '"Dark"'
---| '"Summoning"'
---| '"Ninjutsu"'
---| '"Singing"'
---| '"String"'
---| '"Wind"'
---| '"BlueMagic"'
---| '"Geomancy"'
---| '"Handbell"'
---| '"Fishing"'
---| '"Woodworking"'
---| '"Smithing"'
---| '"Goldsmithing"'
---| '"Clothcraft"'
---| '"Leathercraft"'
---| '"Bonecraft"'
---| '"Alchemy"'
---| '"Cooking"'
---| '"Synergy"'
---| '"ChocoboDigging"'

Export.SkillIds = T {
    [0] = "None",

    -- Weapon Skills
    [1] = "HandToHand",
    [2] = "Dagger",
    [3] = "Sword",
    [4] = "GreatSword",
    [5] = "Axe",
    [6] = "GreatAxe",
    [7] = "Scythe",
    [8] = "Polarm",
    [9] = "Katana",
    [10] = "GreatKatana",
    [11] = "Club",
    [12] = "Staff",

    -- Automaton Skills
    [22] = "AutomatonMelee",
    [23] = "AutomatonRanged",
    [24] = "AutomatonMagic",

    -- Combat Skills
    [25] = "Archery",
    [26] = "Marksmanship",
    [27] = "Throwing",
    [28] = "Guard",
    [29] = "Evasion",
    [30] = "Shield",
    [31] = "Parry",
    [32] = "Divine",
    [33] = "Healing",
    [34] = "Enhancing",
    [35] = "Enfeebling",
    [36] = "Elemental",
    [37] = "Dark",
    [38] = "Summoning",
    [39] = "Ninjutsu",
    [40] = "Singing",
    [41] = "String",
    [42] = "Wind",
    [43] = "BlueMagic",
    [44] = "Geomancy",
    [45] = "Handbell",

    -- Crafting Skills
    [48] = "Fishing",
    [49] = "Woodworking",
    [50] = "Smithing",
    [51] = "Goldsmithing",
    [52] = "Clothcraft",
    [53] = "Leathercraft",
    [54] = "Bonecraft",
    [55] = "Alchemy",
    [56] = "Cooking",
    [57] = "Synergy",
    [58] = "ChocoboDigging",
};


return Export;
