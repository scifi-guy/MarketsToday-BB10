/*
@version: 1.1.0
@author: Sudheer K. <scifi1947 at gmail.com>
@license: GNU General Public License
*/

/**
 * This JavaScript library contains functions used for core business logic
 */

var strErrorMessage;

function reloadQuotes(){
    var query = getQuery();
    if (query){                
        //var queryURL = 'http://query.yahooapis.com/v1/public/yql?q=select Symbol,Name,LastTradePriceOnly,Change,ChangeinPercent,Volume,MarketCapitalization from yahoo.finance.quotes where symbol in ("^IXIC","^GSPC","CLJ11.NYM","YHOO","AAPL","GOOG","MSFT")&env=store://datatables.org/alltableswithkeys';
    	//var queryURL = 'http://download.finance.yahoo.com/d/quotes.csv?s=INDU+^IXIC+^GSPC+CLJ11.NYM+YHOO+AAPL+GOOG+MSFT+ACT&f=snl1c1p2vj1&e=.csv';
        var queryURL = 'http://download.finance.yahoo.com/d/quotes.csv?s='+query+'&f=snl1c1p2vj1&e=.csv';
        console.log("Reloading Data with URL: "+queryURL);
        
        
        var response = new XMLHttpRequest();
        response.onreadystatechange = function() {
            if (response.readyState == XMLHttpRequest.DONE) {
            	var success = refreshDataModel(response);
            	quoteRefreshCompleted(success,strErrorMessage);
            }
        };

        response.open("GET", queryURL);
        response.send();
        activityIndicator.start();
    }
    else{
        console.log("No stock symbols found in configuration.");
        strErrorMessage = "Tap ':' in the Action Bar to add stock tickers and update settings.";
        groupDataModel.clear();
        quoteRefreshCompleted(false,strErrorMessage);
    }
}

function getQuery(){
    var query;
    var symbolsArray = DBUtility.getAllSymbols();
    if (symbolsArray && symbolsArray.length > 0){
        var i = 0;
        for (i = 0; i< symbolsArray.length; i++) {
            console.log("Appending "+symbolsArray[i]+ " to Query");

            if (!query){
                query = symbolsArray[i];
            }
            else{
                query = query + '+' + symbolsArray[i];
            }
        }
    }

    return query;
}

function reloadNews(){
    if (!rssURL || rssURL == "Unknown") {
        console.log("Invalid RSS URL: "+rssURL);
    }
    else{
        console.log("Reloading news from "+rssURL);
        //var queryURL = "http://finance.yahoo.com/rss/topfinstories";
        console.log(rssURL);
        var response = new XMLHttpRequest();
        response.onreadystatechange = function() {
            if (response.readyState == XMLHttpRequest.DONE) {
                var success = refreshNewsModel(response);
                if (success === true){
                    console.log("News Reload Completed..");
                }
                else{
                    console.log("News Reload Failed..");
                }
                newsReloadCompleted(success,strErrorMessage);
            }
        };

        response.open("GET", rssURL);
        response.send();
    }
}


