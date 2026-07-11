# IBM Data Analytics with Excel and R Professional Certificate Data Science with R - Capstone Project
# ------------------------------------------------------------------------
# Ikemefula Oriaku Data Scientist [SQL | Python | R]
# ------------------------------------------------------------------------
# Install and Load Packages
# Import necessary packages for the data collection web scraping task
require("rvest")
require('tidyverse')
require('httr')
require('ggplot2')
require('repr')
require('rlang')
require('tidymodels')
require('stringr')
require('glmnet')
require('caret')
require('randomForest')
# rvest for web scraping task
library(rvest)
# httr library for rest api
library(httr)
# tidyverse for useful data collection functions in r
library(tidyverse)
# ggplot2 and repr for data visualisation
library(ggplot2)
library(repr)

# Define the size of plots
options(repr.plot.width = 18, repr.plot.height = 12)

# rlang for working with R objects
library(rlang)

# tidymodels for modelling and machine learning
library(tidymodels)

# stringr for working with strings
library(stringr)

# glmnet engine for fitting generalised linear models and implementing of regularised regression techniques (L1 and L2)
library(glmnet)

# caret for building predictive models
library(caret)

# randomForest for classification and regression tasks
library(randomForest)

# Data Collection using Web scrapping and API
# ------------------------------------------------------------------------
# Extract bike sharing systems HTML table from a Wiki page
# Define url path
URL <- "https://en.wikipedia.org/wiki/List_of_bicycle-sharing_systems"

# Fetching and parsing the HTML content
htmlContent <- read_html(URL)

# Extract all table nodes from the parsed HTML content
tableNodes <- html_nodes(htmlContent, 'table') 

# Iterate over each table node in the extracted table nodes
for (tableNode in tableNodes) {
  print(tableNodes)
}

# Extract and store the first table node from the list of table nodes
bikeSharing <- tableNodes[[1]]

# Convert extracted table node into a Data Frame
# Convert the stored table node into a dataframe
htmltableDF <- html_table(bikeSharing, fill = TRUE)

# Check and remove duplicate columns
htmltableDF <- htmltableDF[, !duplicated(colnames(htmltableDF))]

# Summarise the Data Frame
# ------------------------------------------------------------------------
# Summarise the dataframe
summary(htmltableDF)

# Display Data Frame
# ------------------------------------------------------------------------
# Display the first few rows of the dataframe
head(htmltableDF)
names(htmltableDF)

# Rename city/region column name
names(htmltableDF)[names(htmltableDF) == "City / Region"] <- "City"
head(htmltableDF)

# Data Collection using API
# ------------------------------------------------------------------------
# Define a function to extract city data using web api
getWeatherForecastByCities <- function(city_names) {
  # create empty vectors to hold data
  city <- c() # empty city column
  weather <- c() # empty weather
  visibility <- c()
  temp <- c() # current temp
  temp_min <- c() # min temp
  temp_max <- c() # max temp
  pressure <- c() # pressure
  humidity <- c() # humidity
  wind_speed <- c() # wind speed
  wind_deg <- c() # wind direction
  forecast_datatime <- c() # forecast timestamp
  season <- c() # season
  weather_labels <- c() # label to be shown on Leaflet
  weather_detail_labels <- c() # detailed label to be shown on Leaflet
  hours <- c() # hour
  
 # loop cities - 5 days forecast
  for (city_name in city_names) {
    forecastURL <- 'https://api.openweathermap.org/data/2.5/forecast'
    forecastQuery <- list(q = city_name, appid = '718c11d667198eb09d9803c3096db8d8', units='metric')
    forecastResponse <- GET(forecastURL, query=forecastQuery)
    jsonList <- content(forecastResponse, as='parsed')
    results <- jsonList$list
    # loop result
    for (result in results) {
      # get weather data by city
      city <- c(city, city_name)
      weather <- c(weather, result$weather[[1]]$main) # get weather status
      visibility <- c(visibility, result$visibility) # get visibility
      temp <- c(temp, result$main$temp) # get temp
      temp_min <- c(temp_min, result$main$temp_min) # get min temp
      temp_max <- c(temp_max, result$main$temp_max) # get max temp
      pressure <- c(pressure, result$main$pressure) # get pressure
      humidity <- c(humidity, result$main$humidity) # get humidity
      wind_speed <- c(wind_speed, result$wind$speed) # get wind speed
      wind_deg <- c(wind_deg, result$wind$deg) # get wind direction
      forecate_date <- result$dt_txt # get timestamp
      forecast_datatime <- c(forecast_datatime, forecate_date) # assign timestamp
     }
  }
    
 # create a data frame to hold the results
 cities_weather_df <- data.frame(CITY_ASCII=city, WEATHER=weather, VISIBILITY=visibility, TEMPERATURE=temp, TEMP_MIN=temp_min, 
                  TEMP_MAX=temp_max, PRESSURE=pressure,HUMIDITY=humidity, WIND_SPEED=wind_speed, WIND_DEG=wind_deg, 
                  FORECASTDATETIME=forecast_datatime)
  return(cities_weather_df)
}

