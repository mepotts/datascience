library(caret)
library(kernlab)
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

# Train the model using a "svm" algorithm
model1 <- train(Survived ~ Pclass + Sex + Age + SibSp + Parch + Embarked + Fare + Pclass:Sex + Pclass:Age + Age:Sex, # Survived is a function of the variables we decided to include
               data = trainSet, # Use the trainSet dataframe as the training data
               method = "svmRadial",# Algorithm used
               metric = "Accuracy",
               preProc = c("knnImpute", "center", "scale"),
               trControl = trainControl(method = "repeatedcv", # Use cross-validation
                                        number = 5), # Use 5 folds for cross-validation
               tuneLength = 10
)

model1

# Remove NAs and replace with the mean.
testSet$Fare <- ifelse(is.na(testSet$Fare), mean(testSet$Fare, na.rm = TRUE), testSet$Fare)
testSet$Age <- ifelse(is.na(testSet$Age), mean(testSet$Age, na.rm = TRUE), testSet$Age)

# Caret SVM model to predict and create a submission file
testSet$Survived <- predict(model1, newdata = testSet)

predictions <- predict(model1, newdata = testSet)
predictions

write.table(testSet[, c("PassengerId", "Survived")], file = "submission4.csv", col.names = TRUE, row.names = FALSE, sep = ",")







