library(dplyr)
library(tidyr)
library(here)
i_am("scripts/loading-adults.R")

df_rbans <- read.table(here("data/df_rbans_a.csv"), sep = ";", header = TRUE)
df_emt_adults <- read.table(here("data/df_emt_adults.csv"),
                            sep = ";", header = TRUE, encoding = "UTF-8")

# rename colums age to asd
df_emt_adults <- df_emt_adults %>%
  rename("Age" = "Věk", "Technical_education" = "Tech..Vz.",
         "Gender" = "Pohlaví")

df_emt_adults <- df_emt_adults %>%
  # relabel Gender "zena" is "female"
  mutate(Gender = case_when(Gender == "žena" ~ "Female",
                            Gender == "muž" ~ "Male"))

df_emt_adults <- df_emt_adults %>%
  select(-c(Pořadí, PC.hry, Technical_education)) %>%
  pivot_longer(cols = X5por:X11poz, names_to = "task",
               values_to = "errors") %>%
  mutate(task = gsub("X", "", task)) %>%
  separate(task, into = c("difficulty", "error_type"),
           sep = "(?<=\\d)(?=\\D)") %>%
  separate(ID_NUDZ, into = c("Project", "Session", "ID"), sep = "_") %>%
  readr::type_convert() %>%
  mutate(relative_error_value = errors / difficulty,
         made_error = relative_error_value > 0) %>%
  mutate(relative_correct = 1 - relative_error_value) %>%
  mutate(error_type = case_when(error_type == "por" ~ "incorrect_order",
                                error_type == "poz" ~ "incorect_placement"))

df_rbans <- df_rbans %>%
  mutate(bindingid = gsub("_", "", ID)) %>%
  filter(grepl("HCE", bindingid)) %>%
  select(ID, vek, RBANS.A.1:RBANS.A.2, bindingid)

df_emt_adults <- df_emt_adults %>%
  mutate(bindingid = paste0(Project, ID)) %>%
  filter(grepl("HCE", bindingid))

df_emt_adults <- df_emt_adults %>%
  left_join(df_rbans, by = "bindingid")
