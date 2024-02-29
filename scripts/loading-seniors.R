library(here)
library(readxl)
library(stringr)
i_am("scripts/loading-seniors.R")

df_seniors <- read_excel(here("data/senior-data.xlsx"), sheet = 1, skip = 1)

df_seniors <- df_seniors %>%
    mutate(ID = str_glue("senior_{row_number()}")) %>%
    mutate(across(-c(ID, Form), as.numeric)) %>%
    pivot_longer(cols = -c(ID, Form)) %>%
    separate(name, into = c("measure", "difficulty"), sep = "_") %>%
    mutate(measure = case_when(measure == "Missing.Items" ~ "selection",
                               measure == "Order.Errors" ~ "incorrect_object_order",
                               measure == "Placement.Errors" ~ "incorrect_placement",
                               TRUE ~ measure))
