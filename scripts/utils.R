get_pop_job_centers <- function() {
  acs_vars <- c(
    "tot_pop" = "B01001_001",
    "short_commute" = "B08134_002"
  )

  acs_raw <- tidycensus::get_acs(
    "block group",
    variables = acs_vars,
    year = 2019,
    state = "25",
    county = c("025"),
    summary_var = "B01001_001"
  )


}
