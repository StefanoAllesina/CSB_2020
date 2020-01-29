## Python wrapup

To wrapup the learning of Python, we are going to tackle a larger project: documenting the growth of *bioRXiv*, the preprint server for biology. We are going to write three programs, that will be run in sequence. At the end, we will build a pipeline that automates the whole task.

For this exercise, you can choose a *Subject Area* that interests you from the [website](https://www.biorxiv.org/); for the examples I am going to use *Ecology*.

Good choices (i.e., disciplines with few pages) are:

* `biophysics` (~305)
* `biochemistry` (~215)
* `animal-behavior-and-cognition` (~115)
* `cancer-biology` (~245)
* `clinical-trials` (10)
* `developmental-biology` (~215)
* `ecology` (~310)
* `molecular-biology` (~230)
* `paleontology` (11)
* `pathology` (~40)
* `scientific-communication-and-education` (29)

### Part 1: Download metadata from bioRXiv

For this we will need the module `requests` (to install, call `conda install -c anaconda requests` from the terminal).

Write code that downloads all of the html files for a given Subject area. For example, the url:

`https://www.biorxiv.org/collection/ecology?page=0` 

shows the first page of ecology, containing information on 10 preprints. At the bottom of the page, you find the total number of pages. You can change the url to move to the second page:

`https://www.biorxiv.org/collection/ecology?page=1` 

and so on. 

- Write code that downloads the first page for the *Subject Area* of choice.
- Save the file to  `data/0.html`.
- Use regular expressions to extract the total number of pages.
- Download all the pages for the *Subject Area*.

**Hint:**
This code downloads a page using Python

```python
import requests
url = 'https://allesinalab.uchicago.edu/'
page = requests.get(url, allow_redirects = True)
```

Here's a possible [solution](solutions/week6_download)

### Part 2: Extract information from the pages

For this we will need the module `bs4` (to install, call `conda install -c anaconda beautifulsoup4 ` from the terminal).

- We're going to use BeautifulSoup, a great HTML parser. Here's what you would do to extract all paper titles from a page:

```python
from bs4 import BeautifulSoup

# read the file
fname = 'data/page_0.html'
with open(fname, 'rb') as f:
    html = f.read().decode('UTF8')
# parse html
soup = BeautifulSoup(html, 'html.parser')
# now find all papers
papers = soup.findAll("div", {"class": "highwire-article-citation highwire-citation-type-highwire-article tooltip-enable"})
for paper in papers:
    title = paper.findAll("span", {"class": "highwire-cite-title"})[0]
    title = title.text.strip()
    print(title)
```

- For each paper in each page, extract the `paper_id`, `date`, `num_authors`, `title`, and save into a csv called `bioRXiv.csv`


Here's a possible [solution](solutions/week6_parse)

### Part 3: Data analysis

- Document the change in number of submissions: plot the number of submission per week for each year, and check whether it's growing.

- Draw the distribution of the number of authors in the *Subject Area*, and compute mean, median and other summary statistics on the distribution. If people choose different areas, we can see whether different disciplines have different authorship cultures.

Here's a possible [solution](solutions/week6_analyze)

### Part 4: Automation

- Make the first two programs runnable from the command line. They should accept a subject area as argument.
