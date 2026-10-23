# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'MSPM0G3507 DriverLib Guide'
copyright = '2026, Ajit Ananthadevan'
author = 'Ajit Ananthadevan'
release = '0.1'

html_baseurl = "https://pub.simplycreate.online/mspm0-guide/"
html_show_copyright = False

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'myst_parser',
]

templates_path = ['_templates']
exclude_patterns = [
    '_build',
    'Thumbs.db',
    '.DS_Store',
    '**/references.md',      # ignore all references.md files
]



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

import better
html_theme = 'better'
html_theme_path = [better.better_theme_path]
html_title = project

# Optional MyST extensions
myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "dollarmath",
    "amsmath",
    "tasklist",
    "attrs_inline",
    "attrs_block",
]
