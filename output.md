# Resultat – optimal elproduktion och överföring

Körning av `optim.jl` (JuMP + Ipopt 3.14.19, MUMPS 5.9.0). Rådata finns i `output.txt`.

> Flöden och reaktiv effekt anges i **mpu** (1 mpu = 10⁻³ pu) och vinklar i **mrad** för läsbarhetens skull.

---

## 1. Sammanfattning

| Storhet | Värde |
|---|---|
| Solverstatus | `LOCALLY_SOLVED` – *EXIT: Optimal Solution Found* (20 iterationer, ≈ 2.7 s) |
| **Total produktionskostnad** | **183.244 SEK** |
| Total aktiv produktion | 0.790698 pu |
| Total efterfrågan | 0.790000 pu |
| Aktiva nätförluster | 0.698 mpu (≈ 0.09 % av efterfrågan) |
| Total reaktiv produktion ∑Qᵢ | 3.457 mpu (= ledningarnas reaktiva förbrukning) |
| Spänningsamplituder | 1.0172 – 1.0200 vu |
| Fasvinklar | −9.22 – 4.54 mrad |

Problemstorlek enligt Ipopt: 40 variabler (9 P + 9 Q + 11 v + 11 θ) och 23 likhetsvillkor
(11 aktiva + 11 reaktiva nodbalanser + referensvillkoret θ₁ = 0). Flödena p och q är uttryck, inte variabler.

---

## 2. Verifiering mot project.pdf

Lösningen har kontrollerats oberoende av JuMP: flödena räknades om direkt ur v och θ med
formlerna i avsnitt 2 i project.pdf, och varje villkor kontrollerades.

| # | Krav i project.pdf | Resultat | OK |
|---|---|---|---|
| 1 | Indata (tabell 2–4) korrekt inmatad | Samtliga b, g, nod, P̄, c och d stämmer | ✅ |
| 2 | Aktiv balans i varje nod (produktion − utflöde = efterfrågan) | max avvikelse 6·10⁻¹² | ✅ |
| 3 | Reaktiv balans i varje nod (ingen reaktiv efterfrågan) | max avvikelse 7·10⁻¹¹ | ✅ |
| 4 | 0 ≤ Pᵢ ≤ P̄ᵢ | uppfyllt (överskott ≤ 10⁻⁸, Ipopts tolerans) | ✅ |
| 5 | \|Qᵢ\| ≤ 0.03 P̄ᵢ | uppfyllt; minsta marginal 0.05 mpu (G5) | ✅ |
| 6 | 0.98 ≤ vₖ ≤ 1.02 | 1.0172 – 1.0200 | ✅ |
| 7 | −π ≤ θₖ ≤ π | \|θ\| ≤ 0.0092 rad (långt ifrån bindande) | ✅ |
| 8 | pₖₗ ≠ −pₗₖ (förluster i nätet) | pₖₗ + pₗₖ = gₖₗ\|Vₖ − Vₗ\|² > 0 på maskinprecision (2·10⁻¹⁵) | ✅ |
| 9 | Energibalans: ∑P − ∑D = förluster | 0.698 mpu = ∑₍ₖ,ₗ₎ pₖₗ | ✅ |
| 10 | Reaktiv balans globalt: ∑Q = ledningarnas förbrukning | 3.457 mpu = ∑₍ₖ,ₗ₎ qₖₗ | ✅ |
| 11 | Kostnad ≥ undre gräns utan förluster (183.0 SEK) | 183.244 SEK | ✅ |
| 12 | Samma optimum från olika startpunkter | 30 slumpade starter → alla 183.2443 SEK | ✅ |

**Varför kostnaden blir exakt 183.244 SEK:** utan förluster skulle efterfrågan täckas av de billigaste
generatorerna i kostnadsordning, och G6 (350 SEK/pu) skulle då producera 0.12 pu. Kostnaden blir då
183.0 SEK. Förlusterna på 0.698 mpu täcks helt av den marginella generatorn G6:
183.0 + 350 · 0.000698 = **183.244 SEK**. Den billigaste lösningen är alltså den som har minst
förluster, givet att alla billigare generatorer går för fullt.

---

## 3. Generatorer

Qᵢ > 0 betyder att generatorn producerar reaktiv effekt, Qᵢ < 0 att den absorberar.

