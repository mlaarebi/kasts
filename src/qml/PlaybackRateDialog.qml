/**
 * SPDX-FileCopyrightText: 2021 Swapnil Tripathi <swapnil06.st@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Layouts 1.14

import org.kde.kirigami 2.14 as Kirigami
import org.kde.kasts 1.0

Loader {
    sourceComponent: !Kirigami.Settings.isMobile ? widescreenComponent : narrowComponent

    function open() {
        item.open();
    }
    ListModel {
        id: playbackRateModel
        ListElement {
            name: "0.50x"
            value: 0.50
        }
        ListElement {
            name: "0.75x"
            value: 0.75
        }
        ListElement {
            name: "1x"
            value: 1
        }
        ListElement {
            name: "1.25x"
            value: 1.25
        }
        ListElement {
            name: "1.50x"
            value: 1.50
        }
        ListElement {
            name: "1.75x"
            value: 1.75
        }
        ListElement {
            name: "2x"
            value: 2
        }
        ListElement {
            name: "2.25x"
            value: 2.25
        }
        ListElement {
            name: "2.5x"
            value: 2.5
        }
    }

    Component {
        id: widescreenComponent
        Kirigami.OverlaySheet {
            id: listViewSheet
            header: Kirigami.Heading {
                text: i18n("Set Playback Rate")
            }
            contentItem: ListView {
                id: playbackRateList
                model: playbackRateModel
                implicitWidth: Kirigami.Units.gridUnit * 12
                clip: true
                delegate: Kirigami.SwipeListItem {
                    id: swipeDelegate
                    highlighted: value == AudioManager.playbackRate
                    Controls.Label {
                        text: name
                    }
                    onClicked: {
                        AudioManager.playbackRate = value;
                        close();
                    }
                }
            }
        }
    }

    Component {
        id: narrowComponent
        Kirigami.OverlayDrawer {
            id: drawer
            height: parent.height / 2
            edge: Qt.BottomEdge
            z: -1

            Behavior on height {
                NumberAnimation { duration: Kirigami.Units.shortDuration }
            }

            contentItem: ColumnLayout {
                id: contents
                spacing: 0

                Kirigami.Heading {
                    level: 3
                    text: i18n("Set Playback Rate")
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: Kirigami.Units.largeSpacing * 2
                }
                ListView {
                    id: playbackRateList
                    model: playbackRateModel
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    delegate: Kirigami.BasicListItem {
                        highlighted: value == AudioManager.playbackRate
                        label: model.name
                        onClicked: {
                            AudioManager.playbackRate = value;
                            close();
                        }
                    }
                }
            }
        }
    }
}