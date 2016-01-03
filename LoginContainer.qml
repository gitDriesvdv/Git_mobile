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

        color: "#f4f4f4"

        //![client]
        EnginioClient {
            id: enginioClient
            backendId: "54be545ae5bde551410243c3"

            onError: console.debug(JSON.stringify(reply.data))
        }
        //![client]

        TabView {
            id: tabView
            anchors.fill: parent
            anchors.margins: 3

            Tab {
                title: "Login"
                LoginTest { anchors.fill: parent }
            }

           
        }
    }
}

