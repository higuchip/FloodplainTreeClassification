# ==============================================================================
# SHINY APP - GROUNDWATER-BASED CLASSIFICATION OF FLOODPLAIN TREES
# Companion App for: Costa et al. 
# Copyright (c) 2025 Higuchi P.
# Licensed under the MIT License
# ==============================================================================

# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(dplyr)
library(tidyr)
library(plotly)
library(analogue)
library(viridis)

# ==============================================================================
# USER INTERFACE (UI)
# ==============================================================================

ui <- dashboardPage(
  dashboardHeader(
    title = "Floodplain Tree Classification Tool",
    titleWidth = 350
  ),
  
  dashboardSidebar(
    width = 250,
    
    # Welcome section
    h4("Welcome!", style = "color: #fff; padding: 10px;"),
    p("This tool helps classify tree species based on their adaptation to water table variations.", 
      style = "color: #fff; padding: 0 10px; font-size: 12px;"),
    
    hr(),
    
    sidebarMenu(
      id = "tabs",  # Add ID for navigation
      menuItem("Getting Started", tabName = "intro", icon = icon("info-circle")),
      menuItem("Upload Data", tabName = "data", icon = icon("upload")),
      menuItem("Species Analysis", tabName = "analysis", icon = icon("chart-line")),
      menuItem("Functional Groups", tabName = "groups", icon = icon("sitemap")),
      menuItem("Export Results", tabName = "export", icon = icon("download")),
      menuItem("Help & Tutorial", tabName = "help", icon = icon("question-circle"))
    ),
    
    hr(),
    
    # Global settings with tooltips
    h4("Analysis Settings"),
    
    div(
      numericInput("n_species", 
                   HTML("Number of species to analyze 
                        <span style='color: #fff; font-size: 11px;'>
                        (Recommend: 10-15 species)<br>
                        <span style='color: #ffc107;'>⚠ Changing this affects classifications</span></span>"),
                   value = 10, min = 5, max = 30, step = 1),
      
      numericInput("water_replacement", 
                   HTML("Replace zero values with (cm)
                        <span style='color: #fff; font-size: 11px;'>
                        (Default: 100 = well depth limit)</span>"),
                   value = 100, min = 50, max = 200, step = 10),
      
      br(),
      actionButton("run_analysis", "Run Analysis", 
                   class = "btn-success btn-block",
                   icon = icon("play"))
    )
  ),
  
  dashboardBody(
    # Custom CSS
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
        .info-box-number {
          font-size: 30px;
        }
        .info-box-text {
          font-size: 14px;
        }
        .example-data {
          background-color: #f0f8ff;
          padding: 10px;
          border-radius: 5px;
          margin: 10px 0;
        }
        .method-box {
          background-color: #fff;
          padding: 15px;
          border-left: 4px solid #3c8dbc;
          margin: 10px 0;
        }
        .tutorial-step {
          background-color: #e8f5e9;
          padding: 10px;
          border-radius: 5px;
          margin: 5px 0;
        }
      "))
    ),
    
    tabItems(
      # Tab 1: Introduction and Context
      tabItem(
        tabName = "intro",
        fluidRow(
          box(
            title = "Welcome to the Floodplain Tree Classification Tool",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            
            h3("About This Tool"),
            p("This application implements the classification framework described in:",
              strong("'Groundwater-based classification of floodplain trees: integrating water table preferences and tolerance ranges'")),
            p("Published in Wetlands Ecology and Management"),
            
            br(),
            
            h4("What Does This Tool Do?"),
            div(class = "method-box",
                p("This tool helps researchers, managers, and students classify tree species based on how they respond to water table variations in floodplain forests. The classification uses two main metrics:"),
                tags$ul(
                  tags$li(strong("Hydrophilic Affinity:"), " How much a species prefers wet conditions (shallow water table)"),
                  tags$li(strong("Hydrological Amplitude:"), " How tolerant a species is to water table variations")
                ),
                p("These metrics combine to create the", strong("Hydrological Niche Index (HNI)"), 
                  "which ranges from 0 to 10, where higher values indicate better adaptation to flooding.")
            ),
            
            br(),
            
            h4("The Four Functional Groups"),
            fluidRow(
              column(6,
                     div(style = "background-color: #1f77b4; color: white; padding: 10px; border-radius: 5px;",
                         h5("High-Affinity Generalists"),
                         p("Prefer wet conditions AND tolerate variations", br())
                     ),
                     br(),
                     div(style = "background-color: #87CEEB; padding: 10px; border-radius: 5px;",
                         h5("High-Affinity Specialists"),
                         p("Prefer wet conditions BUT narrow tolerance", br())
                     )
              ),
              column(6,
                     div(style = "background-color: #228B22; color: white; padding: 10px; border-radius: 5px;",
                         h5("Low-Affinity Generalists"),
                         p("Don't prefer wet BUT tolerate variations", br())
                     ),
                     br(),
                     div(style = "background-color: #90EE90; padding: 10px; border-radius: 5px;",
                         h5("Low-Affinity Specialists"),
                         p("Don't prefer wet AND narrow tolerance", br())
                     )
              )
            )
          )
        ),
        
        fluidRow(
          box(
            title = "Quick Start Guide",
            status = "success",
            solidHeader = TRUE,
            width = 12,
            
            h4("To use this tool, you'll need:"),
            tags$ol(
              tags$li("Water table data: A CSV file with plot numbers and water table depths"),
              tags$li("Community data: A CSV file with plot numbers, species names, and abundance/DBH"),
              tags$li("Click 'Upload Data' in the sidebar to begin")
            ),
            
            br(),
            
            actionButton("go_to_data", "Start Analysis →", 
                         class = "btn-primary btn-lg",
                         icon = icon("arrow-right"))
          )
        )
      ),
      
      # Tab 2: Data Upload with Examples
      tabItem(
        tabName = "data",
        fluidRow(
          box(
            title = "Step 1: Upload Your Data Files",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            
            h4("File Requirements:"),
            
            div(class = "example-data",
                h5("Water Table File Format:"),
                p("Should contain 2 columns:"),
                tags$ul(
                  tags$li(strong("plot:"), " Plot identifier (1, 2, 3...)"),
                  tags$li(strong("water_table:"), " Water table depth in cm (0 = no water observed in 100cm well)")
                ),
                p("Example:"),
                tags$pre(
                  "plot;water_table\n1;0\n2;15.5\n3;23.8\n4;77.8"
                ),
                p(em("Note: 0 means water table is deeper than the 100 cm observation well"))
            ),
            
            fileInput("water_file", "Upload Water Table Data:",
                      accept = c(".csv", ".txt")),
            
            br(),
            
            div(class = "example-data",
                h5("Community File Format:"),
                p("Should contain 3 columns:"),
                tags$ul(
                  tags$li(strong("plot:"), " Plot identifier"),
                  tags$li(strong("species:"), " Scientific name"),
                  tags$li(strong("dbh:"), " Diameter")
                ),
                p("Example:"),
                tags$pre(
                  "plot;species;dbh\n1;Eugenia uniflora;14.2\n1;Myrcia glomerata;5.3\n2;Allophylus edulis;12.3"
                )
            ),
            
            fileInput("community_file", "Upload Community Data:",
                      accept = c(".csv", ".txt")),
            
            br(),
            
            h5("File Settings:"),
            radioButtons("separator", "Column Separator:",
                         choices = c("Semicolon (;)" = ";",
                                     "Comma (,)" = ",",
                                     "Tab" = "\t"),
                         selected = ";",
                         inline = TRUE),
            
            radioButtons("decimal", "Decimal Mark:",
                         choices = c("Comma (,)" = ",",
                                     "Point (.)" = "."),
                         selected = ",",
                         inline = TRUE)
          ),
          
          box(
            title = "Data Preview",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            
            tabsetPanel(
              tabPanel("Water Table", 
                       h5("First 10 rows:"),
                       DT::dataTableOutput("water_preview")),
              tabPanel("Community", 
                       h5("First 10 rows:"),
                       DT::dataTableOutput("community_preview")),
              tabPanel("Summary",
                       h5("Data Statistics:"),
                       verbatimTextOutput("data_summary"))
            )
          )
        ),
        
        fluidRow(
          box(
            title = "Download Example Data",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            collapsed = TRUE,
            
            p("Don't have data? Download our example files to test the tool:"),
            
            fluidRow(
              column(4,
                     downloadButton("download_example_water", "Example Water Table Data",
                                    class = "btn-warning", icon = icon("download"))
              ),
              column(4,
                     downloadButton("download_example_community", "Example Community Data",
                                    class = "btn-warning", icon = icon("download"))
              ),
              column(4,
                     p("These files contain data from the Caveiras River floodplain forest study.")
              )
            )
          )
        )
      ),
      
      # Tab 3: Species Analysis with Explanations
      tabItem(
        tabName = "analysis",
        fluidRow(
          valueBoxOutput("n_species_box"),
          valueBoxOutput("n_plots_box"),
          valueBoxOutput("n_individuals_box")
        ),
        
        fluidRow(
          box(
            title = "Species Classification Results",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            
            h4("Understanding the Metrics:"),
            fluidRow(
              column(4,
                     div(class = "method-box",
                         strong("Optima (cm):"), br(),
                         "Preferred water table depth",
                         br(),
                         em("Lower = prefers wetter conditions")
                     )
              ),
              column(4,
                     div(class = "method-box",
                         strong("Tolerance (cm):"), br(),
                         "Range of conditions tolerated",
                         br(),
                         em("Higher = more flexible")
                     )
              ),
              column(4,
                     div(class = "method-box",
                         strong("HNI (0-10):"), br(),
                         "Hydrological Niche Index",
                         br(),
                         em("Higher = better flood adapted")
                     )
              )
            ),
            
            br(),
            
            DT::dataTableOutput("species_table"),
            
            br(),
            
            fluidRow(
              column(6,
                     downloadButton("download_species", "Download Species Results",
                                    class = "btn-success", icon = icon("download"))
              ),
              column(6,
                     p("💡 Tip: Click column headers to sort the table")
              )
            )
          )
        ),
        
        fluidRow(
          box(
            title = "Hydrological Niche Index (HNI) Ranking",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            
            plotlyOutput("hni_plot", height = "500px"),
            
            p("This chart shows species ranked by their HNI score. Colors indicate functional groups.",
              br(),
              "Hover over bars for detailed information.")
          )
        )
      ),
      
      # Tab 4: Functional Groups with Interpretation
      tabItem(
        tabName = "groups",
        fluidRow(
          box(
            title = "Functional Classification Quadrant",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            
            plotlyOutput("quadrant_plot", height = "600px"),
            
            br(),
            
            h4("How to Read This Chart:"),
            fluidRow(
              column(6,
                     p(strong("X-axis (Hydrological Amplitude):"), 
                       "Species tolerance to water table variations",
                       br(),
                       "← Low tolerance (specialists) | High tolerance (generalists) →")
              ),
              column(6,
                     p(strong("Y-axis (Hydrophilic Affinity):"), 
                       "Species preference for wet conditions",
                       br(),
                       "↓ Low affinity (dry preference) | High affinity (wet preference) ↑")
              )
            ),
            p(strong("Point size:"), "Represents the HNI value (larger = higher HNI)")
          )
        ),
        
        fluidRow(
          box(
            title = "Group Statistics",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            
            h5("Summary by Functional Group:"),
            DT::dataTableOutput("group_stats"),
            
            br(),
            
            p("These statistics help identify which groups dominate your forest community.")
          ),
          
          box(
            title = "Distribution of Functional Groups",
            status = "success",
            solidHeader = TRUE,
            width = 6,
            
            plotOutput("group_pie"),
            
            br(),
            
            p("This shows the proportion of species in each functional group.",
              br(),
              "A balanced distribution suggests diverse hydrological niches.")
          )
        )
      ),
      
      # Tab 5: Export Results
      tabItem(
        tabName = "export",
        fluidRow(
          box(
            title = "Analysis Summary for Export",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            
            # Summary output
            verbatimTextOutput("final_summary"),
            
            br(),
            
            # Single download button for the summary
            fluidRow(
              column(12, align = "center",
                     downloadButton("download_summary", 
                                    "Download Summary Report", 
                                    class = "btn-success btn-lg",
                                    icon = icon("download")),
                     
                     br(), br(),
                     
                     p("Click the button above to download the complete analysis summary as a text file.",
                       style = "font-style: italic; color: #666;")
              )
            )
          )
        )
      ),
      
      # Tab 6: Help and Tutorial
      tabItem(
        tabName = "help",
        fluidRow(
          box(
            title = "Tutorial & Help",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            
            h3("Step-by-Step Tutorial"),
            
            div(class = "tutorial-step",
                h4("Step 1: Prepare Your Data"),
                p("Organize your data in two CSV files:"),
                tags$ul(
                  tags$li("Water table file: plot ID and average water depth"),
                  tags$li("Community file: plot ID, species name, and DBH (diameter at breast height")
                ),
                p("Make sure species names are consistent and use scientific nomenclature.")
            ),
            
            div(class = "tutorial-step",
                h4("Step 2: Upload Files"),
                p("Go to 'Upload Data' tab and select your files.",
                  "Check the preview to ensure data loaded correctly.",
                  "Adjust separator and decimal settings if needed.")
            ),
            
            div(class = "tutorial-step",
                h4("Step 3: Configure Analysis"),
                p("In the sidebar, set:"),
                tags$ul(
                  tags$li("Number of species to analyze (typically 10-15 most abundant)"),
                  tags$li("Replacement value for zero water table (e.g., 100 cm = no flooding)")
                ),
                p("Click 'Run Analysis' to process your data.")
            ),
            
            div(class = "tutorial-step",
                h4("Step 4: Explore Results"),
                p("Navigate through the tabs to:"),
                tags$ul(
                  tags$li("View species metrics and HNI scores"),
                  tags$li("Examine functional group classifications"),
                  tags$li("Export results for reports")
                )
            ),
            
            br(),
            
            h3("Frequently Asked Questions"),
            
            h5("Q: What does HNI mean?"),
            p("A: The Hydrological Niche Index (HNI) combines hydrophilic affinity and hydrological amplitude 
              into a single score from 0-10. Higher values indicate species better adapted to flooding."),
            
            h5("Q: Why replace zero values with 100?"),
            p("A: The observation wells are 100 cm deep. Zero in the data means no water was observed 
              within the 100 cm well depth. We replace zeros with 100 cm to represent the maximum 
              measurable depth, indicating that the water table is deeper than our observation capacity. 
              This maintains the ecological interpretation: lower values = shallower water table = more 
              flooding influence on vegetation."),
            
            h5("Q: Why do classifications change when I select different species?"),
            div(style = "background-color: ; padding: 15px; border-left: 4px solid #ffc107; margin: 10px 0;",
                p(strong("Important: "), "The classification is RELATIVE to the species pool being analyzed. 
                This is a key feature of the method, not a limitation. Here's why:"),
                tags$ul(
                  tags$li("The standardization (0-1 scale) for both metrics is calculated based on the 
                        minimum and maximum values WITHIN your selected species set."),
                  tags$li("A species might be classified as 'High-Affinity' when compared to dry-adapted species, 
                        but 'Low-Affinity' when compared to wetland specialists."),
                  tags$li("This relative approach allows meaningful comparisons within your specific ecological context.")
                ),
                p(em("Example: "), "If you include only wetland species, the driest-adapted among them becomes 
                the 'Low-Affinity' reference, even if it still prefers relatively wet conditions compared 
                to upland species.")
            ),
            
            h5("Q: How many species should I analyze?"),
            p("A: We recommend analyzing the most abundant species for robust results. 
              Too few species may not capture community patterns; too many may include rare species with unreliable estimates."),
            
            br(),
            
            h3("Troubleshooting"),
            
            h5("Data not loading?"),
            tags$ul(
              tags$li("Check file format (CSV)"),
              tags$li("Verify column names match requirements"),
              tags$li("Ensure correct separator and decimal settings"),
              tags$li("Remove special characters from species names")
            ),
            
            h5("Analysis not running?"),
            tags$ul(
              tags$li("Ensure both files are uploaded"),
              tags$li("Check that plot IDs match between files"),
              tags$li("Verify at least 5 species have sufficient data")
            ),
            
            br(),
            
            h3("Citation"),
            p("If you use this tool in your research, please cite:"),
            
            div(style = "background-color: #f0f0f0; padding: 10px; border-left: 3px solid #333;",
                p(strong("Costa, K.J.S., Cruz, M.J.C., Hassan, V.O.C., et al."), " (2025). ",
                  "Groundwater-based classification of floodplain trees: integrating water table preferences and tolerance ranges. ",
                  em("Wetlands Ecology and Management"), " (in press).")
            ),
            
            br(),
            
            h3("Contact & Support"),
            p("For questions, bug reports, or suggestions:"),
            p("📧 Email: higuchip@gmail.com"),
            p("🌐 ", 
              a("GitHub Repository", 
                href = "https://github.com/higuchip/FloodplainTreeClassification", 
                target = "_blank")),
            
            br(),
            
            h3("License"),
            p(strong("MIT License")),
            p("Copyright (c) 2025 Pedro Higuchi"),
            tags$pre(
              "Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE."
            )
          )
        )
      )
    )
  )
)

# ==============================================================================
# SERVER
# ==============================================================================

server <- function(input, output, session) {
  
  # Reactive values
  values <- reactiveValues(
    water_data = NULL,
    community_data = NULL,
    analysis_results = NULL,
    abundance_matrix = NULL,
    top_species = NULL
  )
  
  # Navigation button
  observeEvent(input$go_to_data, {
    updateTabItems(session, "tabs", "data")
  })
  
  # Load water table data
  observeEvent(input$water_file, {
    req(input$water_file)
    
    tryCatch({
      # Read file with proper decimal handling
      if(input$decimal == ",") {
        df <- read.csv2(input$water_file$datapath, 
                        sep = input$separator,
                        stringsAsFactors = FALSE)
      } else {
        df <- read.csv(input$water_file$datapath, 
                       sep = input$separator,
                       stringsAsFactors = FALSE)
      }
      
      # Standardize column names
      names(df) <- tolower(gsub("\\.", "_", names(df)))
      
      # Check for required columns
      if("plot" %in% names(df) || any(grepl("^x$", names(df)))) {
        # Handle unnamed first column
        if(any(grepl("^x$", names(df)))) {
          names(df)[1] <- "plot"
        }
        
        # Find water table column
        water_col <- which(grepl("water|table|lencol|freatic", names(df), ignore.case = TRUE))
        if(length(water_col) > 0) {
          # Rename to standard names
          if(!"plot" %in% names(df)) names(df)[1] <- "plot"
          names(df)[water_col[1]] <- "water_table"
          
          # Ensure numeric values
          df$plot <- as.numeric(as.character(df$plot))
          df$water_table <- as.numeric(as.character(df$water_table))
          
          values$water_data <- df
          showNotification("Water table data loaded successfully!", 
                           type = "default", duration = 3)
        } else {
          showNotification("Error: Water table column not found. Please check file format.", 
                           type = "warning", duration = 5)
        }
      } else {
        showNotification("Error: Plot column not found. Please check file format.", 
                         type = "warning", duration = 5)
      }
    }, error = function(e) {
      showNotification(paste("Error loading file. Please check the file format and settings."), 
                       type = "error", duration = 5)
    })
  })
  
  # Load community data
  observeEvent(input$community_file, {
    req(input$community_file)
    
    tryCatch({
      # Read file with proper decimal handling
      if(input$decimal == ",") {
        df <- read.csv2(input$community_file$datapath, 
                        sep = input$separator,
                        stringsAsFactors = FALSE)
      } else {
        df <- read.csv(input$community_file$datapath, 
                       sep = input$separator,
                       stringsAsFactors = FALSE)
      }
      
      # Standardize column names
      names(df) <- tolower(gsub("\\.", "_", names(df)))
      
      # Check for required columns
      plot_col <- which(names(df) %in% c("plot", "plots", "parcela", "x"))
      species_col <- which(grepl("species|especie|sp", names(df), ignore.case = TRUE))
      dbh_col <- which(grepl("dbh|dap|diameter|abundance|abundancia|n", names(df), ignore.case = TRUE))
      
      if(length(plot_col) > 0 && length(species_col) > 0) {
        # Rename to standard names
        names(df)[plot_col[1]] <- "plot"
        names(df)[species_col[1]] <- "species"
        if(length(dbh_col) > 0) {
          names(df)[dbh_col[1]] <- "dbh"
        } else {
          # If no abundance column, create one
          df$dbh <- 1
        }
        
        # Ensure correct data types
        df$plot <- as.numeric(as.character(df$plot))
        df$dbh <- as.numeric(as.character(df$dbh))
        
        # Remove NA values
        df <- df[!is.na(df$plot) & !is.na(df$species) & df$species != "", ]
        
        values$community_data <- df
        showNotification("Community data loaded successfully!", 
                         type = "default", duration = 3)
      } else {
        showNotification("Error: Required columns (plot, species) not found. Please check file format.", 
                         type = "warning", duration = 5)
      }
    }, error = function(e) {
      showNotification(paste("Error loading file. Please check the file format and settings."), 
                       type = "error", duration = 5)
    })
  })
  
  # Data previews
  output$water_preview <- DT::renderDataTable({
    req(values$water_data)
    DT::datatable(head(values$water_data, 10), 
                  options = list(pageLength = 5, scrollX = TRUE, dom = 't'),
                  rownames = FALSE)
  })
  
  output$community_preview <- DT::renderDataTable({
    req(values$community_data)
    DT::datatable(head(values$community_data, 10), 
                  options = list(pageLength = 5, scrollX = TRUE, dom = 't'),
                  rownames = FALSE)
  })
  
  # Data summary
  output$data_summary <- renderPrint({
    if(!is.null(values$water_data) && !is.null(values$community_data)) {
      cat("✓ DATA LOADED SUCCESSFULLY\n")
      cat(paste(rep("=", 40), collapse=""), "\n\n")
      
      cat("WATER TABLE DATA:\n")
      cat("• Number of plots:", nrow(values$water_data), "\n")
      
      # Safe extraction of water table values
      water_col <- which(grepl("water", names(values$water_data), ignore.case = TRUE))
      if(length(water_col) > 0) {
        water_values <- as.numeric(values$water_data[[water_col[1]]])
        water_values <- water_values[!is.na(water_values)]
        
        if(length(water_values) > 0) {
          # Count zeros BEFORE replacement
          n_zeros <- sum(water_values == 0)
          
          # Display range AFTER conceptual replacement for zeros
          water_display <- water_values
          water_display[water_display == 0] <- input$water_replacement
          
          cat("• Water table range (after zero replacement):", 
              round(min(water_display), 2), "to",
              round(max(water_display), 2), "cm\n")
          cat("• Plots with water table >100cm (beyond well depth): ", 
              n_zeros, " plots\n", sep="")
          cat("• Plots with shallow water table (<10 cm): ", 
              sum(water_values > 0 & water_values < 10), "\n", sep="")
          cat("• Mean water table depth (zeros as ", input$water_replacement, "cm): ",
              round(mean(water_display), 2), " cm\n\n", sep="")
        } else {
          cat("• Water table data: Check numeric format\n\n")
        }
      }
      
      cat("COMMUNITY DATA:\n")
      cat("• Number of records:", nrow(values$community_data), "\n")
      
      # Safe counting of species
      if("species" %in% names(values$community_data)) {
        unique_species <- unique(values$community_data$species)
        unique_species <- unique_species[!is.na(unique_species) & unique_species != ""]
        cat("• Number of species:", length(unique_species), "\n")
      }
      
      # Safe counting of plots
      if("plot" %in% names(values$community_data)) {
        unique_plots <- unique(values$community_data$plot)
        unique_plots <- unique_plots[!is.na(unique_plots)]
        cat("• Number of plots:", length(unique_plots), "\n")
      }
      
      # Top species
      if("species" %in% names(values$community_data)) {
        cat("• Most abundant species:\n")
        
        species_counts <- table(values$community_data$species)
        species_counts <- sort(species_counts, decreasing = TRUE)
        top_sp <- head(species_counts, 5)
        
        if(length(top_sp) > 0) {
          for(i in 1:length(top_sp)) {
            cat("  ", i, ". ", names(top_sp)[i], " (n=", top_sp[i], ")\n", sep="")
          }
        }
      }
      
      cat("\n✓ Ready for analysis! Click 'Run Analysis' button.")
    } else {
      cat("⚠ WAITING FOR DATA\n")
      cat(paste(rep("=", 40), collapse=""), "\n\n")
      
      if(is.null(values$water_data)) {
        cat("• Water table data: NOT LOADED\n")
      } else {
        cat("• Water table data: ✓ LOADED\n")
      }
      
      if(is.null(values$community_data)) {
        cat("• Community data: NOT LOADED\n")
      } else {
        cat("• Community data: ✓ LOADED\n")
      }
      
      cat("\nPlease upload both files to proceed.")
    }
  })
  
  # Main analysis
  observeEvent(input$run_analysis, {
    req(values$water_data, values$community_data)
    
    showNotification("Running analysis...", 
                     type = "default", duration = 2, id = "analyzing")
    
    tryCatch({
      # Find water table column
      water_col <- which(grepl("water", names(values$water_data), ignore.case = TRUE))
      if(length(water_col) == 0) {
        # If no water column found, try second column
        water_col <- 2
      } else {
        water_col <- water_col[1]
      }
      
      # Prepare water values
      water_values <- as.numeric(values$water_data[[water_col]])
      water_values[water_values == 0 | is.na(water_values)] <- input$water_replacement
      
      # Create abundance matrix
      abundance_matrix <- table(values$community_data$plot, 
                                values$community_data$species)
      
      # Remove empty species
      abundance_matrix <- abundance_matrix[, colSums(abundance_matrix) > 0]
      
      # Select top species
      total_abundance <- colSums(abundance_matrix)
      n_species_to_analyze <- min(input$n_species, length(total_abundance))
      
      if(n_species_to_analyze < 2) {
        stop("Need at least 2 species for analysis")
      }
      
      top_species_names <- names(sort(total_abundance, 
                                      decreasing = TRUE)[1:n_species_to_analyze])
      
      # Subset matrix
      matrix_top <- abundance_matrix[, top_species_names, drop = FALSE]
      values$abundance_matrix <- matrix_top
      values$top_species <- top_species_names
      
      # Ensure water_values matches the number of plots
      plot_ids <- as.numeric(rownames(matrix_top))
      water_values_matched <- numeric(length(plot_ids))
      
      for(i in 1:length(plot_ids)) {
        plot_idx <- which(values$water_data$plot == plot_ids[i])
        if(length(plot_idx) > 0) {
          water_values_matched[i] <- water_values[plot_idx[1]]
        } else {
          water_values_matched[i] <- input$water_replacement
        }
      }
      
      # Calculate optima and tolerances
      optima <- optima(matrix_top, water_values_matched)
      tolerances <- tolerance(matrix_top, water_values_matched)
      
      # Create results dataframe
      results <- data.frame(
        Species = top_species_names,
        Optima = as.numeric(optima),
        Tolerance = as.numeric(tolerances),
        stringsAsFactors = FALSE
      )
      
      # Check for valid results
      if(any(is.na(results$Optima)) || any(is.na(results$Tolerance))) {
        stop("Unable to calculate optima or tolerances. Check data format.")
      }
      
      # Standardize metrics
      if(length(unique(results$Optima)) > 1) {
        results$Hydrophilic_Affinity <- 1 - ((results$Optima - min(results$Optima)) / 
                                               (max(results$Optima) - min(results$Optima)))
      } else {
        results$Hydrophilic_Affinity <- 0.5
      }
      
      if(length(unique(results$Tolerance)) > 1) {
        results$Hydrological_Amplitude <- (results$Tolerance - min(results$Tolerance)) / 
          (max(results$Tolerance) - min(results$Tolerance))
      } else {
        results$Hydrological_Amplitude <- 0.5
      }
      
      # Calculate HNI
      results$HNI <- (results$Hydrophilic_Affinity * 0.5 + 
                        results$Hydrological_Amplitude * 0.5) * 10
      
      # Classify functional groups
      results$Functional_Group <- case_when(
        results$Hydrophilic_Affinity >= 0.5 & results$Hydrological_Amplitude >= 0.5 ~ 
          "High-Affinity Generalists",
        results$Hydrophilic_Affinity >= 0.5 & results$Hydrological_Amplitude < 0.5 ~ 
          "High-Affinity Specialists",
        results$Hydrophilic_Affinity < 0.5 & results$Hydrological_Amplitude >= 0.5 ~ 
          "Low-Affinity Generalists",
        TRUE ~ "Low-Affinity Specialists"
      )
      
      # Classify tolerance levels
      if(length(unique(results$HNI)) > 1) {
        results$Tolerance_Class <- cut(results$HNI,
                                       breaks = quantile(results$HNI, 
                                                         probs = seq(0, 1, 0.2)),
                                       labels = c("Very Low", "Low", "Medium", 
                                                  "High", "Very High"),
                                       include.lowest = TRUE)
      } else {
        results$Tolerance_Class <- "Medium"
      }
      
      values$analysis_results <- results
      
      removeNotification(id = "analyzing")
      showNotification("Analysis completed successfully!", 
                       type = "default", duration = 3)
      
    }, error = function(e) {
      removeNotification(id = "analyzing")
      showNotification(paste("Analysis error. Please check your data and settings."), 
                       type = "error", duration = 5)
    })
  })
  
  # Value boxes
  output$n_species_box <- renderValueBox({
    valueBox(
      value = ifelse(!is.null(values$analysis_results), 
                     nrow(values$analysis_results), 0),
      subtitle = "Species Analyzed",
      icon = icon("tree"),
      color = "green"
    )
  })
  
  output$n_plots_box <- renderValueBox({
    valueBox(
      value = ifelse(!is.null(values$water_data), 
                     nrow(values$water_data), 0),
      subtitle = "Sample Plots",
      icon = icon("map-marked-alt"),
      color = "blue"
    )
  })
  
  output$n_individuals_box <- renderValueBox({
    valueBox(
      value = ifelse(!is.null(values$community_data), 
                     nrow(values$community_data), 0),
      subtitle = "Individual Records",
      icon = icon("seedling"),
      color = "yellow"
    )
  })
  
  # Species table
  output$species_table <- DT::renderDataTable({
    req(values$analysis_results)
    
    df <- values$analysis_results %>%
      select(Species, Optima, Tolerance, HNI, Functional_Group, Tolerance_Class) %>%
      mutate(
        Optima = round(Optima, 2),
        Tolerance = round(Tolerance, 2),
        HNI = round(HNI, 2)
      )
    
    DT::datatable(df, 
                  options = list(
                    pageLength = 15, 
                    scrollX = TRUE,
                    order = list(list(3, 'desc'))  # Sort by HNI descending
                  ),
                  rownames = FALSE,
                  caption = "Click column headers to sort. Higher HNI = better flood adaptation.") %>%
      formatStyle('HNI',
                  background = styleColorBar(df$HNI, 'steelblue'),
                  backgroundSize = '100% 90%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'center') %>%
      formatStyle('Functional_Group',
                  backgroundColor = styleEqual(
                    c("High-Affinity Generalists", "High-Affinity Specialists",
                      "Low-Affinity Generalists", "Low-Affinity Specialists"),
                    c("#e3f2fd", "#bbdefb", "#c8e6c9", "#dcedc8")
                  ))
  })
  
  # HNI plot
  output$hni_plot <- renderPlotly({
    req(values$analysis_results)
    
    p <- ggplot(values$analysis_results, 
                aes(x = reorder(Species, HNI), y = HNI, 
                    fill = Functional_Group,
                    text = paste("Species:", Species,
                                 "<br>HNI:", round(HNI, 2),
                                 "<br>Group:", Functional_Group,
                                 "<br>Optima:", round(Optima, 2), "cm",
                                 "<br>Tolerance:", round(Tolerance, 2), "cm"))) +
      geom_bar(stat = "identity") +
      coord_flip() +
      scale_fill_manual(values = c(
        "High-Affinity Generalists" = "#1f77b4",
        "High-Affinity Specialists" = "#87CEEB",
        "Low-Affinity Generalists" = "#228B22",
        "Low-Affinity Specialists" = "#90EE90"
      )) +
      labs(x = "", 
           y = "Hydrological Niche Index (HNI)",
           fill = "Functional Group",
           title = "Species Ranked by Flood Adaptation Capacity") +
      theme_minimal() +
      theme(axis.text.y = element_text(face = "italic"),
            plot.title = element_text(size = 14, face = "bold"))
    
    ggplotly(p, tooltip = "text") %>%
      layout(hoverlabel = list(bgcolor = "white", font = list(size = 12)))
  })
  
  # Quadrant plot
  output$quadrant_plot <- renderPlotly({
    req(values$analysis_results)
    
    p <- ggplot(values$analysis_results, 
                aes(x = Hydrological_Amplitude, y = Hydrophilic_Affinity,
                    color = Functional_Group, size = HNI,
                    text = paste("Species:", Species,
                                 "<br>Hydrophilic Affinity:", round(Hydrophilic_Affinity, 3),
                                 "<br>Hydrological Amplitude:", round(Hydrological_Amplitude, 3),
                                 "<br>HNI:", round(HNI, 2),
                                 "<br>Group:", Functional_Group,
                                 "<br>",
                                 "<br>Optima:", round(Optima, 2), "cm",
                                 "<br>Tolerance:", round(Tolerance, 2), "cm"))) +
      # Quadrant lines
      geom_hline(yintercept = 0.5, linetype = "dashed", color = "gray50", size = 0.8) +
      geom_vline(xintercept = 0.5, linetype = "dashed", color = "gray50", size = 0.8) +
      
      # Species points
      geom_point(alpha = 0.7) +
      
      # Color and size scales
      scale_color_manual(values = c(
        "High-Affinity Generalists" = "#1f77b4",
        "High-Affinity Specialists" = "#87CEEB",
        "Low-Affinity Generalists" = "#228B22",
        "Low-Affinity Specialists" = "#90EE90"
      )) +
      scale_size_continuous(range = c(4, 12)) +
      
      # Labels
      labs(x = "Hydrological Amplitude (Tolerance Range)",
           y = "Hydrophilic Affinity (Wet Preference)",
           color = "Functional Group",
           size = "HNI",
           title = "Functional Classification of Tree Species") +
      
      # Theme
      theme_minimal() +
      theme(legend.position = "right",
            plot.title = element_text(size = 14, face = "bold")) +
      
      # Quadrant labels
      annotate("text", x = 0.25, y = 0.75, 
               label = "High-Affinity\nSpecialists",
               size = 4, fontface = "bold", color = "gray40", alpha = 0.7) +
      annotate("text", x = 0.75, y = 0.75, 
               label = "High-Affinity\nGeneralists",
               size = 4, fontface = "bold", color = "gray40", alpha = 0.7) +
      annotate("text", x = 0.25, y = 0.25, 
               label = "Low-Affinity\nSpecialists",
               size = 4, fontface = "bold", color = "gray40", alpha = 0.7) +
      annotate("text", x = 0.75, y = 0.25, 
               label = "Low-Affinity\nGeneralists",
               size = 4, fontface = "bold", color = "gray40", alpha = 0.7) +
      
      # Axis limits
      scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
      scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25))
    
    ggplotly(p, tooltip = "text") %>%
      layout(hoverlabel = list(bgcolor = "white", font = list(size = 12)))
  })
  
  # Group statistics
  output$group_stats <- DT::renderDataTable({
    req(values$analysis_results)
    
    stats <- values$analysis_results %>%
      group_by(Functional_Group) %>%
      summarise(
        Count = n(),
        `Mean HNI` = round(mean(HNI), 2),
        `SD HNI` = round(sd(HNI), 2),
        `Mean Optima (cm)` = round(mean(Optima), 1),
        `Mean Tolerance (cm)` = round(mean(Tolerance), 1),
        .groups = 'drop'
      )
    
    DT::datatable(stats, 
                  options = list(pageLength = 4, dom = 't'), 
                  rownames = FALSE)
  })
  
  # Pie chart
  output$group_pie <- renderPlot({
    req(values$analysis_results)
    
    group_counts <- values$analysis_results %>%
      count(Functional_Group) %>%
      mutate(percentage = round(n/sum(n) * 100, 1))
    
    ggplot(group_counts, aes(x = "", y = n, fill = Functional_Group)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar("y", start = 0) +
      scale_fill_manual(values = c(
        "High-Affinity Generalists" = "#1f77b4",
        "High-Affinity Specialists" = "#87CEEB",
        "Low-Affinity Generalists" = "#228B22",
        "Low-Affinity Specialists" = "#90EE90"
      )) +
      theme_void() +
      theme(legend.position = "bottom",
            legend.title = element_blank()) +
      geom_text(aes(label = paste0(n, " species\n(", percentage, "%)")),
                position = position_stack(vjust = 0.5),
                size = 4)
  })
  
  # Download handlers
  
  # Example data downloads
  output$download_example_water <- downloadHandler(
    filename = "example_water_table.csv",
    content = function(file) {
      example_water <- data.frame(
        plot = 1:48,
        water_table = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.6, 0, 10.3, 23.8, 77.8,
                        25.8, 13.5, 0, 2.1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 3.7, 0,
                        0, 9.6, 0, 0, 0, 9.3, 69.3, 25.2, 0, 39, 0, 2.2, 6.7,
                        0, 0, 4.4, 0, 0)
      )
      write.csv(example_water, file, row.names = FALSE)
    }
  )
  
  output$download_example_community <- downloadHandler(
    filename = "example_community_data.csv",
    content = function(file) {
      # Create example community data
      set.seed(123)
      species_pool <- c("Myrcia glomerata", "Allophylus edulis", "Annona rugulosa",
                        "Casearia decandra", "Gymnanthes klotzschiana", 
                        "Eugenia uniflora", "Blepharocalyx salicifolius",
                        "Campomanesia xanthocarpa", "Prunus myrtifolia",
                        "Nectandra megapotamica")
      
      example_community <- data.frame()
      for(plot in 1:48) {
        n_species <- sample(3:8, 1)
        plot_species <- sample(species_pool, n_species)
        for(sp in plot_species) {
          n_ind <- sample(1:5, 1)
          for(i in 1:n_ind) {
            example_community <- rbind(example_community,
                                       data.frame(
                                         plot = plot,
                                         species = sp,
                                         dbh = round(runif(1, 5, 35), 2)
                                       ))
          }
        }
      }
      write.csv(example_community, file, row.names = FALSE)
    }
  )
  
  output$download_species <- downloadHandler(
    filename = function() {
      paste0("species_classification_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(values$analysis_results, file, row.names = FALSE)
    }
  )
  
  # Download handler for summary report
  output$download_summary <- downloadHandler(
    filename = function() {
      paste0("analysis_summary_", format(Sys.Date(), "%Y%m%d"), ".txt")
    },
    content = function(file) {
      if(!is.null(values$analysis_results)) {
        # Open connection to file
        sink(file)
        
        cat("FLOODPLAIN TREE CLASSIFICATION - ANALYSIS SUMMARY\n")
        cat("Generated on: ", format(Sys.Date(), "%B %d, %Y"), "\n")
        cat(paste(rep("=", 60), collapse=""), "\n\n")
        
        cat("DATASET INFORMATION\n")
        cat(paste(rep("-", 30), collapse=""), "\n")
        cat("• Species analyzed: ", nrow(values$analysis_results), "\n")
        cat("• Number of plots: ", nrow(values$water_data), "\n")
        cat("• Total observations: ", nrow(values$community_data), "\n")
        cat("• Analysis parameters:\n")
        cat("  - Water replacement value: ", input$water_replacement, " cm\n")
        cat("  - Number of species selected: ", input$n_species, "\n\n")
        
        cat("HYDROLOGICAL METRICS\n")
        cat(paste(rep("-", 30), collapse=""), "\n")
        cat("• Mean HNI: ", round(mean(values$analysis_results$HNI), 2), 
            " (SD = ", round(sd(values$analysis_results$HNI), 2), ")\n")
        cat("• HNI Range: ", round(min(values$analysis_results$HNI), 2), " - ",
            round(max(values$analysis_results$HNI), 2), "\n")
        cat("• Mean Optima: ", round(mean(values$analysis_results$Optima), 2), " cm\n")
        cat("• Mean Tolerance: ", round(mean(values$analysis_results$Tolerance), 2), " cm\n\n")
        
        cat("FUNCTIONAL GROUPS DISTRIBUTION\n")
        cat(paste(rep("-", 30), collapse=""), "\n")
        group_table <- table(values$analysis_results$Functional_Group)
        for(i in 1:length(group_table)) {
          cat("• ", names(group_table)[i], ": ", 
              group_table[i], " species (", 
              round(group_table[i]/sum(group_table)*100, 1), "%)\n", sep="")
        }
        cat("\n")
        
        cat("TOLERANCE CLASSIFICATION\n")
        cat(paste(rep("-", 30), collapse=""), "\n")
        tol_table <- table(values$analysis_results$Tolerance_Class)
        for(i in 1:length(tol_table)) {
          cat("• ", names(tol_table)[i], ": ", tol_table[i], " species\n", sep="")
        }
        cat("\n")
        
        cat("SPECIES RANKINGS\n")
        cat(paste(rep("-", 30), collapse=""), "\n")
        
        cat("\nTop 5 Flood-Adapted Species (Highest HNI):\n")
        top5 <- values$analysis_results[order(-values$analysis_results$HNI),][1:min(5, nrow(values$analysis_results)),]
        for(i in 1:nrow(top5)) {
          cat(sprintf("%d. %-30s HNI = %5.2f | %s\n", 
                      i, 
                      top5$Species[i], 
                      top5$HNI[i],
                      top5$Functional_Group[i]))
        }
        
        cat("\nBottom 5 Species (Lowest HNI):\n")
        bottom5 <- values$analysis_results[order(values$analysis_results$HNI),][1:min(5, nrow(values$analysis_results)),]
        for(i in 1:nrow(bottom5)) {
          cat(sprintf("%d. %-30s HNI = %5.2f | %s\n", 
                      i, 
                      bottom5$Species[i], 
                      bottom5$HNI[i],
                      bottom5$Functional_Group[i]))
        }
        
        cat("\n", paste(rep("=", 60), collapse=""), "\n")
        cat("\nCOMPLETE SPECIES LIST\n")
        cat(paste(rep("-", 30), collapse=""), "\n")
        cat(sprintf("%-30s %8s %10s %10s %25s\n", 
                    "Species", "HNI", "Optima(cm)", "Tol.(cm)", "Functional Group"))
        cat(paste(rep("-", 85), collapse=""), "\n")
        
        # Sort by HNI descending
        sorted_results <- values$analysis_results[order(-values$analysis_results$HNI),]
        for(i in 1:nrow(sorted_results)) {
          cat(sprintf("%-30s %8.2f %10.2f %10.2f %25s\n",
                      sorted_results$Species[i],
                      sorted_results$HNI[i],
                      sorted_results$Optima[i],
                      sorted_results$Tolerance[i],
                      sorted_results$Functional_Group[i]))
        }
        
        cat("\n", paste(rep("=", 60), collapse=""), "\n")
        cat("\nCitation:\n")
        cat("Costa, K.J.S., Cruz, M.J.C., Hassan, V.O.C., et al. (2025).\n")
        cat("Groundwater-based classification of floodplain trees:\n")
        cat("integrating water table preferences and tolerance ranges.\n")
        cat("Wetlands Ecology and Management.\n")
        
        # Close connection
        sink()
        
      } else {
        writeLines("No analysis results available. Please run the analysis first.", file)
      }
    }
  )
  
  # Final summary
  output$final_summary <- renderPrint({
    if(!is.null(values$analysis_results)) {
      cat("ANALYSIS SUMMARY - ", format(Sys.Date(), "%B %d, %Y"), "\n")
      cat(paste(rep("=", 50), collapse=""), "\n\n")
      
      cat("Dataset Information:\n")
      cat("• Species analyzed:", nrow(values$analysis_results), "\n")
      cat("• Number of plots:", nrow(values$water_data), "\n")
      cat("• Total observations:", nrow(values$community_data), "\n\n")
      
      cat("Hydrological Metrics:\n")
      cat("• Mean HNI:", round(mean(values$analysis_results$HNI), 2), 
          "(SD =", round(sd(values$analysis_results$HNI), 2), ")\n")
      cat("• HNI Range:", round(min(values$analysis_results$HNI), 2), "-",
          round(max(values$analysis_results$HNI), 2), "\n\n")
      
      cat("Functional Groups Distribution:\n")
      group_table <- table(values$analysis_results$Functional_Group)
      for(i in 1:length(group_table)) {
        cat("• ", names(group_table)[i], ": ", 
            group_table[i], " species (", 
            round(group_table[i]/sum(group_table)*100, 1), "%)\n", sep="")
      }
      
      cat("\nTolerance Classification:\n")
      tol_table <- table(values$analysis_results$Tolerance_Class)
      for(i in 1:length(tol_table)) {
        cat("• ", names(tol_table)[i], ": ", tol_table[i], " species\n", sep="")
      }
      
      cat("\nTop 3 Flood-Adapted Species (Highest HNI):\n")
      top3 <- values$analysis_results[order(-values$analysis_results$HNI),][1:min(3, nrow(values$analysis_results)),]
      
      for(i in 1:nrow(top3)) {
        cat(i, ". ", top3$Species[i], 
            "\n   HNI = ", round(top3$HNI[i], 2),
            " | Group: ", top3$Functional_Group[i], "\n", sep="")
      }
      
      cat("\nBottom 3 Species (Lowest HNI):\n")
      bottom3 <- values$analysis_results[order(values$analysis_results$HNI),][1:min(3, nrow(values$analysis_results)),]
      
      for(i in 1:nrow(bottom3)) {
        cat(i, ". ", bottom3$Species[i], 
            "\n   HNI = ", round(bottom3$HNI[i], 2),
            " | Group: ", bottom3$Functional_Group[i], "\n", sep="")
      }
      
      cat("\n", paste(rep("=", 50), collapse=""), "\n")
      cat("Analysis parameters:\n")
      cat("• Water replacement value:", input$water_replacement, "cm\n")
      cat("• Number of species analyzed:", input$n_species, "\n")
      
    } else {
      cat("No analysis results available.\n")
      cat("Please upload data files and run the analysis.\n")
    }
  })
}

# ==============================================================================
# RUN APPLICATION
# ==============================================================================

shinyApp(ui = ui, server = server)
