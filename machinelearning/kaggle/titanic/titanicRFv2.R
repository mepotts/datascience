### LIBRARY CALL ###
library(caret)
library(kernlab)
library(randomForest)
library(fields)
library(rpart)

setwd("C:/Users/mpotts/Dropbox/UC Berkeley/Machine Learning/Kaggle Competitions/Titanic_Machine_Learning_from_Disaster")

#######################################################################################################

### READING DATA ###
train <- read.table("train.csv", sep = ",", header = TRUE)
test  <- read.table("test.csv", sep = ",", header = TRUE)
test$Survived <- 0

#######################################################################################################

### CLEANING DATA ###
combi <- rbind(train, test)
combi$Name <- as.character(combi$Name)
strsplit(combi$Name[1], split='[,.]')
strsplit(combi$Name[1], split='[,.]')[[1]]
strsplit(combi$Name[1], split='[,.]')[[1]][2]
combi$Title <- sapply(combi$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][2]})
combi$Title <- sub(' ', '', combi$Title)
combi$Title[combi$PassengerId == 797] <- 'Mrs' # female doctor
combi$Title[combi$Title %in% c('Lady', 'the Countess', 'Mlle', 'Mee', 'Ms')] <- 'Miss'
combi$Title[combi$Title %in% c('Capt', 'Don', 'Major', 'Sir', 'Col', 'Jonkheer', 'Rev', 'Dr', 'Master')] <- 'Mr'
combi$Title[combi$Title %in% c('Dona')] <- 'Mrs'
combi$Title <- factor(combi$Title)

# Passenger on row 62 and 830 do not have a value for embarkment. 
# Since many passengers embarked at Southampton, we give them the value S.
# We code all embarkment codes as factors.
combi$Embarked[c(62,830)] = "S"
combi$Embarked <- factor(combi$Embarked)

# Passenger on row 1044 has an NA Fare value. Let's replace it with the median fare value.
combi$Fare[1044] <- median(combi$Fare, na.rm=TRUE)

# Create new column -> family_size
combi$family_size <- combi$SibSp + combi$Parch + 1


# How to fill in missing Age values?
# We make a prediction of a passengers Age using the other variables and a decision tree model. 
# This time you give method="anova" since you are predicting a continuous variable.

predicted_age <- rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title + family_size,
                       data=combi[!is.na(combi$Age),], method="anova")
combi$Age[is.na(combi$Age)] <- predict(predicted_age, combi[is.na(combi$Age),])


#######################################################################################################

### Split Data After Cleaning ###
train_new <- combi[1:891,]
test_new <- combi[892:1309,]
test_new$Survived <- NULL

# Find Cabin Class 
train_new$Cabin <- substr(train_new$Cabin,1,1)
train_new$Cabin[train_new$Cabin == ""] <- "H"
train_new$Cabin[train_new$Cabin == "T"] <- "H"

test_new$Cabin <- substr(test_new$Cabin,1,1)
test_new$Cabin[test_new$Cabin == ""] <- "H"

train_new$Cabin <- factor(train_new$Cabin)
test_new$Cabin <- factor(test_new$Cabin)

# Create a new model 

train_new$Survived <- factor(train_new$Survived)

set.seed(42)
# Train the model using a "random forest" algorithm
model1 <- train(Survived ~ Age:Sex + Pclass:Age + Fare + Age + Pclass + Pclass:family_size + Age:family_size + Age:Fare +
                  Fare:Sex + Fare:family_size + Embarked:Sex, # Survived is a function of the variables we decided to include
                data = train_new, # Use the trainSet dataframe as the training data
                method = "rf",# Use the "random forest" algorithm
                trControl = trainControl(method = "cv", # Use cross-validation
                                         number = 5) # Use 5 folds for cross-validation
)

model1

gbmImp <- varImp(model1, scale = FALSE)
gbmImp

test_new$Survived <- predict(model1, newdata = test_new)

predictions <- predict(model1, newdata = test_new)
predictions

write.table(test_new[, c("PassengerId", "Survived")], 
            file = "TitanicSubmissionRF3.csv", 
            col.names = TRUE, row.names = FALSE, sep = ",") 