# Weather from Selected Cities
# ------------------------------------------------------------------------
# define a vector containing city names
cities <- c("Seoul", "Washington, D.C.", "Paris", "Suzhou")

# assign a variable to hold the dataframe extracted by the pipeline
cities_weather_df <- getWeatherForecastByCities(cities)

# print 5 days generated data frame for Seoul
head(cities_weather_df, 40)

# Export the Data Frame as a CSV file
# ------------------------------------------------------------------------
# Define the file path for the CSV files
bike_sharing_csv <- 'raw_bike_sharing_systems.csv' 
worldcities_weather_csv <- 'cities_weather_forecast.csv'

# Define a function to write to CSV
writeCSV <- function(dataframe, filepath, row.names=FALSE) {
    write.csv(dataframe, file = filepath, row.names=FALSE)
}

# Write Dataframe to CSV using a function
write.csv(htmltableDF, bike_sharing_csv)
write.csv(cities_weather_df, worldcities_weather_csv)

# Data Wrangling with Regular Expressions and DPLYR
# ------------------------------------------------------------------------
# Load datasets and standardise column names
# ------------------------------------------------------------------------
dataset_list <- c('raw_bike_sharing_systems.csv', 'raw_seoul_bike_sharing.csv', 'raw_cities_weather_forecast.csv', 'raw_worldcities.csv')
dataset_list

# define a function to standardise the columns (change columns to uppercase and replace spaces with underscore) 
standardise_dataset <- function(dataset) {
    names(dataset) <- names(dataset) %>% str_replace_all(" ", "_") %>% toupper(.)  
    return(dataset)
}

# loop through data frames and apply the standardisation function and print summary
for (dataset in dataset_list) {
    # read the dataset
    df <- read.csv(dataset)

    # apply the standardise function
    df_clean <- standardise_dataset(df)

    # print the result and summary of the data frame
    print(paste('New column names for', dataset, ':', toString(names(df_clean))))
    print(summary(df_clean))    
}

# Data Preprocessing Web-scraped Bike-sharing System Dataset
# ------------------------------------------------------------------------
# load wiki bike sharing system dataset
bike_sharing_system_df <- read.csv(dataset_list[1])
head(bike_sharing_system_df)

# Select the four columns from the dataframe and save in a sub-data frame
sub_bike_sharing_system_df <- bike_sharing_system_df %>% select(COUNTRY, CITY, SYSTEM, BICYCLES)

# check the data type of the selected columns
sub_bike_sharing_system_df %>% 
    summarize_all(class) %>%
    gather(variable, class)

# create grepl search function to find non-digital characters in the bicycle column
find_character <- function(strings) grepl("[^0-9]", strings)

# find non-numeric characters in the Bicycles column
sub_bike_sharing_system_df %>% 
    select(BICYCLES) %>% 
    filter(find_character(BICYCLES)) %>%
    slice(0:10) 

# Define a regular expression lookup pattern and create a grepl function to find any reference links
ref_pattern <- "\\[[A-z0-9]+\\]"
find_reference_pattern <- function(strings) grepl(ref_pattern, strings)

# Check whether the COUNTRY column has any reference links
sub_bike_sharing_system_df %>% 
    select(COUNTRY) %>% 
    filter(find_reference_pattern(COUNTRY))

# Check whether the CITY column has any reference links
sub_bike_sharing_system_df %>% 
    select(CITY) %>% 
    filter(find_reference_pattern(CITY)) %>%
    slice(0:10)

# Check for reference links in the System column (variable)
sub_bike_sharing_system_df %>% 
    select(SYSTEM) %>% 
    filter(find_reference_pattern(SYSTEM))

# Remove undesired reference links using regular expressions
# ------------------------------------------------------------------------
# create a remove reference links function using replace_all
remove_reference <- function(strings) {
  reference_path <- ''
  reference_pattern <- '\\[.+\\]' 
  replace_text <- str_replace_all(strings, reference_pattern, reference_path)
  return(replace_text)
}

# apply the remove reference function to dataset columns using mutate
sub_bike_sharing_system_df <- sub_bike_sharing_system_df %>% mutate(CITY=remove_reference(CITY), 
                               SYSTEM=remove_reference(SYSTEM), 
                               COUNTRY=remove_reference(COUNTRY))

