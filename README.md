# Floodplain Tree Classification Tool

[![Shiny App](https://img.shields.io/badge/Shiny-App-blue)](https://higuchip.shinyapps.io/FloodplainTreeClassification/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-%3E%3D4.0-blue)](https://www.r-project.org/)


## Overview
Interactive Shiny application accompanying the paper **"Groundwater-based classification of floodplain trees: integrating water table preferences and tolerance ranges"** (Costa, K.J.S., Cruz, M.J.C., Hassan, V.O.C., Oliveira, C.V., Alves, D.S., Fortkamp, G., Silva, W.F., Santos, R.F., Silva, A.C., Higuchi, P., 2025, *Wetlands Ecology and Management* **33**, 84. https://doi.org/10.1007/s11273-025-10098-5).

This tool implements the hydrological classification framework, enabling researchers and managers to classify tree species based on their adaptation to water table variations in floodplain forests.

**🌐 Live App**: [https://higuchip.shinyapps.io/FloodplainTreeClassification/](https://higuchip.shinyapps.io/FloodplainTreeClassification/)

## Citation

If you use this tool in your research, please cite:
```
Costa, K.J.S., Cruz, M.J.C., Hassan, V.O.C., Oliveira, C.V., Alves, D.S., Fortkamp, G., Silva, W.F., Santos, R.F.,
Silva, A.C., Higuchi, P. (2025). Groundwater-based classification of floodplain trees: integrating water table
preferences and tolerance ranges. Wetlands Ecology and Management 33, 84. https://doi.org/10.1007/s11273-025-10098-5

```

## Features

- 📊 Calculate **Hydrophilic Affinity** and **Hydrological Amplitude** metrics
- 🌳 Classify species into four functional groups
- 📈 Compute the **Hydrological Niche Index (HNI)** (0-10 scale)
- 📁 Support for CSV files with flexible formatting
- 📥 Export comprehensive analysis reports (CSV and TXT)
- 📚 Interactive visualizations and diagnostic plots
- 💾 Download example datasets

## Methodology

The framework uses two key metrics:

1. **Hydrophilic Affinity**: Species preference for shallow water tables (0-1 scale)
2. **Hydrological Amplitude**: Species tolerance to water table variations (0-1 scale)

### Four Functional Groups

| Group | Characteristics |
|-------|----------------|
| **High-Affinity Generalists** | Prefer wet conditions AND tolerate variations |
| **High-Affinity Specialists** | Prefer wet conditions BUT narrow tolerance |
| **Low-Affinity Generalists** | Don't prefer wet BUT tolerate variations |
| **Low-Affinity Specialists** | Don't prefer wet AND narrow tolerance |

### Hydrological Niche Index (HNI)
```
HNI = (Hydrophilic Affinity × 0.5 + Hydrological Amplitude × 0.5) × 10
```

Higher HNI values indicate better adaptation to flooding.

## Quick Start

### 🌐 Online Version (Recommended)

Visit: [https://higuchip.shinyapps.io/FloodplainTreeClassification/](https://higuchip.shinyapps.io/FloodplainTreeClassification/)

### 💻 Local Installation

#### Prerequisites

- R >= 4.0
- Required packages: `shiny`, `shinydashboard`, `DT`, `ggplot2`, `dplyr`, `tidyr`, `plotly`, `analogue`, `viridis`

#### Installation Steps

1. **Clone the repository**
```bash
git clone https://github.com/higuchip/FloodplainTreeClassification.git
cd FloodplainTreeClassification
```

2. **Install dependencies**
```r
install.packages(c("shiny", "shinydashboard", "DT", "ggplot2", 
                   "dplyr", "tidyr", "plotly", "analogue", "viridis"))
```

3. **Run the app**
```r
shiny::runApp("app.R")
```

## Input Data Format

The tool requires two CSV files:

### 1. Water Table Data
| plot | water_table |
|------|-------------|
| 1    | 45.2        |
| 2    | 67.8        |

### 2. Community Data
| plot | species | dbh |
|------|---------|-----|
| 1    | Species A | 25.4 |
| 1    | Species B | 18.3 |

📥 Download example datasets from the app's **Upload Data** tab.

## Outputs

- **Species Classification Table**: Complete metrics for all analyzed species
- **Interactive Plots**: HNI rankings, functional group distributions, optima-tolerance relationships
- **Summary Report**: Detailed analysis statistics in TXT format
- **CSV Export**: All results for further analysis

## Author

**Pedro Higuchi** ([@higuchip](https://github.com/higuchip))

*Developer of the Shiny app implementing the methodology from Costa et al. (2025)*

## Contact

For questions or support:
- 🐛 Technical issues: Open an issue on [GitHub](https://github.com/higuchip/FloodplainTreeClassification/issues)
- 📧 General inquiries: [higuchip@gmail.com]

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This work was supported by CNPq, FAPESC, PAP/FAPESC/UDESC.

---

**Note**: This is a companion tool to a peer-reviewed scientific publication. For methodological details, please refer to the original paper.
