# EDC App / Website Protocol — Original Source Content

> **Preservation note:** This file is a faithful markdown transcription of the original
> `EDC App.docx` (including its two embedded architecture diagrams, saved separately as
> `word/media/image1.png` and `image2.png` in the extracted archive). Content is preserved
> verbatim; only table structure has been reconstructed for readability.

A translation layer that connects real-world exposure (consumer products, environment) to
detection using a scanning app or web-based system.

---

## Table: EDCs + Detection via Scanning App / Web Platform

| S.No | EDC / Chemical | Common Sources | What User Scans | Detection Method (App/Web) | Backend Analytical Link | Output to User |
|---|---|---|---|---|---|---|
| 1 | Bisphenol A (BPA) | Plastic bottles, food containers | Barcode / product label | Ingredient database matching (AI OCR + barcode API) | LC-MS/MS (gold standard) | "High EDC risk – estrogenic chemical detected" |
| 2 | Phthalates (DEP, DBP) | Cosmetics, plastics | Cosmetic ingredient list | OCR + chemical name recognition | LC-MS/MS (urine metabolites) | "Endocrine disruptor – reproductive risk" |
| 3 | Parabens (Methylparaben) | Personal care products | Product label scan | Keyword detection (paraben family) | LC-MS/MS | "Weak estrogenic activity detected" |
| 4 | Tetrabromobisphenol A (TBBPA) | Electronics, e-waste | Device type / category | Database mapping (material composition) | GC-MS / LC-MS | "Flame retardant with thyroid disruption risk" |
| 5 | Tetramethrin | Mosquito repellents | Product barcode | Barcode lookup + pesticide database | GC-MS (metabolites) | "Neuro-endocrine risk in children" |
| 6 | Perchlorate | Drinking water | Location / water source | GIS + environmental database | Ion chromatography | "Thyroid disruption risk in water" |
| 7 | Diethyl Phthalate (DEP) | Perfumes, cosmetics | Label scan | OCR + ingredient parsing | LC-MS/MS | "High concern anti-androgenic chemical" |
| 8 | Galaxolide (HHCB) | Fragrances, detergents | Product scan | AI fragrance database mapping | LC-MS/MS | "Bioaccumulative EDC warning" |
| 9 | BHT | Packaged food | Barcode scan | Food additive database (INS/E numbers) | GC-MS / LC-MS | "Moderate endocrine interaction" |
| 10 | Resorcinol | Hair dyes | Label scan | OCR + cosmetic ingredient DB | LC-MS/MS | "Thyroid interference risk" |
| 11 | Heavy Metals (Cu, Pb) | Water, pipes | Water source / kit input | IoT sensor + manual entry | ICP-MS | "Toxic metal exposure risk" |
| 12 | Pyrethroids (general) | Household sprays | Barcode / product type | Pesticide classification database | GC-MS | "Neurodevelopmental risk" |

---

## Working

### 1. Input Layer (User Interaction)
- Barcode scanning (packaged products)
- Image capture (ingredient list)
- Manual entry (water source, location)

### 2. Processing Layer
- OCR (Google Vision / Tesseract)
- Chemical name extraction (NLP model)
- Mapping to EDC database (ECHA / WHO datasets already mentioned in your doc)

### 3. Detection Logic
Match chemical → EDC classification:
- Strong evidence
- Moderate concern
- Limited evidence

Use your classification already defined in document.

### 4. Output Layer
- Risk score (Low / Moderate / High)
- Affected system (thyroid, reproductive, neuro)
- Exposure route (diet, dermal, inhalation)

---

## Web Integration Options
- Open Food Facts API for packaged foods
- CosIng database (EU cosmetics) for ingredients
- ECHA database for EDC classification
- Environmental APIs (for water contamination)

## Linking App with Lab Validation
Your document already includes lab workflow:
Sample collection → extraction → GC-MS / LC-MS/MS analysis

Now extend it like this:

| App Result | Lab Confirmation |
|---|---|
| BPA detected in plastic | Urinary BPA via LC-MS/MS |
| Phthalate exposure suspected | Urinary metabolites |
| Perchlorate in water | Ion chromatography |
| Pyrethroid exposure | GC-MS metabolite analysis |

### Evidence tiers

| High Concern | Moderate Concern | Lower Evidence |
|---|---|---|
| BPA | Galaxolide | 3-methylpyrazole |
| TBBPA | BHT | Fragrance intermediates |
| Tetramethrin | Di-tert-butyl phenols | — |

---

## Clinical harms of EDCs in Paediatric and adults

