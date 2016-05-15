import QtQuick 2.1
import Enginio 1.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0
import QtQuick.LocalStorage 2.0
ColumnLayout {
    id:rec
    width: Screen.width
    Settings {
           id: settings
           property string username: ""
           property string current_form: ""
       }

    Component.onCompleted: {
        combined()
    }

    anchors.fill: parent
    anchors.margins: 3
    spacing: 3
    Rectangle{
        id: headerspacer
        width: Screen.width
        height: 100
        color: "white"

    }

    ComboBox {
        id: login
        width: Screen.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: headerspacer.bottom
        model: ListModel{
                id: lijstmodel
               }
    }
    Rectangle{
        id: spacer
        width: Screen.width
        height: 20
        color: "white"
         anchors.top: login.bottom
    }
    Button {
        anchors.top: spacer.bottom
        id: proccessButton
        Layout.fillWidth: true
        text: "START"
        onClicked: {
            settings.username = login.currentText
            var component = Qt.createComponent("EHBKeuzeMenu.qml")
            if (component.status == Component.Ready) {
            var window    = component.createObject(rec);
            window.show()}
        }
        style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 25
                    color: "white"
                    border.width: 5
                    border.color: "red"
                    radius: 9
                }
            }
    }
    Rectangle{
        id: spacer3
        width: Screen.width
        height: 80
        color: "white"
         anchors.top: proccessButton.bottom
    }

Rectangle{
    id: logoContainer
    anchors.top: spacer3.bottom
    Image {
        id: logoImage
        width: Screen.width
        height: Screen.height/1.8
        //horizontalAlignment: parent.horizontalCenter
        source: "qrc:/new/prefix1/EHB-LOGO-SID-IN-APP.png"
    }
}
function getTeachers() {
    var xmlhttp = new XMLHttpRequest();
    var url = "https://api.engin.io/v1/objects/EHBTeachers"
    xmlhttp.onreadystatechange=function() {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            var arr = JSON.parse(xmlhttp.responseText);
            var arr1 = arr.results;
            for(var i = 0; i < arr1.length; i++) {
                //lijstmodel.append({text: arr1[i].Name})
                fillLogins(arr1[i].Name)
            }
            findLogins();
        }
        else
        {
            console.log("Bad request")
        }
    }
    xmlhttp.open("GET", url, true);
    xmlhttp.setRequestHeader("Enginio-Backend-Id","54be545ae5bde551410243c3");
    xmlhttp.send();
}
function initDB()
{
    var db = LocalStorage.openDatabaseSync("QQmlDB", "1.0", "EHB FORM OFFLINE SQL!", 1000000);

    db.transaction(
        function(tx) {
            if(doesConnectionExist() === true)
            {
                tx.executeSql('DROP TABLE Login');
            }
            tx.executeSql('CREATE TABLE IF NOT EXISTS Login(Name TEXT)');
        }
    )
}

function findLogins() {
    initDB();
    var db = LocalStorage.openDatabaseSync("QQmlDB", "1.0", "EHB FORM OFFLINE SQL!", 1000000);

    db.transaction(
        function(tx) {
            /*if(doesConnectionExist() == true)
            {
                tx.executeSql('DROP TABLE Login');
                tx.executeSql('CREATE TABLE IF NOT EXISTS Login(Name TEXT)');
            }*/
            tx.executeSql('DROP TABLE Login');
            lijstmodel.clear();
            var rs = tx.executeSql('SELECT * FROM Login');

            for(var i = 0; i < rs.rows.length; i++) {
                lijstmodel.append({text: rs.rows.item(i).Name})
            }
        }
    )
}

function fillLogins(name)
{
    initDB();
    var db = LocalStorage.openDatabaseSync("QQmlDB", "1.0", "EHB FORM OFFLINE SQL!", 1000000);

    db.transaction(
        function(tx) {
            tx.executeSql('INSERT INTO Login VALUES(?)', [name]);
        }
    )
}

function combined()
{
    var nameList = [];

         var xmlhttp = new XMLHttpRequest();
         var url = "https://api.engin.io/v1/objects/EHBTeachers"
         xmlhttp.onreadystatechange=function() {
         if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            var arr = JSON.parse(xmlhttp.responseText);
            var arr1 = arr.results;
            for(var i = 0; i < arr1.length; i++) {
                nameList.push(arr1[i].Name);
            }
            var db = LocalStorage.openDatabaseSync("QQmlDB", "1.0", "EHB FORM OFFLINE SQL!", 1000000);
            db.transaction(
                function(tx) {
                    tx.executeSql('DROP TABLE Login');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Login(Name TEXT)');

            for(var x = 0; x < nameList.length; x++)
             {
                 tx.executeSql('INSERT INTO Login VALUES(?)', [nameList[x]]);
             }
             lijstmodel.clear();
            var rs = tx.executeSql('SELECT * FROM Login');
            for(var i = 0; i < rs.rows.length; i++) {
                lijstmodel.append({text: rs.rows.item(i).Name})
            }
    })
        }
        else
        {
             var db1 = LocalStorage.openDatabaseSync("QQmlDB", "1.0", "EHB FORM OFFLINE SQL!", 1000000);
             db1.transaction(
                 function(tx) {

                        var rs = tx.executeSql('SELECT * FROM Login');
                     lijstmodel.clear();

                            for(var i = 0; i < rs.rows.length; i++) {
                                lijstmodel.append({text: rs.rows.item(i).Name})
                                }
                 })
        }
    }
    xmlhttp.open("GET", url, true);
    xmlhttp.setRequestHeader("Enginio-Backend-Id","54be545ae5bde551410243c3");
    xmlhttp.send();
}

function doesConnectionExist() {
    var xhr = new XMLHttpRequest();
    var file = "http://www.google.com";
    var randomNum = Math.round(Math.random() * 1000);

    xhr.open('HEAD', file + "?rand=" + randomNum, false);

    try {
        xhr.send();

        if (xhr.status >= 200 && xhr.status < 304) {
            return true;
        } else {
            return false;
        }
    } catch (e) {
        return false;
    }
}
}