head(sub_bike_sharing_system_df)

# cross reference to ensure reference links were removed
sub_bike_sharing_system_df %>% 
    select(CITY, SYSTEM, COUNTRY) %>% 
    filter(find_reference_pattern(CITY) | 
           find_reference_pattern(SYSTEM) | 
           find_reference_pattern(COUNTRY)
          )

# Extract the numeric value using regular expressions
# ------------------------------------------------------------------------
# write a function to xtract the first numbers from bicycle column using strinr extract
extract_numeric <- function(columns) {
  digital_pattern <- '^\\d+' # set pattern
  extracted <- str_extract(columns, digital_pattern)
  extracted <- as.numeric(extracted)
  return(extracted)
}

# Use the mutate() function on the BICYCLES column
sub_bike_sharing_system_df <- sub_bike_sharing_system_df %>% mutate(BICYCLES=extract_numeric(BICYCLES))

# print summary of numeric column
summary(sub_bike_sharing_system_df$BICYCLES)

# Data Preprocessing the Seoul Bike-sharing System Dataset
# ------------------------------------------------------------------------
seoul_bike_sharing_df <- read.csv(dataset_list[2])
head(seoul_bike_sharing_df)

summary(seoul_bike_sharing_df)
print('Dimension of Data Frame')
dim(seoul_bike_sharing_df)

# Detect and handle missing values
# ------------------------------------------------------------------------
# drop missing NAs in the rented bike column
seoul_bike_sharing_df <- seoul_bike_sharing_df %>% drop_na(RENTED_BIKE_COUNT)

# use imputation to handle missing NAs in temperature variable 
seoul_bike_sharing_df %>% filter(is.na(TEMPERATURE))

# Calculate the average summer temperature
summer_temperature_avg <- seoul_bike_sharing_df %>% 
  filter(SEASONS == "Summer", !is.na(TEMPERATURE)) %>%
  summarise(average = round(mean(TEMPERATURE), 2))

summer_temperature_avg

# extract the average from the tibble into a variable
average_temperature <- summer_temperature_avg$average
average_temperature

# Use imputation to handle the missing TEMPERATURE values by replacing NAs with summer average temperature
seoul_bike_sharing_df <- seoul_bike_sharing_df %>% 
  mutate(TEMPERATURE = replace_na(TEMPERATURE, average_temperature))

# Print the summary of the dataset again to make sure no missing values in all columns
summary(seoul_bike_sharing_df)
dim(seoul_bike_sharing_df)

# Feature Engineering using indicator (dummy) variables and Min-max Scaler
# ------------------------------------------------------------------------
# Convert the HOUR column into character
seoul_bike_sharing_converted_df <- seoul_bike_sharing_df %>% mutate(HOUR = as.character(HOUR))
summary(seoul_bike_sharing_converted_df)
dim(seoul_bike_sharing_converted_df)

# Convert SEASONS, HOLIDAY, FUNCTIONING_DAY, and HOUR columns into indicator columns.
seoul_bike_sharing_converted_df <- seoul_bike_sharing_converted_df %>%
  mutate(dummy = 1) %>%
  spread(key = HOLIDAY, value = dummy, fill = 0) %>%
  mutate(dummy = 1) %>%
  spread(key = SEASONS, value = dummy, fill = 0) %>%
  mutate(dummy = 1) %>%
  spread(key = HOUR, value = dummy, fill = 0) %>%
  mutate(dummy = 1) %>%
  spread(key = FUNCTIONING_DAY, value = dummy, fill = 0)

summary(seoul_bike_sharing_converted_df)
print('Data frame Dimension')
dim(seoul_bike_sharing_converted_df)

head(seoul_bike_sharing_converted_df)

# Normalise using the min-max scaler
# ------------------------------------------------------------------------
# Create a min-max scaler normalisation function
minmax_scaler <- function(columns) {
  (columns - min(columns)) / (max(columns) - min(columns))
} 

# Use the mutate function to apply the min-max scaler to the variables 
# (rented bike count, temp, humidity, wind speed, visibility, dew_point temp, solar rad, rainfall and snowfall)
seoul_bike_sharing_normalised_df <- seoul_bike_sharing_converted_df %>%
  mutate(
    RENTED_BIKE_COUNT = minmax_scaler(RENTED_BIKE_COUNT), 
    TEMPERATURE = minmax_scaler(TEMPERATURE), 
    HUMIDITY = minmax_scaler(HUMIDITY),
    WIND_SPEED = minmax_scaler(WIND_SPEED),
    VISIBILITY = minmax_scaler(VISIBILITY),
    DEW_POINT_TEMPERATURE = minmax_scaler(DEW_POINT_TEMPERATURE),
    SOLAR_RADIATION = minmax_scaler(SOLAR_RADIATION),
    RAINFALL = minmax_scaler(RAINFALL),
    SNOWFALL = minmax_scaler(SNOWFALL)
  )

