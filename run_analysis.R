# Load Packages and get the Data
library(data.table)
library(dplyr)

# Set the variables for the file and file path for downloading
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI_HAR_Dataset.zip"

# check to see if the file exists and if not then download
if (!file.exists(zipFile)) {
    download.file(fileUrl, zipFile, method="curl")
    
    # Check to see if the file exists and if so, unzip zip file
    dataPath <- "UCI_HAR_Dataset.zip"
    if (file.exists(dataPath)) {
        unzip(dataPath)
    }
    
}



datafilesPath <- file.path("./UCI HAR Dataset/")


# Read the activity labels into a table

activityLabels <- read.table(file.path(datafilesPath, "activity_labels.txt"), as.is = TRUE)
activityLabels[,2] <- as.character(activityLabels[,2])

#Read the Features info int a table
features <- read.table(file.path(datafilesPath, "features.txt"), as.is = TRUE)
features[,2] <- as.character(features[,2])

# Extract only the Features data for mean and standard deviation

#Uses grep funtion to search for regular expressions with Mean and std (std dev)
featuresMeanStdDev <- grep(".*mean.*|.*std.*", features[,2])
featuresMeanStdDev.names <- features[featuresMeanStdDev,2]

#uses gsub to replace all the matches of a string. First for mean and then for std
featuresMeanStdDev.names = gsub('-mean', 'Mean', featuresMeanStdDev.names)
featuresMeanStdDev.names = gsub('-std', 'Std', featuresMeanStdDev.names)
featuresMeanStdDev.names <- gsub('[-()]', '', featuresMeanStdDev.names)

# Load the train datasets
train <- read.table(file.path(datafilesPath,"train/X_train.txt"), as.is = TRUE)[featuresMeanStdDev]
trainActivities <- read.table(file.path(datafilesPath,"train/Y_train.txt"), as.is = TRUE)
trainSubjects <- read.table(file.path(datafilesPath,"train/subject_train.txt"), as.is = TRUE)
#Merge the train datasets in the train table
train <- cbind(trainSubjects, trainActivities, train)

# Load the test datasets
test <- read.table(file.path(datafilesPath,"test/X_test.txt"), as.is = TRUE)[featuresMeanStdDev]
testActivities <- read.table(file.path(datafilesPath,"test/Y_test.txt"), as.is = TRUE)
testSubjects <- read.table(file.path(datafilesPath,"test/subject_test.txt"), as.is = TRUE)
#Merge the test datasets in the test table 
test <- cbind(testSubjects, testActivities, test)

# merge test and train datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresMeanStdDev.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
