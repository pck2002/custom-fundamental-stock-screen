# Custom Fundamental Stock Sreener
a draft framework for custom fundamental stock screens

Wanted to sort stocks by P/T ratio (Price to Taxes Paid Ratio) - a cousin of the P/E ratio (Price to Earnings Ratio).  The fact that I wrote this script probably indicates that it's not the most in demand ratio.  In the future, I hope to include rolling totals/averages/changes - for example 3 year cumulative net income to 3 year cumulative spend on share repurchases.  Short story even shorter, I couldn't find a free screener with a P/T ratio so I decided to make a rough go of one myself.  It still needs work but here's what I have so far:

project contains:

R Code (aqfsCodeYear) and sample csv output (TaxesMarketCap)

data and code sources (perhaps the most useful lines of this project):

SEC AQFS data from http://www.sec.gov/dera/data/financial-statement-data-sets.html

cik to ticker from http://rankandfiled.com/#/data/tickers

script to get market caps (yahoo) from http://allthingsr.blogspot.com/2012/10/pull-yahoo-finance-key-statistics.html
