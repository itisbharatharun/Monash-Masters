FIT5196 DATA WRANGLING
Week 1
Introduction to Data Wrangling

By Jackie Rong

Faculty of Information Technology

Monash University

Outline

• What is Data Wrangling?
• Why need to do Data Wrangling?
• Challenges in Data Wrangling
• Data Wrangling Process & Tasks
• Programming Language & Environments

Data Wrangling

• Data wrangling is a critical step in the data analysis process.

• Data wrangling is a preparatory step for data analysis.

Data Wrangling

• Data wrangling is essential for ensuring that data analysis

leads to accurate and actionable insights.

Data
Collection

Data
Analysis

• Data wrangling is the process of making data useful.

?

Problem
Identification

Data
Cleaning

Result
Interpretation

Data Wrangling

• Data Wrangling is the process of acquiring, cleaning, structuring, and enriching raw data into a format

that is directly usable for analysis.

Data Wrangling

Data
Collection

Data
Analysis

?

Problem
Identification

Data
Cleaning

Result
Interpretation

Why need to do Data Wrangling?

• Data wrangling is essential for ensuring that data analysis leads to accurate and actionable insights.

The ”census income" data set from UCI machine learning data repository

Why need to do Data Wrangling?

• Data wrangling is essential for ensuring that data analysis leads to accurate and actionable insights.

The "credit approval" data set from UCI machine learning data repository

Why need to do Data Wrangling?

• What does raw data really look like?

Posts extracted from Twitter
https://dev.twitter.com/rest/reference/get/blocks/list

Fungal disease CT report

Airline Crash dataset from Wikipedia
https://en.wikipedia.org/wiki/List_of_accidents_and_incidents_invol
ving_commercial_aircraft#2001

Goals of Data Wrangling

•

The goals of data wrangling are multifaceted, aiming to simplify data analysis and maximize the value
extracted from the data.
▪ Improving Data Quality
▪ Data Formatting and Standardization
▪ Simplifying Access to Data
▪ Enriching Data
▪ Reducing Data Complexity
▪ Facilitating Data Integration
▪ Increasing Analytical Efficiency
▪ Supporting Decision Making

Data
Collection

Data
Analysis

Data Wrangling

Raw data

Tidy data

Data + Wrangling + Analysis

= Data Product (Knowledge)

?

Problem
Identification

Data
Cleaning

Result
Interpretation

Challenges in Data Wrangling

• Challenges arise from

▪ the nature of the data itself,
▪ the complexity of data sources, and
▪ the goals of the data analysis projects.

Challenges in Data Wrangling

• Challenges arise from the nature of the data itself, the complexity of data sources, and the goals of

the data analysis projects.
▪ Volume of Data & Scalability

Source: https://infogram.com/the-volume-of-data-created-worldwide-from-2010-to-2025-1h7k2303eevdg2x?utm_source=chatgpt.com

Challenges in Data Wrangling

• Challenges arise from the nature of the data itself, the complexity of data sources, and the goals of

the data analysis projects.
▪ Volume of Data & Scalability
▪ Data Quality Issues

The Switzerland heart disease data set from
UCI machine learning data repository

Where the data problems come from?
• Manual entry errors
• Malfunction of measurement

devices

• Data sources follow different
conventions, formats, or data
models

Challenges in Data Wrangling

• Challenges arise from the nature of the data itself, the complexity of data sources, and the goals of

the data analysis projects.
▪ Volume of Data & Scalability
▪ Data Quality Issues
▪ Data from Diverse Sources

Other formats: CSV, Excel, PDF, PNG, JPGE, ……

JavaScript Object Notation (JSON):

Extensible Markup Language (XML)

Challenges in Data Wrangling

• Challenges arise from the nature of the data itself, the complexity of data sources, and the goals of

the data analysis projects.
▪ Volume of Data & Scalability
▪ Data Quality Issues
▪ Data from Diverse Sources
▪ Complexity of Data Structures

https://blog.kensho.com/structured-vs-unstructured-data-what-you-need-to-know-f1e7ce61cd1e

Challenges in Data Wrangling

