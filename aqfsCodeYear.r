# wanted to sort stocks by P/T ratio (Price to Taxes Paid Ratio) - a cousin to the P/E ratio (Price to Earnings Ratio)
# wonder if this ratio is widely used? Perhaps the fact that I need to writed this for a simple screen may tell me something
# anyways couldn't find any free screens to do this so I decided to make a rough go of one myself:

# data and code sources (perhaps the most useful few lines of this document):
# SEC AQFS data from http://www.sec.gov/dera/data/financial-statement-data-sets.html
# cik to ticker from http://rankandfiled.com/#/data/tickers
# script to get market caps (thanks yahoo) from http://allthingsr.blogspot.com/2012/10/pull-yahoo-finance-key-statistics.html

# February 9, 2016

require(foreign)
require(sqldf)
require(RH2)
require(quantmod)

setwd("C:\\Projects\\aqfs\\data\\")

s1 <- read.table("2015q1\\sub.txt", sep="\t", fill = TRUE, header=TRUE, encoding = "utf-8", quote=NULL)
n1 <- read.table("2015q1\\num.txt", sep="\t", fill = TRUE, header=TRUE, encoding = "utf-8", comment='')
s2 <- read.table("2015q2\\sub.txt", sep="\t", fill = TRUE, header=TRUE, encoding = "utf-8", quote=NULL)
n2 <- read.table("2015q2\\num.txt", sep="\t", fill = TRUE, header=TRUE, encoding = "utf-8", comment='')
s3 <- read.table("2015q3\\sub.txt", sep="\t", fill = TRUE, header=TRUE, encoding = "utf-8", quote=NULL)
n3 <- read.table("2015q3\\num.txt", sep="\t", fill = TRUE, header=TRUE, encoding = "utf-8", comment='')
s4 <- read.table("2015q4\\sub.txt", sep="\t", fill = TRUE, header=TRUE, encoding = "utf-8", quote=NULL)
n4 <- read.table("2015q4\\num.txt", sep="\t", fill = TRUE, header=TRUE, encoding = "utf-8", comment='')

s <- rbind(s1,s2,s3,s4)
n <- rbind(n1,n2,n3,n4)

# cik to ticker 
# from http://rankandfiled.com/#/data/tickers
cik <- read.table("cik_ticker.csv", sep="|", fill = TRUE, header=TRUE, encoding = "utf-8")

head(s)
head(n)
head(cik)

# prep list of adsh form cik name from sub file - using cik as index key
# where form = 10-K : wksi = 1 : 

u <- s[ which(s$form == "10-K"), ] # need to add 10-K/A too
u <- s[ which(s$fp == "FY"), ] # probably overkill but why not
u <- u[ which(u$wksi == 1), ] 
u <- u[ which(u$afs == "1-LAF"), ] # large accelerated filers
head(u)

s_final <- cbind(as.character(u$adsh), u$cik, u$sic, u$period, as.character(u$fp))
colnames(s_final) <- c("ADSH","CIK","SIC","DDATE","PERIOD")
head(s_final)

# extract IncomeTaxesPaid
q <- n[ which(n$tag == "IncomeTaxesPaid"), ]
q <- q[ which(q$qtrs == 4), ]
q <- q[ which(q$ddate == 20141231), ]
q <- q[ which(q$coreg == ''), ]
q <- q[ which(q$uom == "USD"), ] # doesn't seem to matter
q <- q[ which(q$value > 0), ]
head(q,50)

n_final <- cbind(as.character(q$adsh), q$value)
colnames(n_final) <- c("ADSH", "INCOMETAXESPAID")
head(n_final)

# merge n_final, u_final, cik

# me <- sqldf("SELECT n_final.INCOMETAXESPAID, s_final.*
#		FROM n_final 
#		LEFT JOIN s_final
#		ON n_final.ADSH = s_final.ADSH", stringsAsFactors = FALSE)  

me <- merge(n_final, s_final, by = c("ADSH"))
head(me)
head(cik)
me <- merge(me, cik, by = c("CIK"))
me <- me[ which(me$Exchange == "NYSE"), ]
head(me)
as.character(me$Ticker)

# now get market cap from yahoo (wonder if I can get this from google instead)
# slightly modified script to get market caps from http://allthingsr.blogspot.com/2012/10/pull-yahoo-finance-key-statistics.html
require(XML)
require(plyr)
getKeyStats_xpath <- function(symbol) {
  yahoo.URL <- "http://finance.yahoo.com/q/ks?s="
  html_text <- htmlParse(paste(yahoo.URL, symbol, sep = ""), encoding="UTF-8")

  #search for <td> nodes anywhere that have class 'yfnc_tablehead1'
  nodes <- getNodeSet(html_text, "/*//td[@class='yfnc_tablehead1']")
  
  if(length(nodes) > 0 ) {
   measures <- sapply(nodes, xmlValue)
   
   #Clean up the column name
   measures <- gsub(" *[0-9]*:", "", gsub(" \\(.*?\\)[0-9]*:","", measures))   
   
   #Remove dups
   dups <- which(duplicated(measures))
   #print(dups) 
   for(i in 1:length(dups)) 
     measures[dups[i]] = paste(measures[dups[i]], i, sep=" ")
   
   #use siblings function to get value
   values <- sapply(nodes, function(x)  xmlValue(getSibling(x)))
   
   df <- data.frame(t(values), symbol)
   colnames(df) <- c(measures, "Ticker")
   return(df)
  } else {

	#break
	return() # I hope this line fixes the no loop for break/next error
  }
}

tickers <- as.character(me$Ticker)
stats <- ldply(tickers, getKeyStats_xpath)

metoo <- merge(me, stats, by = c("Ticker")) # should probably use a more informative name
head(metoo)

# clean up numbers 
metoo$mc <- gsub("B","e9",as.character(metoo[,14]))
metoo$mc <- gsub("M","e6",as.character(metoo$mc))
metoo$mc <- as.numeric(metoo$mc)
metoo$taxes <- as.numeric(as.character(metoo$INCOMETAXESPAID))

# calcuate tm ratio
metoo$tmratio <-metoo$taxes/metoo$mc
head(metoo)
write.csv(metoo, "TaxesMarketCap.csv")  