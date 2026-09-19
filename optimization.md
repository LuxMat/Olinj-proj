**TMA947 / MMG621 – Olinjär optimering, projektuppgift**

---

## 1. Mängder

| Symbol | Definition | Storlek |
|---|---|---|
| $\mathcal{N}$ | Noderna i nätet, $\mathcal{N}=\{1,\dots,11\}$ | 11 |
| $\mathcal{E}$ | Oriktade kanter (transmissionsledningar), $\{k,\ell\}$ | 15 |
| $\mathcal{A}$ | Riktade bågar, $\mathcal{A}=\{(k,\ell),(\ell,k) : \{k,\ell\}\in\mathcal{E}\}$ | 30 |
| $\mathcal{N}_k$ | Grannar till nod $k$, dvs. $\{\ell : \{k,\ell\}\in\mathcal{E}\}$ | – |
| $\mathcal{G}$ | Generatorerna, $\mathcal{G}=\{1,\dots,9\}$ | 9 |
| $\mathcal{G}_k$ | De generatorer som är placerade i nod $k$ | – |
| $\mathcal{C}$ | Konsumenterna, $\mathcal{C}=\{1,\dots,7\}$ | 7 |
| $\mathcal{C}_k$ | De konsumenter som är placerade i nod $k$ | – |

**Observera att flödesvariablerna indexeras över $\mathcal{A}$ och inte över $\mathcal{E}$.** Eftersom nätet har
förluster gäller $p_{k\ell}\neq -p_{\ell k}$, och varje ledning måste därför beskrivas av två separata
flöden — ett sett från vardera änden.

---

## 2. Parametrar (data)

| Symbol | Enhet | Betydelse |
|---|---|---|
| $g_{k\ell}$ | pu | Konduktans för ledningen mellan $k$ och $\ell$; realdelen av admittansen. Det är $g_{k\ell}>0$ som ger de resistiva förlusterna. Symmetrisk: $g_{k\ell}=g_{\ell k}$. |
| $b_{k\ell}$ | pu | Susceptans för samma ledning; imaginärdelen av admittansen. $b_{k\ell}<0$ eftersom ledningar är induktiva. Symmetrisk: $b_{k\ell}=b_{\ell k}$. |
| $c_i$ | SEK/pu | Marginalkostnad för aktiv effekt från generator $i$. |
| $\bar{P}_i$ | pu | Maximal aktiv produktionskapacitet för generator $i$. |
| $D_k$ | pu | Aggregerad efterfrågan på aktiv effekt i nod $k$: $D_k=\sum_{j\in\mathcal{C}_k}d_j$. |
| $\underline{v}=0.98$, $\bar{v}=1.02$ | vu | Tillåtet intervall för spänningsamplituden. |

### Numeriska värden

**Kantparametrar (Tabell 2).** Notera att samtliga $g_{k\ell}>0$ och samtliga $b_{k\ell}<0$, vilket är
fysikaliskt konsistent.

| $(k,\ell)$ | $b_{k\ell}$ | $g_{k\ell}$ | $(k,\ell)$ | $b_{k\ell}$ | $g_{k\ell}$ |
|---|---|---|---|---|---|
| (1,2) | −20.1 | 4.12 | (5,8) | −9.2 | 1.26 |
| (1,11) | −22.3 | 5.67 | (6,7) | −13.9 | 1.11 |
| (2,3) | −16.8 | 2.41 | (7,8) | −8.7 | 1.32 |
| (2,11) | −17.2 | 2.78 | (7,9) | −11.3 | 2.01 |
| (3,4) | −11.7 | 1.98 | (8,9) | −7.7 | 4.41 |
| (3,9) | −19.4 | 3.23 | (9,10) | −13.5 | 2.14 |
| (4,5) | −10.8 | 1.59 | (10,11) | −26.7 | 5.06 |
| (5,6) | −12.3 | 1.71 | | | |

**Generatorer (Tabell 3).**

| $i$ | Nod | $\bar{P}_i$ [pu] | $c_i$ [SEK/pu] |
|---|---|---|---|
| G1 | 2 | 0.02 | 175 |
| G2 | 2 | 0.15 | 100 |
| G3 | 2 | 0.08 | 150 |
| G4 | 3 | 0.07 | 150 |
| G5 | 4 | 0.04 | 300 |
| G6 | 5 | 0.17 | 350 |
| G7 | 7 | 0.17 | 400 |
| G8 | 9 | 0.26 | 300 |
| G9 | 9 | 0.05 | 200 |