• Challenges arise from the nature of the data itself, the complexity of data sources, and the goals of

the data analysis projects.
▪ Volume of Data & Scalability
▪ Data Quality Issues
▪ Data from Diverse Sources
▪ Complexity of Data Structures
▪ Lack of Standardization & Interpretability

icons created by Flat Icons – Flaticon, https://www.flaticon.com/free-icons/iso

Challenges in Data Wrangling

• Challenges arise from the nature of the data itself, the complexity of data sources, and the goals of

the data analysis projects.
▪ Volume of Data & Scalability
▪ Data Quality Issues
▪ Data from Diverse Sources
▪ Complexity of Data Structures
▪ Lack of Standardization & Interpretability
▪ Highly Time-Consuming

What Data Scientists spend thee most time doing?

3%

5%

4%

9%

19%

Buildinig training sets 3%
Others 5%
Refining algorithms 4%
Mining data for patterns 9%
Collecting data set 19%
Cleaning & organising data 60%

60%

Sarih, Houda & Tchangani, Ayeley & Medjaher, Kamal & PERE, Eric. (2019). Data preparation and preprocessing for
broadcast systems monitoring in PHM framework. 1444-1449. 10.1109/CoDIT.2019.8820370.

Challenges in Data Wrangling

• Challenges arise from the nature of the data itself, the complexity of data sources, and the goals of

the data analysis projects.
▪ Volume of Data & Scalability
▪ Data Quality Issues
▪ Data from Diverse Sources
▪ Complexity of Data Structures
▪ Lack of Standardization & Interpretability
▪ Highly Time-Consuming
▪ Skill and Tool Requirements

Python

Data
Visualisation

Documentation

Programming

Advanced
Statistics

R

Discrete
Math

Database

Business Savvy

Machine
Learning

Natural Language
Processing

Computer
Vision

11 Data Scientist Skills Employers Want to See in 2022, https://bootcamp.berkeley.edu/blog/data-scientist-skills/

Challenges in Data Wrangling

• Challenges arise from the nature of the data itself, the complexity of data sources, and the goals of

the data analysis projects.
▪ Volume of Data & Scalability
▪ Data Quality Issues
▪ Data from Diverse Sources
▪ Complexity of Data Structures
▪ Lack of Standardization & Interpretability
▪ Highly Time-Consuming
▪ Skill and Tool Requirements
▪ Data Privacy and Security

Andrew Kamau, https://blog.google/products/chrome/5-tips-to-stay-safer-online-with-chrome/

Data Wrangling Tasks

• Data Wrangling is the process of acquiring, cleaning, structuring, and enriching raw data into a

format that is directly usable for analysis.

Data
Discovery

Data
Collection

Data
Storing

Data Pre-
processing

Data
Cleaning

Data
Validation

Data
Transformation

Data
Enrichment

Programming Language & Environment

• Programming language: Python 3.14

▪ A scripting language that is easy to get started with and it also comes with a large number of

libraries that can be used in data wrangling tasks

▪ Major libraries used in this units include (but not limited to)

o Pandas: a library that provides high-level data structures and manipulation tools that are designed to

make data processing fast and easy in Python

o NLTK: a platform for building Python programs to work with human language data
o BeautifulSoup: a simple and efficient library for navigating, searching, and modifying HTML and XML

documents.

o Scipy: a fundamental library for scientific computing.
o scikit-learn: an efficient Python library for data mining and data analysis.

Programming Language & Environment

• Programming environment: Jupyter notebook, Anaconda (optional)

▪ The Jupyter Notebook is a web application that allows you to create and share documents that

contain live code, equations, visualisations and explanatory text.

Programming Language & Environment

You can use your Monash
account to access Google Colab
and complete your tasks with AI
assistant.

Summary & To-do List

• Please please download and read materials provided on Moodle.

•

•

Set up your programming environment by installing Anaconda, Python and Jupyter Notebook or
check out Google Colab using your Monash account.

Last but not least,
▪ Choose FIT5196 wisely.
▪ Use the discussion (Ed) forum in a proper way and with respect!

• Next Week: Data Wrangling Process & Tasks

