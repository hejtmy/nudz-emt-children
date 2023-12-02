library(readxl)
library(tidyverse)
library(here)
i_am("scripts/loading.R")

df_vr <- read_excel(here("data/processed-data.xlsx"), sheet = 3)

# rename first columns using dplyr
colnames(df_vr)[1:7] <- c("name", "school", "gender", "age_year", "age_month",
  "birthday", "testing_date")

df_vr <- df_vr[, -c(30:33)] %>%
  mutate(age_months = age_year * 12 + age_month,
    # relabel gender 1 to female and 0 to male
        gender = case_match(gender,  c(0) ~ "male", c(1) ~ "female"))

df_vr <- df_vr %>%
  select(-contains("all"), -(contains(","))) %>%
  pivot_longer(cols = c(starts_with("CO"), starts_with("OPE"),
                        starts_with("OOE"), starts_with("LOE")),
               names_to = c("error_type", "difficulty"),
               names_pattern = "(.*)(\\d{1})",
               values_to = "error_value") %>%
  mutate(difficulty = as.numeric(difficulty)) %>%
  # replace CO with selection_error
  mutate(error_type = case_when(error_type == "CO" ~ "selection",
                                error_type == "OPE" ~ "incorect_placement",
                                error_type == "OOE" ~ "incorrect_object_order",
                                error_type == "LOE" ~ "incorrect_location_order")) %>%
  pivot_wider(names_from = "error_type", values_from = "error_value") %>%
  mutate(total_error = selection + incorect_placement + incorrect_object_order + incorrect_location_order) %>%
  pivot_longer(cols = c(selection, incorect_placement, incorrect_object_order, incorrect_location_order, total_error),
               names_to = "error_type",
               values_to = "error_value") %>%
  mutate(relative_error_value = error_value/difficulty,
         made_error = error_value > 0) %>%
    # if error type is total_error divide relative error by 4
    mutate(relative_error_value = case_when(error_type == "total_error" ~ relative_error_value/4,
                                            TRUE ~ relative_error_value))
