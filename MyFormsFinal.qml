import QtQuick 2.0
import QtQuick 2.0
import Enginio 1.0
import QtQuick.Window 2.0
import Qt.labs.settings 1.0
import QtQuick.Controls 1.4
//lijst met alle formulieren waar de gebruiker toegang tot heeft
Rectangle {
    id: recMyForms
    property var aUniqueList: [];
    width: Screen.width
    height: Screen.height
    z:1

    //bron: https://sameapk.com/wallpapers/nexus-colorful-stock-background/
    Image {
        id: background
        source: "qrc:/new/prefix1/nexus-colorful-stock-background-3723_image.jpg"
        anchors.fill: parent
    }
    Component {
            id: rowDelegate
            Rectangle{
                id: rec
                width: Screen.width; height: Screen.height/8
                color: "white"
                opacity: 0.5
                Text {
                    text: name
                    color: "black"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.bold: true
                    font.pixelSize: 70
                }
                MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            settings.current_form = name;
                            header.z = 0;
                            //Navigeren aan de volgende pagina om een forulier volledig weer te geven
                            var component = Qt.createComponent("FormViewFinal.qml")
                            if (component.status == Component.Ready) {
                            var window    = component.createObject(recMyForms);
                            window.show()
                            }
                            }
                    }
                Rectangle{
                    id: divider
                    height: 1
                    width: Screen.width
                    anchors.bottom: rec.bottom
                    color: "black"
                }
            }
        }
    Rectangle {
               id: header
               anchors.top: parent.top
               width: parent.width
               height: Screen.height/6
               color: "transparent"
                z:1
               Row {
                   id: logo
                   anchors.centerIn: parent
                   anchors.horizontalCenterOffset: -4
                   spacing: 4
                   height: 20
                   Text {

                       text: "Forms"
                       anchors.verticalCenter: parent.verticalCenter
                       anchors.verticalCenterOffset: -30
                       font.bold: true
                       font.pixelSize: 46
                       color: "white"
                   }
               }

               Rectangle{
                   id: subheader
                   anchors.top: logo.bottom
                   height: header.height/2
                   width: Screen.width
                   color: "transparent"
               }
           }

    ListModel {
        id: listForms
    }
    Rectangle{
        color: "white"
        opacity: 0.7
        anchors.fill: formlist
    }

    ListView {
        id: formlist
        width: Screen.width
        height: Screen.height
        anchors.top: header.bottom
        anchors.bottom: footer.top
        model: listForms
        delegate: rowDelegate
        Component.onCompleted: getDataUserForms(settings.username);
    }

    Rectangle{
        id: footer
        anchors.bottom: parent.bottom
        color: "transparent"
        width: Screen.width
        height: Screen.height/10

        Button {
            id: logout
            anchors.fill: parent
            text: "LOGOUT"
        }
    }

    //ophalen van alle formulieren voor de ingelogde gebruiker
    function getDataUserForms(formname_input) {
        var xmlhttp = new XMLHttpRequest();
        var url = "https://api.engin.io/v1/users?q={\"username\":\""+ formname_input +"\"}&limit=1"

        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var arr = JSON.parse(xmlhttp.responseText);
                var arr1 = arr.results;
                for(var i = 0; i < arr1.length; i++) {
                    console.log(arr1[i].forms);
                    for(var y = 0; y < arr1[i].forms.length; y++)
                    {
                        listForms.append({name: arr1[i].forms[y]})
                    }
                }
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
}

