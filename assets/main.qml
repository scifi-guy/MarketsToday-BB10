/*
@version: 1.1.0
@author: Sudheer K. <scifi1947 at gmail.com>
@license: GNU General Public License
*/

//Main application QML screen

import bb.cascades 1.0
import my.customlibrary 1.0 
import "js/CoreLogic.js" as CoreLib
import "js/ISODate.js" as DateLib
import "js/DBUtility.js" as DBUtility
import "js/CSVUtility.js" as CSVUtility

NavigationPane {
    id: navigationPane
    
    property Page newsPage
    property Page detailsPage    
    property Sheet editSheet    
    property string selectedSymbol
    property string lastUpdatedTimeStamp
    
    signal quoteRefreshStarted
    signal quoteRefreshCompleted(bool success, string strMessage)
    
    Page {    
        
        id: stockListPage
        titleBar: TitleBar {
            title : "Markets Today"
            appearance: TitleBarAppearance.Plain
        }        
	    actions: [
	        // Navigation panel actions
	        ActionItem {
	            title: qsTr("Update")
	            imageSource: "images/reload.png"
	            ActionBar.placement: ActionBarPlacement.OnBar
	            onTriggered: {
	                CoreLib.reloadQuotes();
	            }
	        },
	        
	        
            ActionItem {
                title: qsTr("News")
                imageSource: "images/news.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    if (!newsPage) {
                        console.log("Creating News Page..");
                        newsPage  = newsPageDefinition.createObject();
                    }
                    else{
                        console.log("Not creating News page, already exists");
                    }
                    navigationPane.push(newsPage);
                }
                
                attachedObjects: [
                    ComponentDefinition {
                        id: newsPageDefinition
                        source: "NewsPage.qml"
                    }
                ]                   
            },	        
	        
            ActionItem {
                title: qsTr("Edit Stocks")
                imageSource: "images/edit.png"
                //ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    editSheet = editSheetDef.createObject();
                    editSheet.closed.connect(CoreLib.reloadQuotes);
                    editSheet.open();
                }
                
                attachedObjects: [
                    ComponentDefinition {
                        // Component definition for the Sheet that will be shown when pressing the Add/Remove stocks action
                        id: editSheetDef
                        source: "EditStocks.qml"
                    }
                ]                
            }   
	    ]  

        Container {
            id: topLevelContainer
            background: Color.Black
            layout: DockLayout {}  
	        Container {	        
	            id: stockQuotesContainer
	            layout: StackLayout {
	                orientation: LayoutOrientation.TopToBottom
	            }     
	            
	            leftPadding: 10.0
	            
	            attachedObjects: [
	                GroupDataModel {
	                    id: groupDataModel
	                    
	                    // Sort the data items based on the name of the stock
	                    //{"symbol":symbol,"stockName":stockName,"lastTradedPrice":lastTradedPrice,"change":change,"changePercentage":changePercentage,"volume":volume,"marketCap":marketCap}
	                    sortingKeys: ["stockName"]
	                    
	                    // Specify that headers should not be used
	                    grouping: ItemGrouping.None
	                },
	                
	                QTimer{
	                    id: footerMessageTimer
	                    //set singleshot property if requireds
	                    singleShot: true
	                    //set interval
	                    interval: 10000
	                    
	                    onTimeout:{
	                        footerLabel.text = lastUpdatedTimeStamp
	                    }
	                }                
	                
	            ]
	                       
	            ListView {
	                id: stockQuotesListView
	                
	                dataModel: groupDataModel
	                layout: StackListLayout {
	                    headerMode: ListHeaderMode.Standard
	                }
	                listItemComponents: [
	                    ListItemComponent {
	                        type: "item"
	                        Container {
	                            id: itemRoot                     
	                            background: (itemRoot.ListItem.indexPath % 2 == 0) ? Color.Black : Color.create("#323232")
	                            layout: StackLayout {
	                                orientation: LayoutOrientation.LeftToRight
	                            }
	                                                        
	                            gestureHandlers: [
	                                DoubleTapHandler {
	                                    onDoubleTapped: { 
	                                        console.log("DoubleTap for stock "+ListItemData.stockName);
	                                        //show stock details page on double tap
	                                        var page = itemRoot.ListItem.view.getDetailsPage(ListItemData.symbol);
	                                        console.debug("pushing detail " + page)
	                                        Qt.navigationPane.push(page);                                    
	                                    }                                                                     
	                                }
	                            ]                                                     
	                            
	                            bottomPadding: 2.0
	                            topPadding: 2.0
	                            minHeight: 100.0
	                            
	                            Label {
	                                verticalAlignment: VerticalAlignment.Center                                
	                                layoutProperties: StackLayoutProperties {spaceQuota: 42 }
	                                text: ListItemData.stockName
	                                textStyle {
	                                    fontSize: FontSize.Medium
	                                }
	                            }                             		                            
	                            Label {
	                                verticalAlignment: VerticalAlignment.Center
	                                layoutProperties: StackLayoutProperties {spaceQuota: 22 }
	                                text: ListItemData.lastTradedPrice
	                                textStyle {
	                                    fontSize: FontSize.Medium
	                                }		                                	                                
	                            }	
	                            Container {
	                                id: changeContainer
	                                verticalAlignment: VerticalAlignment.Center
	                                layoutProperties: StackLayoutProperties {spaceQuota: 16 }
	                                layout: StackLayout {
	                                    orientation: LayoutOrientation.TopToBottom
	                                }   
	                                Container {
	                                    Label {                                        
	                                        text: ListItemData.change
	                                        textStyle {
	                                            fontSize: FontSize.XSmall
	                                            color: ListItemData.change >= 0 ? Color.Green: Color.Red  
	                                        }		                                		                                
	                                    }    
	                                }    
	                                
	                                Container {
	                                    Label {
	                                        text: ListItemData.changePercentage
	                                        textStyle {
	                                            fontSize: FontSize.XSmall
	                                            color: ListItemData.change >= 0 ? Color.Green: Color.Red
	                                        }		                                		                                
	                                    }    
	                                }                                                                                            
	                            } // End of Containter - changeContainer	
	                            
	                            Label {
	                                verticalAlignment: VerticalAlignment.Center
	                                layoutProperties: StackLayoutProperties {spaceQuota: 20 }
	                                text: ListItemData.volume	
	                                textStyle {
	                                    //base: quoteStyleSmallText.style
	                                    fontSize: FontSize.XXSmall
	                                }		                                	                                
	                            }                                                                                 		                            		                            
	                        } //End of Container - itemRoot                                            
	                    }//End of ListItemComponent                        
	                ]//End of listItemComponents
	                
	                // After the list is created, add the data items
	                onCreationCompleted: {
	                    //Load stock quotes
	                    console.log("Reloading quotes");
	                    CoreLib.reloadQuotes();   
	                }
	                                
	                function getDetailsPage(stockSymbol) {
	                    if (stockSymbol)
	                    { 
	                        selectedSymbol = stockSymbol;
	                        if (! detailsPage) {
	                            console.log("Creating Page Object for " +selectedSymbol);
	                            detailsPage = detailsPageDefinition.createObject();
	                        }
	                        else{
	                            console.log("Not creating page, already exists");
	                        }
	                    }
	                    return detailsPage;
	                }
	                attachedObjects: [
	                    ComponentDefinition {
	                        id: detailsPageDefinition
	                        source: "StockDetailsPage.qml"
	                    }
	                ]                   
	            
	            } // end of ListView
	            
	            Container {
	                layout: StackLayout {
	                    orientation: LayoutOrientation.LeftToRight
	                }	                
	                Label {        
	                    id: footerLabel
	                    text: "Double-tap on a row to display more details."
	                    horizontalAlignment: HorizontalAlignment.Right
	                    verticalAlignment: VerticalAlignment.Center
	                    layoutProperties: StackLayoutProperties {spaceQuota: 90 }
	                    textStyle {
	                        fontSize: FontSize.XXSmall
	                        textAlign: TextAlign.Right                    
	                        color: Color.White  
	                    }	                             
	                }                
	            }            
	            
	            function updateFooter(success, strMessage){
	                if (success){
	                    footerLabel.text = "Double-tap on a row to display more details.";
	                    footerMessageTimer.start();
	                }
	                else{
	                    footerLabel.text = lastUpdatedTimeStamp;
	                    }                
	            } 
	            
	            onCreationCompleted: {
	                //Start timer to update footer message
	                footerMessageTimer.start();      
	                navigationPane.quoteRefreshCompleted.connect(updateFooter);
	            }            	            
	        }//end of stockQuotesContainer
	                              
            Container {
                id: errorMsgContainer
                visible: false                
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                Label {
                    id: errorMessageLabel     
                    text: "Loading Stock Quotes...."
                    multiline: true
                    textStyle {
                        fontSize: FontSize.Small
                        color: Color.White  
	                }                                           
                }
                function displayError(success, strMessage){
                    if (success){
                        errorMsgContainer.visible = false;
                        stockQuotesContainer.visible = true;
                    }
                    else{
                        errorMessageLabel.text = strMessage;
                        errorMsgContainer.visible = true;
                        stockQuotesContainer.visible = true;
                    }                    
                }
                onCreationCompleted: {
                    navigationPane.quoteRefreshCompleted.connect(displayError);
                }
            }
            ActivityIndicator{
                id: activityIndicator 
                preferredHeight: 400
                preferredWidth: 400
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
            }
        }//End of topLevelContainer	    	    	    	                                  
    }// end of Page
    
    onPopTransitionEnded: {
        console.log("Destroying popped page");
        if (newsPage) newsPage.destroy();
        if (detailsPage) detailsPage.destroy();
    }
    
    onCreationCompleted: {
        // this slot is called when declarative scene is created
        // write post creation initialization here
        console.log("NavigationPane - onCreationCompleted()");    
        Qt.navigationPane = navigationPane;        
        // enable layout to adapt to the device rotation
        // don't forget to enable screen rotation in bar-bescriptor.xml (Application->Orientation->Auto-orient)
        OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
        
        //Initialize database - create necessary tables
        DBUtility.initialize();     
    }
}
