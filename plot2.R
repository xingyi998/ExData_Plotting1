# you can pass in the working directory using the first command line argument, 
# or the script will use the default one
args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  setwd(args[1])
} else {
  setwd("./")
}

################
# Getting Data
################

# create a temporary directory to download the zip file.
# If it exist, delete it and re-create the directory.
# The code will re-download the file every time when it is executed, 
# so even if the file in the zip file changes, the plot this code generates will still be up-to-date
tempDir = "./__temp_download/"
if (file.exists(tempDir)) {
  unlink(tempDir, recursive = TRUE)
}
dir.create(tempDir)

# download the file and unzip it
fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
destFile <- paste(tempDir, "household_power_consumption.zip", sep="")
download.file(fileUrl, destfile = destFile, method = "curl")
untar(destFile, exdir = tempDir)

# find out the path of the actual data file that is unzipped from the zip file
filePath <- list.files(tempDir)
filePath <- filePath[filePath != "household_power_consumption.zip"]
filePath <- paste(tempDir, filePath, sep = "")

################
# Cleaning Data
################

# read in the data to a dataframe with the trick mentioned in the previous class
# the code will read the first 100 rows to identify the class of the columns
# and pass it to read.table, so it can read in data much faster
initial <- read.table(filePath, sep = ";", na.strings = "?", header = TRUE, comment.char = "", nrows = 100)
classes <- sapply(initial, class)
df <- read.table(filePath, sep = ";", na.strings = "?", header = TRUE, comment.char = "", colClasses = classes)
# subset the dataframe to only use data from the dates 2007-02-01 and 2007-02-02
# I can make the subset logic simpler like df[df$Date == "1/2/2007" | df$Date == "2/2/2007"],
# but instead, I choose this safer approach just in case that the date is formatted in a slightly different way
# such as 01/02/2007 and 02/02/2007
df <- df[as.Date(df$Date, format = "%d/%m/%Y") == as.Date("2007-02-01") | as.Date(df$Date, format = "%d/%m/%Y") == as.Date("2007-02-02"),]
# merge Date and Time column to a new column called Datetime. The class of the new columm is POSIXlt
df$Datetime <- strptime(paste(df$Date, df$Time), format = "%d/%m/%Y %H:%M:%S")
# remove Date and Time column to free some memory
df <- df[,!(names(df) %in% c("Date","Time"))]

################
# Plotting Data
################

# generate the line graph
png(filename = "plot2.png", width = 480, height = 480, bg="transparent")
par(cex.lab=1, cex.axis=1, cex.main=1.1, cex.sub=1)
plot(df$Datetime, df$Global_active_power, type = "l", xlab = "", ylab = "Global Active Power (kiliwatts)")
dev.off()

# remove the temporary directory
unlink(tempDir, recursive = TRUE)