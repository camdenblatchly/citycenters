# Where is the center of Boston?

Or any city for that matter? Here's my code for exploring that question.

## Background

A few years ago, I needed to calculate the distance 
from the city center for several US metros for a project. I came across an interesting 
[Cityscape article](https://www.huduser.gov/portal/periodicals/cityscpe/vol21num2/ch12.pdf), 
which discussed ways to consistently define city centers across US metro areas. 
I was fascinated by how different methods for defining city centers represented 
different ways of envisioning the city, so I wanted to explore it further here.

## Analysis overview

In the Cityscape article, lat/lon coordinates for most big US cities are 
provided from the following sources:
- Google
- ArcGIS
- Central Business Districts (Census 1982)
- US Census Gazetteer
- City Hall

I wanted to calculate additional estimates to round out the dataset. In 
particular, I was interested in calculating values that would represent 
a city's Population center and Jobs center. While working through these 
methods, I also came across an interesting USGS dataset that estimated the 
average building height by block group. I used this dataset to calculate the 
"peak" of a cities skyline as an additional measure of a city's center.

## Methods


### Population center

To calculate the Population center, I pulled 2019 population data from the 
2019 American Community Survey 5-year estimates for the block groups included 
in the Census place for the principle city in every metropolitan area. Next, I 
filtered to block groups that had nonzero land area (sometimes block groups are 
purely water) and calculated population density using the land area 
of each block.

Calculating the population weighted center of each city doesn't make sense as 
a strategy since block groups are sized to have similar populations. Instead, I 
sought the find the center of each city's residential urban core. To do so, 
I filtered to block groups in the top quintile by population 
density and then calculated a population-density-weighted center 
using the `centr` package.

This estimate worked well across most cities, but for some cities with varied 
terrain (e.g., coastline), the center ended up in an unrealistic location. 
For example, in NYC, the population center was on Wards Island because dense 
neighborhoods in Brooklyn pulled the weighted center east and south.

### Job center

My hopes of calculating a jobs center was stymied by the lack of jobs data 
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
in each city wit the tallest average building height.

### Analysis scope

I calculated city centers using these methods for the top 30 metros in the 
United States. I limited my calculations to the top 30 because I wanted to 
focus on major cities.

## New skills

I used this project to get more familiar with Mapbox styling and storytelling. 
I thought a scrollytelling format would be an ideal way for viewing the 
different city centers. To implement this approach, I made two custom Mapbox 
layers: one for dots and one for text labels. 


## If I had more time


If I had more time, I'd love to make fuller use of my dataset of city centers,