function refreshDataModel(response){
	   activityIndicator.stop();
	   var status = false;   
	   if (!response.responseText) {
	       strErrorMessage = "Error occurred while loading stock quotes.";
	       console.log("No responseText for quotes");
	       return status;
	    }
	   else{
		   //snl1c1p2vj1
		   var quoteDetails = CSVUtility.csvToArray(response.responseText.trim());
		   var i = 0;
	        if (quoteDetails && quoteDetails.length > 0){
	            console.log("Clearing Data Model");
	            groupDataModel.clear();

	            for (i = 0; i < quoteDetails.length; i++){

	                var symbol,stockName,lastTradedPrice,change,changePercentage,volume,marketCap;
	                symbol = quoteDetails[i][0];
	                stockName = quoteDetails[i][1];
	                lastTradedPrice = quoteDetails[i][2];
	                change = (quoteDetails[i][3] !== 'N/A')? quoteDetails[i][3]:'';
	                changePercentage = (quoteDetails[i][4] !== 'N/A')? quoteDetails[i][4]:'';
	                volume = (quoteDetails[i][5] !== 'N/A')? quoteDetails[i][5]:'';
	                marketCap = (quoteDetails[i][6] !== 'N/A')? quoteDetails[i][6]:'';

	                groupDataModel.insert(
	                		{"symbol":symbol,"stockName":stockName,"lastTradedPrice":lastTradedPrice,"change":change,"changePercentage":changePercentage,"volume":volume,"marketCap":marketCap});
	                //console.log("Symbol: "+symbol+", Name: "+ stockName+", LastTraded: "+lastTradedPrice+", Change: "+change+", ChangePercent: "+changePercentage+", Volume: "+volume+", MarketCap: "+marketCap);
	            }

	            status = true;
	            var timeNow = new Date();
	            try{
	                lastUpdatedTimeStamp = "Updated: "+DateLib.ISODate.format(timeNow);
	                console.log(lastUpdatedTimeStamp);
	            }
	            catch(exception){
	                console.log("Error occured while converting timestamp");
	                console.log(exception);
	            }
	        }
	        else
	        {
	            strErrorMessage = "Quotes could not be fetched from Yahoo! Finance. Please verify the tickers and try again later.";
	            console.log(response.responseText);
	            status = false;
	        }		   
	   }

	    return status;
}

function refreshNewsModel(response){
    var status = false;
    if (!response.responseXML) {
        //This shouldn't happen
        strErrorMessage = "Error occurred while loading news.";
        if (response.responseText)
            console.log(response.responseText);
        else
            console.log("No responseXML for news");
        return status;
    }

    //Not the best code I ever wrote, but got no choice
    //Refer to Memory leak issue with XMLListModel --> http://bugreports.qt.nokia.com/browse/QTBUG-15191


    var xmlDoc = response.responseXML.documentElement;
    //var channel = xmlDoc.firstChild; Doesn't work with some RSS providers. THANK YOU, YAHOO

    var channel;

    var i = 0;
    for (i = 0; i < xmlDoc.childNodes.length; i++){
        if (xmlDoc.childNodes[i].nodeName === 'channel') {
            channel = xmlDoc.childNodes[i];
            break;
        }
    }

    if (channel) {
        var itemNodes = channel.childNodes;
        if (itemNodes){

            console.log("Clearing News Model");
            newsDataModel.clear();
            console.log("No. of news stories = "+itemNodes.length);

            for (i = 0; i < itemNodes.length; i++) {
                if (itemNodes[i].nodeName === 'item'){
                    var newsElements = itemNodes[i].childNodes;
                    var j = 0;
                    var newsTitle,newsLink;
                    for (j = 0; j < newsElements.length; j++){

                        switch (newsElements[j].nodeName){
                            case 'title':
                                newsTitle = newsElements[j].childNodes[0].nodeValue;
                                break;
                            case 'link':
                                newsLink = newsElements[j].childNodes[0].nodeValue;
                                break;
                            default:
                        }
                    }
                    newsDataModel.insert({"title":newsTitle,"link":newsLink});
                    //console.log("Title: "+newsDataModel.get(i).title+", Link: "+ newsDataModel.get(i).link);
                    //console.log("Title: "+newsTitle+", Link: "+ newsLink);
                }
            }
            status = true;
        }
        else{
            strErrorMessage = "The RSS feed did not contain any news stories. Please try again later.";
            console.log(response.responseText);
            status = false;
        }
    }
    else{
        strErrorMessage = "The RSS feed did not return valid data. Please check the URL and try again later.";
        console.log(response.responseText);
        status = false;
    }

    return status;
}


function initialize(){
	//if (autoUpdateTimer.running) autoUpdateTimer.stop();
	//loadSettings();
	reloadQuotes();
	//reloadNews();

//	if (autoUpdateInterval !== 0) {
//		console.log("Starting Timer..");
//		autoUpdateTimer.start();
//	}
}