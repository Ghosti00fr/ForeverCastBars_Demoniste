-- ============================================================
--  Forever Cast Bars — pack Démoniste
--  Trois cadres : ombre (runes violettes), enfer (braises) et
--  gangrène (runes vertes) pour les démons. Remplissages et effets
--  des prototypes démoniste, composés avec le kit de la base
--  (PropsKit.lua). Exige ForeverCastBars.
-- ============================================================

if not (FCB and FCB.Looks and FCB.Looks.RegisterPack and FCB.Props and FCB.Props.Kit) then return end

local M = "Interface\\AddOns\\ForeverCastBars_Demoniste\\textures\\"
local B = FCB.TEX_PATH .. "crafts\\"
local Props, K = FCB.Props, FCB.Props.Kit
local Put, END, PutWH = Props.Put, Props.END, K.PutWH
local sin, cos, pi, max, min = math.sin, math.cos, math.pi, math.max, math.min
local VOID, FIRE, FELC, BLOOD, MANA, GHOST = { .75, .35, 1 }, { 1, .5, .12 }, { .45, 1, .2 }, { .9, .1, .12 }, { .4, .6, 1 }, { .95, .9, 1 }
local function Y(c) return c.cy + 4 end
local function EX(c) return END(c) - 12 end
local function Part(slots, Draw) return { slots = slots, Draw = Draw } end
local function R(name, parts) Props.RegisterKit("wl_" .. name, parts) end

-- projectile qui grandit à la pointe puis file vers le bout à la fin (dans le cadre)
local function Bolt(tex, size, col, g0, g1, add)
    return Part(2, function(st, c, o)
        if not c.te then
            local s = size * (g0 + (g1 - g0) * c.p)
            Put(st, o + 1, B .. "P_Glow", min(c.frontX, EX(c)), Y(c), s * 1.8, 0, .5 * c.p, col, true)
            Put(st, o + 2, tex, min(c.frontX, EX(c)), Y(c) + sin(c.t * 3), s, c.t * 40, 1, col, add)
        elseif c.te < .3 then
            local u = c.te / .3
            Put(st, o + 2, tex, EX(c) - 20 + 20 * u, Y(c), size * g1, 0, 1 - u, col, add)
        end
    end)
end
-- âmes terrifiées qui fuient la pointe (ou le bout, en gerbe à la fin)
local function Flee(n, burst)
    return Part(n, function(st, c, o)
        if burst and not (c.te and c.te < .9) then return end
        local x = burst and EX(c) - 20 or min(c.frontX, EX(c))
        for i = 0, n - 1 do
            local u = burst and c.te / .9 or (c.t * .8 + i / n) % 1; local ang = i * 2 * pi / n + .3
            Put(st, o + i + 1, B .. "P_Soul", x + cos(ang) * u * 26, Y(c) + sin(ang) * u * 18, 10, math.deg(ang) + 90, 1 - u, GHOST, true)
        end
    end)
end
-- terreur : voile sombre qui pulse sur la barre
local DARK = Part(1, function(st, c, o)
    if c.te then return end
    local a = (.15 + .35 * c.p) * (.5 + .5 * sin(c.t * (4 + 8 * c.p)))
    PutWH(st, o + 1, B .. "P_Glow", c.fillLX + c.fillW * .45, Y(c), c.fillW * 1.3, 90, 0, a, { 0, 0, 0 })
end)
-- corruption : veines pourries qui s'étendent, gouttes à la pointe
local VEINS = Part(4 * 8 + 3, function(st, c, o)
    local k = c.te and 1 or c.p
    for v = 0, 3 do
        for j = 0, 7 do
            local u = (j + .5) / 8
            if u <= k then Put(st, o + v * 8 + j + 1, B .. "P_Glow", c.fillLX + c.fillW * u, Y(c) - 8 + v * 5 + sin(j * 1.7 + v * 2) * 3, 10, 0, .9, { .55, .85, .2 }, true) end   -- vert pourri : lisible sur le violet
        end
    end
    for i = 0, 2 do
        local u = (c.t * .8 + i / 3) % 1
        Put(st, o + 33 + i, B .. "P_Drop", min(c.frontX, EX(c)) - i * 7, Y(c) - 3 - u * 18, 5, 0, 1 - u, { .4, .7, .15 })
    end
end)
-- asservir : chaînes des deux bandes vers la pointe
local CHAINS = Part(2 * 8 + 1, function(st, c, o)
    local k = c.te and 1 or c.p; local x = min(c.frontX, EX(c))
    for side = 0, 1 do
        local y0 = Y(c) + (side == 0 and 22 or -22)
        for j = 0, 7 do
            local u = j / 8
            if u <= k then PutWH(st, o + side * 8 + j + 1, B .. "P_Bubble", x - (1 - u) * 30, y0 + (Y(c) - y0) * u, j % 2 == 1 and 7 or 4, j % 2 == 1 and 4 or 7, 0, 1, { .75, .78, .7 }) end
        end
    end
    Put(st, o + 17, B .. "P_Glow", x, Y(c), 20 * k, 0, .6, FELC, true)
end)
-- portail démoniaque à la pointe ; une silhouette en sort à la fin
local function Portal(size)
    return Part(2, function(st, c, o)
        local k = c.te and 1 or c.p; local x = min(c.frontX, EX(c) - 8)
        Put(st, o + 1, B .. "P_PortalSwirl", x, Y(c), 10 + size * .45 * k, -c.t * 170, (.5 + .5 * k) * (c.te and max(0, 1 - c.te / .7) or 1), FELC, true)
        if c.te and c.te < .7 then local u = c.te / .7; Put(st, o + 2, B .. "P_Soul", EX(c) - 8 + 5 * u, Y(c) + 10 * u, 26, 0, 1 - u, { .6, 1, .4 }, true) end
    end)
