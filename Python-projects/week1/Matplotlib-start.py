import matplotlib.pyplot as plt
import numpy as np
import secrets

np.set_printoptions(formatter={"float": "{: 0.2f}".format})

# list of different graphic parameters for PLOT() function:
"""
Värit:
'b': sininen
'g': vihreä
'r': punainen
'c': syaani
'm': magenta
'y': keltainen
'k': musta
'w': valkoinen

Viivatyylit:
'-': kiinteä viiva
'--': katkoviiva
'-.': pistekatkoviiva
':': pisteviiva

Merkit:
'.': piste
',': pikseli
'o': ympyrä
'v': alaspäin osoittava kolmio
'^': ylöspäin osoittava kolmio
'<': vasemmalle osoittava kolmio
'>': oikealle osoittava kolmio
'1': alaspäin osoittava tähti
'2': ylöspäin osoittava tähti
'3': vasemmalle osoittava tähti
'4': oikealle osoittava tähti
's': neliö
'p': viisikulmio
'*': tähti
'h': heksagoni
'H': iso heksagoni
'+': plusmerkki
'x': x-merkki
'D': iso timantti
'd': pieni timantti

Esimerkkejä:
'ro-': punainen ympyrä kiinteällä viivalla
'bs--': sininen neliö katkoviivalla
'g^:': vihreä kolmio pisteviivalla
"""

"""
# how to draw a simple scatter graph
plt.plot([1, 2, 3, 4], [1, 4, 9, 16], "ro")
plt.ylabel("some numbers")
plt.show()
"""


# how to draw a more complex scatter graph and use arange
"""
t = np.arange(0.0, 5.0, 0.2)  # range with steps
print(t)
t2 = np.arange(50)  # range with integers
print(t2)
print(type(t))
plt.plot(t, 100 * t, "r--", t, t**2, "bs", t, t**3, "g^")
plt.show()
"""

# how to use python random number generator and seed number
"""
rng = np.random.default_rng()
print(rng.random())
print(rng.standard_normal(20))
print(rng.integers(low=0, high=10, size=5))
print(secrets.randbits(16))
print(rng.random(10))
print(rng.random(10))
rng2 = np.random.default_rng(11111)
print(rng2.random(10))
rng2 = np.random.default_rng(11111)
print(rng2.random(10))

print(np.random.randint(1000))
print(np.random.randint(10, 50, 20))"

print(np.random.randn(50)) # generates array of normal Z numbers
"""


# scatterplot with different size balls
"""
print(np.random.randn(50))
data = {"a": np.arange(50), "c": np.random.randint(0, 50, 50), "d": np.random.randn(50)}
data["b"] = data["a"] + 10 * np.random.randn(50)
data["d"] = data["d"] * 100

plt.scatter("a", "b", c="c", s="d", data=data)
plt.xlabel("entry a")
plt.ylabel("entry b")
plt.show()
"""


# learn how to do many plots in 1 image file
"""
names = ["group_a", "group_b", "group_c"]
values = [1, 10, 100]
z_values = np.random.randn(3)
for i in range(len(z_values)):
    z_values[i] = abs(z_values[i])
print(z_values)

plt.figure(figsize=(9, 3))

plt.subplot(221)
plt.bar(names, values)
plt.subplot(222)
plt.scatter(names, values)
plt.subplot(223)
plt.plot(names, values)
plt.subplot(224)
print(values)
values += 10 * z_values
print(values)
plt.plot(names, values)
plt.suptitle("Categorical Plotting")
plt.show()
"""


# line graph basics, use filter function:
"""
def filter(t):
    return np.exp(-t) * np.cos(2 * np.pi * t)


t1 = np.arange(0.0, 5.0, 0.1)
t2 = np.arange(0.0, 5.0, 0.02)

plt.figure()
plt.subplot(211)
plt.plot(t1, filter(t1), "bo", t2, filter(t2), "k")

plt.subplot(212)
plt.plot(t2, np.cos(2 * np.pi * t2), "r--")
plt.show()"
"""

# learn to make a histogram
# make 2x IQ-score histograms, first probability, below amount of test makers
# other showing probability, other amount of test makers

import matplotlib.pyplot as plt8

MOOOO, sigma, bins, how_many_tested = 100, 15, 30, 100000
x = MOOOO + sigma * np.random.randn(how_many_tested)


plt8.figure(figsize=(7, 5))

# the hist function has next parameters:
# x = data for histogram
# bins = the amount of pilars in histogram
# density = True means showing probability rather than amounts
#           most meaningful in normalized data
# facebolor = color of pilars
# alpha=0.75 = pilars show through 25%
plt8.subplot(211)
plt8.style.use("classic")
n, bins, patches = plt8.hist(
    x,
    bins,
    density=True,
    facecolor="g",
    alpha=0.75,
    label=f"test makers: {how_many_tested}",
)
plt8.ylabel("Probability")
plt8.title("Histogram of IQ")
plt8.text(60, 0.025, r"$\mu=100,\ \sigma=15$")
plt8.axis([40, 160, 0, 0.05])
plt8.grid(True)
plt8.legend()

plt8.subplot(212)
n, bins, patches = plt8.hist(
    x,
    bins,
    density=False,
    facecolor="g",
    alpha=0.75,
    label=f"test makers: {how_many_tested}",
)
plt8.xlabel("IQ-score")
plt8.ylabel("Amount of test makers")
plt8.title("Histogram of IQ")
plt8.text(60, how_many_tested / 5 / 2, r"$\mu=100,\ \sigma=15$")
plt8.axis([40, 160, 0, how_many_tested / 5])
plt8.grid(True)
plt8.legend()
plt8.show()


# how to add arrow to a plot
"""
ax = plt.subplot()

t = np.arange(0.0, 5.0, 0.01)
s = np.cos(2 * np.pi * t)
# line dot refers to the only variable in Line2D object
(line,) = plt.plot(t, s, lw=2)

plt.annotate(
    "local max",
    xy=(2, 1),
    xytext=(3, 1.5),
    arrowprops=dict(facecolor="black"),
)

plt.ylim(-2, 2)
plt.show()
"""