Total kapacitet: $\sum_{i\in\mathcal{G}}\bar{P}_i=1.01$ pu.

**Aggregerad efterfrågan (Tabell 4).**

$$D_1=0.10,\quad D_4=0.19,\quad D_6=0.11,\quad D_8=0.09,\quad D_9=0.21,\quad D_{10}=0.05,\quad D_{11}=0.04$$

och $D_k=0$ för $k\in\{2,3,5,7\}$. Total efterfrågan: $\sum_{k\in\mathcal{N}}D_k=0.79$ pu.

---

## 3. Variabler

| Symbol | Enhet | Index | Betydelse |
|---|---|---|---|
| $P_i$ | pu | $i\in\mathcal{G}$ | Aktiv effekt producerad av generator $i$ |
| $Q_i$ | pu | $i\in\mathcal{G}$ | Reaktiv effekt genererad ($Q_i>0$) eller absorberad ($Q_i<0$) av generator $i$ |
| $v_k$ | vu | $k\in\mathcal{N}$ | Spänningsamplitud i nod $k$ |
| $\theta_k$ | rad | $k\in\mathcal{N}$ | Spänningens fasvinkel i nod $k$ |
| $p_{k\ell}$ | pu | $(k,\ell)\in\mathcal{A}$ | Aktiv effekt som lämnar nod $k$ på väg mot nod $\ell$ |
| $q_{k\ell}$ | pu | $(k,\ell)\in\mathcal{A}$ | Reaktiv effekt som lämnar nod $k$ på väg mot nod $\ell$ |

De verkliga besluten är $(P,Q,v,\theta)$. Flödena $p_{k\ell}$ och $q_{k\ell}$ är **hjälpvariabler** som är
fullständigt bestämda av nodtillståndet via ekvationerna nedan; de behålls i modellen enbart
för läsbarhet och för att kunna redovisa flödena i resultatet.

---

## 4. Modellen

$$
\begin{array}{llr}
\displaystyle\min_{P,\,Q,\,v,\,\theta,\,p,\,q} & \displaystyle\sum_{i\in\mathcal{G}} c_i P_i & (1)\\[5mm]
\text{u.b.} & p_{k\ell} = v_k^2 g_{k\ell} - v_kv_\ell g_{k\ell}\cos(\theta_k-\theta_\ell) - v_kv_\ell b_{k\ell}\sin(\theta_k-\theta_\ell), & (k,\ell)\in\mathcal{A} \quad (2)\\[3mm]
& q_{k\ell} = -v_k^2 b_{k\ell} + v_kv_\ell b_{k\ell}\cos(\theta_k-\theta_\ell) - v_kv_\ell g_{k\ell}\sin(\theta_k-\theta_\ell), & (k,\ell)\in\mathcal{A} \quad (3)\\[5mm]
& \displaystyle\sum_{i\in\mathcal{G}_k} P_i - \sum_{\ell\in\mathcal{N}_k} p_{k\ell} = D_k, & k\in\mathcal{N} \quad (4)\\[5mm]
& \displaystyle\sum_{i\in\mathcal{G}_k} Q_i - \sum_{\ell\in\mathcal{N}_k} q_{k\ell} = 0, & k\in\mathcal{N} \quad (5)\\[5mm]
& 0 \le P_i \le \bar{P}_i, & i\in\mathcal{G} \quad (6)\\[2mm]
& |Q_i| \le 0.03\,\bar{P}_i, & i\in\mathcal{G} \quad (7)\\[2mm]
& 0.98 \le v_k \le 1.02, & k\in\mathcal{N} \quad (8)\\[2mm]
& -\pi \le \theta_k \le \pi, & k\in\mathcal{N} \quad (9)\\[2mm]
& \theta_1 = 0 & (10)
\end{array}
$$

---

## 5. Motivering av varje del

### (1) Målfunktion

