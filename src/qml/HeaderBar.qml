/**
 * SPDX-FileCopyrightText: 2021 Swapnil Tripathi <swapnil06.st@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Layouts 1.14
import QtMultimedia 5.15
import QtGraphicalEffects 1.15

import org.kde.kirigami 2.14 as Kirigami

import org.kde.kasts 1.0

Rectangle {
    id: headerBar
    implicitHeight: headerRowLayout.implicitHeight
    implicitWidth: headerRowLayout.implicitWidth

    //set background color
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Header
    color: Kirigami.Theme.backgroundColor

    RowLayout {
        id: headerRowLayout
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing
        ImageWithFallback {
            id: mainImage
            imageSource: AudioManager.entry ? AudioManager.entry.cachedImage : "no-image"
            height: controlsLayout.height
            width: height
            absoluteRadius: 5
            Layout.leftMargin: Kirigami.Units.largeSpacing
        }
        ColumnLayout {
            id: controlsLayout
            Layout.fillWidth: true
            RowLayout {
                Layout.rightMargin: Kirigami.Units.largeSpacing
                ColumnLayout {
                    Kirigami.Heading {
                        text: AudioManager.entry ? AudioManager.entry.title : i18n("No Track Title")
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignLeft
                        level: 3
                        // wrapMode: Text.Wrap
                        // maximumLineCount: 2
                        font.bold: true
                    }
                    Controls.Label {
                        text: AudioManager.entry ? AudioManager.entry.feed.name : i18n("No Track Loaded")
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        //wrapMode: Text.Wrap
                        //maximumLineCount: 1
                        horizontalAlignment: Text.AlignLeft
                        opacity: 0.6
                        Layout.bottomMargin: Kirigami.Units.largeSpacing
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                RowLayout {
                    property int iconSize: Kirigami.Units.gridUnit
                    property int buttonSize: playButton.implicitWidth
                    Controls.ToolButton {
                        contentItem: Controls.Label {
                            text: AudioManager.playbackRate + "x"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: playbackRateDialog.open()
                        Layout.alignment: Qt.AlignHCenter
                        padding: 0
                        implicitWidth: playButton.width * 2
                        implicitHeight: playButton.height

                        Controls.ToolTip.visible: hovered
                        Controls.ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                        Controls.ToolTip.text: i18n("Playback Rate: ") + AudioManager.playbackRate + "x"

                    }
                    Controls.ToolButton {
                        icon.name: "media-seek-backward"
                        icon.height: parent.iconSize
                        icon.width: parent.iconSize
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.buttonSize
                        onClicked: AudioManager.skipBackward()
                        enabled: AudioManager.canSkipBackward

                        Controls.ToolTip.visible: hovered
                        Controls.ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                        Controls.ToolTip.text: i18n("Seek Backward")

                    }
                    Controls.ToolButton {
                        id: playButton
                        icon.name: AudioManager.playbackState === Audio.PlayingState ? "media-playback-pause" : "media-playback-start"
                        icon.height: parent.iconSize
                        icon.width: parent.iconSize
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.buttonSize
                        onClicked: AudioManager.playbackState === Audio.PlayingState ? AudioManager.pause() : AudioManager.play()
                        enabled: AudioManager.canPlay

                        Controls.ToolTip.visible: hovered
                        Controls.ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                        Controls.ToolTip.text: AudioManager.playbackState === Audio.PlayingState ? i18n("Pause") : i18n("Play")

                    }
                    Controls.ToolButton {
                        icon.name: "media-seek-forward"
                        icon.height: parent.iconSize
                        icon.width: parent.iconSize
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.buttonSize
                        onClicked: AudioManager.skipForward()
                        enabled: AudioManager.canSkipForward

                        Controls.ToolTip.visible: hovered
                        Controls.ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                        Controls.ToolTip.text: i18n("Seek Forward")
                    }
                    Controls.ToolButton {
                        icon.name: "media-skip-forward"
                        icon.height: parent.iconSize
                        icon.width: parent.iconSize
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.buttonSize
                        onClicked: AudioManager.next()
                        enabled: AudioManager.canGoNext

                        Controls.ToolTip.visible: hovered
                        Controls.ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                        Controls.ToolTip.text: i18n("Skip Forward")

                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Controls.Label {
                    text: AudioManager.formattedPosition
                }
                Controls.Slider {
                    id: durationSlider
                    enabled: AudioManager.entry
                    Layout.fillWidth: true
                    padding: 0
                    from: 0
                    to: AudioManager.duration
                    value: AudioManager.position
                    onMoved: AudioManager.seek(value)
                }

                Item {
                    Layout.preferredHeight: endLabel.implicitHeight
                    Layout.preferredWidth: endLabel.implicitWidth
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Controls.Label {
                        id: endLabel
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: (SettingsManager.toggleRemainingTime) ?
                                "-" + AudioManager.formattedLeftDuration
                                : AudioManager.formattedDuration

                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: SettingsManager.toggleRemainingTime = !SettingsManager.toggleRemainingTime
                    }
                }
            }
        }
    }
}