end
-- rituel : grand cercle runique autour de la barre
local SIGIL = Part(11, function(st, c, o)
    local k = c.te and 1 or c.p; local zx, rx, ry = c.fillLX + c.fillW * .5, c.fillW * .5, 28
    PutWH(st, o + 1, B .. "P_Bubble", zx, Y(c), rx * 2, ry * 2, 0, .7, FELC, true)
    for i = 0, 9 do
        local ang = c.t * .5 + i * pi / 5
        Put(st, o + 2 + i, B .. "P_Rune_0" .. (i % 4 + 1), zx + cos(ang) * rx, Y(c) + sin(ang) * ry, 10, math.deg(ang), .5 + .5 * k, FELC, true)
    end
end)
-- flammes infernales : une couronne de flammes ondule autour de la barre
local FLAMES = Part(16, function(st, c, o)
    local zx, rx, ry = c.fillLX + c.fillW * .5, c.fillW * .5, 26
    for i = 0, 15 do
        local ang = i * 2 * pi / 16
        PutWH(st, o + i + 1, B .. "P_Flame", zx + cos(ang) * rx, Y(c) + sin(ang) * ry + 5, 7, 9 + 5 * sin(c.t * 9 + i), 0, 1, FIRE, true)
    end
end)
-- palefroi : traces de sabots enflammés, fer à cheval à la pointe
local HOOVES = Part(9, function(st, c, o)
    local k = c.te and 1 or c.p
    for i = 0, 7 do
        if (i + .5) / 8 <= k then Put(st, o + i + 1, B .. "P_Flame", c.fillLX + c.fillW * (i + .5) / 8, c.cy - 14, 10, 0, .6 + .4 * sin(c.t * 9 + i), FELC, true) end
    end
    Put(st, o + 9, M .. "P_Horseshoe", min(c.frontX + 6, EX(c)), Y(c), 14, 0, c.te and max(0, 1 - c.te / .4) or 1)
end)