| Gen. | Nod | cᵢ [SEK/pu] | P̄ᵢ [pu] | Pᵢ [pu] | Status | Qᵢ [mpu] | Gräns Q [mpu] | Kostnad [SEK] |
|---|---|---|---|---|---|---|---|---|
| G1 | 2 | 175 | 0.02 | 0.0200 | vid max | −0.04 | ±0.6 | 3.50 |
| G2 | 2 | 100 | 0.15 | 0.1500 | vid max | −1.96 | ±4.5 | 15.00 |
| G3 | 2 | 150 | 0.08 | 0.0800 | vid max | −0.64 | ±2.4 | 12.00 |
| G4 | 3 | 150 | 0.07 | 0.0700 | vid max | 1.82 | ±2.1 | 10.50 |
| G5 | 4 | 300 | 0.04 | 0.0400 | vid max | 1.15 | ±1.2 | 12.00 |
| G6 | 5 | 350 | 0.17 | **0.1207** | delvis | 0.63 | ±5.1 | 42.24 |
| G7 | 7 | 400 | 0.17 | **0.0000** | avstängd | 0.96 | ±5.1 | 0.00 |
| G8 | 9 | 300 | 0.26 | 0.2600 | vid max | 1.48 | ±7.8 | 78.00 |
| G9 | 9 | 200 | 0.05 | 0.0500 | vid max | 0.06 | ±1.5 | 10.00 |
| **Σ** | | | 1.01 | **0.7907** | | **3.46** | | **183.24** |

- Sju generatorer går på full kapacitet. **G6 är marginalgenerator** och täcker restbehovet och förlusterna.
  **G7**, den dyraste, används inte alls.
- De tre generatorerna i nod 2 (G1–G3) **absorberar** reaktiv effekt. De övriga producerar reaktiv effekt,
  och G5 ligger nära sin gräns (1.15 av 1.2 mpu).
- G7 producerar reaktiv effekt trots att den inte producerar någon aktiv effekt. Det är tillåtet
  eftersom Q-gränsen beror på P̄ᵢ och inte på Pᵢ.

---

## 4. Noder

Nodpriset är Lagrangemultiplikatorn (dualvariabeln) för den aktiva balansen: hur mycket totalkostnaden
ökar om efterfrågan i noden ökar med 1 pu.

| Nod | Efterfrågan Dₖ [pu] | Lokal produktion [pu] | vₖ [vu] | θₖ [mrad] | Nodpris [SEK/pu] |
|---|---|---|---|---|---|
| 1 | 0.10 | 0.0000 | 1.0192 | 0.00 (ref.) | 349.08 |
| 2 | — | 0.2500 | **1.0200** | **4.54** | 348.50 |
| 3 | — | 0.0700 | 1.0195 | 0.65 | 348.94 |
| 4 | 0.19 | 0.0400 | 1.0178 | −8.15 | 350.16 |
| 5 | — | 0.1207 | 1.0180 | −4.63 | 350.00 |
| 6 | 0.11 | 0.0000 | 1.0175 | **−9.22** | 350.35 |
| 7 | — | 0.0000 | 1.0179 | −5.73 | 350.07 |
| 8 | 0.09 | 0.0000 | **1.0172** | −6.78 | 350.57 |
| 9 | 0.21 | 0.3100 | 1.0194 | −0.76 | 349.04 |
| 10 | 0.05 | 0.0000 | 1.0191 | −1.39 | 349.18 |
| 11 | 0.04 | 0.0000 | 1.0193 | 0.05 | 349.02 |

- Alla spänningar ligger i **övre delen** av intervallet [0.98, 1.02], och nod 2 ligger på gränsen 1.02.
  Högre spänning ger lägre ström för samma överförda effekt och därmed lägre förluster.
- Nod 2 har högst fasvinkel och är nätets största aktiva källa. Nod 6 har lägst vinkel och ligger
  längst från den billiga produktionen.
- Nodpriset i nod 5 är exakt 350 SEK/pu, vilket är G6:s kostnad. Priset är lägre nära den billiga
  produktionen (nod 2) och högre längre bort (nod 8), eftersom varje extra pu som ska transporteras
  dit orsakar förluster.

---

## 5. Flöden i ledningarna

