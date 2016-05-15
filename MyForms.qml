import QtQuick 2.0
import QtQuick 2.0
import Enginio 1.0
import QtQuick.Window 2.0
import Qt.labs.settings 1.0
import QtQuick.Controls 1.4
Rectangle {
    id: recMyForms
    property var aUniqueList: [];
    width: Screen.width
    height: Screen.height
    z:1
    Component {
            id: contactDelegate

            Rectangle{
                id: rec
                width: Screen.width; height: Screen.height/8
                color: "white"
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
                            var component = Qt.createComponent("FormViewTest.qml")
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
               height: Screen.height/4
               color: "#f01313"
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
                   color: "red"
                   /*Row{
                       anchors.centerIn: parent
                       height: 50*/

                       Image {
                           id: name
                           anchors.top: logo.bottom
                           source: "qrc:/new/prefix1/cropped-skyline_header2.png"
                           //anchors.centerIn: parent
                           anchors.horizontalCenter: parent.horizontalCenter
                           height: Screen.height/7
                           width: Screen.width
                       }
                   //}
               }



               /*Rectangle {
                   width: parent.width ; height: 1
                   anchors.bottom: parent.bottom
                   color: "#bbb"
               }*/
           }

    ListModel {
        id: listForms
    }

    ListView {
        width: Screen.width
        height: Screen.height
        anchors.top: header.bottom
        anchors.bottom: footer.top
        model: listForms
        delegate: contactDelegate
        Component.onCompleted: getDataUserForms(settings.username);
    }

    Rectangle{
        id: footer
        anchors.bottom: parent.bottom
        color: "#f01313"
        width: Screen.width
        height: Screen.height/10

        Button {
            id: logout
            anchors.fill: parent
            text: "LOGOUT"
        }
    }

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

