import QtQuick 2.1
import Enginio 1.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0
ColumnLayout {
    id:rec
    //width: Screen.width
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
    Rectangle{
        id: headerspacer
        width: Screen.width
        height: 100
        color: "white"

    }
    TextField {
        id: login
        Layout.fillWidth: true
        placeholderText: "Username"
        anchors.top: headerspacer.bottom
        enabled: enginioClient.authenticationState == Enginio.NotAuthenticated
        style: TextFieldStyle {
                textColor: "black"
                background: Rectangle {
                    radius: 10
                    border.color: "gray"
                    border.width: 4
                }
            }
    }
    /*Rectangle{
        id: line
        width: login.width
        height: 2
        color: "red"
         anchors.top: login.bottom
    }*/
    Rectangle{
        id: spacer
        width: Screen.width
        height: 20
        color: "white"
         anchors.top: login.bottom
    }

    TextField {
        id: password
        anchors.top: spacer.bottom
        Layout.fillWidth: true
        placeholderText: "Password"
        echoMode: TextInput.PasswordEchoOnEdit
        style: TextFieldStyle {
                textColor: "black"
                background: Rectangle {
                    radius: 10
                    border.color: "gray"
                    border.width: 2
                }
            }
        enabled: enginioClient.authenticationState == Enginio.NotAuthenticated
    }
    /*Rectangle{
        id: line2
        width: login.width
        height: 2
        color: "red"
         anchors.top: password.bottom
    }*/
    Rectangle{
        id: spacer2
        width: Screen.width
        height: 20
        color: "white"
         anchors.top: password.bottom
    }
    Button {
        anchors.top: spacer2.bottom
        id: proccessButton
        Layout.fillWidth: true
        style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 25
                    color: "white"
                    border.width: 5//control.activeFocus ? 2 : 1
                    border.color: "red"
                    radius: 9

                    gradient: Gradient {
                        GradientStop { position: 0 ; color: control.pressed ? "white" : "white" }
                        GradientStop { position: 1 ; color: control.pressed ? "white" : "white" }
                    }
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
                if (component.status === Component.Ready) {
                var window    = component.createObject(main);
                window.show()
            }
            }
            onSessionAuthenticationError: {
                var arr = JSON.stringify(reply.data);
                var arr1 = arr.error
                data.text = "Authentication failed"
                console.log("TEST: " + JSON.stringify(reply.data, undefined, 2))
            }
            onSessionTerminated: {
                //data.text = data.text + "Session closed.\n\n"
            }
        }
        //![connections]
    }
Rectangle{
    id: logoContainer
    anchors.top: spacer3.bottom
    //width: Screen.width
    Image {
        id: logoImage
        //anchors.fill: logoContainer
        width: Screen.width
        height: Screen.height/1.8
        horizontalAlignment: parent.horizontalCenter
        source: "qrc:/new/prefix1/EHB-LOGO-SID-IN-APP.png"
    }

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


