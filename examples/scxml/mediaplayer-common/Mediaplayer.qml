// Copyright (C) 2016 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Window
import QtScxml

Window {
    id: root
    property StateMachine stateMachine: scxmlLoader.stateMachine
    property alias source: scxmlLoader.source

    visible: true
    width: 750
    height: 350
    color: "white"

    ListView {
        id: theList
        width: parent.width / 2
        height: parent.height
        keyNavigationWraps: true
        highlightMoveDuration: 0
        focus: true
        model: ListModel {
            id: theModel
            ListElement { media: "Song 1" }
            ListElement { media: "Song 2" }
            ListElement { media: "Song 3" }
        }
        highlight: Rectangle { color: "lightsteelblue" }
        currentIndex: -1
        delegate: Rectangle {
            height: 40
            width: parent.width
            color: "transparent"
            MouseArea {
                anchors.fill: parent;
                onClicked: tap(index)
            }
            Text {
                id: txt
                anchors.fill: parent
                text: media
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Text {
        id: theLog
        anchors.left: theList.right
        anchors.top: theText.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    Text {
        id: theText
        anchors.left: theList.right
        anchors.right: parent.right;
        anchors.top:  parent.top
        text: "Stopped"
        color: stateMachine.playing ? "green" : "red"
    }

    StateMachineLoader {
        id: scxmlLoader
    }

    EventConnection {
        stateMachine: root.stateMachine
        events: ["playbackStarted", "playbackStopped"]
        onOccurred: (event)=> {
            var media = event.data.media;
            if (event.name === "playbackStarted") {
                theText.text = "Playing '" + media + "'";
                theLog.text = theLog.text + "\nplaybackStarted with data: "
                                          + JSON.stringify(event.data);
            } else if (event.name === "playbackStopped") {
                theText.text = "Stopped '" + media + "'";
                theLog.text = theLog.text + "\nplaybackStopped with data: "
                                          + JSON.stringify(event.data);
            }
        }
    }

    // Submit tap event to state machine.
    // "tap" toggles playing state of the current media.
    function tap(idx) {
        var media = theModel.get(idx).media;
        var data = { "media": media };
        stateMachine.submitEvent("tap", data);
    }
}
