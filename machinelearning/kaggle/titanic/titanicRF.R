library(caret)
library(randomForest)
library(fields)

trainSet <- read.table("https://raw.githubusercontent.com/mepotts/datascience/master/machinelearning/kaggle/titanic/data/train.csv", sep = ",", header = TRUE)
testSet <- read.table("https://raw.githubusercontent.com/mepotts/datascience/master/machinelearning/kaggle/titanic/data/test.csv", sep = ",", header = TRUE)

# Comparing variables and survived.

fields::bplot.xy(trainSet$Survived, trainSet$Age)

table(trainSet[,c("Survived", "Pclass")])


# Convert Survived to Factor
trainSet$Survived <- factor(trainSet$Survived)

# Set a random seed (so you will get the same results as me)
set.seed(42)
# Train the model using a "random forest" algorithm
model1 <- train(Survived ~ Pclass + Sex + Age + SibSp + Parch + Embarked + 
                  Pclass:Sex + Pclass:Age + Age:Sex, # Survived is a function of the variables we decided to include
               data = trainSet, # Use the trainSet dataframe as the training data
               method = "rf",# Use the "random forest" algorithm
               trControl = trainControl(method = "cv", # Use cross-validation
                                        number = 5) # Use 5 folds for cross-validation
)

model1


# Remove NAs from train and replace with the mean. 
#trainSet$Fare <- ifelse(is.na(trainSet$Fare), mean(trainSet$Fare, na.rm = TRUE), trainSet$Fare)
#trainSet$Age <- ifelse(is.na(trainSet$Age), mean(trainSet$Age, na.rm = TRUE), trainSet$Age)

# Train with the same variables using randomForest instead of caret.
# set.seed(107)

# model2 <- randomForest(Survived ~ Pclass + Sex + Age + SibSp + Parch + Embarked + 
#                        Pclass:Sex + Pclass:Age + Age:Sex, data = trainSet, ntree=20000)

# model2

testSet$Fare <- ifelse(is.na(testSet$Fare), mean(testSet$Fare, na.rm = TRUE), testSet$Fare)
testSet$Age <- ifelse(is.na(testSet$Age), mean(testSet$Age, na.rm = TRUE), testSet$Age)

testSet$Survived <- predict(model1, newdata = testSet)

predictions <- predict(model1, newdata = testSet)

submission <- testSet[, c("PassengerId", "Survived")]
write.table(submission, file = "submission3.csv", col.names = TRUE, row.names = FALSE, sep = ",")




