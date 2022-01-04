# Jupyter notebook

Patch Jupyter notebook to have all of the missing functionality. Install the notebook extensions:
```bash
python3 -m pip install jupyter_contrib_nbextensions jupyter_nbextensions_configurator
jupyter contrib nbextension install --user
jupyter nbextensions_configurator enable --user
```

Start a notebook server, and navigate to the Nbextensions tab at the top. I personally use

- **Table of Contents**: displays a navigable TOC in a column
- **Collapsible Headings**: allows markdown headings to be collapsed
- **spellchecker**: adds a spellcheck toolbar
