import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0

Rectangle {
    id: menuscreen
    property var initialListNames:[];
    property var finalListNames:[];
    property var sessionIds:[];

    width: Screen.width
    height: Screen.height
    Component.onCompleted:{
        init();
        getExistingStudents();
    }

    Rectangle {
                id: header
                anchors.top: parent.top
                width: Screen.width
                height: 120
                color: "red"

                Row {
                    id: logo
                    anchors.horizontalCenterOffset: -4
                    spacing: 4
                    Image {
                        source: "qrc:/new/prefix1/Icons8-Ios7-Arrows-Back.ico"
                        width: 60 ; height: 120
                        fillMode: Image.PreserveAspectFit
                        x: 10
                    }
                    Rectangle{
                        width: Screen.width - 60
                        height: 120
                        color: "red"
                        Text {
                            text: "Menu"
                            width: 200
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenterOffset: -3
                            font.bold: true
                            font.pixelSize: 46
                            color: "#555"
                        }
                    }


                }
                Rectangle {
                    width: parent.width ; height: 1
                    anchors.bottom: parent.bottom
                    color: "#bbb"
                }
            }


    Rectangle{
        id: toprectangle
        anchors.top: header.bottom
        width: parent.width
        height: parent.height/2
        color: "white"
        Column{
            width: Screen.width
            height: parent.height
            anchors.left: parent.left
            //spacing: 4
        Rectangle{
            id: whitespace
            height: parent.height/4
        }

        Text {
            id: existingText
            anchors.top: whitespace.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Choose an existing student")
        }
        ComboBox {
            id: login
            width: Screen.width
            anchors.top: existingText.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            model: ListModel{
                    id: lijstmodel
                   }
            Button{
                id: selectExistingButton
                anchors.top: login.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Choose Student"
                width: Screen.width - 50
                height: Screen.height/10
                onClicked: {
                    var component = Qt.createComponent("EHBEditStudentTest.qml")
                    if (component.status === Component.Ready) {
                    var window    = component.createObject(menuscreen);
                    window.show()
                    }
                }
            }
          }

        }
    }
    Rectangle{
        id: bottomrectangle
        width: parent.width
        height: parent.height/2
        anchors.top: toprectangle.bottom
        color: "white"
        Button {
            id: selectNewButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: "New Student"
            width: Screen.width - 50
            height: Screen.height/10
            onClicked: {
                var component = Qt.createComponent("EHBNewStudent.qml")
                if (component.status == Component.Ready) {
                var window    = component.createObject(menuscreen);
                window.show()
                }
            }
        }
    }
    function getExistingStudents() {
        var xmlhttp = new XMLHttpRequest();
        var url = "https://api.engin.io/v1/objects/resultforms"
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var arr = JSON.parse(xmlhttp.responseText);
                var arr1 = arr.results;
                for(var i = 0; i < arr1.length; i++) {
                    if(arr1[i].type === "ComplexType")
                    {
                    sessionIds.push(arr1[i].sessionID)
                    var person = {id:arr1[i].sessionID, Name:arr1[i].input, Type:arr1[i].fieldname};
                    initialListNames.push(person);
                    }
                }
                getSessionIDs()
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

    function getSessionIDs()
    {
        Array.prototype.unique = function()
        {
            var tmp = {}, out = [];
            for(var i = 0, n = this.length; i < n; ++i)
            {
                if(!tmp[this[i]]) { tmp[this[i]] = true; out.push(this[i]); }
            }
            return out;
        }

        var b = sessionIds.unique();
        for(var i = 0; i < b.length;i++)
        {
            var person = {id:b[i], FirstName:"", LastName:""};
            finalListNames.push(person);
        }

            for(var y = 0; y < finalListNames.length;y++)
            {
                for(var i = 0; i < initialListNames.length;i++)
                {
                if(finalListNames[y].id === initialListNames[i].id)
                {
                    if(initialListNames[i].Type === "First Name")
                    {
                        finalListNames[y].FirstName = initialListNames[i].Name
                    }
                    else
                    {
                        finalListNames[y].LastName = initialListNames[i].Name

                    }
                }
            }
        }
        for(var a = 0; a < finalListNames.length;a++)
        {
            lijstmodel.append({text: finalListNames[a].LastName +" "+ finalListNames[a].FirstName})
        }
    }
    function init() {
        var db = LocalStorage.openDatabaseSync("CrazyBox", "1.0", "Store form offline", 100000);
            db.transaction( function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Form(FormName TEXT, Name TEXT, Type TEXT, User TEXT, Height NUMBER, RowIndex NUMBER, Req BOOL)');
                tx.executeSql('CREATE TABLE IF NOT EXISTS FormLists(FormName TEXT, Name TEXT, ListItem TEXT)');
            });
    }
}

