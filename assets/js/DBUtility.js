/*
@version: 1.0.0
@author: Sudheer K. <scifi1947 at gmail.com>
@license: GNU General Public License
*/

function getDatabase() {
     console.log("Opening MarketsToday database..");
     return openDatabaseSync("MarketsToday", "1.0", "StorageDatabase", 100);
}

//function logMessage(strMessage){
//    if (logUtility){
//        logUtility.logMessage(strMessage);
//    }
//    else{
//        console.log(strMessage);
//    }
//}

// Initialize tables
function initialize() {
    var db = getDatabase();
    db.transaction(
        function(tx) {
            // Create the settings table if it doesn't already exist
            // If the table exists, this is skipped
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS tickers(symbol TEXT UNIQUE)');
          },
        function(error) {
            console.log("Error ["+error.code +"] - " + error.DOMString+" occurred.");
         });
}

function getSetting(setting) {
    var db = getDatabase();
    var res="";
    db.transaction(
      function(tx) {
          var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
          if (rs.rows.length > 0) {
               res = rs.rows.item(0).value;
               console.log(setting+" is "+res);
          } else {
              res = "Unknown";
          }
      },
      function(error) {
         console.log("Error ["+error.code +"] - " + error.DOMString+" occurred.");
      }
     );
     return res;
}


function setSetting(setting, value) {
    var db = getDatabase();
    var res = "";
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
            if (rs.rowsAffected > 0) {
                res = "OK";
                console.log("Updated "+setting+" to "+value);
            } else {
             res = "Error";
            }
        },
        function(error) {
            console.log("Error ["+error.code +"] - " + error.DOMString+" occurred.");
        }
    );
   return res;
}

function addSymbol(symbol){
    console.log('SQL> INSERT OR REPLACE INTO tickers VALUES ('+[symbol]+')');
    var db = getDatabase();
    var res = "";
    console.log("Opened MarketsToday database..");

    db.transaction(function(tx) {
         var rs = tx.executeSql('INSERT OR REPLACE INTO tickers VALUES (?);', [symbol]);
               console.log("Inserted/replaced "+rs.rowsAffected+" rows");
               if (rs.rowsAffected > 0) {
                 res = "OK";
               } else {
                 res = "Error";
               }
         },
         function(error) {
           console.log("Error ["+error.code +"] - " + error.DOMString+" occurred.");
         }
   );
   return res;
}

function removeSymbol(symbol){
    console.log('SQL> DELETE FROM tickers WHERE symbol = '+[symbol]);
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
         var rs = tx.executeSql('DELETE FROM tickers WHERE symbol = ?;', [symbol]);
               console.log("Deleted "+rs.rowsAffected+" rows");
               if (rs.rowsAffected > 0) {
                 res = "OK";
               } else {
                 res = "Error";
               }
         },
         function(error) {
            console.log("Error ["+error.code +"] - " + error.DOMString+" occurred.");
         }
   );
   return res;
}

function getAllSymbols(){
    var db = getDatabase();
    var symbolsArray = new Array();
    db.transaction(function(tx) {
           var rs = tx.executeSql('SELECT symbol FROM tickers');
           console.log("Fetched "+rs.rows.length+" rows");
           var i = 0;
           for (i = 0; i < rs.rows.length; i++){
               symbolsArray[i] = rs.rows.item(i).symbol;
           }
       },
       function(error) {
           console.log("Error ["+error.code +"] - " + error.DOMString+" occurred.");
       }
   );
   return symbolsArray;
}
