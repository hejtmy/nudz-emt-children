# download file from google drive# Install the googledrive package if you haven't already
# install.packages("googledrive")

library(googledrive)

# Authenticate with your Google account
drive_auth()
# Specify the file ID of the file you want to download
file_id <- "1SDkYcVC8ZY6KPHchzYEya7rCr6GUqUBb"
dir.create("data", showWarnings = FALSE)
# Download the file
drive_download(file = as_id(file_id), path = "data/processed-data.xlsx")