Den totala produktionskostnaden är summan av producerad aktiv effekt gånger respektive
marginalkostnad. Reaktiv effekt ingår inte, eftersom uppgiften anger att den är kostnadsfri.
Målfunktionen är **linjär**, och därmed både konvex och konkav. All icke-konvexitet i problemet
kommer följaktligen uteslutande från bivillkoren.

### (2)–(3) Flödesekvationer

Dessa uttrycker Ohms lag i komplex form. Med $V_k=v_ke^{j\theta_k}$ och admittansen
$Y_{k\ell}=g_{k\ell}+jb_{k\ell}$ ges den komplexa effekten från $k$ mot $\ell$ av
$S_{k\ell}=V_k\overline{(V_k-V_\ell)\,Y_{k\ell}}$, vars real- och imaginärdel är just (2) respektive (3).

Ekvationerna säger att **flödet inte är något som väljs, utan en konsekvens av spänningstillståndet
i ledningens två ändnoder**. En nätoperatör kan inte styra flödet i en enskild ledning; det som kan
styras är produktionen och spänningssättpunkterna, varefter flödena fördelar sig enligt
Kirchhoffs lagar. Detta är den avgörande skillnaden mot ett vanligt linjärt nätverksflödesproblem.

Kontroll: sätts $v_k=v_\ell$ och $\theta_k=\theta_\ell$ fås $p_{k\ell}=q_{k\ell}=0$ — ingen
spänningsskillnad ger inget flöde.

### (4) Aktiv effektbalans

Kirchhoffs strömlag i nod $k$: lokal produktion minus utgående flöden ska exakt täcka den lokala
efterfrågan. En generator och en konsument i samma nod kan alltså mötas direkt utan att belasta
nätet.

Villkoret är en **jämlikhet**, inte en olikhet. En elektrisk nod har ingen buffert som kan absorbera
ett överskott — effekt kan varken försvinna ur eller uppstå i en nod.

Summeras (4) över alla noder erhålls den systemomfattande identiteten

$$\sum_{i\in\mathcal{G}}P_i - \sum_{k\in\mathcal{N}}D_k \;=\; \sum_{(k,\ell)\in\mathcal{A}}p_{k\ell} \;=\; \sum_{\{k,\ell\}\in\mathcal{E}} g_{k\ell}\,|V_k-V_\ell|^2 \;\ge\; 0,$$

dvs. total produktion måste överstiga total efterfrågan med exakt nätförlusterna.

### (5) Reaktiv effektbalans

Generatorerna är enligt förutsättningarna de enda enheter som kan generera eller absorbera
reaktiv effekt, och konsumenterna har ingen reaktiv efterfrågan. Högerledet är därför noll.

Villkoret får inte utelämnas trots att $Q$ varken kostar något eller efterfrågas. Skälet är att
ledningarna **konsumerar** reaktiv effekt,

$$q_{k\ell}+q_{\ell k} = -b_{k\ell}\,|V_k-V_\ell|^2 > 0 \qquad (\text{ty } b_{k\ell}<0),$$

och att (5) är det villkor som kopplar spänningsamplituderna till varandra. Utan (5) skulle $v_k$
kunna väljas fritt inom sitt intervall utan fysikalisk konsekvens.

I noder utan generator ($k\in\{1,6,8,10,11\}$) reduceras villkoret till
$\sum_{\ell\in\mathcal{N}_k}q_{k\ell}=0$ — ett hårt villkor som tvingar den reaktiva effekten att
passera rakt igenom noden.

### (6)–(7) Kapacitetsvillkor för generatorerna

Aktiv produktion är icke-negativ och begränsad uppåt av den installerade kapaciteten. Den
reaktiva kapabiliteten är symmetrisk kring noll och utgör högst 3 % av **maxkapaciteten**
$\bar{P}_i$, alltså en konstant — inte av den producerade effekten $P_i$. Hade gränsen berott på
$P_i$ hade villkoret blivit ytterligare ett olinjärt, kopplande bivillkor.

Den totala reaktiva budgeten är $0.03\cdot 1.01\approx 0.030$ pu, vilket är stramt i förhållande till
ledningarnas reaktiva konsumtion.

### (8)–(9) Tekniska gränser i noderna

