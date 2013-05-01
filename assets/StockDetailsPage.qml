/*
@version: 1.0.0
@author: Sudheer K. <scifi1947 at gmail.com>
@license: GNU General Public License
*/

// Page with details of the selected stock

import bb.cascades 1.0
import "js/CSVUtility.js" as CSVUtility

Page {
    property string symbol: ""
    property string stockName: ""
    property string lastTradedPrice: ""
    property string lastTradedDateTime: ""
    property string change: ""
    property string changePercentage: ""
    property string daysRange: ""
    property string yearRange: ""
    property string marketVolume: ""
    property string prevClose: ""
    property string marketCap: ""
    property string baseChartURL: "http://chart.finance.yahoo.com/z?q=&l=&z=m&p=s&a=v&p=s&lang=en-US&region=US"
    property string chartURL: ""
    property string rssURL: ""
    
    property Page chartPage 
    
    
    id: pgStockDetail
    
    titleBar: TitleBar {
        title : "Markets Today"
        appearance: TitleBarAppearance.Plain
    }    
    
//    actions: [
//        // create navigation panel actions here
//        ActionItem {
//            title: qsTr("Charts")
//            ActionBar.placement: ActionBarPlacement.OnBar
//            onTriggered: {
//                if (!chartPage) {
//                    console.log("Creating charts page for "+selectedSymbol);
//                    chartPage  = chartPageDefinition.createObject();
//                }
//                else{
//                    console.log("Not creating charts page, already exists");
//                }
//                navigationPane.push(chartPage);
//            }
//            
//            attachedObjects: [
//                ComponentDefinition {
//                    id: chartPageDefinition
//                    source: "StockChartPage.qml"
//                }
//            ]                   
//        }
//    ]

    paneProperties: NavigationPaneProperties {
        backButton: ActionItem {
            onTriggered: {
                // define what happens when back button is pressed here
                // in this case it closes the detail page
                navigationPane.pop()
            }
        }
    }
    
    attachedObjects: [                
        GroupDataModel {
            id: stockNewsDataModel
            
            // Sort the data items based on the timestamp of the news item
            sortingKeys: ["timestamp"]
            
            //Display most recent news item first
            sortedAscending: false            
            
            // Specify that headers should not be used
            grouping: ItemGrouping.None
        }
    ]   
    
    
    Container {
        id: rootContainer
        background: Color.Black
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom
        } 
        
        bottomPadding: 20.0 
                          
        Label {
            text: stockName
            horizontalAlignment: HorizontalAlignment.Center
            textStyle {
                fontSize: FontSize.Medium
            }
        }
        
        Container {
            id: detailsContainer
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }
            
            bottomPadding: 10.0                                     
            
            StockDetailsRow{
                label1: "Last Traded"
                value1: lastTradedPrice
                
                label2: "Day's Range"
                value2: daysRange
            }
            
            StockDetailsRow{
                label1: "Last Trade Time"
                value1: lastTradedDateTime
                
                label2: "52w Range"
                value2: yearRange
            }
            
            StockDetailsRow{
                label1: "Change"
                value1: ((change != "" && changePercentage != "")? change + " ("+changePercentage+")":"")
                
                label2: "Volume"
                value2: marketVolume
            }
            
            StockDetailsRow{
                label1: "Prev. Close"
                value1: prevClose
                
                label2: "Market Cap"
                value2: marketCap
            }
        }//End of detailsContainer
        
        
        ListView {
            id: stockQuotesListView            
            dataModel: stockNewsDataModel
            layout: StackListLayout {
                headerMode: ListHeaderMode.Standard
            }                      
            
            listItemComponents: [
                ListItemComponent {
                    type: "item"
                    Container {
                        id: itemRoot
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }   
                        background: (itemRoot.ListItem.indexPath % 2 != 0) ? Color.Black : Color.create("#323232")
                        minHeight: 100.0
                        verticalAlignment: VerticalAlignment.Center
                        
                        Label {
                            layoutProperties: StackLayoutProperties {spaceQuota: 100 }
                            verticalAlignment: VerticalAlignment.Center                                
                            text: ListItemData.title
                            multiline: true
                            textStyle {
                                color: Color.White
                                //base: SystemDefaults.TextStyles.SubtitleText
                                fontSize: FontSize.Small
                            }
                        }//End of Label
                         
                        
                        gestureHandlers: 
                        [
                            DoubleTapHandler {
                                onDoubleTapped: {
                                    itemRoot.ListItem.view.openURL(ListItemData.link);                         
                                }                                                                     
                            }
                        ]
                                              
                    } //End of itemRoot
                }
            ]
            
            function openURL(strURL){
                if (strURL && strURL.length > 0){
                    console.log("Opening URL: "+strURL);
                    app.launchBrowser(strURL);
                }
            }             
        }//End of ListView
        
        
        onCreationCompleted: {
            // this slot is called when declarative scene is created
            // write post creation initialization here
            console.log("Stock Symbol is "+selectedSymbol);  
            loadDetails();
            loadNews();       
        }
        function loadDetails(){
            var queryURL = 'http://download.finance.yahoo.com/d/quotes.csv?s='+selectedSymbol+'&f=snl1d1t1c1p2mwvpj1&e=.csv';
            console.log("Loading stock details from "+queryURL);
            var response = new XMLHttpRequest();
            response.onreadystatechange = function() {
                if (response.readyState === XMLHttpRequest.DONE) {
                    refreshDetails(response.responseText);
                }
            }
            
            response.open("GET", queryURL);
            response.send();
        }//End of function loadDetails()
        
        function loadNews(){
            rssURL = "http://feeds.finance.yahoo.com/rss/2.0/headline?region=US&lang=en-US&s="+selectedSymbol;
            console.log("Loading news from "+rssURL);
            var response = new XMLHttpRequest();
            response.onreadystatechange = function() {
                if (response.readyState === XMLHttpRequest.DONE) {
                    refreshNewsModel(response.responseXML);
                }
            }
            
            response.open("GET", rssURL);
            response.send();
        }//End of function loadNews()
        
        function refreshDetails(responseText){
            if (!responseText) {
                console.log("No responseText for quote "+symbol);
                return;
            }
                        
            var quoteDetails = CSVUtility.csvToArray(responseText.trim());
            if (quoteDetails && quoteDetails.length > 0){
                //We are only expecting one quote row per symbol.
                //snl1d1t1c1p2mwvpj1
                var lastTradedDate = "", lastTradedTime ="";
                stockName = quoteDetails[0][1];
                lastTradedPrice = quoteDetails[0][2];
                lastTradedDate = quoteDetails[0][3];
                lastTradedTime = quoteDetails[0][4];
                change = quoteDetails[0][5];
                changePercentage = quoteDetails[0][6];
                daysRange = quoteDetails[0][7];
                yearRange = quoteDetails[0][8];
                marketVolume = quoteDetails[0][9];
                prevClose = quoteDetails[0][10];
                marketCap = quoteDetails[0][11];
                if (lastTradedDate !== "") lastTradedDateTime = lastTradedDate + " " + lastTradedTime;
            }
            else {
                console.log("No results for stock quote details");
            }
        }//End of function refreshDetails(responseText)
        
        function refreshNewsModel(responseXML){
            if (!(responseXML && stockNewsDataModel)) return;
            
            var xmlDoc = responseXML.documentElement;
            var channel = xmlDoc.firstChild;
            
            //Not the best code I ever wrote, but got no choice
            //Refer to Memory leak issue with XMLListModel --> http://bugreports.qt.nokia.com/browse/QTBUG-15191
            
            if (channel) {
                var itemNodes = channel.childNodes;
                if (itemNodes){
                    
                    console.log("Clearing News Model");
                    stockNewsDataModel.clear();
                    
                    var i = 0;
                    for (i = 0; i < itemNodes.length; i++) {
                        
                        if (itemNodes[i].nodeName === 'item'){
                            var newsElements = itemNodes[i].childNodes;
                            var j = 0;
                            var newsTitle,newsLink
                            for (j = 0; j < newsElements.length; j++){
                                
                                switch (newsElements[j].nodeName){
                                    case 'title':
                                        newsTitle = newsElements[j].childNodes[0].nodeValue;
                                        break;
                                    case 'link':
                                        newsLink = newsElements[j].childNodes[0].nodeValue;
                                        break;
                                    default:
                                }//End of switch
                            }//End of for
                            stockNewsDataModel.insert({"title":newsTitle,"link":newsLink});
                        }//End of if (itemNodes[i].nodeName === 'item')
                    }//End of for
                }//End of if (itemNodes)
            }//End of if (channel)
        } //End of function refreshNewsModel(responseXML)
    }//End of rootContainer
}//End of Page
