import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog

    property string topicid
    property string post_number
    property string username
    property string postid
    property string raw
    property string loggedin

    function findFirstPage() {
        return pageStack.find(function(page) { return page.hasOwnProperty('loadmore'); });
    }

    function getraw(postid){
        var xhr = new XMLHttpRequest;
        xhr.open("GET", "https://forum.sailfishos.org/posts/" + postid + ".json");
        xhr.setRequestHeader("User-Api-Key", loggedin);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){   var data = JSON.parse(xhr.responseText);
                raw = data["raw"];
                if(username){
                    postbody.text = "[quote=\"" + username +", post:" + post_number + ", topic:" + topicid +"\"]\n" + raw + "\n[/quote]\n";
                } else {
                    postbody.text = raw;
                }
                return raw;
            }
        }
        xhr.send();
    }
    canAccept: postbody.text.length >19

    onAccepted: {
        if(username){
            findFirstPage().replytopost(postbody.text, topicid, post_number);
        } else if (!postid){
            findFirstPage().reply(postbody.text, topicid);
        } else {
            findFirstPage().edit(postbody.text, postid);
        }
    }
    SilicaFlickable{
        id: flick
        anchors.fill: parent

        PullDownMenu{
            visible: postid

            MenuItem{
                text: qsTr("Insert quote")
                onClicked: getraw(postid)
            }
        }

        PageHeader {
            id: pageHeader
            title: username ? qsTr("Enter post") : !postid ? qsTr("Enter post") : qsTr("Edit post");
        }
        TextArea {
            id: postbody
            text: raw
            anchors.top: pageHeader.bottom
            width: parent.width

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            softwareInputPanelEnabled: true
            placeholderText: qsTr("Body");


        }

    }
    //Component.onCompleted: getraw(postid);
}