| Chemical | Safety Level / Guideline Criteria | Mechanism of Toxicity | Paediatric Clinical Harms | Adult Clinical Harms | Overall Risk Category |
|---|---|---|---|---|---|
| Tetramethrin (pyrethroid) | WHO ADI: ~0.02 mg/kg/day (class-based) | Sodium channel neurotoxicity; possible neuroendocrine modulation | Neurodevelopmental delay (high exposure), behavioral changes, asthma exacerbation | Neurotoxicity, paresthesia, endocrine modulation (limited evidence) | Moderate concern |
| Ammonium Perchlorate | US EPA reference dose (RfD): 0.0007 mg/kg/day | Inhibits iodine uptake → thyroid hormone suppression | Hypothyroidism, impaired neurodevelopment, growth delay | Thyroid dysfunction, subclinical hypothyroidism | High concern (thyroid disruptor) |
| Diethyl Phthalate (DEP) | EFSA TDI (phthalate class-based) | Anti-androgenic; steroidogenesis interference | Early puberty, altered genital development (high exposure), metabolic risk | Reduced sperm quality, endocrine disruption | High concern |
| Bis(2-propylheptyl) phthalate | Phthalate group TDI applied | Anti-androgenic activity | Reproductive tract developmental effects | Fertility impairment | High concern |
| Bisphenol A (BPA) (previous list) | EFSA 2023 TDI: 0.2 ng/kg/day (extremely low) | Estrogen receptor agonist | Precocious puberty, obesity risk, behavioral disorders | Metabolic syndrome, reproductive dysfunction | High concern |
| Tetrabromobisphenol A (TBBPA) (previous list) | No global TDI; monitored | Thyroid hormone disruption | Thyroid dysfunction, neurodevelopmental risk | Thyroid imbalance | Moderate–High |
| Resorcinol | Cosmetic safety limit (≤1.25% topical use) | Thyroid peroxidase inhibition | Goiter risk (high exposure), thyroid imbalance | Thyroid dysfunction | Moderate concern |
| Methylparaben | Acceptable cosmetic limit ≤0.4% | Weak estrogenic activity | Early breast development (limited evidence) | Hormonal imbalance (weak evidence) | Low–Moderate |
| BHT (2,6-di-tert-butyl-p-cresol) | JECFA ADI: 0–0.3 mg/kg/day | Oxidative stress; weak endocrine interaction | Possible hyperactivity (controversial) | Liver enzyme elevation (high dose) | Low–Moderate |
| Galaxolide (synthetic musk) (previous list) | No established TDI; monitored | Bioaccumulation; possible estrogenic action | Accumulation in adipose tissue | Endocrine modulation (experimental evidence) | Moderate |
| Copper | WHO drinking water limit: 2 mg/L | Oxidative stress; excess affects endocrine balance | GI toxicity; liver damage (high exposure) | Hepatotoxicity; Wilson-like effects | Dose-dependent |
| Peracetic acid | Occupational exposure limits apply | Strong oxidizer (not endocrine) | Respiratory irritation | Respiratory irritation | Non-EDC; irritant risk |
| Alphachloralose | No ADI established | CNS depressant | Seizures (poisoning cases) | CNS depression | Acute toxicity risk |
| Perchlorate (water exposure context in India) | WHO provisional guideline: 0.07 mg/L | Thyroid inhibition | Cognitive impairment risk | Thyroid dysfunction | High concern |
| Phenolic antioxidants (methylenedi-xylenol derivatives) | No formal TDI | Potential estrogen receptor binding (theoretical) | Limited human evidence | Limited human evidence | Emerging concern |
| Silver-based antimicrobials | WHO silver guideline: 0.1 mg/L (drinking water) | Argyria (chronic exposure) | Rare systemic toxicity | Argyria (skin discoloration) | Low systemic endocrine risk |

---

## Severity level of EDCs

| Risk Level | Definition | Characteristics | Examples of EDCs |
|---|---|---|---|
| High Risk EDCs | Chemicals with strong endocrine-disrupting activity and proven adverse health effects | Strong hormonal receptor binding; Persistent and bioaccumulative; Linked to developmental and reproductive toxicity | Bisphenol A, Dioxins, PCBs |
| Moderate Risk EDCs | Chemicals with moderate evidence of endocrine disruption | Partial hormone interaction; Moderate exposure risk; Limited or emerging human evidence | Phthalates, Atrazine |
| Low Risk EDCs | Chemicals with weak or minimal endocrine-disrupting evidence | Weak receptor interaction; Low exposure levels; Limited biological impact | Some parabens, mild plant phytoestrogens |

