/*
@version: 1.0.0
@author: Sudheer K. <scifi1947 at gmail.com>
@license: GNU General Public License
*/

//QML screen to Add/Remove Stocks

import bb.cascades 1.0
import "js/DBUtility.js" as DBUtility

Sheet {
    id: editStocksSheet
    Page {
        id: editStocksPage        
        
        function loadSymbols(){
	        var symbolsArray = DBUtility.getAllSymbols();
	        if (symbolsArray && symbolsArray.length > 0){
	            var i = 0;
	            for (i = 0; i< symbolsArray.length; i++) {
	                console.log("Appending "+symbolsArray[i]+ " to ListModel");
	                groupDataModel.insert({"symbol": symbolsArray[i]});
	            }
	            console.log("ListModel count is  "+groupDataModel.count);
	        }
         }

	    function addSymbol(symbol){
	        if (symbol && symbol.length > 0){
	            symbol = symbol.toUpperCase();
	            console.log("Adding symbol "+symbol);
	            var result = DBUtility.addSymbol(symbol);
	            console.log("Result is "+result);
	
	            if (result != "Error"){
	                groupDataModel.insert({"symbol": symbol});
	            }
	            else{
	                console.log("Error: DB error while adding "+symbol);
	            }
	        }
	        else{
	            console.log("Error: Invalid symbol "+symbol);
	        }                
	    }
	    
        attachedObjects: [
            GroupDataModel {
                id: groupDataModel
                
                // Sort the data items based on the name of the stock
                //{"symbol":symbol,"stockName":stockName,"lastTradedPrice":lastTradedPrice,"change":change,"changePercentage":changePercentage,"volume":volume,"marketCap":marketCap}
                sortingKeys: ["symbol"]
                
                // Specify that headers should not be used
                grouping: ItemGrouping.None
            }
        ]	            
        
        titleBar: TitleBar {
            id: titleBar
            title: "Edit Stocks"
            visibility: ChromeVisibility.Visible
            appearance: TitleBarAppearance.Plain
            
            dismissAction: ActionItem {
                title: "Close"
                onTriggered: {
                    editStocksSheet.close()
                }
            }
        } // TitleBar
        
        Container {
            id: editStocksContainer
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }   
            
            leftPadding: 20.0
            
            Container {
                id: addStocksContainer
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                TextField {
                    id: firstNameField
                    layoutProperties: StackLayoutProperties {spaceQuota: 85 }
                    verticalAlignment: VerticalAlignment.Center
                    hintText: "Enter Yahoo! Finance Stock Symbol"
                    
                    
                    onTextChanging: {
                        // if no symbol is entered, disable add button
                        if (text.length > 0) {
                            //addPage.titleBar.acceptAction.enabled = true;
                        } else {
                            //addPage.titleBar.acceptAction.enabled = false;
                        }
                    }
                    //onTextChanging
                }//End of TextField
                
                Container {
                    layoutProperties: StackLayoutProperties {spaceQuota: 15}
                    verticalAlignment: VerticalAlignment.Center
                    
                    ImageView {
                        imageSource: "images/add.png"
                        minWidth: 71.0
                        minHeight: 71.0
                        maxWidth: 71.0
                        maxHeight: 71.0
                        rightMargin: 100.0
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                        onTouch: {
                            editStocksPage.addSymbol(firstNameField.text.trim());
                            firstNameField.text = "";
                        }
                    }
                }
            } //End of addStocksContainer
            ListView {
                id: symbolsListView
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
                            bottomPadding: 2.0
                            topPadding: 2.0
                            Label {
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 85
                                }
                                text: ListItemData.symbol
                                textStyle {
                                    base: SystemDefaults.TextStyles.BodyText
                                    color: Color.White
                                }
                            } //End of Label
                            Container {
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 15
                                }
                                verticalAlignment: VerticalAlignment.Center
                                ImageView {
                                    imageSource: "images/remove.png"
                                    //scalingMethod: ScalingMethod.None
                                    minWidth: 71.0
                                    minHeight: 71.0
                                    maxWidth: 71.0
                                    maxHeight: 71.0
                                    rightMargin: 100.0
                                    verticalAlignment: VerticalAlignment.Center
                                    horizontalAlignment: HorizontalAlignment.Left
                                    onTouch: {
                                        itemRoot.ListItem.view.removeSymbol(ListItemData.symbol);
                                    }
                                }
                            }
                        } //End of Container itemRoot
                    }
                ]
                function removeSymbol(symbol) {
                    console.log("Removing symbol " + symbol);
                    var result = DBUtility.removeSymbol(symbol);
                    if (result != "Error") {
                        groupDataModel.remove({
                                "symbol": symbol
                            });
                    } else {
                        console.log("Error: DB error while removing " + symbol + " at index " + index);
                    }
                }
            } //End of symbolsListView
        } // End of editStocksContainer
        onCreationCompleted: {
            //Initialize database - create necessary tables
            //DBUtility.initialize();   
            loadSymbols();  
        }
        
    }//End of editStocksPage
}//End of Sheet