# Print the summary of the dataset
summary(seoul_bike_sharing_normalised_df)

# Standardise the Column and Export Dataframes to CSV
# ------------------------------------------------------------------------
# Use a list to define the data frame variable
dataframes <- list(sub_bike_sharing_system_df, seoul_bike_sharing_df, seoul_bike_sharing_converted_df, seoul_bike_sharing_normalised_df)

# Use a vector to define the CSV file names 
file_names <- c('bike_sharing_systems.csv', 
                'seoul_bike_sharing.csv', 
                'seoul_bike_sharing_converted.csv', 
                'seoul_bike_sharing_converted_normalized.csv')

# Define a function to export the data frames as CSV files
export_to_csv <- function(dataframes, csv_file_names) {
  # Check if the dataframes and CSV file names are the same
  if (length(dataframes) != length(csv_file_names)) {
    stop("Data frames and file names do not have the same length")
  }
  
  # Iterate through the data frames and file names to save each data frame to a CSV file
  for (i in seq_along(dataframes)) {
    write_csv(dataframes[[i]], csv_file_names[[i]])
  }
}

# Define a function to standardise column names in the data frames
standardise_column_names <- function(dataframe_list) {
    colnames(dataframe_list) <- colnames(dataframe_list) %>%
    str_replace_all(' ', '_') %>%
    toupper()
    return(dataframe_list)
}

# Apply the function to each data frame in the list
standardised_dataframe_list <- lapply(dataframes, standardise_column_names)

# Print the overview of dataframes to verify
glimpse(standardised_dataframe_list)

# Export dataframes to CSV and print the result
export_to_csv(standardised_dataframe_list, file_names)
print('Dataframes successfully exported as CSV')

# Exploratory Data Analysis (EDA)
# ------------------------------------------------------------------------
# load the Seoul CSV file into a data frame with the DATE import as a character
seoul_bike_sharing <- read_csv('seoul_bike_sharing.csv', col_types = cols(DATE = col_character()))
head(seoul_bike_sharing)

# Cast DATE as a date ("%d/%m/%Y")
seoul_bike_sharing <- seoul_bike_sharing %>% mutate(DATE = as.Date(DATE, format = '%d/%m/%Y'))
head(seoul_bike_sharing)

# Cast HOURS as categorical variable
seoul_bike_sharing <- seoul_bike_sharing %>% mutate(HOUR = as.character(HOUR))

# Print the structure of the dataframe
str(seoul_bike_sharing)

# Cross check for missing values
sum(is.na(seoul_bike_sharing))

# Descriptive Statistics
# ------------------------------------------------------------------------
# Provide a detailed summary statistics
summary(seoul_bike_sharing)
print('Data frame Dimension')
dim(seoul_bike_sharing)

# Count the number of records by season using the table function
season_count_records <- table(seoul_bike_sharing$SEASONS)
season_count_records

# Calculating the number of holidays
holiday_count <- paste('Number of Holiday:', sum(seoul_bike_sharing$HOLIDAY == 'Holiday'))
holiday_count

# Calculating the percentage of holidays
percentage_holiday <- paste(
    'Percentage Holidays:', 
    round(sum(seoul_bike_sharing$HOLIDAY == 'Holiday') / nrow(seoul_bike_sharing) * 100, digits = 1), 
    '%')
percentage_holiday

# Total number of records
total_record <- paste("Total Records:", ncol(seoul_bike_sharing) * nrow(seoul_bike_sharing))
total_record

# Length of records in functional day column
total_functional_day_record <- paste('Records in Functional Day Column:', length(seoul_bike_sharing$FUNCTIONING_DAY))
total_functional_day_record

# Calculating the seasonal total rainfall and snowfall
seasonal_total <- seoul_bike_sharing %>% 
  group_by(SEASONS) %>%
  summarise(total_rain = sum(RAINFALL, na.rm = TRUE), 
            total_snow = sum(SNOWFALL, na.rm = TRUE))
seasonal_total

# Data Visualization
# ------------------------------------------------------------------------
# Scatter plot of rented bike time series
ggplot(seoul_bike_sharing, aes(x = DATE, y = RENTED_BIKE_COUNT)) + 
    geom_point(alpha=0.3) +
    labs(x = 'Dates',
        y = 'Rented Bike',
        title = 'Scatter plot of Rented Bike vs Date') +
    theme_light() +
    theme(
        text = element_text(size = 20)
    )

