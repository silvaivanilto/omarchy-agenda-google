import QtQuick
import qs.Commons
import qs.Ui

Column {
    id: root
    required property var panel
    required property var onboarding

    anchors.fill: parent
    anchors.margins: Style.space(20)
    spacing: Style.space(16)

    Item {
        width: parent.width
        height: Style.space(36)

        Text {
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "󰃭  " + root.panel.tr("appTitle")
            color: root.panel.contentForeground
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            font.bold: true
        }
    }

    Item { width: 1; height: Style.space(32) }

    Text {
        textFormat: Text.PlainText
        width: parent.width
        text: root.panel.tr("onboardingHeadline")
        color: root.panel.contentForeground
        font.family: Style.font.family
        font.pixelSize: Style.font.title
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Text {
        textFormat: Text.PlainText
        width: parent.width
        text: root.panel.tr("onboardingBody")
        color: root.panel.mutedForeground
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Rectangle {
        width: parent.width
        height: privacyText.implicitHeight + Style.space(20)
        radius: Style.cornerRadius
        color: Qt.rgba(
            root.panel.contentForeground.r,
            root.panel.contentForeground.g,
            root.panel.contentForeground.b,
            0.07
        )

        Text {
            textFormat: Text.PlainText
            id: privacyText
            anchors.fill: parent
            anchors.margins: Style.space(10)
            text: root.panel.tr("onboardingBadges")
            color: root.panel.accentForeground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 0.8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }

    Text {
        visible: !root.onboarding.configured || !root.onboarding.secretServiceAvailable
        width: parent.width
        textFormat: Text.PlainText
        text: !root.onboarding.configured
            ? root.onboarding.configurationError
            : root.panel.tr("onboardingSecretUnavailable")
        color: root.panel.accentForeground
        font.family: Style.font.family
        font.pixelSize: Style.font.bodySmall
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Text {
        visible: root.onboarding.lastError !== ""
        width: parent.width
        textFormat: Text.PlainText
        text: root.onboarding.lastError
        color: root.panel.accentForeground
        font.family: Style.font.family
        font.pixelSize: Style.font.bodySmall
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.onboarding.busy ? root.panel.tr("onboardingConnecting") : root.panel.tr("onboardingConnect")
        bordered: true
        enabled: root.onboarding.configured
            && root.onboarding.secretServiceAvailable
            && !root.onboarding.busy
        horizontalPadding: Style.space(14)
        verticalPadding: Style.space(8)
        onClicked: root.onboarding.addAccount()
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !root.onboarding.configured
            || !root.onboarding.secretServiceAvailable
            || root.onboarding.lastError !== ""
        text: root.panel.tr("onboardingRetry")
        bordered: true
        enabled: !root.onboarding.busy
        horizontalPadding: Style.space(12)
        verticalPadding: Style.space(5)
        onClicked: root.onboarding.refresh()
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.panel.tr("onboardingPrivacy")
        bordered: false
        horizontalPadding: Style.space(8)
        verticalPadding: Style.space(3)
        onClicked: Qt.openUrlExternally(
            "https://omarchy.alexinslc.com/calendar-agenda/privacy/"
        )
    }

    Text {
        textFormat: Text.PlainText
        width: parent.width
        text: root.panel.tr("onboardingFooter")
        color: root.panel.mutedForeground
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }
}