R("shadowbolt",   { K.Converge(VOID, 10), Bolt(B .. "P_Essence", 14, { .9, .7, 1 }, .6, 2.4, true), K.Ring(VOID, 180), K.Burst(VOID, "P_Star") })
R("immolate",     { K.Rise(FIRE, "P_Flame", 12, { speed = 50, size = 10, filled = true }), K.TipGlow(FIRE, 45), K.Pillar({ 1, .6, .2 }, { width = 40 }), K.Ring(FIRE, 160) })
R("soulfire",     { K.Orbit(GHOST, "P_Soul", 5, { r = 26, speed = 2, size = 16 }), K.Converge({ 1, .5, .6 }, 10, "P_Star", 60), Bolt(M .. "P_Fireball", 16, nil, .3, 2.2), K.Ring({ 1, .5, .6 }, 220), K.Flash({ 1, .8, .9 }, 280), K.Burst({ 1, .6, .3 }, "P_Flame", 12, 80) })
R("searing",      { K.FrontSprite("P_Flame", 30, { grow = { .6, 1.4 }, col = { 1, .6, .15 }, add = true, dx = 10 }), K.TipGlow(FIRE, 35, 12), K.Flash(FIRE, 160, .2) })
R("incinerate",   { K.Converge(FIRE, 10), Bolt(M .. "P_FireOrb", 16, nil, .5, 1.8), K.Ring(FIRE, 180), K.Burst({ 1, .7, .3 }, "P_Flame", 12, 60) })
R("fear",         { DARK, Flee(6), K.FrontSprite("P_Soul", 28, { grow = { .6, 1.3 }, col = GHOST, add = true, bob = 4 }), Flee(8, true) })
R("howl",         { DARK, Flee(8), K.Ring(VOID, 300, { dur = .7, at = "icon" }), K.Ring({ .9, .7, 1 }, 200, { dur = .5, at = "icon" }) })
R("corruption",   { VEINS, K.Burst({ .5, .8, .2 }, "P_Drop", 4, 50) })
R("drainlife",    { K.ToIcon({ 1, .5, .5 }, "P_Drop", 12, .8, 10), K.IconGlow(BLOOD) })
R("drainmana",    { K.ToIcon({ .6, .8, 1 }, "P_Drop", 12, .8, 10), K.IconGlow(MANA) })
R("drainsoul",    { K.ToIcon(GHOST, "P_Soul", 6, .35, 16), K.IconGlow(VOID), K.IconGlow({ .9, .7, 1 }, 60) })
R("healthfunnel", { K.FromIcon({ 1, .3, .3 }, "P_Drop", 10, .8, 8), K.TipGlow({ .5, 1, .45 }, 40), K.Orbit({ .6, 1, .5 }, "P_Cross", 4, { r = 20, speed = 2, size = 9 }) })
R("rainfire",     { K.Fall(FIRE, M .. "P_Fireball", 10, { speed = 120, size = 16 }), K.Rise({ 1, .5, .2 }, "P_Smoke", 8, { speed = 20, size = 14 }) })
R("hellfire",     { FLAMES, K.Rise(FIRE, "P_Flame", 12, { speed = 45, size = 9 }) })
R("enslave",      { CHAINS, K.RuneCircle(FELC), K.Ring(FELC, 160) })
R("banish",       { K.RuneCircle(FELC, { r0 = 30, r1 = 20 }), K.Orbit({ .6, 1, .4 }, "P_Rune_02", 4, { r = 18, speed = 3, size = 14 }), K.Ring(FELC, 140) })
R("ritual",       { SIGIL, Portal(50) })
R("summon",       { K.RuneCircle(FELC), Portal(80), K.Flash(FELC, 260), K.Burst(FELC, "P_Flame", 12, 70) })
-- wrack (Forever, canalisé) : la cible est déchirée de l'intérieur, une salve d'éclats d'ombre chaque seconde
local TEAR = Part(9, function(st, c, o)
    if c.te and c.te >= .4 then return end
    local x = min(c.frontX, EX(c)); local u = c.te and c.te / .4 or c.t % 1
    for i = 0, 7 do
        local ang = i * pi / 4 + .4
        Put(st, o + i + 1, B .. "P_ShardBit", x + cos(ang) * (6 + 40 * u), Y(c) + sin(ang) * (4 + 24 * u), 18 * (1 - u * .4), math.deg(ang), 1 - u, { .85, .5, 1 }, true)
    end
    Put(st, o + 9, B .. "P_Soul", x, Y(c), 40 * (1.3 - u * .4), 0, .8 * (1 - u * .6), GHOST, true)
end)
R("wrack",        { K.TipGlow(VOID, 45), TEAR, K.IconGlow(VOID) })
R("felsteed",     { HOOVES, K.Rise(FELC, "P_Flame", 10, { speed = 40, size = 8 }), K.Ring(FELC, 180), K.Burst(FELC, "P_Flame", 12, 60) })

local FILL = { s = B .. "Fill_shadow", f = B .. "Fill_fire", g = B .. "Fill_summon" }
local FAM = { s = "wl_shadow", f = "wl_hell", g = "wl_fel" }
local VEIL = { s = VOID, f = FIRE, g = FELC }
local function S(props, school, extra)
    local L = { family = FAM[school], fill = FILL[school], props = { "wl_" .. props }, veil = VEIL[school], veilAlpha = { .1, .25 } }
    for k, v in pairs(extra or {}) do L[k] = v end
    return L
end
local FAST = { wakeCurve = 1.4 }
FCB.Looks:RegisterPack(M, {
    families = { "wl_shadow", "wl_hell", "wl_fel" },
    spells = {
        wl_shadowbolt = S("shadowbolt", "s"), wl_immolate = S("immolate", "f"),
        wl_soulfire = S("soulfire", "f", { shake = { late = 3, finish = 8 } }), wl_searing = S("searing", "f", FAST),
        wl_incinerate = S("incinerate", "f"), wl_fear = S("fear", "s", { wakeCurve = 1.4, shake = { late = 2 } }),
        wl_howl = S("howl", "s", { shake = { late = 2, finish = 10 } }), wl_corruption = S("corruption", "s"),
        wl_drainlife = S("drainlife", "s", { fill = "Fill_wl_blood", veil = BLOOD }), wl_drainmana = S("drainmana", "s", { fill = "Fill_wl_mana", veil = MANA }),
        wl_drainsoul = S("drainsoul", "s"), wl_healthfunnel = S("healthfunnel", "g"),
        wl_rainfire = S("rainfire", "f"), wl_hellfire = S("hellfire", "f"),
        wl_enslave = S("enslave", "g"), wl_banish = S("banish", "g", FAST), wl_ritual = S("ritual", "g"),
        wl_summon = S("summon", "g"), wl_felsteed = S("felsteed", "g"),
        wl_wrack = S("wrack", "s", { shake = { late = 2 } }),
    },
})
