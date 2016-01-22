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
    color: "gray"

    property variant aInputFormArray: [];
    property variant aCheckboxArray: [];
    property string aSessionID: "";
    property string aErrorMessage: "";

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
            "query" : { "User": settings.username, "FormName" : settings.current_form},
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
        color: "gray"
        Component.onCompleted: aSessionID = generateUUID();


            Component {
                id: listDelegate
                Item {
                    id: item_list
                    width: Screen.width - 50 ;
                    height: Screen.height/heightItem_mobile//+ 40
                    Column{
                        id: col
                        width: parent.width
                        x: 10;
                                spacing: 10
                                Rectangle {
                                    width: parent.width;
                                    height: 45;
                                    color: "gray"
                                    x: 20
                                    Label {
                                        id: name_component
                                        width: parent.width/2 ;
                                        text: req === true ? Name + "*": Name
                                    }
                                }
                                Rectangle {
                                    id: itemAdress
                                    visible: Type == "Adress"
                                    x: 20
                                    width: parent.width;
                                    height: Screen.height/(heightItem_mobile)
                                    color: "gray"
                                    //autocomplete
                                    Rectangle {
                                        id: autocomplete_adress
                                        width: parent.width;
                                        //height: 100
                                        anchors.fill: parent
                                        color: "gray"
                                        TextField{
                                            id: textfield_autocomplete
                                            width: parent.width;
                                            height: Screen.height/(heightItem_mobile + 17)
                                            placeholderText: "autocomplete"                                            
                                            onTextChanged: {
                                                model.clear();
                                                var xmlhttp = new XMLHttpRequest();
                                                var url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input="+ textfield_autocomplete.text +"&types=address&language=nl&components=country:be&key=AIzaSyAlaSiDm2B3v_xwLhfguwONmNzMrj3ffrc"

                                                xmlhttp.onreadystatechange=function() {
                                                    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                                                        var arr = JSON.parse(xmlhttp.responseText);
                                                        var arr1 = arr.predictions;
                                                        for(var i = 0; i < arr1.length; i++) {
                                                            listview.model.append( {listdata: arr1[i].description,
                                                                                      listdata1: arr1[i].place_id})
                                                        }
                                                    }
                                                }
                                                xmlhttp.open("GET", url, true);
                                                xmlhttp.send();
                                            }
                                        }

                                        ListModel {
                                            id: model
                                        }

                                        Component {
                                                id: listDelegate
                                                Item {
                                                width: Screen.width; height: 60
                                                Rectangle{

                                                    anchors.fill: parent
                                                    Text {
                                                        id: text1
                                                        text: listdata
                                                    }
                                                    Text {
                                                        id : text2
                                                        visible: false
                                                        anchors.top: text1.bottom
                                                        text: listdata1
                                                    }
                                                    MouseArea{
                                                        id: mousearea2
                                                                        anchors.fill: parent
                                                                        onClicked: {
                                                                            var mySplitResult = listdata.split(",");
                                                                            textfield_street.text = mySplitResult[0];
                                                                            textfield_place.text = mySplitResult[1];
                                                                            textfield_country.text = mySplitResult[2];
                                                                            var xmlhttp = new XMLHttpRequest();
                                                                            var url = "https://maps.googleapis.com/maps/api/place/details/json?placeid="+ text2.text +"&key=AIzaSyAlaSiDm2B3v_xwLhfguwONmNzMrj3ffrc"

                                                                            xmlhttp.onreadystatechange=function() {
                                                                                if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                                                                                    var arr = JSON.parse(xmlhttp.responseText);
                                                                                    var arr1 = arr.result;
                                                                                    var arr2 = arr1.address_components;
                                                                                    for(var i = 0; i < arr2.length; i++) {
                                                                                        if(arr2[i].types == "postal_code")
                                                                                        {
                                                                                             textfield_postcode.text = arr2[i].long_name;
                                                                                        }
                                                                                        if(arr2[i].types[0] == "administrative_area_level_2")
                                                                                        {
                                                                                             textfield_state.text = arr2[i].long_name;
                                                                                        }
                                                                                    }
                                                                                    textfield_autocomplete.text = "";
                                                                                    console.log(xmlhttp.responseText);
                                                                                }
                                                                            }
                                                                            xmlhttp.open("GET", url, true);
                                                                            xmlhttp.send();
                                                                        }
                                                    }
                                                }
                                                }
                                            }

                                        ListView {
                                            id: listview
                                            height: 300
                                            width: 500
                                            anchors.top: textfield_autocomplete.bottom
                                            model: model
                                            delegate: listDelegate
                                            visible: textfield_autocomplete.length > 0 ? true : false
                                            z: 1
                                        }
                                    //straat + nummer
                                TextField {
                                    height: Screen.height/(heightItem_mobile + 17)
                                    anchors.top: textfield_autocomplete.bottom
                                    font.pixelSize: 15
                                    width: parent.width;
                                    id: textfield_street
                                    onTextChanged: push_aInputFormArray("StreetNr",textfield_street.text,List,Type,req)
                                    Component.onCompleted: {
                                        if(itemAdress.visible === true)
                                        {
                                        init_aInputFormArray("StreetNr",textfield_street.text,List,Type,req);
                                        }
                                    }
                                }
                                Text{
                                    id: text_streetname
                                    height: 20
                                    text:qsTr("streetname + number")
                                    width: parent.width/2.5;
                                    font.pixelSize :20
                                    anchors.top: textfield_street.bottom
                                    color: "white"
                                }

                                //plaats
                                TextField {
                                    height: Screen.height/(heightItem_mobile + 17)
                                    font.pixelSize: 15
                                    width: parent.width/2;
                                    id: textfield_place
                                    anchors.top: text_streetname.bottom
                                    onTextChanged: push_aInputFormArray("Place",textfield_place.text,List,Type,req)
                                    Component.onCompleted: {
                                        if(itemAdress.visible === true)
                                        {
                                        init_aInputFormArray("Place",textfield_place.text,List,Type,req);
                                        }
                                    }
                                }
                                Text{
                                    id: text_place
                                    height: 20
                                    text:qsTr("place")
                                    width: parent.width/2;
                                    font.pixelSize :20
                                    anchors.top: textfield_place.bottom
                                    color: "white"
                                }

                                //staat
                                TextField {
                                    height: Screen.height/(heightItem_mobile + 17)
                                    font.pixelSize: 15
                                    width: parent.width/2;
                                    id: textfield_state
                                    anchors.top: text_streetname.bottom
                                    anchors.left: textfield_place.right
                                    onTextChanged: push_aInputFormArray("State",textfield_state.text,List,Type,req)
                                    Component.onCompleted: {
                                        if(itemAdress.visible === true)
                                        {
                                        init_aInputFormArray("State",textfield_state.text,List,Type,req);
                                        }
                                    }
                                }
                                Text{
                                    id: text_state
                                    height: 20
                                    text:qsTr("State")
                                    font.pixelSize :20
                                    anchors.top: textfield_state.bottom
                                    anchors.left: text_place.right
                                    color: "white"
                                }

                                //postcode
                                TextField {
                                    height: Screen.height/(heightItem_mobile + 17)
                                    font.pixelSize: 35
                                    width: parent.width/2;
                                    id: textfield_postcode
                                    anchors.top: text_state.bottom
                                    onTextChanged: push_aInputFormArray("Postcode",textfield_postcode.text,List,Type,req)
                                    Component.onCompleted: {
                                        if(itemAdress.visible === true)
                                        {
                                        init_aInputFormArray("Postcode",textfield_postcode.text,List,Type,req);
                                        }
                                    }
                                }
                                Text{
                                    id: text_postcode
                                    height: 20
                                    width: parent.width/2;
                                    text:qsTr("zip code")
                                    font.pixelSize :20
                                    anchors.top: textfield_postcode.bottom
                                    color: "white"
                                }

                                //land
                                TextField {
                                    height: Screen.height/(heightItem_mobile + 17)
                                    font.pixelSize: 35
                                    width: parent.width/2;
                                    id: textfield_country
                                    anchors.top: text_state.bottom
                                    anchors.left: textfield_postcode.right
                                    onTextChanged: push_aInputFormArray("Country",textfield_country.text,List,Type,req)
                                    Component.onCompleted: {
                                        if(itemAdress.visible === true)
                                        {
                                        init_aInputFormArray("Country",textfield_country.text,List,Type,req);
                                        }
                                    }
                                }
                                Text{
                                    id: text_country
                                    height: 20
                                    text:qsTr("country")
                                    font.pixelSize :20
                                    anchors.top: textfield_country.bottom
                                    anchors.left: text_postcode.right
                                    color: "white"
                                }
              /////////////////////////////////////
                                }
              /////////////////////////////////////
                                }

                                Rectangle {
                                    id: itemFullName
                                    visible: Type == "ComplexType"
                                    x: 20
                                    width: parent.width;
                                    height: Screen.height/(heightItem_mobile + 6)
                                    color: "gray"

                                TextField {
                                    height: Screen.height/(heightItem_mobile + 17)
                                    font.pixelSize: 15
                                    width: parent.width/2;
                                    id: textfield_firstname
                                    onTextChanged: push_aInputFormArray("First Name",textfield_firstname.text,List,Type,req)
                                    Component.onCompleted: {
                                        if(itemFullName.visible === true)
                                        {
                                        init_aInputFormArray("First Name",textfield_firstname.text,List,Type,req);
                                        }
                                    }
                                }
                                Text{
                                    id: text_firstname
                                    //height: 7
                                    text:qsTr("first name")
                                    width: parent.width/2;
                                    anchors.top: textfield_firstname.bottom
                                    color: "white"
                                    font.pixelSize :20
                                }

                                TextField {
                                    height: Screen.height/(heightItem_mobile + 17)
                                    font.pixelSize: 15
                                    width: parent.width/2;
                                    id: textfield_lastname
                                    anchors.left: textfield_firstname.right
                                    onTextChanged: push_aInputFormArray("Last Name",textfield_lastname.text,List,Type,req)
                                    Component.onCompleted: {
                                        if(text_firstname.visible === true)
                                        {
                                        init_aInputFormArray("Last Name",textfield_lastname.text,List,Type,req);
                                        }
                                    }

                                }
                                Text{
                                    //height: 10
                                    text:qsTr("last name")
                                    anchors.top: textfield_lastname.bottom
                                    anchors.left: text_firstname.right
                                    color: "white"
                                    font.pixelSize :20
                                }
                                }
                                Rectangle {
                                    id: itemEmail
                                    visible: Type == "Email"
                                    x: 20
                                    width: parent.width;
                                    height: Screen.height/(heightItem_mobile + 9)
                                    color: "gray"
                                TextField {
                                    height: Screen.height/(heightItem_mobile + 17)
                                    font.pixelSize: 15
                                    width: parent.width;
                                    id: email_item
                                    onTextChanged: push_aInputFormArray(Name,email_item.text,List,Type,req)
                                    Component.onCompleted: {
                                        if(itemEmail.visible === true)
                                        {
                                        init_aInputFormArray(Name,email_item.text,List,Type,req);
                                        }
                                    }
                                }
                                }
                                Rectangle {
                                    id: item1
                                    visible: Type == "TextField"
                                    x: 20
                                    //y: 20
                                    width: parent.width;
                                    height: Screen.height/(heightItem_mobile + 9)
                                    color: "gray"
                                TextField {
                                    font.pixelSize: 15
                                    height: Screen.height/(heightItem_mobile + 17)//heightItem_mobile/0.5
                                    width: parent.width;
                                    id: textfield_item
                                    onTextChanged: push_aInputFormArray(Name,textfield_item.text,List,Type,req)
                                    Component.onCompleted: {
                                        if(item1.visible === true)
                                        {
                                        init_aInputFormArray(Name,textfield_item.text,List,Type,req);
                                        }
                                    }
                                }
                                }

                                Rectangle {
                                    width: parent.width;
                                    color: "gray"
                                    height: Screen.height/(heightItem_mobile + 4)
                                    id: item2
                                    visible: Type == "TextArea"
                                    x: 20
                                TextArea {
                                    height: Screen.height/(heightItem_mobile + 4.5)
                                    font.pixelSize: 15
                                    id: textarea_item
                                    onTextChanged: push_aInputFormArray(Name,textarea_item.text,List,Type,req)
                                    Component.onCompleted: {
                                        if(item2.visible === true)
                                        {
                                        init_aInputFormArray(Name,textarea_item.text,List,Type,req);
                                        }
                                    }
                                }
                                }
                    /*
                        Checkbox nog niet werkend. Een listview nog aan koppelen om meerdere weer te geven.
                        Idem maken voor radiobuttons
                    */
                                Rectangle {
                                    width: parent.width;
                                    color: "gray"
                                    height: Screen.height/(heightItem_mobile + 3)
                                    id: item4
                                    visible: Type == "CheckBox"
                                    x: 20

                                    ScrollView {
                                        width: Screen.width;
                                        height: Screen.height/(heightItem_mobile + 4)

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
                                                spacing: 10

                                            CheckBox {
                                                height: Screen.height/(heightItem_mobile + 15)
                                                id: checkbox_item
                                                text: modelData
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
                                                }
                                            }
                                            }
                                    }
                                    Component.onCompleted: {
                                        if(item4.visible === true)
                                        {
                                        init_aInputFormArray(Name,"",extend_singleArray(Name),Type,req);
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
                                    color: "gray"
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
                                    onCurrentIndexChanged: push_aInputFormArray(Name,combobox_item.currentText,List,Type,req)
                                    Component.onCompleted:{
                                        if(item3.visible == true)
                                        {
                                            init_aInputFormArray(Name,combobox_item.currentText,List,Type,req)}
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

            Rectangle{
                id: header
                anchors.top: parent.top
                width: parent.width
                height: 70
                color: "white"

                Row {
                    id: logo
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: -4
                    spacing: 4

                    Text {
                        text: "Form"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -3
                        font.bold: true
                        font.pixelSize: 46
                        color: "#555"
                    }
                }
                Rectangle {
                    width: parent.width ; height: 1
                    anchors.bottom: parent.bottom
                    color: "#bbb"
                }
            }
                ListView {
                    id: formListView
                    model: enginioModel
                    delegate: listDelegate
                    clip: true
                    //y: 20
                    visible: true
                    width: Screen.width
                    height: Screen.height //- (actionbar.height)
                    //anchors.fill: parent
                    anchors.top : header.bottom
                    anchors.bottom: actionbar.top
                    // Animations
                    add: Transition { NumberAnimation { properties: "y"; from: root.height; duration: 250 } }
                    removeDisplaced: Transition { NumberAnimation { properties: "y"; duration: 150 } }
                    remove: Transition { NumberAnimation { property: "opacity"; to: 0; duration: 150 } }
                }

                Rectangle{
                    id: actionbar
                    color: "gray"
                    width: Screen.width
                    height: Screen.height / 16
                    visible: true;
                    anchors.bottom: parent.bottom
                    Row{
                        id: rowActionbar
                        height :parent.height
                        x:0
                        width: parent.width
                        spacing: 20;
                     Button {
                         id: swapBUtton
                         anchors.verticalCenter: rowActionbar.verticalCenter
                         text: "Send";
                         width: parent.width;
                         height: parent.height;
                         visible: true
                         onClicked: {
                             if(testValidation() !== false)
                             {
                                 messageDialog.text = "Thank you for your info";
                                 messageDialog.visible = true;
                                 writetoDatabase();
                             }
                             else
                             {
                                 messageDialog.visible = true;
                             }
                         }
                     }
                    }
                }
                MessageDialog {
                    id: messageDialog
                    title: "Message"
                    text: ""
                    visible: false
                    onAccepted: {
                        messageDialog.close();
                    }
                }

    }

    function init_aInputFormArray(fieldname,input,list,type,requ)
    {
        var user = settings.username;
        var formname = settings.current_form;

        for (var i =0; i < aInputFormArray.length; i++){
           if  (aInputFormArray[i].fieldname === fieldname) {
              aInputFormArray.splice(i,1);
              break;
           }
        }
            var a = {"user":user,"sessionID":aSessionID,"fieldname": fieldname, "formname":formname, "input":input,"list":list, "type":type,"req":requ};
            console.log("init: " + fieldname +  ":" + input);
            aInputFormArray.push(a);
    }

    function push_aInputFormArray(fieldname,input,list,type,requ)
    {
        var user = "Dries";
        var formname = "azerty";
            for (var i =0; i < aInputFormArray.length; i++){
               if  (aInputFormArray[i].fieldname === fieldname) {
                  aInputFormArray.splice(i,1);
                  break;
               }
            }
            var a = {"user":user,"sessionID":aSessionID,"fieldname": fieldname, "formname":formname, "input":input,"list":list, "type":type,"req":requ};
            if(input !== "" || (type ==="CheckBox" && list.length != 0))
            {
                console.log(fieldname +  ":" + input);
            aInputFormArray.push(a);
            }
    }

    function validateEmail2(email)
    {
        var re = /\S+@\S+\.\S+/;
        return re.test(email);
    }

    function testValidation()
    {
        for (var i =0; i < aInputFormArray.length; i++)
           {
            if(aInputFormArray[i].req === true)
            {
                if(aInputFormArray[i].type == "CheckBox" && aInputFormArray[i].list.length == 0)
                {
                    messageDialog.text = "Fill in all required fields";
                    return false;
                }
                if (aInputFormArray[i].input == "" && aInputFormArray[i].type !== "CheckBox")
                {
                    messageDialog.text = "Fill in all required fields";
                    return false;
                }
            }

            if(aInputFormArray[i].type === "Email" && aInputFormArray[i].type !== "")
             {
                if(validateEmail2(aInputFormArray[i].input) === false)
                {
                    messageDialog.text = "Fill in a valid Email";
                    return false;
                }
            }

        }
        return true;
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
                console.log("Naar database: " + aInputFormArray[i].fieldname)
             }
            else
            {
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
                console.log("Naar database: " + aInputFormArray[i].fieldname)
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
    }

    function push_aCheckboxArray(naam,input)
    {
        for (var i =0; i < aCheckboxArray.length; i++)
           if (aCheckboxArray[i].Name === naam) {
              aCheckboxArray[i].List.push(input);
               extend_singleArray(naam)
           }
    }

    function pop_aCheckboxArray(naam,input)
    {
        for (var i =0; i < aCheckboxArray.length; i++)
           if (aCheckboxArray[i].Name === naam) {
              aCheckboxArray[i].List.splice(i,1);
               extend_singleArray(naam)
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
        for (var z =0; z < aInputFormArray.length; z++){
            if( aInputFormArray[z].fieldname === naam)
            {
            aInputFormArray[z].list = arrayList;
            }

           }
    }
}