# Scatter plot of the RENTED_BIKE_COUNT time series with HOURS as the colour
ggplot(seoul_bike_sharing, aes(x = DATE, y = RENTED_BIKE_COUNT, color = HOUR)) +
  geom_point(alpha = 0.3) +
  labs(x = 'Dates',
       y = 'Rented Bike',
       color = 'HOURS',
       title = 'Scatter Plot of Rented Bike vs Date with HOURS as hue') +
  theme_light() +
    theme(
        text = element_text(size = 20)
    )

# Histogram with a kernel density curve
ggplot(seoul_bike_sharing, aes(x = RENTED_BIKE_COUNT, y = after_stat(density))) +
  geom_histogram(aes(fill = after_stat(count)), color = "gray", alpha = 4/5, bins = 20) +
  geom_density(color = "red") +
  labs(title = "Histogram with Kernel Density Curve",
       x = "Rented Bike",
       y = "Density",
       fill = 'Bike Count') +
  theme_light() +
    theme(
        text = element_text(size = 20)
    )

# Scatter plot showing the relationship between rented bike count and temperature
ggplot(seoul_bike_sharing, aes(x=TEMPERATURE,y=RENTED_BIKE_COUNT,colour=HOUR)) +
   geom_point(alpha=4/5) + 
  labs(title = "Scatter Plot: Rented Bike Count vs Temperature",
       x = "Temperature",
       y = "Rented Bike") +
  theme_light() +
    theme(
        text = element_text(size = 20)
    )

# Scatter plot showing the correlation between rented bike count and temperature by seasons
ggplot(seoul_bike_sharing, aes(x = TEMPERATURE, y = RENTED_BIKE_COUNT, color = HOUR)) +
  geom_point(alpha = 4/5) +
  facet_wrap(~ as.factor(SEASONS)) + 
  labs(title = "Scatter Plot: Rented Bike Count vs Temperature by Seasons",
       x = "Temperature",
       y = "Rented Bike",
       color = "Hour") +
  theme_light() +
    theme(
        text = element_text(size = 20)
    )

# Boxplot of rented bike count vs hour grouped by seasons
ggplot(seoul_bike_sharing, aes(x = HOUR, y = RENTED_BIKE_COUNT, fill = HOUR)) +
  geom_boxplot() +
  facet_wrap(~ as.factor(SEASONS)) +
  labs(title = "Boxplots: Rented Bike Cout vs Hour by Seasons",
       x = "Hour",
       y = "Rented Bikes",
       fill = "Hour") +
  theme_classic() +
    theme(
        text = element_text(size = 20)
    )

# Calculate the total rainfall and snowfall by date
daily_total <- seoul_bike_sharing %>% 
  group_by(DATE) %>%
  summarise(total_rain = sum(RAINFALL, na.rm = TRUE),
            total_snow = sum(SNOWFALL, na.rm = TRUE))
# print values
head(daily_total)

# visualise the total rainfall and snowfall by date
ggplot(daily_total, aes(x = DATE)) + 
    geom_line(aes(y = total_rain, color = 'Rainfall'), linewidth = 1.5) +
    geom_line(aes(y = total_snow, color = 'Snowfall'), linewidth = 1.5) +
    labs(title = "Daily Total Rainfall and Snowfall by Date",
       x = "Date",
       y = "Total",
       color = "Weather Condition") +
    scale_color_manual(values = c("Rainfall" = "navy", "Snowfall" = "red")) +
    theme_light() +
    theme(
        text = element_text(size = 20)
    )

# Calculate how many days had snowfall
snow_days <- paste('Number of days of snowfall:', sum(daily_total$total_snow > 0), 'days')
snow_days

# Predictive Modeling of Seoul Bike Rentals Using Linear Regression
# ------------------------------------------------------------------------
seoul_bike_sharing <- read_csv('seoul_bike_sharing_converted_normalized.csv', show_col_types = FALSE)
readr::spec(seoul_bike_sharing)

# Drop the date and functional day variables 
seoul_bike_sharing <- seoul_bike_sharing %>% select(-DATE, -YES)

# Print summary statistics of dataset
summary(seoul_bike_sharing)

# Split Training and Testing Data
# ------------------------------------------------------------------------
# Use the initial_split(), training(), and testing() functions to split the dataset (set seed to 1234 and prop 3/4)

# set seed
set.seed(1234)

# split data variable
split_data <- initial_split(seoul_bike_sharing, prop = 3/4)

# train_data variable
training_data <- training(split_data)

# test_data variable
testing_data <- testing(split_data)

# Print training and test data sets 
paste('Training Dataset:', ceiling(nrow(training_data) / (nrow(training_data) + nrow(testing_data)) * 100), '%')
head(training_data)