Spänningsamplituden måste hållas nära nominellt värde eftersom ansluten utrustning är
konstruerad för det; $\pm 2\,\%$ är en typisk driftmarginal. Intervallet är smalt men inte en punkt,
vilket ger optimeraren ett verkligt spelrum att välja spänningsprofil.

Vinkelgränserna är i praktiken inte bindande. Med $|b_{k\ell}|\sim 20$ krävs endast
$\Delta\theta\approx p/|b|\approx 0.005$ rad för att transportera 0.1 pu; villkoret finns där för att
vinklar är definierade modulo $2\pi$.

### (10) Referensnod

Flödena i (2)–(3) beror enbart på differenserna $\theta_k-\theta_\ell$. Om $\theta$ är tillåten är
$\theta+c\mathbf{1}$ det också, med identiskt målfunktionsvärde. Utan (10) har varje optimallösning
alltså en kontinuerlig familj av kopior, vilket får tre konsekvenser:

* lösningen är aldrig unik;
* Hessianen blir singulär längs den platta riktningen, varför andra ordningens tillräckliga villkor
  inte kan uppfyllas och strikt lokal optimalitet inte kan hävdas;
* solvern kan få konvergensproblem.

Nod 1 väljs som referens (s.k. *slack bus*); valet är godtyckligt.

### Vad som *inte* är ett bivillkor

Relationerna

$$p_{k\ell}\neq -p_{\ell k}, \qquad q_{k\ell}\neq -q_{\ell k}, \qquad \sum_k p_{k\ell}\neq -\sum_k p_{\ell k}$$

är **egenskaper hos modellen**, inte villkor som ska ställas på lösningen. De följer automatiskt av
(2)–(3) tillsammans med $g_{k\ell}>0$, eftersom

$$p_{k\ell}+p_{\ell k} = g_{k\ell}\,|V_k-V_\ell|^2 > 0 \quad\text{då } V_k \neq V_\ell .$$

De hör hemma i löptexten som motivering till varför flödena indexeras över riktade bågar, och får
inte placeras bland bivillkoren.

---

## 6. Egenskaper hos problemet

### Frihetsgrader

| Post | Antal |
|---|---|
| Variabler $P$ | 9 |
| Variabler $Q$ | 9 |
| Variabler $v$ | 11 |
| Variabler $\theta$ | 11 |
| Villkor (10) | −1 |
| **Oberoende variabler** | **39** |
| Aktiv balans (4) | −11 |
| Reaktiv balans (5) | −11 |
| **Återstående frihetsgrader** | **17** |

(Flödena $p,q$ är eliminerade via (2)–(3) och räknas inte.) Att differensen är strikt positiv är
anledningen till att detta är ett *optimeringsproblem* och inte ett rent ekvationssystem. Vore den
noll skulle systemets tillstånd vara entydigt bestämt och det skulle inte finnas något att välja
mellan.

### Konvexitet

Målfunktionen (1) är linjär och lådvillkoren (6)–(9) definierar en konvex mängd. Däremot är
jämlikhetsvillkoren (2)–(5) icke-affina på tre oberoende sätt:

| Term | Typ av olinjäritet |
|---|---|
| $v_k^2 g_{k\ell}$ | kvadratisk |
| $v_kv_\ell(\cdot)$ | bilinjär, indefinit |
| $\cos(\theta_k-\theta_\ell)$, $\sin(\theta_k-\theta_\ell)$ | trigonometrisk, icke-monoton |

En mängd $\{z : h(z)=0\}$ är konvex endast om $h$ är affin. Eftersom så inte är fallet här är den
**tillåtna mängden icke-konvex**, och problemet är ett icke-konvext olinjärt program.

### Optimalitet

Ipopt är en inrepunktsmetod som konvergerar mot en punkt som uppfyller KKT-villkoren. För ett
icke-konvext problem gäller:

* KKT är, under lämplig *constraint qualification* (t.ex. LICQ), ett **nödvändigt** villkor för lokalt
  optimum, men **inte tillräckligt** för globalt optimum.
* Uppfylls andra ordningens tillräckliga villkor (positivt definit reducerad Hessian på
  tangentrummet) är den erhållna punkten **strikt lokalt optimal**.
* **Global optimalitet kan inte garanteras.** Empiriskt stöd kan erhållas genom att lösa problemet
  från många slumpmässiga startpunkter och konstatera om samma målfunktionsvärde
  återkommer — detta är dock indicier, inte bevis.

