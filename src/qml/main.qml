/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 * SPDX-FileCopyrightText: 2021-2022 Bart De Vries <bart@mogwai.be>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.12
import Qt.labs.settings 1.0

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kasts.solidextras 1.0

import org.kde.kasts 1.0

Kirigami.ApplicationWindow {
    id: kastsMainWindow
    title: "Kasts"

    width: Kirigami.Settings.isMobile ? 360 : 800
    height: Kirigami.Settings.isMobile ? 660 : 600

    pageStack.clip: true
    pageStack.popHiddenPages: true
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar;
    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton;

    // only have a single page visible at any time
    pageStack.columnView.columnResizeMode: Kirigami.ColumnView.SingleColumn

    minimumWidth: Kirigami.Units.gridUnit * 17
    minimumHeight: Kirigami.Units.gridUnit * 12

    property var miniplayerSize: Kirigami.Units.gridUnit * 3 + Kirigami.Units.gridUnit / 6
    property int bottomMessageSpacing: {
        if (Kirigami.Settings.isMobile) {
            return Kirigami.Units.largeSpacing + ( AudioManager.entry ? ( footerLoader.item.contentY == 0 ? miniplayerSize : 0 ) : 0 )
        } else {
            return Kirigami.Units.largeSpacing;
        }
    }
    property var lastFeed: ""
    property string currentPage: ""

    property bool isWidescreen: kastsMainWindow.width > kastsMainWindow.height

    function getPage(page) {
        switch (page) {
            case "QueuePage": return "qrc:/QueuePage.qml";
            case "EpisodeListPage": return "qrc:/EpisodeListPage.qml";
            case "DiscoverPage": return "qrc:/DiscoverPage.qml";
            case "FeedListPage": return "qrc:/FeedListPage.qml";
            case "DownloadListPage": return "qrc:/DownloadListPage.qml";
            case "SettingsPage": return "qrc:/Settings/SettingsPage.qml";
            default: {
                currentPage = "FeedListPage";
                return "qrc:/FeedListPage.qml";
            }
        }
    }
    function pushPage(page) {
        pageStack.clear();
        pageStack.layers.clear();
        pageStack.push(getPage(page));
        currentPage = page;
    }

    Settings {
        id: settings

        property alias x: kastsMainWindow.x
        property alias y: kastsMainWindow.y
        property var mobileWidth
        property var mobileHeight
        property var desktopWidth
        property var desktopHeight
        property int headerSize: Kirigami.Units.gridUnit * 5
        property alias lastOpenedPage: kastsMainWindow.currentPage
    }

    function saveWindowLayout() {
        if (Kirigami.Settings.isMobile) {
            settings.mobileWidth = kastsMainWindow.width;
            settings.mobileHeight = kastsMainWindow.height;
        } else {
            settings.desktopWidth = kastsMainWindow.width;
            settings.desktopHeight = kastsMainWindow.height;
        }
    }

    function restoreWindowLayout() {
        if (Kirigami.Settings.isMobile) {
            if (settings.mobileWidth) kastsMainWindow.width = settings.mobileWidth;
            if (settings.mobileHeight) kastsMainWindow.height = settings.mobileHeight;
        } else {
            if (settings.desktopWidth) kastsMainWindow.width = settings.desktopWidth;
            if (settings.desktopHeight) kastsMainWindow.height = settings.desktopHeight;
        }
    }

    Component.onDestruction: {
        saveWindowLayout();
    }

    Component.onCompleted: {
        restoreWindowLayout();
        pageStack.initialPage = getPage(currentPage);

        // Delete played enclosures if set in settings
        if (SettingsManager.autoDeleteOnPlayed == 2) {
            DataManager.deletePlayedEnclosures();
        }

        // Refresh feeds on startup if allowed
        // NOTE: refresh+sync on startup is handled in Sync and not here, since it
        // requires credentials to be loaded before starting a refresh+sync
        if (NetworkStatus.connectivity != NetworkStatus.No && (SettingsManager.allowMeteredFeedUpdates || NetworkStatus.metered !== NetworkStatus.Yes)) {
            if (SettingsManager.refreshOnStartup && !(SettingsManager.syncEnabled && SettingsManager.syncWhenUpdatingFeeds)) {
                Fetcher.fetchAll();
            }
        }
    }

    globalDrawer: sidebar.item
    Loader {
        id: sidebar
        active: !Kirigami.Settings.isMobile || kastsMainWindow.isWidescreen
        sourceComponent: Kirigami.OverlayDrawer {
            id: drawer
            modal: false

            readonly property real listViewThreshold: Kirigami.Settings.isMobile ? Kirigami.Units.gridUnit * 22 : Kirigami.Units.gridUnit * 20

            readonly property real pinnedWidth: Kirigami.Units.gridUnit * 3
            readonly property real widescreenSmallWidth: Kirigami.Units.gridUnit * 6
            readonly property real widescreenBigWidth: Kirigami.Units.gridUnit * 10
            readonly property int buttonDisplayMode: kastsMainWindow.isWidescreen ? (drawer.height < listViewThreshold ? Kirigami.NavigationTabButton.TextBesideIcon : Kirigami.NavigationTabButton.TextUnderIcon) : Kirigami.NavigationTabButton.IconOnly

            width: kastsMainWindow.isWidescreen ? (drawer.height < listViewThreshold ? widescreenBigWidth : widescreenSmallWidth) : pinnedWidth

            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            Kirigami.Theme.inherit: false

            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0

            contentItem: ColumnLayout {
                spacing: 0

                Loader {
                    active: Kirigami.Settings.isMobile
                    visible: active
                    Layout.fillWidth: true
                    sourceComponent: Kirigami.AbstractApplicationHeader { }
                }

                Controls.ScrollView {
                    id: scrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Controls.ScrollBar.vertical.policy: Controls.ScrollBar.AlwaysOff
                    Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
                    contentWidth: -1 // disable horizontal scroll

                    ColumnLayout {
                        id: column
                        width: scrollView.width
                        spacing: 0

                        Kirigami.NavigationTabButton {
                            Layout.fillWidth: true
                            display: drawer.buttonDisplayMode
                            text: i18n("Queue")
                            icon.name: "source-playlist"
                            checked: currentPage == "QueuePage"
                            onClicked: {
                                pushPage("QueuePage")
                            }
                        }
                        Kirigami.NavigationTabButton {
                            Layout.fillWidth: true
                            display: drawer.buttonDisplayMode
                            text: i18n("Discover")
                            icon.name: "search"
                            checked: currentPage == "DiscoverPage"
                            onClicked: {
                                pushPage("DiscoverPage")
                            }
                        }
                        Kirigami.NavigationTabButton {
                            Layout.fillWidth: true
                            display: drawer.buttonDisplayMode
                            text: i18n("Subscriptions")
                            icon.name: "bookmarks"
                            checked: currentPage == "FeedListPage"
                            onClicked: {
                                pushPage("FeedListPage")
                            }
                        }
                        Kirigami.NavigationTabButton {
                            Layout.fillWidth: true
                            display: drawer.buttonDisplayMode
                            text: i18n("Episodes")
                            icon.name: "rss"
                            checked: currentPage == "EpisodeListPage"
                            onClicked: {
                                pushPage("EpisodeListPage")
                            }
                        }
                        Kirigami.NavigationTabButton {
                            Layout.fillWidth: true
                            display: drawer.buttonDisplayMode
                            text: i18n("Downloads")
                            icon.name: "download"
                            checked: currentPage == "DownloadListPage"
                            onClicked: {
                                pushPage("DownloadListPage")
                            }
                        }
                    }
                }

                Kirigami.Separator {
                    Layout.fillWidth: true
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                }

                Kirigami.NavigationTabButton {
                    Layout.fillWidth: true
                    display: drawer.buttonDisplayMode

                    text: i18n("Settings")
                    icon.name: "settings-configure"
                    checked: currentPage == "SettingsPage"
                    onClicked: {
                        checked = false;
                        kastsMainWindow.pageStack.layers.clear()
                        kastsMainWindow.pageStack.pushDialogLayer("qrc:/SettingsPage.qml", {}, {
                            title: i18n("Settings")
                        })
                    }
                }
            }
        }
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
        // make room at the bottom for miniplayer
        handle.anchors.bottomMargin: ( (AudioManager.entry && Kirigami.Settings.isMobile) ? ( footerLoader.item.contentY == 0 ? miniplayerSize : 0 ) : 0 ) + Kirigami.Units.smallSpacing
        handleVisible: Kirigami.Settings.isMobile ? !AudioManager.entry || footerLoader.item.contentY === 0 : false
    }

    // Implement slots for MPRIS2 signals
    Connections {
        target: AudioManager
        function onRaiseWindowRequested() {
            kastsMainWindow.visible = true;
            kastsMainWindow.show();
            kastsMainWindow.raise();
            kastsMainWindow.requestActivate();
        }
    }
    Connections {
        target: AudioManager
        function onQuitRequested() {
            kastsMainWindow.close();
        }
    }

    header: Loader {
        id: headerLoader
        active: !Kirigami.Settings.isMobile
        visible: active

        sourceComponent: HeaderBar { focus: true }
    }

    // create space at the bottom to show miniplayer without it hiding stuff
    // underneath
    pageStack.anchors.bottomMargin: (AudioManager.entry && Kirigami.Settings.isMobile) ? miniplayerSize + 1 : 0

    Loader {
        id: footerLoader

        anchors.fill: parent
        active: AudioManager.entry && Kirigami.Settings.isMobile
        visible: active
        z: (!item || item.contentY === 0) ? -1 : 999
        sourceComponent: FooterBar {
            contentHeight: kastsMainWindow.height * 2
            focus: true
            contentToPlayerSpacing: footer.active ? footer.item.height + 1 : 0
        }
    }

    Loader {
        id: footerShadowLoader
        active: footer.active && !footerLoader.active
        anchors.fill: footer

        sourceComponent: RectangularGlow {
            glowRadius: 5
            spread: 0.3
            color: Qt.rgba(0.0, 0.0, 0.0, 0.1)
        }
    }

    footer: Loader {
        visible: active
        height: visible ? implicitHeight : 0
        active: Kirigami.Settings.isMobile && !kastsMainWindow.isWidescreen
        sourceComponent: BottomToolbar {
            transparentBackground: footerLoader.active
            opacity: (!footerLoader.item || footerLoader.item.contentY === 0) ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: Kirigami.Units.shortDuration }
            }
        }
    }

    // Notification that shows the progress of feed updates
    // It mimicks the behaviour of an InlineMessage, because InlineMessage does
    // not allow to add a BusyIndicator
    UpdateNotification {
        id: updateNotification
        text: i18ncp("Number of Updated Podcasts",
                     "Updated %2 of %1 Podcast",
                     "Updated %2 of %1 Podcasts",
                     Fetcher.updateTotal,
                     Fetcher.updateProgress)

        showAbortButton: true

        function abortAction() {
            Fetcher.cancelFetching();
        }

        Connections {
            target: Fetcher
            function onUpdatingChanged() {
                if (Fetcher.updating) {
                    updateNotification.open();
                } else {
                    updateNotification.close();
                }
            }
        }
    }

    // Notification to show progress of copying enclosure and images to new location
    UpdateNotification {
        id: moveStorageNotification
        text: i18ncp("Number of Moved Files",
                     "Moved %2 of %1 File",
                     "Moved %2 of %1 Files",
                     StorageManager.storageMoveTotal,
                     StorageManager.storageMoveProgress)
        showAbortButton: true

        function abortAction() {
            StorageManager.cancelStorageMove();
        }

        Connections {
            target: StorageManager
            function onStorageMoveStarted() {
                moveStorageNotification.open()
            }
            function onStorageMoveFinished() {
                moveStorageNotification.close()
            }
        }
    }

    // Notification that shows the progress of feed and episode syncing
    UpdateNotification {
        id: updateSyncNotification
        text: Sync.syncProgressText
        showAbortButton: true

        function abortAction() {
            Sync.abortSync();
        }

        Connections {
            target: Sync
            function onSyncProgressChanged() {
                if (Sync.syncStatus != SyncUtils.NoSync && Sync.syncProgress === 0) {
                    updateSyncNotification.open();
                } else if (Sync.syncStatus === SyncUtils.NoSync) {
                    updateSyncNotification.close();
                }
            }
        }
    }


    // This InlineMessage is used for displaying error messages
    ErrorNotification {
        id: errorNotification
    }

    // overlay with log of all errors that have happened
    ErrorListOverlay {
        id: errorOverlay
    }

    // This item can be used to trigger an update of all feeds; it will open an
    // overlay with options in case the operation is not allowed by the settings
    ConnectionCheckAction {
        id: updateAllFeeds
    }

    // Overlay with options what to do when metered downloads are not allowed
    ConnectionCheckAction {
        id: downloadOverlay

        headingText: i18n("Podcast downloads are currently not allowed on metered connections")
        condition: SettingsManager.allowMeteredEpisodeDownloads
        property var entry: undefined
        property var selection: undefined

        function action() {
            if (selection) {
                DataManager.bulkDownloadEnclosuresByIndex(selection);
            } else if (entry) {
                entry.queueStatus = true;
                entry.enclosure.download();
            }
            selection = undefined;
            entry = undefined;
        }

        function allowOnceAction() {
            SettingsManager.allowMeteredEpisodeDownloads = true;
            action();
            SettingsManager.allowMeteredEpisodeDownloads = false;
        }

        function alwaysAllowAction() {
            SettingsManager.allowMeteredEpisodeDownloads = true;
            SettingsManager.save();
            action();
        }
    }

    SleepTimerDialog {
        id: sleepTimerDialog
    }

    Connections {
        target: Sync
        function onPasswordInputRequired() {
            syncPasswordOverlay.open();
        }
    }

    SyncPasswordOverlay {
        id: syncPasswordOverlay
    }

    Loader {
        id: fullScreenImageLoader
        active: false
        visible: active
    }

    //Global Shortcuts
    Shortcut {
        sequence:  "space"
        enabled: AudioManager.canPlay
        onActivated: AudioManager.playPause()
    }
    Shortcut {
        sequence:  "n"
        enabled: AudioManager.canGoNext
        onActivated: AudioManager.next()
    }

    // Systray implementation
    Connections {
        target: kastsMainWindow

        function onClosing() {
            if (SystrayIcon.available && SettingsManager.showTrayIcon && SettingsManager.minimizeToTray) {
                close.accepted = false;
                kastsMainWindow.hide();
            } else {
                close.accepted = true;
                Qt.quit();
            }
        }
    }

    Connections {
        target: SystrayIcon

        function onRaiseWindow() {
            if (kastsMainWindow.visible) {
                kastsMainWindow.visible = false;
                kastsMainWindow.hide();
            } else {
                kastsMainWindow.visible = true;
                kastsMainWindow.show();
                kastsMainWindow.raise();
                kastsMainWindow.requestActivate();
            }
        }
    }
}