paste('Testing Dataset:', floor(nrow(testing_data) / (nrow(training_data) + nrow(testing_data)) * 100), '%')
head(testing_data)

# Build a Linear Regression Model
# ------------------------------------------------------------------------
# Use `linear_reg()` with engine `lm` and mode `regression`
regression_model <- linear_reg() %>% set_engine('lm') %>% set_mode('regression')

# Define response and predictor weather variables
response_weather_variables <- RENTED_BIKE_COUNT ~ TEMPERATURE + HUMIDITY + WIND_SPEED + VISIBILITY + DEW_POINT_TEMPERATURE + 
                            SOLAR_RADIATION + RAINFALL + SNOWFALL

# Fit the linear regression model using Weather Predictor Variables Only
lr_model_weather <- regression_model %>% fit(response_weather_variables, data=training_data)

# Build a linear regression model using all variables
lr_model_all <- regression_model %>% fit(RENTED_BIKE_COUNT ~ ., data=training_data)

# Model Evaluation
# ------------------------------------------------------------------------
# Print weather variables model summary
summary(lr_model_weather$fit)

# Print all variables model summary
summary(lr_model_all$fit)

# Use the predict() function to generate test results for both models and generate two test results dataframe with a truth column
# Test Results for Weather Predictor Variable 
test_weather_model <- lr_model_weather %>%
  predict(new_data = testing_data) %>%
  mutate(truth = testing_data$RENTED_BIKE_COUNT)
head(test_weather_model)

# Test Results for all Predictor Variable
test_all_model <- lr_model_all %>%
  predict(new_data = testing_data) %>%
  mutate(truth = testing_data$RENTED_BIKE_COUNT)
head(test_all_model)

# Calculate R-squared and RMSE metrics for the weather and all variable test results

# R-squared Metric
r_squared_weather <- rsq(test_weather_model, truth = truth, estimate = .pred)
rmse_weather <- rmse(test_weather_model, truth = truth, estimate = .pred)

# RMSE metric
r_squared_all <- rsq(test_all_model, truth = truth, estimate = .pred)
rmse_all <- rmse(test_all_model, truth = truth, estimate = .pred)

# Print Results
print('R-squared and RMSE metrics for Weather Predictor Variables')
r_squared_weather
rmse_weather
print('R-squared and RMSE metrics for all Predictors Variables')
r_squared_all
rmse_all

# Feature Importance
# ------------------------------------------------------------------------
# Sort and order coefficient list
# Define a variable to hold the model coefficient
coefficient_all_variables <- lr_model_all$fit$coefficient

# Handle NAs 
coefficient_all_variables <- coefficient_all_variables %>% na.omit(coefficient_all_variables)

# Extract the names and values from the list
coefficient_names <- names(coefficient_all_variables)
coefficient_values <- unname(coefficient_all_variables)

# Write names and values to a data frame
coefficient_df <- data.frame(
    Variables = coefficient_names, 
    Coefficients = coefficient_values
)

# Print data frame
head(coefficient_df)

# Filter positive coefficient values
filter_positive_coefficient_df <- coefficient_df %>% dplyr::filter(Coefficients >= 0)

# Visualise the coefficient list using a bar chart
ggplot(filter_positive_coefficient_df, aes(x = Coefficients, y = fct_reorder(Variables, Coefficients, .desc = FALSE))) +
  geom_bar(stat = "identity", fill = "blue", color = "navy") +
  labs(title = "Top-ranked Variables by Coefficient", x = "Coefficient", y = "Variable") +
  theme_light() +
    theme(
        text = element_text(size = 20)
    ) 

# Refine the Baseline Regression Model
# ------------------------------------------------------------------------
# Add Polynomial Terms
# ------------------------------------------------------------------------
# Visualise correlations between rented bike count and temperature
ggplot(data = training_data, aes(RENTED_BIKE_COUNT, TEMPERATURE)) + 
    geom_point() +
  theme_light() +
    theme(
        text = element_text(size = 20)
    )

# Plot the higher-order polynomial fits
ggplot(data=training_data, aes(RENTED_BIKE_COUNT, TEMPERATURE)) + 
    geom_point() + 
    geom_smooth(method = "lm", formula = y ~ x, color="red") + 
    geom_smooth(method = "lm", formula = y ~ poly(x, 2), color="yellow") + 
    geom_smooth(method = "lm", formula = y ~ poly(x, 4), color="green") + 
    geom_smooth(method = "lm", formula = y ~ poly(x, 6), color="blue") +
  theme_light() +
    theme(
        text = element_text(size = 20)
    )

