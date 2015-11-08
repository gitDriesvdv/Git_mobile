import QtQuick 2.0
import QtQuick.Layouts 1.1
import Enginio 1.0
import QtQuick.Dialogs 1.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0

Rectangle {
    width: Screen.width
    height: Screen.height
    color: "white"

    property variant aInputFormArray: [];
    property variant aCheckboxArray: [];
    property string aSessionID: "";

    //test
    EnginioClient {
        id: client
        backendId: "54be545ae5bde551410243c3"
        onError:
        {
         console.log("Enginio error: " + reply.errorCode + ": " + reply.errorString)
         enginioModelErrors.append({"Error": "Enginio " + reply.errorCode + ": " + reply.errorString + "\n\n", "User": "Admin"})
        }
    }

    EnginioModel {
        id: enginioModel
        client: client
        query: {
            "objectType": "objects.Form",
            "query" : { "User": "Dries", "FormName" : "azerty"},
            "sort" : [ {"sortBy": "indexForm", "direction": "asc"} ]
        }
    }
    EnginioModel {
        id: enginioModelResult
        client: client
        query: {
            "objectType": "objects.resultforms"

        }
    }

    //FormName
    Rectangle{
        width: parent.width
        height: parent.height
        color: "white"
        Component.onCompleted: aSessionID = generateUUID();


            Component {
                id: listDelegate
                Item {
                    id: item_list
                    width: Screen.width - 50 ;
                    height: Screen.height/heightItem_mobile //heightItem_mobile

                    Column{
                        id: col
                        width: parent.width
                        x: 10;

                                spacing: 20
                                Rectangle {
                                    width: parent.width;
                                    height: Screen.height/(heightItem_mobile + 12);
                                    color: "white"
                                    x: 20

                                    Label {
                                        id: name_component
                                        width: parent.width/2 ;
                                        text: Name
                                    }

                                }
                                Rectangle {
                                    id: item1
                                    visible: Type == "TextField"
                                    x: 20
                                    //y: 20
                                    width: parent.width;
                                    height: Screen.height/(heightItem_mobile + 9)//heightItem_mobile;
                                    color: "white"
                                TextField {
                                    height: Screen.height/(heightItem_mobile + 10)//heightItem_mobile/0.5
                                    font.pointSize: 15
                                    width: parent.width;
                                    id: textfield_item
                                    onTextChanged: push_aInputFormArray(Name,textfield_item.text,List,Type)

                                }
                                }

                                Rectangle {
                                    width: parent.width;
                                    color: "white"
                                    height: Screen.height/(heightItem_mobile + 4)
                                    id: item2
                                    visible: Type == "TextArea"
                                    x: 20
                                    //y: 10
                                TextArea {
                                    height: Screen.height/(heightItem_mobile + 4.5)
                                    width: parent.width;
                                    font.pointSize: 15
                                    id: textarea_item
                                    onTextChanged: push_aInputFormArray(Name,textarea_item.text,List,Type)

                                }
                                }
                    /*
                        Checkbox nog niet werkend. Een listview nog aan koppelen om meerdere weer te geven.
                        Idem maken voor radiobuttons
                    */

                                Rectangle {
                                    width: parent.width;
                                    color: "gray"
                                    height: Screen.height/(heightItem_mobile + 4)
                                    id: item4
                                    visible: Type == "CheckBox"
                                    x: 20

                                    ScrollView {
                                        width: Screen.width; height: Screen.height/(heightItem_mobile + 6)

                                    Column{
                                        id: columnCheckbox
                                        spacing: 20
                                        width: parent.width
                                    Repeater {
                                            id: rep
                                            model: List
                                            Component.onCompleted: {
                                                if(item4.visible == true)
                                                createArrayInCheckboxArray(Name)
                                            }
                                            Row{
                                                spacing: 5

                                            CheckBox {
                                                height: Screen.height/(heightItem_mobile + 15)
                                                id: checkbox_item
                                                text: modelData
                                                //onClicked:

                                                onClicked: {
                                                    if(checkbox_item.checked == true)
                                                    {
                                                        console.log("Checked");
                                                         push_aCheckboxArray(Name,checkbox_item.text);

                                                    }
                                                    else
                                                    {
                                                        console.log("niet meer checked");
                                                         pop_aCheckboxArray(Name,checkbox_item.text);
                                                    }
                                                    push_aInputFormArray(Name,"",extend_singleArray(Name),Type)
                                                }
                                            }



                                            }
                                    }
                                    }
                                }

                                }
                                Rectangle {
                                    height: Screen.height/(heightItem_mobile + 6)
                                    width: parent.width
                                    id: item3
                                    visible: qsTr(Type) === "ComboBox"
                                    x: 20
                                    color: "white"
                                Text{
                                    id: containerID
                                    text: id
                                    visible: false
                                }
                                ComboBox {
                                    height: Screen.height/(heightItem_mobile + 8)
                                    id: combobox_item
                                    width: parent.width
                                    model: List
                                    onCurrentIndexChanged: push_aInputFormArray(Name,combobox_item.currentText,List,Type)//combobox_item.currentText
                                    Component.onCompleted:{
                                        if(item3.visible == true)
                                        {
                                            push_aInputFormArray(Name,combobox_item.currentText,List,Type)}

                                        }

                                        }

                                }

                                Rectangle {
                                                height: 1
                                                width: parent.width
                                                color: "white"
                                            }

                    }
                }
            }

                ListView {
                    id: formListView
                    model: enginioModel
                    delegate: listDelegate
                    clip: true
                    y: 20
                    visible: true
                    width: Screen.width
                    height: Screen.height - (actionbar.height*2)

                    // Animations
                    add: Transition { NumberAnimation { properties: "y"; from: root.height; duration: 250 } }
                    removeDisplaced: Transition { NumberAnimation { properties: "y"; duration: 150 } }
                    remove: Transition { NumberAnimation { property: "opacity"; to: 0; duration: 150 } }


                }

                Rectangle{
                    id: actionbar
                    color: "gray"
                    width: Screen.width //- grid.width
                    height: 150
                    //y:0
                    visible: true;
                    anchors.top: formListView.bottom
                    Row{
                        id: rowActionbar
                        height :parent.height
                        x:0
                        width: parent.width //- grid.width
                        spacing: 20;
                     Button{
                         id: swapBUtton
                         anchors.verticalCenter: rowActionbar.verticalCenter
                         text: "Send";
                         width: parent.width;
                         height: parent.height;
                         visible: true
                         onClicked: {
                             writetoDatabase()
                         }
                     }

                    }
                }

    }


    function push_aInputFormArray(fieldname,input,list,type)
    {
        var user = "Dries";
        var formname = "azerty";

            for (var i =0; i < aInputFormArray.length; i++)
               if (aInputFormArray[i].fieldname === fieldname) {
                  aInputFormArray.splice(i,1);
                  break;
               }

            var a = {"user":user,"sessionID":aSessionID,"fieldname": fieldname, "formname":formname, "input":input,"list":list, "type":type};
            aInputFormArray.push(a);
    }

    function writetoDatabase()
    {
        for (var i =0; i < aInputFormArray.length; i++)
           {
            if(aInputFormArray[i].type !== "CheckBox")
             {
                var result = {
                       "objectType": "objects.resultforms",
                       "sessionID": aInputFormArray[i].sessionID,
                       "fieldname": aInputFormArray[i].fieldname,
                       "formname" : aInputFormArray[i].formname,
                       "input" : aInputFormArray[i].input,
                       "list" : null,
                       "type" : aInputFormArray[i].type,
                       "user" : aInputFormArray[i].user
                   }
                enginioModelResult.append(result);
             }
            else
            {
                /*var arrayList = [];
                for (var z =0; z < aInputFormArray[i].list.length; z++)
                   {
                    arrayList.push(aInputFormArray[i].list[z]);
                   }*/
                var resultCheckbox = {
                       "objectType": "objects.resultforms",
                       "sessionID": aInputFormArray[i].sessionID,
                       "fieldname": aInputFormArray[i].fieldname,
                       "formname" : aInputFormArray[i].formname,
                       "input" : aInputFormArray[i].input,
                       "list" : aInputFormArray[i].list.toString(),
                       "type" : aInputFormArray[i].type,
                       "user" : aInputFormArray[i].user
                   }
                enginioModelResult.append(resultCheckbox);
            }
           }
    }

   //bron : http://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript

    function createSessionID()
    {
      var lut = [];
      for (var i=0; i<256; i++) { lut[i] = (i<16?'0':'')+(i).toString(16); }

      var d0 = Math.random()*0xffffffff|0;
      var d1 = Math.random()*0xffffffff|0;
      var d2 = Math.random()*0xffffffff|0;
      var d3 = Math.random()*0xffffffff|0;
      console.log(lut[d0&0xff]+lut[d0>>8&0xff]+lut[d0>>16&0xff]+lut[d0>>24&0xff]+'-'+
                  lut[d1&0xff]+lut[d1>>8&0xff]+'-'+lut[d1>>16&0x0f|0x40]+lut[d1>>24&0xff]+'-'+
                  lut[d2&0x3f|0x80]+lut[d2>>8&0xff]+'-'+lut[d2>>16&0xff]+lut[d2>>24&0xff]+
                  lut[d3&0xff]+lut[d3>>8&0xff]+lut[d3>>16&0xff]+lut[d3>>24&0xff]);
      return lut[d0&0xff]+lut[d0>>8&0xff]+lut[d0>>16&0xff]+lut[d0>>24&0xff]+'-'+
        lut[d1&0xff]+lut[d1>>8&0xff]+'-'+lut[d1>>16&0x0f|0x40]+lut[d1>>24&0xff]+'-'+
        lut[d2&0x3f|0x80]+lut[d2>>8&0xff]+'-'+lut[d2>>16&0xff]+lut[d2>>24&0xff]+
        lut[d3&0xff]+lut[d3>>8&0xff]+lut[d3>>16&0xff]+lut[d3>>24&0xff];
    }

    //bron: http://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
    function generateUUID(){
        var d = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (d + Math.random()*16)%16 | 0;
            d = Math.floor(d/16);
            return (c=='x' ? r : (r&0x3|0x8)).toString(16);
        });
        return uuid;
    }
    function createArrayInCheckboxArray(naam)
    {
        var a = {"Name": naam, "List":[]};
        aCheckboxArray.push(a);
        console.log(naam);
    }

    function push_aCheckboxArray(naam,input)
    {
        for (var i =0; i < aCheckboxArray.length; i++)
           if (aCheckboxArray[i].Name === naam) {
              aCheckboxArray[i].List.push(input);
           }


    }

    function pop_aCheckboxArray(naam,input)
    {
        for (var i =0; i < aCheckboxArray.length; i++)
           if (aCheckboxArray[i].Name === naam) {
              aCheckboxArray[i].List.splice(i,1);
              break;
           }
    }

    function extend_singleArray(naam)
    {
        var arrayList = [];
        for (var i =0; i < aCheckboxArray.length; i++)
           if (aCheckboxArray[i].Name === naam) {
              arrayList = aCheckboxArray[i].List;
           }
        return arrayList;
    }
}





