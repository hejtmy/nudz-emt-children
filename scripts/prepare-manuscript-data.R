here::i_am("scripts/prepare-manuscript-data.R")

source(here::here("scripts", "loading-children.R"))
df_all_unfiltered <- df_all
df_vr_unfiltered <- df_vr

df_all <- df_all %>%
  filter(!(error_type %in% c("total_error", "incorrect_location_order")))

# Adding total error -----
df_all <- df_all %>%
  group_by(error_type, name, age_month) %>%
  summarise(all_trials_error = sum(error_value),
            all_trials_avg_relative_error = sum(relative_error_value)/3,
            all_trials_avg_relative_correct = 1 - all_trials_avg_relative_error) %>%
  ungroup() %>%
  right_join(df_all, by = c("name", "age_month", "error_type"))

df_vr <- select(df_all, name:relative_correct, error_type)
