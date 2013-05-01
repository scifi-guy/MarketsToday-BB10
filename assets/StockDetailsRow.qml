/*
@version: 1.1.0
@author: Sudheer K. <scifi1947 at gmail.com>
@license: GNU General Public License
*/

// Component to display a row in stock details screen

import bb.cascades 1.0

Container {
    
    property string label1
    property string value1
    property string label2
    property string value2        
    
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    bottomMargin: 2.0
    topMargin: 2.0
    
    
    Label {
        layoutProperties: StackLayoutProperties {spaceQuota: 55 }
        text: label1+": "+value1
        multiline: true
        textStyle {
            fontSize: FontSize.XSmall
            color: Color.White            
        }
    }        
    
    Label {
        layoutProperties: StackLayoutProperties {spaceQuota: 45 }
        text: label2+": "+value2
        multiline: true
        textStyle {
            fontSize: FontSize.XSmall
            color: Color.White
        }
    }                                
}
