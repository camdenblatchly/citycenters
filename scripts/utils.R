acs_vars <- c(
  "short_commute" = "B08134_002"
)

get_pop_job_centers <- function(principle_geoid_st, geoid_pl) {

  # principle_geoid_st <- top50_simple$PrincipleCityStateFIPS[i]

  acs_raw <- tidycensus::get_acs(
    "block group",
    variables = acs_vars,
    year = 2019,
    state = principle_geoid_st,
    summary_var = "B01001_001"
  ) %>%
  select(-c(NAME, moe, summary_moe)) %>%
  rename(
    tot_pop = summary_est,
    short_commute_pop = estimate
  )

  state_bg <- tigris::block_groups(state = principle_geoid_st, cb = TRUE, year = 2019)

  place_geo <- tigris::places(state = principle_geoid_st) %>%
    filter(GEOID == geoid_pl)

  place_bg <- state_bg %>%
    filter(st_intersects(., place_geo, sparse = FALSE) %>% apply(1, any))

  place_dta <- left_join(
    place_bg,
    acs_raw,
    by = "GEOID"
  ) %>%
    # Remove water only block groups and ones without people
    filter(ALAND > 0) %>%
    # Minimum population size for block group
    filter(tot_pop > 100) %>%
    mutate(
      pct_with_short_commute = short_commute_pop / tot_pop,
      pop_density = tot_pop / ALAND
    ) %>%
    # calculate Block Group Lat Lon
    mutate(
      centroid = st_centroid(geometry)
    ) %>%
    mutate(
      lon = st_coordinates(centroid)[, 1],
      lat = st_coordinates(centroid)[, 2]
    ) %>%
    st_as_sf() %>%
    st_transform(crs = 4326)

  pop_weighted_center <- place_dta %>%
    # Get the top quintile of population dense block groups
    filter(pop_density >= quantile(pop_density, .8, na.rm = TRUE)) %>%
    mean_center(
      group = c("variable"),
      weight = "pop_density"
    ) %>%
    mutate(
      lon = st_coordinates(geometry)[, 1],
      lat = st_coordinates(geometry)[, 2]
    )

  return(pop_weighted_center)

}
