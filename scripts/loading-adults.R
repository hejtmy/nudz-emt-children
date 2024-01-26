library(dplyr)
library(tidyr)

df_rbans <- read.table("data/df_rbans_a.csv", sep = ";", header = TRUE)
df_emt_adults <- read.table("data/df_emt_adults.csv", sep = ";", header = TRUE)

df_emt_adults <- df_emt_adults %>%
  select(-c(Pořadí, PC.hry, Tech..Vz.)) %>%
  pivot_longer(cols = X5por:X11poz, names_to = "task",
               values_to = "errors") %>%
  mutate(task = gsub("X", "", task)) %>%
  separate(task, into = c("task_number", "task_name"),
           sep = "(?<=\\d)(?=\\D)") %>%
  separate(ID_NUDZ, into = c("Project", "Session", "ID"), sep = "_") %>%
  readr::type_convert()

df_rbans <- df_rbans %>%
  mutate(bindingid = gsub("_", "", ID)) %>%
  filter(grepl("HCE", bindingid))

df_emt_adults <- df_emt_adults %>%
  mutate(bindingid = paste0(Project, ID)) %>%
  filter(grepl("HCE", bindingid))

df_emt_adults %>%
  left_join(df_rbans, by = "bindingid") %>%
  filter(Environment == "House", task_number == 5) %>%
  group_by(task_name, Environment) %>%
  group_modify(~broom::tidy(cor.test(.$RBANS.A.1, .$errors, method = "spearman"))) %>%
  select(estimate, statistic, p.value)
