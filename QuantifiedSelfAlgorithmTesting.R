#
# quantified self analysis: R version for testing alternate 
# machine learning algorithms 


# data download 

theFiles <- c("pml-testing.csv","pml-training.csv")
theDirectory <- "./data/"
dlMethod <- "curl"
if(substr(Sys.getenv("OS"),1,7) == "Windows") dlMethod <- "wininet"
if(!dir.exists(theDirectory)) dir.create(theDirectory)
for (i in 1:length(theFiles)) {
  aFile <- paste(theDirectory,theFiles[i],sep="")
  if (!file.exists(aFile)) {
    url <- paste("https://d396qusza40orc.cloudfront.net/predmachlearn/",
                 theFiles[i],
                 sep="")
    download.file(url,destfile=aFile,
                  method=dlMethod,
                  mode="w") # use mode "w" for text 
  }
}

# read and clean data 

pkgs <- c("lattice","MASS","ggplot2","grid","readr","knitr","caret","YaleToolkit",
          "iterators","parallel","foreach","doParallel")
notInstalled <- pkgs[!(pkgs %in% installed.packages())]
if(sum(!(pkgs %in% installed.packages())) > 0) {
  for(i in notInstalled) install.packages(i)
}

for(pkg in pkgs) {
  library(pkg,character.only = TRUE)
}

string40 <-  "ncnnccnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
string80 <-  "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
string120 <- "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
string160 <- "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnc"
colString <- paste(string40,string80,string120,string160,sep="")

validation <- readr::read_csv("./data/pml-testing.csv",
                              col_names=TRUE,
                              col_types=colString)
originalData <- readr::read_csv("./data/pml-training.csv",
                                col_names=TRUE,
                                col_types=colString)
# fix missing column name for "observation / row number"
theColNames <- colnames(originalData)
theColNames[1] <- "obs"
colnames(originalData) <- theColNames

originalData$classe <- as.factor(originalData$classe)
valResult <- whatis(originalData)
# retain all columns with fewer than 50 missing values
theNames <- as.character(valResult[valResult$missing < 50 & valResult$variable.name != "obs",1])
originalSubset <- originalData[,theNames]
# remove date variables and binary window 
originalSubset <- originalSubset[c(-2,-3,-4,-5)]
# valSubset <- whatis(originalSubset)
set.seed(102134)
trainIndex <- createDataPartition(originalSubset$classe,p=.60,list=FALSE)
training <- originalSubset[trainIndex,]
testing <- originalSubset[-trainIndex,]

# initiate parallel processing

cluster <- makeCluster(detectCores() - 1)
registerDoParallel(cluster)

# build baseline model: linear discriminant analysis

yvars <- training[,55]
xvars <- training[,-55]
intervalStart <- Sys.time()
mod1Control <- trainControl(method="cv",number=5,allowParallel=TRUE)
# modFit1 <- train(x=xvars,y=yvars,method="rpart",trControl=mod1Control)
modFit1 <- train(classe ~ .,data=training,method="lda",trControl=mod1Control)
# Model 1
intervalEnd <- Sys.time()
paste("Train model1 took: ",intervalEnd - intervalStart,attr(intervalEnd - intervalStart,"units"))
pred1 <- predict(modFit1,training)
# confusionMatrix(pred1,training$classe)
predicted_test <- predict(modFit1,testing)
confusionMatrix(predicted_test,testing$classe)
# predicted_validation <- predict(modFit,validation)

# build alternate model: random forest 

library(randomForest)
intervalStart <- Sys.time()
mod2Control <- trainControl(method="boot",number=25,allowParallel=TRUE)
modFit2 <- train(classe ~ .,data=training,method="rf",trControl=mod2Control)
intervalEnd <- Sys.time()
print(modFit2)
paste("Train model2 took: ",intervalEnd - intervalStart,attr(intervalEnd - intervalStart,"units"))
pred2 <- predict(modFit2,training)
confusionMatrix(pred2,training$classe)
predicted_test <- predict(modFit2,testing)
confusionMatrix(predicted_test,testing$classe)

# build an alternate model: neural network 
library(nnet)
intervalStart <- Sys.time()
mod3Control <- trainControl(method="boot",number=25,allowParallel=TRUE)
modFit3 <- train(classe ~ .,data=training,method="nnet",trControl=mod3Control)
intervalEnd <- Sys.time()
print(modFit3)
paste("Train model3 took: ",intervalEnd - intervalStart,attr(intervalEnd - intervalStart,"units"))
pred3 <- predict(modFit3,training)
confusionMatrix(pred3,training$classe)
predicted_test <- predict(modFit3,testing)
confusionMatrix(predicted_test,testing$classe)


# turn off parallel processing 
stopCluster(cluster)
registerDoSEQ() 
