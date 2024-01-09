# download file from google drive# Install the googledrive package if you haven't already
# install.packages("googledrive")

library(googledrive)
drive_auth()
file_id <- "1SDkYcVC8ZY6KPHchzYEya7rCr6GUqUBb"
dir.create("data", showWarnings = FALSE)
drive_download(file = as_id(file_id), path = "data/processed-data.xlsx")
