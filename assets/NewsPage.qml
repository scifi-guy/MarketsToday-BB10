/*
@version: 1.0.0
@author: Sudheer K. <scifi1947 at gmail.com>
@license: GNU General Public License
*/

//QML screen to display News RSS feed 
import bb.cascades 1.0
import "js/CoreLogic.js" as CoreLib

Page {
    id: pgNewsFeed
    property string rssURL: "http://finance.yahoo.com/rss/topfinstories"
    signal newsReloadCompleted(bool success, string strMessage)
    
    titleBar: TitleBar {
        title : "Markets Today"
        appearance: TitleBarAppearance.Plain
    }  
    
    paneProperties: NavigationPaneProperties {
        backButton: ActionItem {
            onTriggered: {
                // define what happens when back button is pressed here
                // in this case it closes the detail page
                navigationPane.pop()
            }
        }
    }       
    
    Container {
        id: newsFeedContainer
        
        attachedObjects: [
            GroupDataModel {
                id: newsDataModel
                
                // Sort the data items based on the name of the stock
                //{"symbol":symbol,"stockName":stockName,"lastTradedPrice":lastTradedPrice,"change":change,"changePercentage":changePercentage,"volume":volume,"marketCap":marketCap}
                sortingKeys: ["timestamp"]
                
                // Specify that headers should not be used
                grouping: ItemGrouping.None
            }
        ]        
        
        ListView {
            id: newsFeedListView
            dataModel: newsDataModel
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
                                                
                        background: (itemRoot.ListItem.indexPath % 2 == 0) ? Color.Black : Color.create("#323232")
                        minHeight: 100.0
                        verticalAlignment: VerticalAlignment.Center
                        
                        Label {
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            layoutProperties: StackLayoutProperties {spaceQuota: 100 }                                
                            text: ListItemData.title
                            multiline: true
                            textStyle {
                                color: Color.White
                                fontSize: FontSize.Medium 
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
                }//End of ListItemComponent
            ]
            
            onCreationCompleted: {
                //Load News Feed
                console.log("Reloading News Items");
                CoreLib.reloadNews();   
            }
            
            function openURL(strURL){
                if (strURL && strURL.length > 0){
                    console.log("Opening URL: "+strURL);
                    app.launchBrowser(strURL);
                }
            }            
            
        }//End of ListView                        
    }//End of Container        
}//End of Page

