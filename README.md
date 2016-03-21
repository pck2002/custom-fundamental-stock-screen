# Custom Fundamental Stock Sreener
Custom Fundamental Stock Screener - Cash Taxes Paid to Market Cap

a draft framework for custom fundamental stock screens

Wanted to sort stocks by P/T ratio (Price to Taxes Paid Ratio) - a cousin of the P/E ratio (Price to Earnings Ratio).
The fact that I need to write this script for this screen may indicate that's probably not the most in demand ratio.
I hope to include rolling totals/averages/changes - 3 year cumulative net income to 3 year cumulative spend on share repurchases - in the future.  Short story even shorter, I couldn't find any free screens with a P/T ratio so I decided to make a rough go of one myself.  It still needs work but here's what I have so far:

project contains:

R Code (aqfsCodeYear) and sample csv output (TaxesMarketCap)

data and code sources (perhaps the most useful lines of this project):

SEC AQFS data from http://www.sec.gov/dera/data/financial-statement-data-sets.html

cik to ticker from http://rankandfiled.com/#/data/tickers

script to get market caps (thanks yahoo) from http://allthingsr.blogspot.com/2012/10/pull-yahoo-finance-key-statistics.html
