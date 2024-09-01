# Data Science Capstone Project: Advanced Analytics with R (Bike-Sharing Demand Analysis)
### Problem Overview

An AI-powered weather data analytic company requires a data scientist to extract, analyse, and communicate data insight to understand how the weather would affect bike-sharing demand in urban areas in real time.
Objective

The objective of this analysis was:

- Collect and understand data from multiple sources
- Perform data wrangling and preparation with regular expressions and Tidyverse
- Perform exploratory data analysis with SQL and visualization using Tidyverse and ggplot2
- Perform modelling of the data with linear regressions using Tidymodels
- Build an interactive dashboard using R Shiny
- Present a report to stakeholders.

### About Datasets

A summary of the data required for the analysis includes:

- Seoul Bike Sharing Demand Data Set: The Seoul Bike Sharing Demand Data Set contains weather information (Temperature, Humidity, Windspeed, Visibility, Dewpoint, Solar radiation, Snowfall, Rainfall) and the number of bikes rented per hour and date.
- Open Weather API Data Set: The Open Weather API allows users to access current and forecasted weather data for any location, including over 200,000 cities. OpenWeather collects and processes weather data from different sources including global and local weather models, satellites, radars and a vast network of weather stations.
- Global Bike Sharing Systems Data Set: The Global Bike Sharing Cities Dataset is an HTML table on the Wikipedia page. It lists active bicycle-sharing systems around the world. Most systems listed allow users to pick up and drop off bicycles at any of the automated stations within the network.
- World Cities Data: The World Cities Data contains information about major cities around the world, such as names, latitudes, and longitudes.

### Summary of Notebook

#### Data Preprocessing
I started with data collection, scraping global bike-sharing system information and gathering weather data via API. Then, I embarked on extensive data wrangling by standardising column names and preprocessing the datasets.

I addressed missing values for the Seoul bike-sharing dataset before applying feature engineering techniques like dummy encoding and min-max scaling to prepare the data for predictive modelling.

#### Exploratory Data Analysis
Exploratory Data Analysis (EDA) uncovered the following hidden insights:

- The dataset covered one year of data.
- No record and day had zero bike rentals.
- There were clear seasonal trends, with summer having the most records.
- Temperature has a significant influence on bike rentals because of its wide range.
- Precipitation was rare, only happening in the fourth quartiles for rain and snowfall.
- The average windspeed is very light at 1.7 m/s, and even the maximum is a moderate breeze.

#### Predictive Modelling
I started the predictive modelling with baseline linear regressions. I discovered that the model using all predictor variables outperformed the model using weather-only predictor variables, with 66% of the variance compared to 43% for the weather-only predictor variables.

I refined my approach to improve the predictive accuracy (R-squared) and reduce the average predictive error (RMSE) of the model by:

- Adding polynomial terms, which increased predictive accuracy by 11%.
- Adding interaction terms and introducing regularisation with glmnet, improving the model further by 1%

I went a step further by implementing a non-linear predictive model (Random Forest model), and I was able to achieve an 88% predictive accuracy and a 6% average prediction error, representing an 11% accuracy improvement and a 2% error reduction over the best-performing linear model.

#### Conclusion and Recommendation
From my analysis, I was able to identify key factors influencing bike rentals, including temperature, seasonal variations, and time of day. I recommend the following to improve the analysis and predictive modelling:
- Managing outliers and multicollinearity to improve the performance of linear models,
- Collecting additional data to improve model performance,
- Performing time series analysis to better capture the trends and seasonality in the data, and
- Exploring advanced feature engineering techniques like lag features or moving averages.

#### Dependencies
- R version 4.3.1
- rvest version: 1.0.4
- httr version: 1.4.7
- ggplot2 version: 3.5.1
- repr version: 1.1.7
- rlang version: 1.1.4
- tidymodels version: 1.2.0
- stringr version: 1.5.1
- glmnet version: 4.1.8
- caret version: 6.0.94
- randomForest version: 4.7.1.1 

