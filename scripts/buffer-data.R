# download file from google drive# Install the googledrive package if you haven't already
# install.packages("googledrive")

library(googledrive)
library(googlesheets4)

drive_auth()
file_id <- "1SDkYcVC8ZY6KPHchzYEya7rCr6GUqUBb"
dir.create("data", showWarnings = FALSE)
drive_download(file = as_id(file_id), path = "data/processed-data.xlsx")

## Adults results
df_emt_adults <- read_sheet("1sE3a7nEeaB-6norUF9QCgvfZpYdbPLTGBgVnExR1poc",
                            sheet = "ENVIRONMENTS")
write.table(df_emt_adults, "data/df_emt_adults.csv", row.names = FALSE,
            sep = ";", fileEncoding = "UTF-8")
df_rbans_a <- read_sheet("1N11offQ6y2SavR-PmYQJgerzMlEqkjVkXvWfyazH1t8",
                         sheet = "RBANS.A", na = c("", "X"))
write.table(df_rbans_a, "data/df_rbans_a.csv", row.names = FALSE, sep = ";")

## Senior results
drive_download(file = as_id("1068tUCXQc2ZgBH7K_q7LBGHlEC-xHYPS"),
               path = "data/senior-data.xlsx", overwrite = TRUE)
