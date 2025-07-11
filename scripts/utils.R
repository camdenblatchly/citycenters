# Did not end up using this variable, but I considered short commute
# as a possible definition
acs_vars <- c(
  "short_commute" = "B08134_002"
)


#' Get the population center of a US city
#'
#' @param principle_geoid_st The state of the principle city
#' @param geoid_pl The place GEOID for the city
#'
#' @return 1 row DF with lat and lon columns
get_pop_center <- function(principle_geoid_st, geoid_pl) {

  # Pull population by block group
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

  # Pull all block groups in the state
  state_bg <- tigris::block_groups(state = principle_geoid_st, cb = TRUE, year = 2019) %>%
    st_transform(crs = 5070)

  # Pull the place geography
  place_geo <- tigris::places(state = principle_geoid_st) %>%
    filter(GEOID == geoid_pl) %>%
    st_transform(crs = 5070)

  # Get just the block groups for the place
  place_bg <- state_bg %>%
    filter(st_intersects(., place_geo, sparse = FALSE) %>% apply(1, any)) %>%
    tigris::erase_water(year = 2019) %>%
    mutate(
      geometry = sf::st_make_valid(geometry)
    )

  # Calculate population densities for the city, by block group
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
      centroid = st_point_on_surface(geometry)
    ) %>%
    st_transform(crs = 4326) %>%
    mutate(
      lon = st_coordinates(centroid)[, 1],
      lat = st_coordinates(centroid)[, 2]
    ) %>%
    st_as_sf()

  pop_weighted_center <- place_dta %>%
    # Get the top Quintile of population dense block groups
    # Focus on urban cores
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


#' Get the building height center of a US city
#'
#' @param building_heights NASA dataset of building heights by Block group
#' @param principle_geoid_st The state of the principle city
#' @param geoid_pl The place GEOID for the city
#'
#' @return 1 row DF with lat and lon columns
get_height_center <- function(building_heights, principle_geoid_st, geoid_pl) {

  # Load in state block groups
  state_bg <- tigris::block_groups(state = principle_geoid_st, cb = TRUE, year = 2019) %>%
    st_transform(crs = 5070)

  place_geo <- tigris::places(state = principle_geoid_st) %>%
    filter(GEOID == geoid_pl) %>%
    st_transform(crs = 5070)

  # Get all block groups for the place/city
  place_bg <- state_bg %>%
    filter(st_intersects(., place_geo, sparse = FALSE) %>% apply(1, any)) %>%
    filter(ALAND > 0) %>%
    tigris::erase_water(year = 2019, area_threshold = .75) %>%
    mutate(
      geometry = sf::st_make_valid(geometry)
    )

  place_bg_geoids <- place_bg %>%
    pull(GEOID) %>%
    unique()

  # Get the centroid of the block group with the tallest average
  # building height
  tallest_bg <- building_heights %>%
    filter(geoid_bg %in% place_bg_geoids) %>%
    slice_max(order_by = SEPH, n = 1) %>%
    left_join(
      .,
      place_bg,
      by = c("geoid_bg" = "GEOID")
    ) %>%
    sf::st_as_sf() %>%
    st_transform(crs = 4326) %>%
    mutate(
      centroid = st_centroid(geometry)
    ) %>%
    mutate(
      lon = st_coordinates(centroid)[, 1],
      lat = st_coordinates(centroid)[, 2]
    )

  return(tallest_bg)

}
