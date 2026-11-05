pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery summary from UPower's composite display device.
Singleton {
    readonly property var device: UPower.displayDevice
    readonly property bool present: !!(device && device.isLaptopBattery)
    readonly property real level: present ? device.percentage : 0
    readonly property bool charging: present
        && (device.state === UPowerDeviceState.Charging
            || device.state === UPowerDeviceState.FullyCharged)
    readonly property bool low: present && !charging && level <= 0.15
}
