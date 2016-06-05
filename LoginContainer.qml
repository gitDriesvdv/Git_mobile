import QtQuick 2.0

import QtQuick 2.1
import Enginio 1.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Item {
    id: main
    height: 800
    width: 600

    Rectangle {
        id: root
        anchors.fill: parent
        opacity: 1
        color: "white"
        EnginioClient {
            id: enginioClient
            backendId: "54be545ae5bde551410243c3"
            onError: console.debug(JSON.stringify(reply.data))
        }

        // login is geplaatst in een tabview. Indien deze zou worden uitgebreid met een registratie dan kan dit snel worden toegepast.
        TabView {
            id: tabView
            anchors.fill: parent
            anchors.margins: 3
            tabsVisible: false
            Tab {
                title: "Login"
                LoginFinal { anchors.fill: parent
                }
            }

           
        }
    }
}