För varje ledning {k, ℓ} visas flödet sett från båda ändarna. Skillnaden mellan dem är förlusten,
pₖₗ + pₗₖ > 0. Riktningen anger åt vilket håll den aktiva effekten går.

| Ledning k–ℓ | Aktiv riktning | pₖₗ [mpu] | pₗₖ [mpu] | Aktiv förlust [mpu] | qₖₗ [mpu] | qₗₖ [mpu] | Reaktiv förbrukning [mpu] |
|---|---|---|---|---|---|---|---|
| 1–2 | 2 → 1 | −98.29 | 98.38 | 0.0911 | 2.28 | −1.84 | 0.444 |
| 1–11 | 11 → 1 | −1.71 | 1.71 | 0.0001 | −2.28 | 2.28 | 0.000 |
| 2–3 | 2 → 3 | 69.22 | −69.18 | 0.0385 | −0.91 | 1.18 | 0.269 |
| 2–11 | 2 → 11 | 82.40 | −82.34 | 0.0598 | 0.10 | 0.27 | 0.370 |
| 3–4 | 3 → 4 | **110.40** | −110.23 | 0.1650 | 2.98 | −2.01 | **0.975** |
| 3–9 | 3 → 9 | 28.78 | −28.77 | 0.0067 | −2.35 | 2.39 | 0.040 |
| 4–5 | 5 → 4 | −39.77 | 39.79 | 0.0205 | 3.16 | −3.02 | 0.139 |
| 5–6 | 5 → 6 | 59.34 | −59.30 | 0.0377 | −1.54 | 1.81 | 0.271 |
| 5–8 | 5 → 8 | 21.57 | −21.57 | 0.0069 | 5.19 | −5.14 | 0.051 |
| 6–7 | 7 → 6 | −50.70 | 50.72 | 0.0142 | −1.81 | 1.99 | 0.178 |
| 7–8 | 7 → 8 | 10.51 | −10.51 | 0.0023 | 5.24 | −5.22 | 0.015 |
| 7–9 | 9 → 7 | −61.22 | 61.28 | 0.0558 | −6.26 | 6.58 | 0.314 |
| 8–9 | 9 → 8 | −57.93 | 58.11 | **0.1875** | 10.36 | −10.04 | 0.327 |
| 9–10 | 9 → 10 | 9.38 | −9.38 | 0.0010 | 2.61 | −2.60 | 0.007 |
| 10–11 | 11 → 10 | −40.62 | 40.63 | 0.0109 | 2.60 | −2.54 | 0.058 |
| **Σ** | | | | **0.698** | | | **3.457** |

- **Huvudflödet:** den billiga produktionen i nod 2 (0.25 pu) delar sig i tre vägar: mot nod 1 (98 mpu),
  mot nod 11 (82 mpu, som sedan går vidare till 10 och 1) och mot nod 3 (69 mpu, som tillsammans med
  G4 går vidare till nod 4).
- **3–4 är den mest belastade ledningen** (110 mpu). **8–9 har störst aktiv förlust** trots ett måttligt
  flöde, eftersom den har högst konduktans (g = 4.41) och den lägsta susceptansen (|b| = 7.7).
- Flödet 7 → 6 kommer i sin tur från nod 9 (9 → 7), eftersom G7 inte producerar något. Nod 6 får
  alltså effekt både från nod 5 och via nod 9–7.
- Aktiv effekt går från högre till lägre fasvinkel. Det stämmer för alla 15 ledningarna
  (jämför θ i avsnitt 4).

---

## 6. Vad vi vet om lösningen

- **Problemet är icke-konvext.** Flödesekvationerna innehåller produkter vₖvₗ och cos/sin av
  vinkelskillnader. Likhetsvillkor som inte är affina ger en icke-konvex tillåten mängd.
- **Lösningen är en KKT-punkt och (numeriskt) lokalt optimal.** Ipopt konvergerade med
  dual infeasibility 1.6·10⁻⁸ och villkorsbrott 7·10⁻¹¹.
- **Global optimalitet kan inte bevisas**, men det finns starka indicier:
  1. Kostnaden ligger bara 0.244 SEK (0.13 %) över den förlustfria undre gränsen på 183.0 SEK, som
     gäller för alla tillåtna lösningar.
  2. 30 körningar från slumpade startpunkter gav alla samma optimum.
