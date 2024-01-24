library(dplyr)
library(tidyr)

df_rbans <- read.table("data/df_rbans_a.csv", sep = ";", header = TRUE)
df_emt_adults <- read.table("data/df_emt_adults.csv", sep = ";", header = TRUE)

df_emt_adults <- df_emt_adults %>%
  select(-c(Pořadí, PC.hry, Tech..Vz.))

View(df_emt_adults)

df_emt_adults <- df_emt_adults %>%
  pivot_longer(cols = X5por:X11poz, names_to = "task",
               values_to = "errors") %>%
  mutate(task = gsub("X", "", task)) %>%
  separate(task, into = c("task_number", "task_name"),
           sep = "(?<=\\d)(?=\\D)") %>%
  separate(ID_NUDZ, into = c("Project", "Session", "ID"), sep = "_")


