library(readxl)
library(tidyverse)
library(here)
i_am("scripts/loading-children.R")

rename_demographics <- function(df_input) {
  colnames(df_input)[1:7] <- c(
    "name", "school", "gender", "age_year",
    "age_month", "birthday", "testing_date")
  return(df_input)
}

df_vr <- read_excel(here("data/processed-data.xlsx"), sheet = 3)
df_vr <- rename_demographics(df_vr)

df_vr <- df_vr[, -c(30:33)] %>%
  mutate(age_months = age_month,
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
  mutate(total_error = selection + incorect_placement +
                       incorrect_object_order + incorrect_location_order) %>%
  pivot_longer(cols = c(selection, incorect_placement, incorrect_object_order,
                        incorrect_location_order, total_error),
               names_to = "error_type",
               values_to = "error_value") %>%
  mutate(relative_error_value = error_value / difficulty,
         made_error = error_value > 0) %>%
  # if error type is total_error divide relative error by 4
  mutate(relative_error_value = case_when(error_type == "total_error" ~ relative_error_value/4,
                                          TRUE ~ relative_error_value),
         relative_correct = 1 - relative_error_value)

## NR SR preparation -------
df_nr <- read_excel(here("data/processed-data.xlsx"),
                    sheet = 1, na = c("", "-"))
df_nr <- rename_demographics(df_nr)

df_nr <- select(df_nr, 1:7, NR = `NR [40]`, SR = `SR [34]`)

## Hiding preparation -------
df_hiding <- read_excel(here("data/processed-data.xlsx"),
                        sheet = 6, na = c("", "-"))
df_hiding <- rename_demographics(df_hiding)
colnames(df_hiding)[8:13] <- c(paste0(c("plush_"), c("what", "where", "order")),
  paste0(c("child_"), c("what", "where", "order")))
df_hiding <- select(df_hiding, name:child_order)
# separate column hiding which is 1+2 into hiding_1 and hiding_2

df_hiding <- df_hiding %>%
  separate(plush_what, into = c("plush_what_target", "plush_what_actor"),
           sep = "\\+", remove = FALSE, convert = TRUE) %>%
  separate(child_what, into = c("child_what_target", "child_what_actor"),
           sep = "\\+", remove = FALSE, convert = TRUE)

## Merging it all together
df_all <- df_vr %>%
  left_join(select(df_nr, name, school, NR, SR), by = c("name", "school")) %>%
  left_join(select(df_hiding, name, school, plush_what:child_order),
            by = c("name", "school"))