# Fit a Polynomial Terms
lm_polynomial_terms <- regression_model %>% fit(RENTED_BIKE_COUNT ~ poly(VISIBILITY, 6) + poly(DEW_POINT_TEMPERATURE, 6) +  
                           poly(TEMPERATURE, 4) + poly(SOLAR_RADIATION, 4) + poly(HUMIDITY, 4) + poly(WIND_SPEED, 2) + poly(RAINFALL, 2) + 
                           poly(SNOWFALL, 2) + ., data=training_data)

# Print summary
summary(lm_polynomial_terms$fit)

# Use the predict function to generate test results
lm_polynomial_terms_test <- lm_polynomial_terms %>%
    predict(new_data = testing_data) %>%
    mutate(truth = testing_data$RENTED_BIKE_COUNT)

head(lm_polynomial_terms_test)

# Convert all Negative Prediction Results to Zero
lm_polynomial_terms_test[lm_polynomial_terms_test<0] <- 0
head(lm_polynomial_terms_test, 10)

# Evaluate using R-squared and RMSE metrics
r_squared_polynomial_terms <- rsq(lm_polynomial_terms_test, truth = truth, estimate = .pred)
rmse_polynomial_terms <- rmse(lm_polynomial_terms_test, truth = truth, estimate = .pred)

print('R-squared and RMSE metrics for Polynomial Terms')
r_squared_polynomial_terms
rmse_polynomial_terms

# Add Interaction Terms
# ------------------------------------------------------------------------
# Add first-degree interaction terms to the poly regression from above
lm_interaction_terms <- regression_model %>% fit(RENTED_BIKE_COUNT ~ poly(VISIBILITY, 6) * poly(DEW_POINT_TEMPERATURE, 6) +  
                           poly(TEMPERATURE, 4) * poly(SOLAR_RADIATION, 4) + poly(HUMIDITY, 4) * poly(WIND_SPEED, 2) + poly(RAINFALL, 2) * 
                           poly(SNOWFALL, 2) + ., data=training_data)

# Print summary 
summary(lm_interaction_terms$fit)

# Use the predict function to generate test results for the interaction term model
lm_interaction_terms_test <- lm_interaction_terms %>%
    predict(new_data = testing_data) %>%
    mutate(truth = testing_data$RENTED_BIKE_COUNT)

head(lm_interaction_terms_test)

# Convert all Negative Prediction Results to Zero
lm_interaction_terms_test[lm_interaction_terms_test<0] <- 0
head(lm_interaction_terms_test, 10)

# Evaluate using R-squared and RMSE metrics
r_squared_interaction_terms <- rsq(lm_interaction_terms_test, truth = truth, estimate = .pred)
rmse_interaction_terms <- rmse(lm_interaction_terms_test, truth = truth, estimate = .pred)

print('R-squared and RMSE metrics for Interactions Terms')
r_squared_interaction_terms
rmse_interaction_terms

# Add regularisation
# ------------------------------------------------------------------------
# Add L1 and L2 regularisation using glmnet engine 
lr_glmnet <- linear_reg(penalty = 0.01, mixture = 0) %>% 
    set_engine('glmnet') %>%
    set_mode('regression')

lm_glmnet <- lr_glmnet %>% fit(RENTED_BIKE_COUNT ~ poly(VISIBILITY, 6) * poly(DEW_POINT_TEMPERATURE, 6) +  
                           poly(TEMPERATURE, 4) * poly(SOLAR_RADIATION, 4) + poly(HUMIDITY, 4) * poly(WIND_SPEED, 2) + poly(RAINFALL, 2) * 
                           poly(SNOWFALL, 2) + ., data=training_data)

# Use the predict function to generate test results for the glmnet model
lm_glmnet_test <- lm_glmnet %>%
    predict(new_data = testing_data) %>%
    mutate(truth = testing_data$RENTED_BIKE_COUNT)

head(lm_glmnet_test)

# Convert all Negative Prediction Results to Zero
lm_glmnet_test[lm_glmnet_test<0] <- 0
head(lm_glmnet_test, 10)

# Evaluate using R-squared and RMSE metrics
r_squared_glmnet <- rsq(lm_glmnet_test, truth = truth, estimate = .pred)
rmse_glmnet <- rmse(lm_glmnet_test, truth = truth, estimate = .pred)

print('R-squared and RMSE metrics for Glmnet')
r_squared_glmnet
rmse_glmnet

# Improved Model
# ------------------------------------------------------------------------
# Print the column names
print('Training Data Column Names')
colnames(training_data)
print('Testing Data Column Names')
colnames(testing_data)

# Create new variable for the training and testing data
training_data_random_forest <- training_data
testing_data_random_forest <- testing_data

