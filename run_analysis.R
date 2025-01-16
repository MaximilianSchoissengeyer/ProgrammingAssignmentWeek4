# prepare workspace
library(dplyr)
rm(list = ls())

# load and bind datas, we already load them with nice column names
activity_labels <- read.table(file = "./UCI HAR Dataset/activity_labels.txt", col.names = c("acivityID", "activity"))
features <- read.table(file = "./UCI HAR Dataset/features.txt", col.names = c("featureID","feature"))

X_train <- read.table(file = "./UCI HAR Dataset/train/X_train.txt", col.names = features$feature)
y_train <- read.table(file = "./UCI HAR Dataset/train/y_train.txt", col.names = c("activityasID"))
subject_train <- read.table(file = "./UCI HAR Dataset/train/subject_train.txt", col.names = c("subjectID"))
train <- cbind(subject_train, y_train, X_train)

X_test <- read.table(file = "./UCI HAR Dataset/test/X_test.txt", col.names = features$feature)
y_test <- read.table(file = "./UCI HAR Dataset/test/y_test.txt", col.names = c("activityasID"))
subject_test <- read.table(file = "./UCI HAR Dataset/test/subject_test.txt", col.names = c("subjectID"))
test <- cbind(subject_test, y_test, X_test)

#combine train and test data
df <- as_tibble(rbind(train,test))

#sort them according to the test subjects and give ID to measurements
df <- arrange(df,subjectID)
df <- as_tibble(cbind("measureID" = 1:nrow(df), df))

#choose just mean and std features
df <- select(df,1:3,grep("(mean[^F])|(std)",names(df)))

#give right names to activities instead of numbers
df <- df %>% mutate(activityasID = activity_labels$activity[match(activityasID, activity_labels$acivityID)]) %>% rename(activity = activityasID)

#create dataframe which has averages on activity and test subjects
df_grouped <- group_by(df, activity, subjectID)
dfsummarise <- summarize(df_grouped, across(seq(2,ncol(df_grouped)-2), mean))

print(dfsummarise)
