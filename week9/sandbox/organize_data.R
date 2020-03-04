source("load_data.R")
# 1) assign a gender and division to all professors
# use cutoff of 97.5% for ungendered

# a) for each name, calculate proportion M and F
names <- names %>% 
  group_by(name, sex) %>% 
  summarise(tot = sum(count)) %>% 
  ungroup() %>% 
  group_by(name) %>% 
  mutate(proportion = tot / sum(tot)) %>% 
  select(-tot) %>% 
  ungroup()
# now only retain name and sex if above a certain threshold
threshold <- 0.975
names <- names %>% filter(proportion >= threshold)

# b) join with salaries
# use left join such that names not in database
# or gender-neutral(ish) are NAs
salaries <- salaries %>% 
  left_join(
    names %>% 
      mutate(first = toupper(name)) %>% 
      select(first, sex)
    )
# now assign U to ungendered people
salaries <- salaries %>% 
  mutate(sex = ifelse(is.na(sex), "U", sex))

# c) join with departments
salaries <- salaries %>% inner_join(departments)

# 2) Plot number (or proportion) of M/F/U per year and discipline
pl1 <- ggplot(data = salaries) + aes(x = year, fill = sex) + 
  geom_bar(position = "dodge") + facet_wrap(~division, scales = "free")
# slightly different, highlighting proportions
pl1.1 <- ggplot(data = salaries) + aes(x = year, fill = sex) + 
  geom_bar(position = "fill") + facet_wrap(~division, scales = "free")

# 3) plot the median salary by year and discipline
pl2 <- ggplot(data = salaries %>% filter(gross_salary > 40000)) + 
  aes(x = division, y = gross_salary, fill = division) + 
  geom_boxplot() + facet_grid(year~.) + scale_y_log10()

# alternative
pl2.1 <- ggplot(data = salaries %>% 
                  group_by(division, year) %>% 
                  summarize(gross_salary = median(gross_salary))) + 
  aes(x = year, y = gross_salary, colour = division) + 
  geom_point() + geom_line()

# 3) repeat but facet by rank
pl3 <- ggplot(data = salaries %>% 
                  group_by(division, year, rank) %>% 
                  summarize(gross_salary = median(gross_salary))) + 
  aes(x = year, y = gross_salary, colour = division) + 
  geom_point() + geom_line() + facet_wrap(~rank, scales = "free")
# alternative
pl3.1 <- ggplot(data = salaries %>% 
                group_by(division, year, rank) %>% 
                summarize(gross_salary = median(gross_salary))) + 
  aes(x = year, y = gross_salary, colour = rank) + 
  geom_point() + geom_line() + facet_wrap(~division, scales = "free")

# 4) repeat but facet by sex and rank
pl4 <- ggplot(data = salaries %>% 
                  group_by(division, year, rank, sex) %>% 
                  summarize(gross_salary = median(gross_salary))) + 
  aes(x = year, y = gross_salary, colour = sex) + 
  geom_point() + geom_line() + facet_wrap(division~rank, scales = "free")

# 5) compute time in rank before tenure/promotion and plot by discipline
tenure <- salaries %>% group_by(first, last, department, division, rank) %>% 
  summarise(years_in_rank = n()) %>% spread(rank, years_in_rank, fill = 0)
# time to tenure
time_to_tenure <- tenure %>% filter(`assistant professor` > 0, `associate professor` > 0) %>% 
  ggplot() + aes(x = division, y = `assistant professor`, fill = division) + geom_boxplot()
# time to promotion
time_to_promotion <- tenure %>% filter(`professor` > 0, `associate professor` > 0) %>% 
  ggplot() + aes(x = division, y = `associate professor`, fill = division) + geom_boxplot()

# 6) find starting salary (assistant prof) by discipline and year. 
# strategy: take second year in database as first year could be partial
# only consider people with 5 or more years as assistant prof
assistants <- salaries %>% 
  filter(rank == "assistant professor") %>% 
  group_by(first, last, department) %>% mutate(years_assistant = n()) %>% 
  filter(years_assistant > 4) %>% ungroup()

initial_salaries <- assistants %>% 
  group_by(first, last, department) %>% 
  top_n(2, gross_salary) %>% 
  top_n(1, desc(gross_salary)) %>% 
  ungroup()

pl7 <- ggplot(initial_salaries) + 
  aes(x = sex, y = gross_salary, fill = sex) + 
  geom_boxplot() + 
  facet_wrap(~division, scales = "free")

# 7) attrition: when do people leave? Does it change by discipline/sex?
survival <- salaries %>% group_by(first, last, department, division) %>% 
  mutate(year_in = min(year), year_out = max(year)) %>% 
  filter(year_out < 2015) %>%  # only those that left
  filter(year == year_out) %>% # to get what the rank when they left
  mutate(years_at_Berkeley = year_out - year_in + 1)

# how many left as assistant professors?
survival %>% filter(rank == "assistant professor")
