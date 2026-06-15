# Export anonymised, analysis-ready datasets for public release.
# Produces two tidy CSVs containing only the variables actually used in
# emt-manuscript.qmd (see also prepare-manuscript-data.R):
#   - public-data-children.csv : VR-EMT errors + NEPSY NR/SR
#   - public-data-adults.csv   : VR-EMT errors (House only) + RBANS A.1/A.2
#
# Excluded on purpose: hiding task, adult Office environment, location-order
# error (LOE), total_error, and any direct identifiers (names, school names,
# birthday, testing date).

library(tidyverse)
library(here)
i_am("scripts/export-public-data.R")

source(here("scripts/loading-children.R"), encoding = "UTF-8")
source(here("scripts/loading-adults.R"), encoding = "UTF-8")

out_dir <- here("report", "public-data")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# helper: turn an identifier column into a stable anonymous id (P001, P002, ...)
anonymise <- function(x, prefix) {
  sprintf("%s%03d", prefix, as.integer(factor(x)))
}

relabel_error_type <- function(x) {
  case_match(x,
    "selection"               ~ "selection",
    "incorrect_placement"     ~ "placement",
    "incorrect_object_order"  ~ "object_order",
    "incorrect_order"         ~ "object_order",  # adult naming
    .default = x)
}

## Children -------------------------------------------------------------------
# df_all (from loading-children.R) is the long VR table with NR/SR joined.
children_public <- df_all %>%
  filter(error_type %in% c("selection", "incorrect_placement",
                           "incorrect_object_order")) %>%
  transmute(
    id = anonymise(name, "C"), age_month, gender, difficulty,
    error_type = relabel_error_type(error_type), error_value,
    relative_correct, NR, SR) %>%
  arrange(id, error_type, difficulty)

write_csv(children_public, file.path(out_dir, "public-data-children.csv"))

## Adults (House only) --------------------------------------------------------
adults_public <- df_emt_adults %>%
  filter(Environment == "House",
         error_type %in% c("incorrect_placement", "incorrect_order")) %>%
  transmute(
    id = anonymise(bindingid, "A"), age = Age,
    gender = Gender, 
    difficulty, 
    error_type   = relabel_error_type(error_type),
    error_value  = errors,
    RBANS_A_1    = RBANS.A.1,
    RBANS_A_2    = RBANS.A.2,
    relative_correct) %>%
  arrange(id, error_type, difficulty)

write_csv(adults_public, file.path(out_dir, "public-data-adults.csv"))