### Undre gräns på det globala optimumet

En giltig undre gräns fås genom att bortse från förlusterna och täcka efterfrågan 0.79 pu med de
billigaste generatorerna i kostnadsordning:

| Ordning | Generator | $c_i$ | $\bar{P}_i$ | Kumulativt |
|---|---|---|---|---|
| 1 | G2 | 100 | 0.15 | 0.15 |
| 2 | G3 | 150 | 0.08 | 0.23 |
| 3 | G4 | 150 | 0.07 | 0.30 |
| 4 | G1 | 175 | 0.02 | 0.32 |
| 5 | G9 | 200 | 0.05 | 0.37 |
| 6 | G5 | 300 | 0.04 | 0.41 |
| 7 | G8 | 300 | 0.26 | 0.67 |
| 8 | G6 | 350 | 0.12 | 0.79 |

$$f_{\text{undre}} = 100(0.15)+150(0.15)+175(0.02)+200(0.05)+300(0.30)+350(0.12) = 183{,}0 \text{ SEK}$$

Eftersom förlusterna är icke-negativa gäller $f^\star \ge 183{,}0$ SEK. Ligger den numeriska
lösningen strax över detta värde är det ett starkt indicium på att ingen dålig lokal optimum har
träffats.

---

## 7. Verifiering av den numeriska lösningen

| # | Kontroll | Förväntat |
|---|---|---|
| 1 | Teckenkontroll på data | $g_{k\ell}>0$, $b_{k\ell}<0$ för alla kanter |
| 2 | Symmetri | $g_{k\ell}=g_{\ell k}$, $b_{k\ell}=b_{\ell k}$ |
| 3 | Nollflöde | $v_k=v_\ell$, $\theta_k=\theta_\ell \Rightarrow p_{k\ell}=q_{k\ell}=0$ |
| 4 | Förlustidentitet | $p_{k\ell}+p_{\ell k} = g_{k\ell}\lvert V_k-V_\ell\rvert^2$ på maskinprecision |
| 5 | Energibalans | $\sum_i P_i - 0.79 = \sum_{(k,\ell)\in\mathcal{A}}p_{k\ell} > 0$ |
| 6 | Reaktiv budget | $\lvert Q_i\rvert \le 0.03\bar{P}_i$ för varje $i$; $\sum_i Q_i > 0$ |
| 7 | Kostnadsgräns | $f^\star \ge 183{,}0$ SEK |

Kontroll 5 är den viktigaste. Om $\sum_i P_i$ är exakt 0.79 pu har flödena sannolikt implementerats
antisymmetriskt ($p_{k\ell}=-p_{\ell k}$), vilket är fel. Är summan mindre än 0.79 pu är modellen
definitivt felaktig.

---

## 8. Implementation i Julia / JuMP

```julia

---

## 9. Tolkningsnyckel för resultatavsnittet

Eftersom $|b_{k\ell}| \gg g_{k\ell}$ (kvoten ligger mellan 1.7 och 12.5 i datan) är ledningarna
övervägande induktiva. Med $v\approx 1$ och små vinklar gäller approximativt

$$p_{k\ell} \approx -b_{k\ell}(\theta_k-\theta_\ell), \qquad q_{k\ell} \approx -b_{k\ell}\,v_k(v_k-v_\ell),$$

där $-b_{k\ell}>0$. Detta ger två tumregler som kan användas för att tolka den numeriska lösningen:

* **Aktiv effekt flödar från högre fasvinkel till lägre.** Noden med högst $\theta_k$ är nätets
  dominerande aktiva källa.
* **Reaktiv effekt flödar från högre spänningsamplitud till lägre.** Spänningsprofilen avslöjar var
  den reaktiva effekten produceras.

Vidare noteras att en avsevärd del av den billiga kapaciteten (G1, G2, G3 med totalt 0.25 pu) är
placerad i nod 2, som saknar lokal efterfrågan. Den billiga produktionen måste därför överföras,
vilket kostar i form av förluster. Avvägningen mellan att använda billig men avlägsen produktion
och dyrare men lokal produktion är den huvudsakliga ekonomiska mekanismen i modellen.
