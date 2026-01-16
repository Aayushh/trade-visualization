# RPC (Rate Provision Code) Reference Guide

**Purpose**: Document all RPC codes used in USITC trade data to ensure accurate interpretation and analysis.

**Source**: U.S. International Trade Commission (USITC) Harmonized Tariff Schedule (HTS)

**Last Updated**: January 4, 2026

---

## Quick Reference

| RPC Code | Category | Status | Definition |
|----------|----------|--------|-----------|
| 00 | Bonded/FTZ | Other | Articles entered into bonded warehouses or Foreign Trade Zones |
| 10-19 | Free Items | Free | Various free status provisions (see below) |
| 61-79 | Dutiable Items | Dutiable | Various dutiable rate provisions (see below) |

---

## FREE ITEMS (RPC 10-19)

These items enter the U.S. duty-free under various provisions of HTS chapters 01-99.

### RPC 10 - Free (General)
**Definition**: Free under specific provisions for free status prescribed in Rates of Duty columns of HTS chapters 01 to 97, inclusive; or free under certain special classification provisions in HTS chapter 98 except those referred to, by HTS number, elsewhere in this list of rate provision codes.

**Usage**: General free entry under established HTS provisions

---

### RPC 13 - Free (Bond Export)
**Definition**: Free as articles to be processed under bond for exportation, including processes which result in articles manufactured or produced in the United States (see HTS number 9813.00.0520); or free for manufacture in bonded warehouse and export.

**Usage**: Goods entered for processing and re-export; bonded manufacturing

---

### RPC 14 - Free (Vessels/Aircraft)
**Definition**: Free as supplies for certain vessels and aircraft. Includes equipment and repairs to vessels if duty remitted.

**Usage**: Ship stores, aircraft equipment, vessel repairs

---

### RPC 16 - Free (U.S. Government)
**Definition**: Free as articles imported by or for the United States Government which otherwise would be dutiable under specific provisions in HTS chapters 01 to 97, inclusive, were it not for the following provisions for free entry in HTS chapter 98, subchapter VIII:
- Articles for military departments (HTS number 9808.00.3000)
- Articles for General Services Administration (HTS number 9808.00.4000)
- Articles for Nuclear Regulatory Commission or the Department of Energy (HTS number 9808.00.5000)
- Articles for the Commodity Credit Corporation (HTS number 9808.00.7000)

**Usage**: Government procurement, military imports

---

### RPC 17 - Free (Special Provisions)
**Definition**: Free for HTS numbers 9817.00.92, 9817.00.94, or 9817.00.96.

**Usage**: Specific HTS numbers with special free status

---

### RPC 18 - Free (Legislative/Special Programs)
**Definition**: Free under provisions established by legislation, Presidential Proclamation, or administrative action not covered by a more specific free rate provision. Free items specified in chapter 99 of the HTS and articles claiming free entry under special programs such as the Generalized System of Preferences (GSP) are assigned rate provision code 18.

**Usage**: 
- Generalized System of Preferences (GSP)
- Trade preference programs
- Presidential proclamations
- Chapter 99 free items

---

### RPC 19 - Free (Chapter 99)
**Definition**: Free under provisions for the free status prescribed in Rates of Duty columns of HTS chapter 99.

**Usage**: Free entry under temporary/emergency provisions in HTS Chapter 99

---

## OTHER ITEMS (RPC 00)

### RPC 00 - Bonded Warehouses / Foreign Trade Zones (FTZ)
**Definition**: Articles entered into bonded warehouses or Foreign Trade Zones, duty not applicable.

**Usage**: Temporary storage without immediate duty payment; not yet released into U.S. commerce

**Note**: These items do not immediately incur tariffs; duty status depends on whether they are re-exported or released into commerce.

---

## DUTIABLE ITEMS (RPC 61-79)

These items are subject to tariffs. The key distinction is between:
- **RPC 61-64** = Dutiable at rates in HTS chapters 01-97 (Established trade)
- **RPC 69, 70, 79** = Dutiable at rates in HTS chapter 99 (Trade War / Special)

### RPC 61 - Dutiable (General/MFN Rates)
**Definition**: Dutiable at rates prescribed in the **General Rates of Duty column** of HTS chapters 01 to 97, inclusive.

**Usage**: 
- Normal Most-Favored-Nation (MFN) tariff rates
- Applied to non-special trading partners (e.g., China as standard competitor)
- Long-standing tariff rates from HTS base structure
- **Key**: These are the baseline/MFN rates established in the HTS

**Analysis Note**: Rate 61 goods show strong margin compression (β ≈ -2.2), suggesting exporters have optimized supply chains and face strong substitution pressure.

---

### RPC 62 - Dutiable (Alternative Rates)
**Definition**: Dutiable at rates prescribed in the **Rates of Duty column labeled "2"** of HTS chapters 01 to 97, inclusive.

**Usage**: Alternative tariff rates for specific products or trading relationships (less common than RPC 61)

---

### RPC 64 - Dutiable (Special Rates)
**Definition**: Dutiable at rates prescribed in the **Special Rates of Duty column** in HTS chapters 01 to 97, inclusive.

**Usage**: 
- Tariffs negotiated under bilateral/regional trade agreements
- Preferential rates for FTAs (USMCA, etc.)
- Specialized product categories with non-standard rates

---

### RPC 69 - Dutiable (Chapter 99, Duty Calculated)
**Definition**: Dutiable at rates prescribed in **Chapter 99 of HTS**. **Duty reported.**

**Usage**: 
- **Trade War / Section 301 tariffs (primary use)**
- Trump-era tariffs (2018-2025) on Chinese goods and retaliatory items
- Emergency/special tariffs imposed outside normal HTS structure
- Ad-hoc tariffs added to Chapter 99

