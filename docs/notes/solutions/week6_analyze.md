## Possible solution to warmup problem Week 6 (Analyze)

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
%matplotlib notebook

data = pd.read_csv('bioRXiv.csv')

# 1. Document the change in number of submissions: plot the number of submission per week for each year, and check whether it's growing.

# transform to datetime
data.date = pd.to_datetime(data.date)
# extract year
data['year'] = pd.DatetimeIndex(data['date']).year
# extract month
data['month'] = pd.DatetimeIndex(data['date']).month
# extract day of the week
data['weekday'] = pd.DatetimeIndex(data['date']).dayofweek

# plot number of submissions per year
plt.figure()
# this creates a Series
s_per_year = data.groupby('year').size()
s_per_year.plot()
# now by month and year
plt.figure()
s_per_mo_year = data.groupby(['year', 'month']).size()
s_per_mo_year.plot()
# if this was exponential growth, in log it should be a line
s_per_year.plot(loglog = True)
# which day is the one with most submissions?
s_per_weekday = data.groupby('weekday').size()
s_per_weekday.plot.bar()
# which month is the one with most submissions?
s_per_month = data.groupby('month').size()
s_per_month.plot.bar()

# 2. Draw the distribution of the number of authors in the *Subject Area*. If people choose different areas, we can see whether different disciplines have different cultures.

plt.figure()
data['num_authors'].hist(bins = bins)
# very skewed distribution; try to plot in log
plt.hist(data['num_authors'], log = 'xy')

# see whether mean and median have changed
trend_num_auth = data.groupby('year')['num_authors'].agg(mean_na = 'mean',
                                                         median_na= 'median',
                                                         sd_na = 'std')
trend_num_auth.plot()

```
