library(caret)
library(randomForest)
library(fields)

trainSet <- read.csv("https://raw.githubusercontent.com/mepotts/datascience/master/machinelearning/kaggle/titanic/data/train.csv", header = TRUE)
testSet <- read.table("https://raw.githubusercontent.com/mepotts/datascience/master/machinelearning/kaggle/titanic/data/test.csv", sep = ",", header = TRUE)

# Comparing variables and survived.

fields::bplot.xy(trainSet$Survived, trainSet$Age)

table(trainSet[,c("Survived", "Pclass")])


# Convert Survived to Factor
trainSet$Survived <- factor(trainSet$Survived)
trainSet$Pclass <- factor(trainSet$Pclass)
testSet$Pclass <- factor(testSet$Pclass)

# Remove NAs and replace with the mean. 
trainSet$Fare <- ifelse(is.na(trainSet$Fare), mean(trainSet$Fare, na.rm = TRUE), trainSet$Fare)
trainSet$Age <- ifelse(is.na(trainSet$Age), mean(trainSet$Age, na.rm = TRUE), trainSet$Age)


# Set a random seed (so you will get the same results as me)
set.seed(42)
# Train the model using a "random forest" algorithm

lgrs <- glm(Survived ~ Pclass + Sex + Age + SibSp + Embarked + Pclass:Sex + Pclass:Age
            , data = trainSet, family = binomial(logit))

lgrs

stepb <- step(lgrs, direction = "backward")
stepf <- step(lgrs, direction = "forward")
stepw <- step(lgrs, direction = "both")

stepb$anova
stepf$anova
stepw$anova

trainSet$pr <- as.vector(ifelse(predict(lgrs, type = "response", trainSet) > 0.6, "1", "0"))
table(trainSet$Survived, trainSet$pr, dnn = c("Actual", "Predicted"))

###############ROC Curve##################################

library(ROCR)
fitpreds = predict(lgrs,newdata=trainSet,type="response");
fitpred = prediction(fitpreds,trainSet$Survived);
fitperf = performance(fitpred,"tpr","fpr");
plot(fitperf,col="green",lwd=2,main="ROC Curve for Logistic regression")
abline(a=0,b=1,lwd=2,lty=2,col="gray")
summary(lgrs);


# Remove NAs from trainSet and replace with the mean. 
testSet$Fare <- ifelse(is.na(testSet$Fare), mean(testSet$Fare, na.rm = TRUE), testSet$Fare)
testSet$Age <- ifelse(is.na(testSet$Age), mean(testSet$Age, na.rm = TRUE), testSet$Age)

# add the predictions to the testSet
testSet$Survived <- as.vector(ifelse(predict(lgrs, type = "response", testSet) > 0.6, "1", "0"))

# view predictions
predictions <- as.vector(ifelse(predict(lgrs, type = "response", testSet) > 0.6, "1", "0"))
predictions

submission <- testSet[, c("PassengerId", "Survived")]
write.table(submission, file = "submission.csv", col.names = TRUE, row.names = FALSE, sep = ",")