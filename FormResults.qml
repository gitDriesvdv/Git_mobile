import QtQuick 2.0
import QtQuick 2.1
import Enginio 1.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.1
import "qrc:/FormResultFuntions.js" as Logic
import QtQuick.Window 2.0
Rectangle{
    height: Screen.height
    width: Screen.width
    anchors.fill: parent
    property var fieldnames: [];
    property var ids: [];
    property var sortedItems: [];

    EnginioClient {
        id: enginioClientLog
        backendId: "54be545ae5bde551410243c3"
        onError: {
        enginioModelErrors.append({"Error": "Enginio" + reply.errorCode + ": " + reply.errorString + "\n\n", "User": "Admin"})
        }
    }
    EnginioModel {
        id: enginioModelErrors
        client: enginioClientLog
        query: {
            "objectType": "objects.Errors"
        }
    }
    Rectangle{
        id: resultlist
        height: 400
        width: 800
        Component.onCompleted: {
            getData(settings.current_form)
        }


        ListModel{
            id:listmodel
        }

    TableView{
        id: primaireTableView
        width: Screen.width
        height: Screen.height
        model:listmodel
        onClicked: {
            console.log(listmodel.get(row).source);
        }
    }
    }
    function getData(formname_input) {
        var xmlhttp = new XMLHttpRequest();

        var url = "https://api.engin.io/v1/objects/resultforms";

        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var arr = JSON.parse(xmlhttp.responseText);
                var arr1 = arr.results;
                for(var i = 0; i < arr1.length; i++) {
                    console.log(arr1[i].sessionID);
                    createFieldnamesList(arr1[i].fieldname)
                    createIdsList(arr1[i].sessionID)
                    var a = {"fieldname":arr1[i].fieldname, "input":arr1[i].input,"type":arr1[i].type,"list":arr1[i].list};
                    finaliseList(arr1[i].sessionID,a);
                }
                fillTable();
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

    //bron:http://openstackwiki.org/wiki/QML_TableView_mit_dynamischer_Spaltenanzahl
    function addColumnToTable(roleName) {
        var columnString = 'import QtQuick 2.3; import QtQuick.Controls 1.2; TableViewColumn {role: "'
                + roleName + '"; title: "' + roleName + '"; width: 100}';
        var column = Qt.createQmlObject(
                    columnString
                    , primaireTableView
                    , "dynamicSnippet1")
        primaireTableView.addColumn(column);
    }

    //fieldnames uithalen
    function createFieldnamesList(input)
    {
        if(input !== "")
        {
        if(fieldnames.length == 0)
        {
            fieldnames.push(input)
            addColumnToTable(input)
            return true;
        }
        else
        {
            for(var i = 0; i < fieldnames.length;i++)
            {
                if(fieldnames[i] === input)
                {
                    return false;
                }
            }
            fieldnames.push(input)
            addColumnToTable(input)
            return true;
        }
        }
    }
    //ids uithalen
    function createIdsList(input)
    {
        if(input !== "")
        {
        if(ids.length == 0)
        {
            var a = {"id":input,"lijst":[]}
            ids.push(a)
            return true;
        }
        else
        {
            for(var i = 0; i < ids.length;i++)
            {
                if(ids[i].id === input)
                {
                    return false;
                }
            }
            var b = {"id":input,"lijst":[]}
            ids.push(b)
            return true;
        }
        }
    }
    function finaliseList(id,input)
    {
        var a = input;
        for(var i = 0; i < ids.length;i++)
        {
            if(ids[i].id === id)
            {
                ids[i].lijst.push(a);
            }
        }
    }

    function fillTable()
    {
        for(var i = 0; i < ids.length;i++)
        {
            var samenstelling = {};
            for(var y = 0; y < ids[i].lijst.length;y++)
            {
                if(ids[i].lijst[y].type == "CheckBox")
                 {
                    samenstelling[ids[i].lijst[y].fieldname] = ids[i].lijst[y].list;
                }
                else{
                   samenstelling[ids[i].lijst[y].fieldname] = ids[i].lijst[y].input;
                }
            }
            listmodel.append(samenstelling);
        }
    }
}