---

## Master EDC Severity Reference Table

| No. | EDC | Severity | Major Effects | Reference / Typical Range |
|---|---|---|---|---|
| 1 | Bisphenol A (BPA) | High | Infertility, obesity, diabetes | 7.9–521.8 ng/L (water) (PMC) |
| 2 | Phthalates | High | Hormonal imbalance, reproductive defects | Urinary metabolites (µg/L, varies) |
| 3 | Dioxins | High | Cancer, immune suppression | Very low ppt levels considered toxic |
| 4 | PCBs | High | Neurotoxicity, developmental delay | Bioaccumulative (lipid-based) |
| 5 | PFAS | High | Thyroid dysfunction, cancer | 43–519 ng/L (water PFOA) (PMC) |
| 6 | Atrazine | Moderate | Reproductive toxicity | µg/L in groundwater |
| 7 | Perchlorate | Moderate | Thyroid hormone disruption | Drinking water µg/L |
| 8 | Parabens | Low–Moderate | Weak estrogenic effects | Low environmental levels |
| 9 | Triclosan | Moderate | Thyroid disruption | µg/L (urine/plasma) |
| 10 | PBDEs | High | Neurodevelopmental delay | Persistent in fat tissue |
| 11 | Nonylphenol | High | Estrogenic activity | 12–547 ng/L (PMC) |
| 12 | Alkylphenols | Moderate | Hormone disruption | Environmental ng/L |
| 13 | DDT/DDE | High | Reproductive toxicity | Persistent, bioaccumulative |
| 14 | Vinclozolin | Moderate | Antiandrogenic effects | Agricultural exposure |
| 15 | Methoxychlor | Moderate | Estrogenic effects | Soil/water exposure |
| 16 | Glyphosate | Low–Moderate | Possible endocrine effects | µg/L |
| 17 | Lead | High | Neurodevelopmental delay | Blood: >5 µg/dL unsafe |
| 18 | Cadmium | High | Kidney, endocrine toxicity | Blood/urine µg/L |
| 19 | Arsenic | High | Cancer, endocrine effects | WHO limit: 10 µg/L |
| 20 | Mercury | High | Neurotoxicity | Blood µg/L |
| 21 | Perfluorooctane sulfonate (PFOS) | High | Immune and endocrine effects | ng/L |
| 22 | BPS (Bisphenol S) | Moderate | BPA-like effects | Emerging data |
| 23 | BPF (Bisphenol F) | Moderate | Hormonal disruption | Limited data |
| 24 | Phytoestrogens | Low | Mild estrogenic effects | Dietary levels |
| 25 | DES (Diethylstilbestrol) | High | Cancer, reproductive defects | No safe level |
| 26 | Flame retardants | High | Thyroid disruption | Persistent |
| 27 | Organophosphates | Moderate | Neuroendocrine toxicity | Exposure dependent |
| 28 | Chlorpyrifos | High | Neurodevelopmental toxicity | µg/L |
| 29 | Carbamates | Moderate | Endocrine interference | Variable |
| 30 | Benzophenones | Moderate | Estrogenic activity | Cosmetic exposure |
| 31 | UV filters | Low–Moderate | Hormonal disruption | Low environmental levels |
| 32 | Microplastics | Emerging | Hormone disruption via carriers | No standard range |
| 33 | Nanoplastics | Emerging | Cellular toxicity | No standard range |
| 34 | Perfluorinated compounds | High | Metabolic disorders | ng/L |
| 35 | Tributyltin | High | Obesity, endocrine disruption | ng/L |
| 36 | Bisphenol analogues | Moderate | Estrogen mimic | Emerging concern |
| 37 | Synthetic hormones (EE2) | High | Reproductive disruption | ~0.3 ng/L (PMC) |

---

## Embedded Diagrams (from original docx)

- **image1.png** — "EDC Scanning App Architecture": 5 layers (User Input → Processing →
  Database & Knowledge Base → Risk Assessment Engine → Output & Action Layer) plus a Lab
  Validation & Feedback Loop, and 6 phone-screen mockups (Home, Scan Options, Scanning,
  Result, Chemical Details, History & Trends).
- **image2.png** — "EDC Detection App Architecture": 7 layers (Input → Processing → Database
  & Knowledge Base → Risk Assessment Engine → Output → Laboratory Validation Workflow →
  Feedback & Learning Loop) with External Databases & Integration sidebar and a risk-level legend.
