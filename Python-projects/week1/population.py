# Use a custom model to estimate stick insect population
# assuming they escape enclosure and survive the climate

import matplotlib.pyplot as plt
import numpy as np

# variables u can modify
starting_population = 5
years_to_predict = 50

# final datas
years = np.arange(1, years_to_predict + 1)
population = np.arange(1, years_to_predict + 1)


# returns population at the end of year
def pop_growth_yearly(population_start):
    return population_start * 1.3 + np.random.uniform(-0.5, 0.5)


for i in range(len(population)):
    population[i] = pop_growth_yearly(starting_population)
    starting_population = population[i]

print(years)
print(population)

plt.plot(years, population, "g--", linewidth=3)
plt.grid(True)
plt.title("Population of Stick Insects")
plt.xlabel("Years")
plt.ylabel("Population")
plt.ticklabel_format(style="plain")
# plt.axis((0, 100000, 0, 2000000))
plt.show()
