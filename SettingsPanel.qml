import QtQuick
import QtQuick.Controls as QQC2
import qs.Commons
import qs.Ui

Flickable {
    id: root
    property var panel
    property var onboarding
    property string pendingRemovalId: ""
    anchors.fill: parent
    anchors.margins: Style.space(16)
    enabled: panel.preferencesLoaded
    contentWidth: width
    contentHeight: contentColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.VerticalFlick
    interactive: contentHeight > height
    QQC2.ScrollBar.vertical: QQC2.ScrollBar { policy: QQC2.ScrollBar.AsNeeded }

    function toggleField(key) {
        var updated = Object.assign({}, panel.preferences)
        updated[key] = !panel.preferences[key]
        panel.preferences = updated
        panel.savePreferences()
    }

    Column {
        id: contentColumn
        width: root.width
        spacing: Style.space(10)

        Item {
            width: parent.width
            height: Style.space(34)
            Text {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: panel.tr("settingsTitle")
                color: panel.contentForeground
                font.family: Style.font.family
                font.pixelSize: Style.font.title
                font.bold: true
            }

            Button {
                anchors.right: parent.right
                text: panel.tr("settingsDone")
                bordered: true
                horizontalPadding: Style.space(8)
                verticalPadding: Style.space(4)
                anchors.verticalCenter: parent.verticalCenter
                onClicked: panel.settingsOpen = false
            }
        }

        Text {
            textFormat: Text.PlainText
            text: panel.tr("settingsAccounts")
            color: panel.accentForeground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }

        Text {
            visible: onboarding.actionStatus !== "" || onboarding.lastError !== ""
            width: root.width
            textFormat: Text.PlainText
            text: onboarding.lastError !== "" ? onboarding.lastError : onboarding.actionStatus
            color: onboarding.lastError !== "" ? panel.accentForeground : panel.mutedForeground
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.Wrap
        }

        Button {
            visible: onboarding.localRemovalAccountId !== ""
            text: panel.tr("settingsRemoveLocally")
            bordered: true
            enabled: !onboarding.busy
            horizontalPadding: Style.space(8)
            verticalPadding: Style.space(4)
            onClicked: onboarding.removeAccount(onboarding.localRemovalAccountId, true)
        }

        Row {
            width: root.width
            spacing: Style.space(6)

            Button {
                text: onboarding.busy ? panel.tr("settingsWorking") : panel.tr("settingsAddAccount")
                bordered: true
                enabled: onboarding.configured && onboarding.secretServiceAvailable && !onboarding.busy
                horizontalPadding: Style.space(8)
                verticalPadding: Style.space(4)
                onClicked: onboarding.addAccount()
            }

            Button {
                text: panel.tr("settingsSyncNow")
                bordered: true
                enabled: !onboarding.busy && onboarding.accounts.length > 0
                horizontalPadding: Style.space(8)
                verticalPadding: Style.space(4)
                onClicked: onboarding.syncNow()
            }
        }

        Repeater {
            model: onboarding.accounts
            delegate: Rectangle {
                required property var modelData
                width: root.width
                height: accountColumn.implicitHeight + Style.space(16)
                radius: Style.cornerRadius
                color: Qt.rgba(panel.contentForeground.r, panel.contentForeground.g, panel.contentForeground.b, 0.07)

                Column {
                    id: accountColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Style.space(8)
                    spacing: Style.space(5)

                    Text {
                        width: parent.width
                        textFormat: Text.PlainText
                        text: modelData.email || modelData.displayName || modelData.id
                        color: panel.contentForeground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        textFormat: Text.PlainText
                        visible: modelData.legacy === true
                        width: parent.width
                        text: panel.tr("settingsLegacyReconnect")
                        color: panel.accentForeground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        wrapMode: Text.Wrap
                    }

                    Text {
                        visible: modelData.state === "needs-attention"
                        width: parent.width
                        textFormat: Text.PlainText
                        text: panel.tr("settingsNeedsAttention") + String(modelData.lastError || panel.tr("settingsReconnectPrompt"))
                        color: panel.accentForeground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        wrapMode: Text.Wrap
                    }

                    Row {
                        spacing: Style.space(6)
                        visible: root.pendingRemovalId !== modelData.id

                        Button {
                            text: panel.tr("settingsReconnect")
                            bordered: true
                            enabled: !onboarding.busy
                            horizontalPadding: Style.space(7)
                            verticalPadding: Style.space(3)
                            onClicked: onboarding.reconnectAccount(modelData.id)
                        }

                        Button {
                            text: panel.tr("settingsRemove")
                            bordered: true
                            enabled: !onboarding.busy
                            horizontalPadding: Style.space(7)
                            verticalPadding: Style.space(3)
                            onClicked: root.pendingRemovalId = modelData.id
                        }
                    }

                    Text {
                        textFormat: Text.PlainText
                        visible: root.pendingRemovalId === modelData.id
                        width: parent.width
                        text: panel.tr("settingsRemoveConfirmText")
                        color: panel.contentForeground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        wrapMode: Text.Wrap
                    }

                    Row {
                        spacing: Style.space(6)
                        visible: root.pendingRemovalId === modelData.id

                        Button {
                            text: panel.tr("settingsConfirmRemove")
                            bordered: true
                            enabled: !onboarding.busy
                            horizontalPadding: Style.space(7)
                            verticalPadding: Style.space(3)
                            onClicked: {
                                root.pendingRemovalId = ""
                                onboarding.removeAccount(modelData.id, false)
                            }
                        }

                        Button {
                            text: panel.tr("settingsCancel")
                            bordered: true
                            enabled: !onboarding.busy
                            horizontalPadding: Style.space(7)
                            verticalPadding: Style.space(3)
                            onClicked: root.pendingRemovalId = ""
                        }
                    }
                }
            }
        }

        Text {
            textFormat: Text.PlainText
            text: panel.tr("settingsDisplay")
            color: panel.accentForeground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }

        Repeater {
            model: [
                { "key": "showTime", "label": panel.tr("settingsShowTime") },
                { "key": "showCalendar", "label": panel.tr("settingsShowCalendar") },
                { "key": "showLocation", "label": panel.tr("settingsShowLocation") }
            ]
            delegate: CompactToggle {
                required property var modelData
                width: root.width
                label: modelData.label
                checked: panel.preferences[modelData.key]
                onClicked: root.toggleField(modelData.key)
            }
        }

        Text {
            textFormat: Text.PlainText
            text: panel.tr("settingsTimeFormat")
            color: panel.accentForeground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }

        ButtonGroup {
            width: root.width
            options: [panel.tr("settings24h"), panel.tr("settings12h")]
            value: panel.preferences.timeFormat === "12" ? panel.tr("settings12h") : panel.tr("settings24h")
            onChanged: function(value) {
                var updated = Object.assign({}, panel.preferences)
                updated.timeFormat = value === panel.tr("settings12h") ? "12" : "24"
                panel.preferences = updated
                panel.savePreferences()
            }
        }

        Text {
            textFormat: Text.PlainText
            text: panel.tr("settingsLanguage")
            color: panel.accentForeground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }

        ButtonGroup {
            width: root.width
            options: [
                panel.tr("settingsLangAuto"),
                panel.tr("settingsLangPt"),
                panel.tr("settingsLangEn")
            ]
            value: panel.preferences.language === "pt-BR"
                ? panel.tr("settingsLangPt")
                : (panel.preferences.language === "en"
                    ? panel.tr("settingsLangEn")
                    : panel.tr("settingsLangAuto"))
            onChanged: function(value) {
                var updated = Object.assign({}, panel.preferences)
                if (value === panel.tr("settingsLangPt")) updated.language = "pt-BR"
                else if (value === panel.tr("settingsLangEn")) updated.language = "en"
                else updated.language = "auto"
                panel.preferences = updated
                panel.savePreferences()
                panel.reloadLanguage()
            }
        }

        Text {
            textFormat: Text.PlainText
            text: panel.tr("settingsCalendars")
            color: panel.accentForeground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }

        Repeater {
            model: panel.calendarOptions
            delegate: CompactToggle {
                required property var modelData
                readonly property string preferenceKey: modelData.accountId + "::" + modelData.id
                width: root.width
                label: modelData.name + "  ·  " + panel.accountLabelForId(modelData.accountId)
                checked: panel.calendarEnabledFor(modelData.accountId, modelData.id)
                onClicked: {
                    var calendars = Object.assign({}, panel.preferences.calendars)
                    calendars[preferenceKey] = !panel.calendarEnabledFor(modelData.accountId, modelData.id)
                    panel.preferences = Object.assign({}, panel.preferences, { "calendars": calendars })
                    panel.savePreferences()
                    panel.rebuild()
                }
            }
        }

        Text {
            textFormat: Text.PlainText
            text: panel.tr("settingsAccountVisibility")
            color: panel.accentForeground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }

        Repeater {
            model: panel.accountOptions
            delegate: CompactToggle {
                required property var modelData
                readonly property string accountId: String(modelData.id)
                width: root.width
                label: panel.accountLabel(modelData)
                checked: panel.preferenceEnabled(panel.preferences.accounts, accountId)
                onClicked: {
                    var accounts = Object.assign({}, panel.preferences.accounts)
                    accounts[accountId] = !panel.preferenceEnabled(accounts, accountId)
                    panel.preferences = Object.assign({}, panel.preferences, { "accounts": accounts })
                    panel.savePreferences()
                    panel.rebuild()
                }
            }
        }

    }
}
