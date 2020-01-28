## Possible solution to warmup problem Week 4

```python
# coding: utf-8

import re # regular expressions
# for plotting
import matplotlib.pyplot as plt
get_ipython().run_line_magic('matplotlib', 'inline')

# for each author extract
# name
# number of documents
# h-index

# because working with the large file is difficult
# create a small file that is easier to read
# for example
# grep -B4 -A4 Allesina scopus.html > small.html

# Step 1: read the whole file
with open('scopus.html', 'r') as content_file:
    content = content_file.read()

# Step 2: Extracting names
# Note that the names reported as:
"""title="View this author&#39;s profile"> Allesina, Stefano</a>"""

names = re.findall(r'title="View this author&#39;s profile"> (.*)</a>', content)

names[:10]

# make sure we have 2000 names
len(names)

# Step 3: Extracting number of documents
# Similarly, we have strings like
"""title="View documents for this author">
88
</a>"""
# reporting the number of documents
# we use the same strategy
# note we need to add .*? in front of (\d+) 
# as some numbers are misformatted

documents = re.findall(r'title="View documents for this author">\n?.*?(\d+)\s?\n?</a>', content)

documents[:10]
# make sure there are 2000 values
len(documents)

# Step 4: extracting h-index
# the pattern is 
"""
<td class="dataCol4 alignRight">
33
"""

hindex = re.findall(r'<td class="dataCol4 alignRight">\n(\d+)\n', content)

hindex[:10]
len(hindex)

# now make documents and hindex integers for computing
documents = [int(x) for x in documents] # list comprehension
hindex = [int(x) for x in hindex] 

# some stats
print("documents: max", max(documents), 
      "min", min(documents), 
      "mean", sum(documents) / len(documents))
print("hindex: max", max(hindex), 
      "min", min(hindex), 
      "mean", sum(hindex) / len(hindex))

def scatter_plot(x, y, label = 'my plot'):
    plt.plot(x, y, 'o', c = 'g')
    plt.title(label)
    plt.show()

scatter_plot(documents, hindex, "number of documents")

# try with logarithm
import math
logdoc = [math.log(x) for x in documents]

scatter_plot(logdoc, hindex, "log number of documents")

# try with sqrt
sqrtdoc = [math.sqrt(x) for x in documents]

scatter_plot(sqrtdoc, hindex, "sqrt number of documents")

# compute correlation between
# number of docs and h-index
# log(number of docs) and h-index
# sqrt(number of docs) and h-index

def compute_pearson_correlation(x, y):
    meanx = sum(x) / len(x)
    sdx = math.sqrt(sum([(a - meanx) ** 2 for a in x]) / len(x))
    meany = sum(y) / len(y)
    sdy = math.sqrt(sum([(a - meany) ** 2 for a in y]) / len(y))
    # now compute mean(x y)
    xy = x
    for i in range(len(x)):
        xy[i] = xy[i] * y[i]
    # correlation:
    # (E[x y] - E[x] E[y]) / (sd[x] sd[y])
    meanxy = sum(xy) / len(xy)
    return (meanxy - meanx * meany)/ (sdx * sdy)

compute_pearson_correlation(sqrtdoc, hindex)
```

