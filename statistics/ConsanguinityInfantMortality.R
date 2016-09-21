
read.csv("https://raw.githubusercontent.com/mepotts/datascience/master/datasets/GDP_World_Bank.csv", header = TRUE) -> wbGDP

# Create the gdp_growth variable that is the nominal increase in GDP from 2011 to 2012
wbGDP$gdp_growth <- wbGDP$gdp2012 - wbGDP$gdp2011

# Print the mean of gdp_growth by removing NA values
mean(wbGDP$gdp_growth, na.rm = TRUE)

hist(wbGDP$gdp_growth, breaks = 100)


# Create a new variable that is a logical vector with TRUE equal to countries where 
# gdp_growth is greater that the mean of gdp_growth
wbGDP$high_growth <- wbGDP$gdp_growth > mean(wbGDP$gdp_growth, na.rm = TRUE)

# Look at the count of countries above and below the mean
table(wbGDP$high_growth)

# Load cousin marriage data and read to data frame
x <- "https://raw.githubusercontent.com/fivethirtyeight/data/master/cousin-marriage/cousin-marriage-data.csv"
consan <- read.csv(x, header = TRUE)

# Do a bit of cleaning
# Find country name differences
consan$match <- match(consan$Country, wbGDP$Country)

# Do some manual replacements
consan$Country <- as.character(consan$Country)
consan$Country[consan$Country == "Great Britain"] <- "United Kingdom"
consan$Country[consan$Country == "Kyrgyzstan"] <- "Kyrgyz Republic"
consan$Country[consan$Country == "Syria"] <- "Syrian Arab Republic"
consan$Country[consan$Country == "The Netherlands"] <- "Netherlands"
consan$Country[consan$Country == "Yemen"] <- "Yemen, Rep."

# Drop the match column in consan
consan$match <- NULL

# Load infant mortality data from the World Bank (Children under 5 and per 1000 individuals)
mortality <- read.csv("https://raw.githubusercontent.com/mepotts/datascience/master/datasets/Data_Extract_From_World_Development_Indicators_Data.csv", header = TRUE)

# Merge the World Bank data sets with the Consanguineous data.
merge <- merge(x = wbGDP, y = consan, all.y = TRUE, by = "Country")
merge <- merge(x = merge, y = mortality, all.x = TRUE, by.x = "Country", by.y = "Country.Name")

# Clean data set and create an infant mortality percentage

finaldata <- merge[c(1:7, 22)]
names(finaldata)[8] <- "Mortality"
names(finaldata)[7] <- "ConsanguinityPct"
finaldata$Mortality <- suppressWarnings(as.numeric(levels(finaldata$Mortality))[finaldata$Mortality])
finaldata$InfantMortalityPct <- (finaldata$Mortality / 10)
finaldata <- finaldata[-c(69, 19, 27), ]

# Create a plot of InfantMortality vs. Consanguinity
suppressWarnings(library(ggplot2))
ggplot(data = finaldata, aes(x = ConsanguinityPct, y = InfantMortalityPct)) + geom_point(shape = 1) + stat_smooth(method = "lm") + ggtitle("Infant Mortality (% of pop) vs Consanguinity (% of pop)")

# Investigate effect of high and low consanguinity on infant mortality

finaldata$high_consan <- ifelse(finaldata$ConsanguinityPct > mean(finaldata$ConsanguinityPct, 
                                                                  na.rm = TRUE), "High", "Low")
ggplot(data = finaldata, aes(high_consan, InfantMortalityPct)) + stat_summary(fun.y = mean, geom = "bar", fill = "White", colour = "Black") + stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2)

# Plot the log10 of both varables
suppressWarnings(library(ggplot2))
ggplot(data = finaldata, aes(x = ConsanguinityPct, y = InfantMortalityPct)) + geom_point(shape = 1) + stat_smooth(method = "lm") + ggtitle("logInfant Mortality (% of pop) vs logConsanguinity (% of pop)") + scale_y_log10() + scale_x_log10()





