/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 * SPDX-FileCopyrightText: 2021 Bart De Vries <bart@mogwai.be>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Layouts 1.14

import org.kde.kirigami 2.14 as Kirigami

import org.kde.kasts 1.0

Kirigami.ApplicationWindow {
    id: root
    title: "Kasts"

    minimumWidth: Kirigami.Units.gridUnit * 17
    minimumHeight: Kirigami.Units.gridUnit * 20

    property var miniplayerSize: Kirigami.Units.gridUnit * 3 + Kirigami.Units.gridUnit / 6
    property int tabBarHeight: Kirigami.Units.gridUnit * 2
    property int bottomMessageSpacing: Kirigami.Settings.isMobile ? Kirigami.Units.largeSpacing * 9 + ( AudioManager.entry ? ( footerLoader.item.contentY == 0 ? miniplayerSize : 0 ) : 0 ) + tabBarActive * tabBarHeight : Kirigami.Units.largeSpacing * 2
    property int tabBarActive: 0
    property int originalWidth: Kirigami.Units.gridUnit * 10
    property var lastFeed: ""
    property string currentPage: ""

    property bool isWidescreen: root.width >= root.height
    onIsWidescreenChanged: {
        if (!Kirigami.Settings.isMobile) {
            changeNavigation(!isWidescreen);
        }
    }
    function getPage(page) {
        switch (page) {
            case "QueuePage": return "qrc:/QueuePage.qml";
            case "EpisodeSwipePage": return "qrc:/EpisodeSwipePage.qml";
            case "FeedListPage": return "qrc:/FeedListPage.qml";
            case "DownloadListPage": return "qrc:/DownloadListPage.qml";
            case "SettingsPage": return "qrc:/SettingsPage.qml";
            case "AboutPage": return "qrc:/AboutPage.qml";
        }
    }
    function pushPage(page) {
        pageStack.clear()
        pageStack.push(getPage(page))
        currentPage = page
    }

    Component.onCompleted: {
        tabBarActive = SettingsManager.lastOpenedPage === "FeedListPage" ? 0
                     : SettingsManager.lastOpenedPage === "QueuePage" ? 0
                     : SettingsManager.lastOpenedPage === "EpisodeSwipePage" ? 1
                     : SettingsManager.lastOpenedPage === "DownloadListPage" ? 0
                     : 0
        currentPage = SettingsManager.lastOpenedPage
        pageStack.initialPage = getPage(SettingsManager.lastOpenedPage)
        if (SettingsManager.refreshOnStartup) Fetcher.fetchAll();
    }

    globalDrawer: Kirigami.GlobalDrawer {
        isMenu: false
        modal: Kirigami.Settings.isMobile
        collapsible: !Kirigami.Settings.isMobile
        header: Kirigami.AbstractApplicationHeader {
            visible: !Kirigami.Settings.isMobile
        }

        Component.onCompleted: {
            if (!Kirigami.Settings.isMobile) {
                Kirigami.Theme.colorSet = Kirigami.Theme.Window;
                Kirigami.Theme.inherit = false;
            }
        }

        // make room at the bottom for miniplayer
        handle.anchors.bottomMargin: (( AudioManager.entry && Kirigami.Settings.isMobile ) ? (footerLoader.item.contentY == 0 ? miniplayerSize : 0) : 0) + Kirigami.Units.smallSpacing + tabBarActive * tabBarHeight
        handleVisible: Kirigami.Settings.isMobile ? !AudioManager.entry || footerLoader.item.contentY === 0 : false
        showHeaderWhenCollapsed: true
        actions: [
            Kirigami.Action {
                text: i18n("Queue")
                iconName: "source-playlist"
                checked: currentPage == "QueuePage"
                onTriggered: {
                    pushPage("QueuePage")
                    SettingsManager.lastOpenedPage = "QueuePage" // for persistency
                    tabBarActive = 0
                }
            },
            Kirigami.Action {
                text: i18n("Episodes")
                iconName: "rss"
                checked: currentPage == "EpisodeSwipePage"
                onTriggered: {
                    pushPage("EpisodeSwipePage")
                    SettingsManager.lastOpenedPage = "EpisodeSwipePage" // for persistency
                    tabBarActive = 1
                }
            },
            Kirigami.Action {
                text: i18n("Subscriptions")
                iconName: "document-open-folder"
                checked: currentPage == "FeedListPage"
                onTriggered: {
                    pushPage("FeedListPage")
                    SettingsManager.lastOpenedPage = "FeedListPage" // for persistency
                    tabBarActive = 0
                }
            },
            Kirigami.Action {
                text: i18n("Downloads")
                iconName: "download"
                checked: currentPage == "DownloadListPage"
                onTriggered: {
                    pushPage("DownloadListPage")
                    SettingsManager.lastOpenedPage = "DownloadListPage" // for persistency
                    tabBarActive = 0
                }
            },
            Kirigami.Action {
                text: i18n("Settings")
                iconName: "settings-configure"
                checked: currentPage == "SettingsPage"
                onTriggered: {
                    pushPage("SettingsPage")
                }
            },
            Kirigami.Action {
                text: i18n("About")
                iconName: "help-about-symbolic"
                checked: currentPage == "AboutPage"
                onTriggered: {
                    pushPage("AboutPage")
                }
            }
        ]
    }

    function changeNavigation(isNarrow) {
        if(isNarrow) {
            globalDrawer.collapsed = true
            globalDrawer.width = Layout.implicitWidth
        }
        else {
            globalDrawer.collapsed = false
            globalDrawer.width = originalWidth
        }
    }

    Component {
        id: aboutPage

        Kirigami.AboutPage {
            aboutData: _aboutData
        }
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
        // make room at the bottom for miniplayer
        handle.anchors.bottomMargin: ( (AudioManager.entry && Kirigami.Settings.isMobile) ? ( footerLoader.item.contentY == 0 ? miniplayerSize : 0 ) : 0 ) + Kirigami.Units.smallSpacing + tabBarActive * tabBarHeight
        handleVisible: Kirigami.Settings.isMobile ? !AudioManager.entry || footerLoader.item.contentY === 0 : false
    }

    Mpris2 {
        id: mpris2Interface

        playerName: 'kasts'
        audioPlayer: AudioManager

        onRaisePlayer:
        {
            root.visible = true
            root.show()
            root.raise()
            root.requestActivate()
        }
    }

    header: Loader {
        id: headerLoader
        active: !Kirigami.Settings.isMobile
        visible: active

        sourceComponent: HeaderBar {
            focus: true
        }
    }

    // create space at the bottom to show miniplayer without it hiding stuff
    // underneath
    pageStack.anchors.bottomMargin: (AudioManager.entry && Kirigami.Settings.isMobile) ? miniplayerSize : 0

    Loader {
        id: footerLoader

        anchors.fill: parent
        active: AudioManager.entry && Kirigami.Settings.isMobile
        visible: active
        z: (!item || item.contentY === 0) ? -1 : 999
        sourceComponent: FooterBar {
            contentHeight: root.height * 2
            focus: true
        }

    }

    UpdateNotification {
        z: 2
        id: updateNotification

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: bottomMessageSpacing + ( errorNotification.visible ? errorNotification.height + Kirigami.Units.largeSpacing : 0 )
        }
    }

    ErrorNotification {
        id: errorNotification
    }

    // overlay with log of all errors that have happened
    ErrorListOverlay {
        id: errorOverlay
    }
}
