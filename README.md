# About

I noticed that the NYTimes main Twitter account ([@nytimes](https://twitter.com/nytimes)) seems to be hit or miss in adding alt text with images. To investigate if this represents a pattern, I pulled 3,250 of their most recent tweets. The result? Yes, it appears to be a pattern.

This repo holds the code pull the tweets and conduct this analysis in R. If you wish to reproduce this, you will have to authenticate yourself, and I didn't include my authentication here.

UPDATE: You'll notice that I've included analysis of tweets from more accounts. I expanded this analysis to provide comparisons with other accounts, plus I improved the script so that rate limits would be less of an issue. 

![NYTimes tweets from July 6, 2022 to August 4, 2022 show a pattern of neglecting to add alt text with images.](plots/time_series.png)

![Line graph showing which of CNN's past 3250 tweets with images included alt text.](plots/@cnn.png)

![Line graph showing which of Le Monde's past 3250 tweets with images included alt text.](plots/@lemondefr.png)

![Line graph showing which of NASA's past 3250 tweets with images included alt text.](plots/@nasa.png)

![Line graph showing which of National Geographic's past 3250 tweets with images included alt text.](plots/@natgeo.png)

![Line graph showing which of The Washington Post's past 3250 tweets with images included alt text.](plots/@washingtonpost.png)

![Line graph showing which of Wired's past 3250 tweets with images included alt text.](plots/@wired.png)

![Line graph showing which of The Wall Street Journal's past 3250 tweets with images included alt text.](plots/@wsj.png)