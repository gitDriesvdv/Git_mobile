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
        opacity: 1 - backendHelper.opacity

        color: "#f4f4f4"

        //![client]
        EnginioOAuth2Authentication {
            id: identity
            user: login.text
            password: password.text
        }
        EnginioClient {
            id: enginioClient
            backendId: "54be545ae5bde551410243c3"

            onError:{
                console.debug(JSON.stringify(reply.data))
                enginioModelErrors.append({"Error": "Enginio " + JSON.stringify(reply.data) + "\n\n", "User": "Admin"})
            }
        }
        /*EnginioModel {
            id: enginioModel
            client: enginioClient
            query: {"objectType": "objects.OS_components",
                    "include": {"file": {}},
                    "query" : { "type": Qt.platform.os, "name" : "Login_Mobiel" } }
        }*/
        EnginioModel {
            id: enginioModelErrors
            client: enginioClient
            query: {
                "objectType": "objects.Errors"
            }

        }
        EnginioModel {
            id: enginioModelLogs
            client: enginioClient
            query: {
                "objectType": "objects.Logs"
            }
        }
        //![client]

        TabView {
            id: tabView
            anchors.fill: parent
            anchors.margins: 3

            Tab {
                title: "Login"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 3

                    TextField {
                        id: login
                        Layout.fillWidth: true
                        placeholderText: "Username"
                        enabled: enginioClient.authenticationState == Enginio.NotAuthenticated
                    }

                    TextField {
                        id: password
                        anchors.top: login.bottom
                        Layout.fillWidth: true
                        placeholderText: "Password"
                        echoMode: TextInput.PasswordEchoOnEdit
                        enabled: enginioClient.authenticationState == Enginio.NotAuthenticated
                    }

                    Button {
                        id: proccessButton
                         anchors.top: password.bottom
                        Layout.fillWidth: true
                        //text: "Login"
                        //onClicked: root.visible = true
                    }

                    TextArea {
                        id: data
                        text: "Not logged in.\n\n"
                        readOnly: true
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        visible: false

                        //![connections]
                        Connections {
                            target: enginioClient
                            onSessionAuthenticated: {
                                data.text = data.text + "User '"+ login.text +"' is logged in.\n\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n"
                                enginioModelLogs.append({"Log": data.text, "User": login.text})
                                root.visible = true

                            }
                            onSessionAuthenticationError: {
                                data.text = data.text + "Authentication of user '"+ login.text +"' failed.\n\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n"
                                enginioModelErrors.append({"Error": "Enginio " + data.text + "\n\n", "User": login.text})

                            }
                            onSessionTerminated: {
                                data.text = data.text + "Session closed.\n\n"
                            }
                        }
                        //![connections]
                    }

                    states: [
                        State {
                            name: "NotAuthenticated"
                            when: enginioClient.authenticationState == Enginio.NotAuthenticated
                            PropertyChanges {
                                target: proccessButton
                                text: "Login"
                                onClicked: {
                                    //![assignIdentity]
                                    enginioClient.identity = identity
                                    //![assignIdentity]
                                }
                            }
                        },
                        State {
                            name: "Authenticating"
                            when: enginioClient.authenticationState == Enginio.Authenticating
                            PropertyChanges {
                                target: proccessButton
                                text: "Authenticating..."
                                enabled: false
                            }
                        },
                        State {
                            name: "AuthenticationFailure"
                            when: enginioClient.authenticationState == Enginio.AuthenticationFailure
                            PropertyChanges {
                                target: proccessButton
                                text: "Login failed, restart"
                                onClicked: {
                                    enginioClient.identity = null
                                }
                            }
                        },
                        State {
                            name: "Authenticated"
                            when: enginioClient.authenticationState == Enginio.Authenticated
                            PropertyChanges {
                                target: proccessButton
                                text: "Logout"
                                onClicked: {
                                    //![assignNull]
                                    enginioClient.identity = null
                                    //![assignNull]
                                }
                            }
                        }
                    ]
                }

            }
        //geen register omdat dit centraal door de admin moet gebeuren en niet in de handen van elke gebruiker mag gegeven worden
           /* Tab {
                title: "Register"
                Rectangle { anchors.fill: parent }
            }*/
        }
    }
}



