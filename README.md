# Floodplain Tree Classification Tool

[![Shiny App](https://img.shields.io/badge/Shiny-App-blue)](https://your-app-url.shinyapps.io/)

## Overview

Interactive Shiny application accompanying the paper **"Groundwater-based classification of floodplain trees: integrating water table preferences and tolerance ranges"** .

This tool implements the hydrological classification framework described in Costa et al. (2025), enabling researchers and managers to classify tree species based on their adaptation to water table variations in floodplain forests.

**Live App**: [https://higuchip.shinyapps.io/FloodplainTreeClassification/](https://higuchip.shinyapps.io/FloodplainTreeClassification/)

## Citation

If you use this tool in your research, please cite the paper:


## Features

- 📊 Calculate **Hydrophilic Affinity** and **Hydrological Amplitude** metrics
- 🌳 Classify species into four functional groups
- 📈 Compute the **Hydrological Niche Index (HNI)** (0-10 scale)
- 📁 Support for CSV files with flexible formatting options
- 📥 Export comprehensive analysis reports
- 📚 Interactive visualizations of species relationships

## Methodology

The framework uses two key metrics:

1. **Hydrophilic Affinity**: Species preference for shallow water tables (0-1 scale)
2. **Hydrological Amplitude**: Species tolerance to water table variations (0-1 scale)

These metrics classify species into four functional groups:
- **High-Affinity Generalists**: Prefer wet conditions AND tolerate variations
- **High-Affinity Specialists**: Prefer wet conditions BUT narrow tolerance
- **Low-Affinity Generalists**: Don't prefer wet BUT tolerate variations
- **Low-Affinity Specialists**: Don't prefer wet AND narrow tolerance

The **Hydrological Niche Index (HNI)** integrates both metrics:
HNI = (Hydrophilic Affinity × 0.5 + Hydrological Amplitude × 0.5) × 10

## Quick Start

### Online Version
Visit: [https://higuchip.shinyapps.io/FloodplainTreeClassification/]

### Local Installation

1. **Clone the repository**
```bash
git clone https://github.com/higuchip/FloodplainTreeClassification
cd FloodplainTreeClassification

