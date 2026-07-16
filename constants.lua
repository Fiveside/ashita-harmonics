
---@alias Element
---| '"Thunder"'
---| '"Ice"'
---| '"Fire"'
---| '"Wind"'
---| '"Water"'
---| '"Earth"'
---| '"Dark"'
---| '"Light"'

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

---@type table<Skillchain, Element[]>
local SKILLCHAIN_ELEMENTS = T{
    Light = T{"Light", "Thunder", "Fire", "Wind"},
    Darkness = T{"Dark", "Ice", "Water", "Earth"},
    Gravitation = T{"Dark", "Earth"},
    Fragmentation = T{"Fire", "Wind"},
    Distortion = T{"Ice", "Water"},
    Fusion = T{"Light", "Fire"},
    Compression = T{"Dark"},
    Liquefaction = T{"Fire"},
    Induration = T{"Ice"},
    Reverberation = T{"Water"},
    Transfixion = T{"Light"},
    Scission = T{"Earth"},
    Detonation = T{"Wind"},
    Impaction = T{"Thunder"},
    Radiance = T{"Light", "Thunder", "Fire", "Wind"},
    Umbra = T{"Dark", "Ice", "Water", "Earth"},
};

-- This is the integer sent in the packet for a skillchain. 0 = no skillchain.
---@type Skillchain[]
local SKILLCHAIN_IDS = T{
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

---@type table<Skillchain, table<Skillchain, Skillchain>>
local RESONANCE_CHAINS = T{
    Impaction = T{
        Liquefaction = "Liquefaction",
        Detonation = "Detonation",
    },
    Reverberation = T{
        Impaction = "Impaction",
        Induration = "Induration",
    },
    Induration = T{
        Impaction = "Impaction",
        Compression = "Compression",
        Reverberation = "Fragmentation",
    },
    Compression = T{
        Detonation = "Detonation",
        Transfixion = "Transfixion",
    },
    Scission = T{
        Liquefaction = "Liquefaction",
        Detonation = "Detonation",
        Reverberation = "Reverberation",
    },
    Detonation = T{
        Scission = "Scission",
        Compression = "Gravitation",
    },
    Transfixion = T{
        Compression = "Compression",
        Scission = "Distortion",
    },
    Distortion = T{
        Fusion = "Fusion",
        Gravitation = "Darkness",
    },
    Fusion = T{
        Gravitation = "Gravitation",
        Fragmentation = "Light",
    },
    Gravitation = T{
        Fragmentation = "Fragmentation",
        Distortion = "Darkness",
    },
    Fragmentation = T{
        Distortion = "Distortion",
        Fusion = "Light",
    },
    Light = T{
        Light = "Radiance",
    },
    Darkness = T{
        Darkness = "Umbra",
    }
}

return {
    SkillchainElements = SKILLCHAIN_ELEMENTS,
    SkillchainIds = SKILLCHAIN_IDS,
}