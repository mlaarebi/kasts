/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 * SPDX-FileCopyrightText: 2021 Bart De Vries <bart@mogwai.be>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.14

import org.kde.kirigami 2.12 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import org.kde.kasts 1.0

Kirigami.ScrollablePage {
    title: i18n("General Settings")

    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit

    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false

    ColumnLayout {
        spacing: 0

        MobileForm.FormCard {
            Layout.fillWidth: true

            contentItem: ColumnLayout {
                spacing: 0

                MobileForm.FormCardHeader {
                    title: i18n("Appearance")
                }

                MobileForm.FormCheckDelegate {
                    id: alwaysShowFeedTitles
                    text: i18n("Always show podcast titles in subscription view")
                    onToggled: SettingsManager.alwaysShowFeedTitles = checked
                }
            }
        }

        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing

            contentItem: ColumnLayout {
                spacing: 0

                MobileForm.FormCardHeader {
                    title: i18n("Playback settings")
                }

                MobileForm.FormCheckDelegate {
                    id: showTimeLeft
                    Kirigami.FormData.label: i18nc("Label for settings related to the play time, e.g. whether the total track time is shown or a countdown of the remaining play time", "Play Time:")
                    checked: SettingsManager.toggleRemainingTime
                    text: i18n("Show time left instead of total track time")
                    onToggled: SettingsManager.toggleRemainingTime = checked
                }
                MobileForm.FormCheckDelegate {
                    id: adjustTimeLeft
                    checked: SettingsManager.adjustTimeLeft
                    enabled: SettingsManager.toggleRemainingTime
                    text: i18n("Adjust time left based on current playback speed")
                    onToggled: SettingsManager.adjustTimeLeft = checked
                }
                MobileForm.FormCheckDelegate {
                    id: prioritizeStreaming
                    checked: SettingsManager.prioritizeStreaming
                    text: i18n("Prioritize streaming over downloading")
                    onToggled: SettingsManager.prioritizeStreaming = checked
                }
            }
        }

        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing

            contentItem: ColumnLayout {
                spacing: 0

                MobileForm.FormCardHeader {
                    title: i18n("Queue settings")
                }

                MobileForm.FormCheckDelegate {
                    id: continuePlayingNextEntry
                    checked: SettingsManager.continuePlayingNextEntry
                    text: i18n("Continue playing next episode after current one finishes")
                    onToggled: SettingsManager.continuePlayingNextEntry = checked
                }
                MobileForm.FormCheckDelegate {
                    id: refreshOnStartup
                    Kirigami.FormData.label: i18nc("Label for settings related to podcast updates", "Update Settings:")
                    checked: SettingsManager.refreshOnStartup
                    text: i18n("Automatically fetch podcast updates on startup")
                    onToggled: SettingsManager.refreshOnStartup = checked
                }
                MobileForm.FormCheckDelegate {
                    id: doFullUpdate
                    checked: SettingsManager.doFullUpdate
                    text: i18n("Update existing episode data on refresh (slower)")
                    onToggled: SettingsManager.doFullUpdate = checked
                }

                MobileForm.FormCheckDelegate {
                    id: autoQueue
                    checked: SettingsManager.autoQueue
                    text: i18n("Automatically queue new episodes")

                    onToggled: {
                        SettingsManager.autoQueue = checked
                        if (!checked) {
                            autoDownload.checked = false
                            SettingsManager.autoDownload = false
                        }
                    }
                }

                MobileForm.FormCheckDelegate {
                    id: autoDownload
                    checked: SettingsManager.autoDownload
                    text: i18n("Automatically download new episodes")

                    enabled: autoQueue.checked
                    onToggled: SettingsManager.autoDownload = checked
                }

                MobileForm.FormDelegateSeparator { above: autoDownload; below: episodeBehavior }

                MobileForm.FormComboBoxDelegate {
                    id: episodeBehavior
                    text: i18n("Played episode behavior")
                    textRole: "text"
                    valueRole: "value"
                    model: [{"text": i18n("Do Not Delete"), "value": 0},
                            {"text": i18n("Delete Immediately"), "value": 1},
                            {"text": i18n("Delete at Next Startup"), "value": 2}]
                    Component.onCompleted: currentIndex = indexOfValue(SettingsManager.autoDeleteOnPlayed)
                    onActivated: {
                        SettingsManager.autoDeleteOnPlayed = currentValue;
                    }
                }

                MobileForm.FormDelegateSeparator { above: episodeBehavior; below: resetPositionOnPlayed }

                MobileForm.FormCheckDelegate {
                    id: resetPositionOnPlayed
                    checked: SettingsManager.resetPositionOnPlayed
                    text: i18n("Reset play position after an episode is played")
                    onToggled: SettingsManager.resetPositionOnPlayed = checked
                }
            }
        }

        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing

            contentItem: ColumnLayout {
                spacing: 0

                MobileForm.FormCardHeader {
                    title: i18n("When adding new podcasts")
                }

                MobileForm.FormRadioDelegate {
                    checked: SettingsManager.markUnreadOnNewFeed === 0
                    text: i18n("Mark all episodes as played")
                    onToggled: SettingsManager.markUnreadOnNewFeed = 0
                }


                MobileForm.FormRadioDelegate {
                    id: markCustomUnreadNumberButton
                    checked: SettingsManager.markUnreadOnNewFeed === 1
                    text: i18n("Mark most recent episodes as unplayed")
                    onToggled: SettingsManager.markUnreadOnNewFeed = 1

                    trailing: Controls.SpinBox {
                        Layout.rightMargin: Kirigami.Units.gridUnit
                        id: markCustomUnreadNumberSpinBox
                        enabled: markCustomUnreadNumberButton.checked
                        value: SettingsManager.markUnreadOnNewFeedCustomAmount
                        from: 0
                        to: 100

                        onValueModified: SettingsManager.markUnreadOnNewFeedCustomAmount = value
                    }
                }

                MobileForm.FormRadioDelegate {
                    checked: SettingsManager.markUnreadOnNewFeed === 2
                    text: i18n("Mark all episodes as unplayed")
                    onToggled: SettingsManager.markUnreadOnNewFeed = 2
                }
            }
        }

        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing

            contentItem: ColumnLayout {
                spacing: 0

                MobileForm.FormCardHeader {
                    title: i18n("Article")
                }

                MobileForm.FormTextDelegate {
                    id: fontSize
                    text: i18n("Font size")

                    trailing: Controls.SpinBox {
                        id: articleFontSizeSpinBox

                        enabled: !useSystemFontCheckBox.checked
                        value: SettingsManager.articleFontSize
                        Kirigami.FormData.label: i18n("Font size:")
                        from: 6
                        to: 20

                        onValueModified: SettingsManager.articleFontSize = value
                    }
                }

                MobileForm.FormDelegateSeparator { above: fontSize; below: useSystemFontCheckBox }

                MobileForm.FormCheckDelegate {
                    id: useSystemFontCheckBox
                    checked: SettingsManager.articleFontUseSystem
                    text: i18n("Use system default")

                    onToggled: SettingsManager.articleFontUseSystem = checked
                }
            }
        }

        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing

            contentItem: ColumnLayout {
                spacing: 0

                MobileForm.FormCardHeader {
                    title: i18n("Errors")
                }

                MobileForm.FormTextDelegate {
                    text: i18n("Error log")
                    trailing: Controls.Button {
                        icon.name: "error"
                        text: i18n("Open Log")
                        onClicked: settingsErrorOverlay.open()
                    }
                }

                ErrorListOverlay {
                    id: settingsErrorOverlay
                }
            }
        }
    }
}