**Analysis Note**: Rate 69 goods show partial pass-through (β ≈ +0.27), indicating consumers bear significant burden from Trade War tariffs. This is the **critical distinction** in the "Friend-Shoring Inflation" hypothesis.

**Key Finding**: When comparing Rate 61 (MFN) vs. Rate 69 (Trade War):
- Rate 61: Exporters absorb costs (margin compression, β < 0)
- Rate 69: Costs pass to consumers (over-shifting, β > 0)
- **Implication**: New tariffs have greater consumer impact than established tariffs

---

### RPC 70 - Dutiable (Various Rates, No Duty Calculated)
**Definition**: Dutiable at various or special rates prescribed in Rates of Duty columns of HTS chapters 01 to 97, inclusive. **No duty calculated.**

**Usage**: Mixed tariff rates; duty waived or suspended for specific entries

---

### RPC 79 - Dutiable (Chapter 99, No Duty Calculated)
**Definition**: Dutiable at rates prescribed in Rates of Duty columns of HTS chapter 99. **No duty calculated.**

**Usage**: Chapter 99 items with duty suspended or not calculated for specific entries

---

## Analysis Implications

### RPC 61 vs RPC 69: The Core Distinction in Pass-Through Analysis

The distinction between RPC 61 and RPC 69 is **central to the Friend-Shoring Inflation hypothesis**:

| Dimension | RPC 61 (MFN) | RPC 69 (Trade War) |
|-----------|--------------|-------------------|
| **Established** | Yes; long-standing HTS | No; new/emergency Ch. 99 |
| **Supplier Adaptation** | High; optimized supply chains | Low; limited time to adjust |
| **Substitution Options** | Many; importers can switch | Few; new tariff on specific goods |
| **Expected Pass-Through** | Low (exporters absorb) | High (consumers pay) |
| **Empirical β Coefficient** | β ≈ -2.2*** | β ≈ +0.27* |
| **Consumer Impact** | **Favorable** (price falls) | **Unfavorable** (price rises) |

### Why This Matters for Trade War Analysis

When evaluating **friend-shoring policy** (shift from China to Mexico/Canada):

1. **Old tariffs (RPC 61)** on imports from adversaries (China) don't harm consumers much because exporters absorb costs
2. **New tariffs (RPC 69)** on allies (Mexico, Canada) harm consumers more because they face upstream shocks
3. **Vertical contagion**: Allied exporters relying on Chinese inputs face both direct tariffs (RPC 69) and upstream cost shocks
4. **Result**: Reshuffling to allies amplifies inflation through new tariff regimes (RPC 69)

---

## Data Quality Notes

### When Processing USITC Data

1. **RPC 00 (Bonded/FTZ)**: Exclude from most analyses unless studying warehousing patterns. These items haven't entered commerce and don't have final tariff status.

2. **RPC 10-19 (Free)**: Include when analyzing tariff incidence, but note that zero tariff does not mean zero pass-through (can have negative β if quality effects exist).

3. **RPC 61 vs 69 Split**: The split between RPC 61 and RPC 69 is **critical for identifying Trade War impacts**. Always report separately for policy analysis.

4. **Mixed RPC Groups**: Some product-country-month combinations have multiple RPCs. This indicates:
   - Product classification ambiguity
   - Multiple shipments with different tariff treatments
   - Possible classification gaming
   - **Recommendation**: Report both frequency and impact of mixed-RPC cases

---

## Reference Implementation in R

### Loading and Labeling RPCs

```r
rpc_labels <- data.table(
  rpc_code = c("00", "10", "13", "14", "16", "17", "18", "19", 
               "61", "62", "64", "69", "70", "79"),
  rpc_category = c("Bonded/FTZ [00]", "Free (HS 1-98) [10]", "Free (bond export) [13]", 
                   "Free (vessels/aircraft) [14]", "Free (govt) [16]", "Free (special) [17]", 
                   "Free (special prog) [18]", "Free (chapter 99) [19]",
                   "Dutiable (general) [61]", "Dutiable (normal) [62]", 
                   "Dutiable (special) [64]", "Dutiable (ch99) [69]", 
                   "Dutiable (no calc) [70]", "Dutiable (ch99 no calc) [79]"),
  rpc_status = c("Other", "Free", "Free", "Free", "Free", "Free", "Free", "Free",
                 "Dutiable", "Dutiable", "Dutiable", "Dutiable", "Dutiable", "Dutiable")
)

df <- merge(df, rpc_labels, by = "rpc_code", all.x = TRUE)
```

### Filtering for Analysis

```r
# For pass-through analysis (exclude bonded/FTZ)
df_analysis <- df[rpc_status %in% c("Free", "Dutiable")]

# For Trade War analysis (focus on RPC 69)
df_trade_war <- df[rpc_code == "69"]

# For comparison: MFN vs Trade War
df_comparison <- df[rpc_code %in% c("61", "69")]
```

---

## Related Files

- **USITC Data Structure**: `data/raw/readme_data_source.txt`
- **Cleaned Data Dictionary**: `data/clean/usitc_long.parquet` (column definitions)
- **Regression Analysis**: `scripts/03_run_all_regressions.R` (uses RPC distinctions)
- **RPC Analysis Visualizations**: `scripts/03_rpc_analysis.R`, `scripts/04_rpc_visualizations.R`

---

## Citation

U.S. International Trade Commission (USITC). *Harmonized Tariff Schedule (HTS)*. Rate Provision Code definitions derived from HTS documentation and USITC DataWeb.

---

## Version History

| Date | Update | Author |
|------|--------|--------|
| 2026-01-04 | Initial comprehensive guide with pass-through analysis context | GitHub Copilot |