# Create a variable to hold new column names
new_column_names <- c('RENTED_BIKE_COUNT', 'TEMPERATURE', 'HUMIDITY', 'WIND_SPEED', 'VISIBILITY', 'DEW_POINT_TEMPERATURE', 
                      'SOLAR_RADIATION', 'RAINFALL', 'SNOWFALL', 'HOLIDAY', 'NO_HOLIDAY', 'AUTUMN', 'SPRING', 'SUMMER', 
                      'WINTER', 'ZERO', 'ONE', 'TEN', 'ELEVEN', 'TWELVE', 'THIRTEEN', 'FOURTEEN', 'FIFTEEN', 'SIXTEEN', 
                      'SEVENTEEN', 'EIGHTEEN', 'NINETEEN', 'TWO', 'TWENTY', 'TWENTY_ONE', 'TWENTY_TWO', 'TWENTY_THREE', 
                      'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE')

# Rename column names for training and testing data
colnames(training_data_random_forest) <- new_column_names
colnames(testing_data_random_forest) <- new_column_names

# Display the new variable column names
print('Training Data Column Names')
colnames(training_data_random_forest)
print('Testing Data Column Names')
colnames(testing_data_random_forest)

# Train using the Random Forest model
random_forest <- randomForest(
  formula = RENTED_BIKE_COUNT ~ ., 
  data = training_data_random_forest, 
  ntree = 500,  
  mtry = 10,  
  importance = TRUE
)

# Predict and test
random_forest_test <- predict(random_forest, newdata = testing_data_random_forest)

# Convert predictions to a data frame and then use mutate
random_forest_test_df <- data.frame(predictions = random_forest_test) %>%
  mutate(truth = testing_data_random_forest$RENTED_BIKE_COUNT)

# print head of data frame
head(random_forest_test_df)

# Convert all Negative Prediction Results to Zero
random_forest_test_df[random_forest_test_df<0] <- 0
head(random_forest_test_df, 10)

# Evaluate using R-squared and RMSE metrics
r_squared_randomForest <- rsq(random_forest_test_df, truth = truth, estimate = predictions)
rmse_randomForest <- rmse(random_forest_test_df, truth = truth, estimate = predictions)

print('R-squared and RMSE metrics for Random Forest')
r_squared_randomForest
rmse_randomForest

# View importance of variables
head(importance(random_forest), 10)

# Save rmse and rsq values of different models in a data frame
model_results <- data.frame(
  Model = c("Linear", "Polynomial", "Poly + Interaction", "Glmnet", "Random Forest"),
  RMSE = c(rmse_all$.estimate, rmse_polynomial_terms$.estimate, rmse_interaction_terms$.estimate, 
           rmse_glmnet$.estimate, rmse_randomForest$.estimate),
  R_Squared = c(r_squared_all$.estimate, r_squared_polynomial_terms$.estimate, r_squared_interaction_terms$.estimate, 
                r_squared_glmnet$.estimate, r_squared_randomForest$.estimate)
)

model_results

# Visualise Results from all Models
# ------------------------------------------------------------------------
# Convert result data frame from wide to long format
model_results_long_format <- model_results %>%
  pivot_longer(cols = c(RMSE, R_Squared), names_to = "Metric", values_to = "Value")

# Create the grouped bar chart
ggplot(model_results_long_format, aes(x = Model, y = Value, fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "RMSE and R-squared Values",
       x = "Models",
       y = "Metric Values") +
  theme_light() +
    theme(
        text = element_text(size = 20)
    )

# Plot a Q-Q plot for Best Performing Linear Model and Non-Linear Model
# ------------------------------------------------------------------------
# Create the Q-Q plot for Random Forest Model
ggplot(random_forest_test_df) +
    stat_qq(aes(sample = truth), color = 'navy') +
    stat_qq(aes(sample = predictions), color = 'red') +
    labs(title = "Q-Q Plot: True Values vs. Predictions for Random Forest",
         x = "True Values",
         y = "Predicted Values") +
    theme_light() +
    theme(
        text = element_text(size = 20)
    )

# Create the Q-Q plot for the Glmnet Model
ggplot(lm_glmnet_test) +
    stat_qq(aes(sample = truth), color = 'navy') +
    stat_qq(aes(sample = .pred), color = 'blue') +
    labs(title = "Q-Q Plot: True Values vs. Predictions for Linear with Glmnet Engine",
         x = "True Values",
         y = "Predicted Values") +
    theme_light() +
    theme(
        text = element_text(size = 20)
    )

# Save Model for Deployment
# ------------------------------------------------------------------------
# Save model to a file
saveRDS(lm_glmnet, file = "glmnet_model.rds") # Glmnet

saveRDS(random_forest, file = "random_forest_model.rds") # Random Forest

# ------------------------------------------------------------------------
