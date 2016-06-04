import QtQuick 2.1
import Enginio 1.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0
//login pagina
//Bron: The Qt Company, http://doc.qt.io/archives/qt-5.5/enginio-qml-users-example.html
Rectangle {
    id:rec
    width: Screen.width

    //achtergrond image
    //Bron:Michal Parulski,https://www.pinterest.com/pin/338825571947355848/
    Image
    {
        id: background
        source: "qrc:/new/prefix1/loginAndroidApp.jpg"
        anchors.fill: parent
    }

    //gebruikt om de authenticatie af te handelen. Steeds de gebruikersnaam en het wachtwoord meegeven.
    EnginioOAuth2Authentication {
        id: identity
        user: login.text
        password: password.text
    }

    //hier wordt gebruik gemaakt van settings die gedurende de duur van de applicatie zal onthouden worden
    Settings {
           id: settings
           property string username: ""
           property string current_form: ""
       }

    anchors.fill: parent
    anchors.margins: 3

    //invoer van de gebruikersnaam.
    TextField {
        id: login
        Layout.fillWidth: true
        y: 720
        x: 250
        placeholderText: "Username"
        enabled: enginioClient.authenticationState == Enginio.NotAuthenticated
        style: TextFieldStyle {
                textColor: "black"
                background: Rectangle {
                    radius: 0
                    border.color: "transparent"
                    border.width: 0
                }
            }
    }

    Rectangle{
        id: spacer
        width: Screen.width
        height: 170
        color: "transparent"
         anchors.top: login.bottom
    }

    //invoer van het wachtwoord
    TextField {
        id: password
        anchors.top: spacer.bottom
        Layout.fillWidth: true
        x: 250
        placeholderText: "Password"
        echoMode: TextInput.PasswordEchoOnEdit
        style: TextFieldStyle {
                textColor: "black"
                background: Rectangle {
                    radius: 0
                    border.color: "transparent"
                    border.width: 0
                }
            }
        enabled: enginioClient.authenticationState == Enginio.NotAuthenticated
    }

    Rectangle{
        id: spacer2
        width: Screen.width
        height: 200
        color: "transparent"
         anchors.top: password.bottom
    }
    Button {
        anchors.top: spacer2.bottom
        id: proccessButton
        y : 200
        x: 140
        Layout.fillWidth: true
        style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 800
                    implicitHeight: 200
                    color: "white"
                    border.width: 5
                    border.color: "orange"
                    radius: 9

                    gradient: Gradient {
                        GradientStop { position: 0 ; color: control.pressed ? "orange" : "orange" }
                        GradientStop { position: 1 ; color: control.pressed ? "orange" : "orange" }
                    }
                }
            }
    }

    Rectangle{
        id: spacer3
        width: Screen.width
        height: 80
        color: "transparent"
         anchors.top: proccessButton.bottom
    }
    //Weergeven van een bericht indien de login niet succesvol is
    TextArea {
        id: data
        text: "Not logged in.\n\n"
        readOnly: true
        visible: false
        Layout.fillHeight: true
        Layout.fillWidth: true

        Connections {
            target: enginioClient
            onSessionAuthenticated: {
                data.text = data.text + "User '"+ login.text +"' is logged in.\n\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n"
                settings.username = login.text;

                //Navigeren naar de lijst met formulieren waar de gebruiker toegang tot heeft.
                var component = Qt.createComponent("MyFormsFinal.qml")
                if (component.status === Component.Ready) {
                var window    = component.createObject(main);
                window.show()
            }
            }
            onSessionAuthenticationError: {
                var arr = JSON.stringify(reply.data);
                var arr1 = arr.error
                data.text = "Authentication failed"
            }
            onSessionTerminated: {
                //data.text = data.text + "Session closed.\n\n"
            }
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
                    enginioClient.identity = identity
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
                    enginioClient.identity = null
                }
            }
        }
    ]
}


