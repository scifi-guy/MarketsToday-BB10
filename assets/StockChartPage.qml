/*
@version: 1.1.0
@author: Sudheer K. <scifi1947 at gmail.com>
@license: GNU General Public License
*/
import bb.cascades 1.0

Page {
    
    property string baseChartURL: "http://chart.finance.yahoo.com/z?q=&l=&z=m&p=s&a=v&p=s&lang=en-US&region=US"
    property string chartURL: ""
    
    id: pgStockDetail
    titleBar: TitleBar {
        title : "Markets Today"
        appearance: TitleBarAppearance.Plain
    }
    
    paneProperties: NavigationPaneProperties {
        backButton: ActionItem {
            onTriggered: {
                // define what happens when back button is pressed here
                // in this case it closes the chart page
                navigationPane.pop()
            }
        }
    }     
    
    Container {
        id: rootContainer
        background: Color.White
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom
        }     
        
        ImageView {
            id: stockChartImgView
            horizontalAlignment: HorizontalAlignment.Center            
            scalingMethod: ScalingMethod.AspectFit
            imageSource: ""
        }
        
        onCreationCompleted: {
            chartURL = baseChartURL + "&t=1d&s="+selectedSymbol;
            console.log("Loading chart: "+chartURL);
            stockChartImgView.imageSource = chartURL;
        }    
    }

}
