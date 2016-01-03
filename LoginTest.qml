import QtQuick 2.1
import Enginio 1.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0

ColumnLayout {
    id:rec
    //![identity]
    EnginioOAuth2Authentication {
        id: identity
        user: login.text
        password: password.text
    }
    Settings {
           id: settings
           property string username: ""
           property string current_form: ""
       }
    //![identity]
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
        Layout.fillWidth: true
        placeholderText: "Password"
        echoMode: TextInput.PasswordEchoOnEdit
        enabled: enginioClient.authenticationState == Enginio.NotAuthenticated
    }

    Button {
        id: proccessButton
        Layout.fillWidth: true
    }

    TextArea {
        id: data
        text: "Not logged in.\n\n"
        readOnly: true
        Layout.fillHeight: true
        Layout.fillWidth: true

        //![connections]
        Connections {
            target: enginioClient
            onSessionAuthenticated: {
                data.text = data.text + "User '"+ login.text +"' is logged in.\n\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n"
                settings.username = login.text;
                var component = Qt.createComponent("MyForms.qml")
                if (component.status == Component.Ready) {
                var window    = component.createObject(main);
                window.show()
            }
            }
            onSessionAuthenticationError: {
                data.text = data.text + "Authentication of user '"+ login.text +"' failed.\n\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n"
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
                text: "Authentication failed, restart"
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


