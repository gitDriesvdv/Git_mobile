.pragma library
.import QtQuick 2.0
.import QtQuick.LocalStorage 2.0 as Sql


    var db = Sql.LocalStorage.openDatabaseSync("CrazyBox", "1.0", "Store form offline", 100000);

    function init() {
        print('initDatabase()')
            //db = LocalStorage.openDatabaseSync("CrazyBox", "1.0", "Store form offline", 100000);
            db.transaction( function(tx) {
                print('... create table')
                tx.executeSql('CREATE TABLE Form IF NOT EXISTS data(FormName TEXT, Name TEXT, Type TEXT, User TEXT, Height INT, Index INT, Req BOOL)');
                tx.executeSql('CREATE TABLE FormLists IF NOT EXISTS data(FormName TEXT, Name TEXT, ListItem TEXT)');
            });
    }

    function insertData(formname,name,type,user,height,index,req)
    {
        db.transaction(
                    function(tx){
                        tx.executeSql('INSERT INTO Form VALUES(?,?,?,?,?,?,?);'
                                      ,[formname],[name],[type],[user],[height],[index],[req]);
                    }
                        );
    }

    function storeData() {
        // stores data to DB
        // FormName
        print('storeData()')
            if(!db) { return; }
            db.transaction( function(tx) {
                print('... check if a crazy object exists')
                var result = tx.executeSql('SELECT * from Form where Name = "crazy"');
                result = tx.executeSql('INSERT INTO data VALUES (?,?)', ['crazy', JSON.stringify(obj)]);

                // prepare object to be stored as JSON
                var obj = { x: crazy.x, y: crazy.y };
                if(result.rows.length === 1) {// use update
                    print('... crazy exists, update it')
                    result = tx.executeSql('UPDATE data set value=? where name="crazy"', [JSON.stringify(obj)]);
                } else { // use insert
                    print('... crazy does not exists, create it')
                    result = tx.executeSql('INSERT INTO data VALUES (?,?)', ['crazy', JSON.stringify(obj)]);
                }
            });
        //tx.executeSql('CREATE TABLE Form IF NOT EXISTS data(FormName TEXT, Name TEXT, Type TEXT, User TEXT, Height INT, Index INT, Req BOOL)');

        //List nog omzetten eens de fields zonder list getest zijn
        //Name
        //Type
        //User
        //heightItem_mobile
        //indexForm
        //req
    }

    function readData() {
        // reads and applies data from DB
    }


    Component.onCompleted: {
        initDatabase();
        //readData();
    }

    Component.onDestruction: {
        storeData();
    }

