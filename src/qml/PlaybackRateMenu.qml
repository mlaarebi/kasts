/**
 * SPDX-FileCopyrightText: 2023 Bart De Vries <bart@mogwai.be>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Layouts 1.14

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kasts 1.0

Controls.Menu {
    id: playbackRateMenu

    required property QtObject parentButton

    title: i18nc("@title:window", "Select Playback Rate")

    Controls.ButtonGroup { id: playbackRateGroup }

    ColumnLayout {
        Repeater {
            model: playbackRateModel

            Controls.RadioButton {
                padding: Kirigami.Units.smallSpacing
                text: model.value
                checked: model.value === AudioManager.playbackRate.toFixed(2)
                Controls.ButtonGroup.group: playbackRateGroup

                onToggled: {
                    if (checked) {
                        AudioManager.playbackRate = value;
                    }
                    playbackRateMenu.dismiss();
                }
            }
        }
    }

    Controls.MenuSeparator {
        padding: Kirigami.Units.smallSpacing
    }

    Kirigami.Action {
        text: i18nc("@action:button", "Customize")
        icon.name: "settings-configure"
        onTriggered: {
            const dialog = customizeDialog.createObject(parent);
            dialog.open();
        }
    }

    ListModel {
        id: playbackRateModel

        function resetModel() {
            playbackRateModel.clear();
            for (var rate in SettingsManager.playbackRates) {
                playbackRateModel.append({"value": (SettingsManager.playbackRates[rate] / 100.0).toFixed(2),
                                          "name": (SettingsManager.playbackRates[rate] / 100.0).toFixed(2) + "x"});
            }
        }

        Component.onCompleted: {
            resetModel();
        }
    }

    Component {
        id: customizeDialog
        PlaybackRateCustomizerDialog {
            onAccepted: {
                var newRates = getRateList();
                SettingsManager.playbackRates = newRates;
                SettingsManager.save();
                playbackRateModel.resetModel();
            }
        }
    }
}
