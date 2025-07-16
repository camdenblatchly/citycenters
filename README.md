# Where is the city center of Boston?

Or any city for that matter? Here's my code for exploring that question.

## Background

A few years ago, while trying to determine the city center of several US metros 
for a project on bid-rent curves, I came across an interesting 
[Cityscape article](https://www.huduser.gov/portal/periodicals/cityscpe/vol21num2/ch12.pdf), 
which discussed possible options for consistently defining city centers across metro areas. 
Curious about how these definitions shaped our understanding of cities, 
I decided to use this project to explore further.

## Analysis overview

The Cityscape article provides city center coordinates 
based on the following possible measures of a city's center:

- Google
- ArcGIS
- Central Business Districts
- The US Census Gazetteer
- City Halls

To complement these definitions, I sought to calculate my own city center 
estimates using data on population density, job concentration, and building heights.

## Methods

### Analysis scope

While I focus on Boston in my final piece, I wanted to make my analysis 
generalizable across major cities. To that end, I calculated city centers 
using the following methods for the top 30 metros in the 
United States.

### Population center

To calculate the population center of a city, I pulled 2019 population data from 
the American Community Survey 5-year estimates for block groups included 
in the Census place for the principle city in every metropolitan area. Next, I 
filtered to block groups that had nonzero land area (sometimes block groups are 
purely water) and calculated population density using the land area 
of each block.

Calculating the population-weighted-center using block groups is a poor 
strategy since block groups are sized to have similar population sizes. Instead, I 
used population densities to identify the center of each city's residential urban core. 
To do so, I filtered to block groups in the top quintile by population 
density and then calculated a population-density-weighted center 
using the `centr` package.

This estimate worked well across most major cities, but for some cities with varied 
terrain (e.g., coastline), the center ended up in an improbable location. 
For example, in New York City, the population center was on Wards Island because dense 
neighborhoods in Brooklyn pulled the weighted center east and south.

### Job center

My hopes of calculating a jobs center was stymied by a lack of jobs data 
available at the block group level. As a proxy, I explored finding the 
block group or groups in each city with the highest percentage of people 
who have a sub 10-minute commute, thinking that this metric could indicate 
proximity to a primary job center. I decided to abandon this metric because 
(1) The idea of a job center was already captured by the Central Business 
District definition and (2) The estimate proved unreliable as block groups 
with short commutes were often outside the city center in polycentric cities.

### The peak of the skyline

While considering job center alternatives, I wondered if it would be 
possible to calculate the "peak" of a city's skyline. I found a USGS dataset 
that calculated the average building height per block group, as measured by 
radar from Space Shuttle Endeavor. Using this source, I found the block group 
in each city with the tallest average building height.

The radar data was collected in February 2000, so for some fast-changing downtowns 
the building height center has since changed.

## New skills

I used this project to get more familiar with Mapbox styling and storytelling. 
Due to the coordinate-based nature of my data, I thought a map-centric scrollytelling format 
would be an ideal way to explore different ways of defining city centers. To implement 
this approach, I made two custom Mapbox layers. One layer was made up of 
circles which were placed at the coordinates of each definition. The other layer 
was composed of text labels describing each definition. Using callback functions, I 
filtered to the relevant circle and label at each scroll step.

## If I had more time

If I had more time, I'd love to make fuller use of my dataset of city centers. 
At it's most simple, I'd like the story to end with a searchable map so 
users can see where estimated city centers are located 
in their city. At it's most complex, it would be cool to allow users to vote 
for a definition or place a marker where they think the city center is in 
their city.

## Sources

- [Where is the City Center? Five Measures of Central Location](https://www.huduser.gov/portal/periodicals/cityscpe/vol21num2/ch12.pdf)
- [Coordinates for definitions featured in the Cityscape article](https://mattholian.blogspot.com/2019/02/where-is-citys-center-on-recent-use-of.html)
- [USGS building heights data](https://www.usgs.gov/data/us-national-categorical-mapping-building-heights-block-group-shuttle-radar-topography-mission)





