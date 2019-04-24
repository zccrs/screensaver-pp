import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Particles 2.0

import "pp"

Image {
    id: root

    anchors.fill: parent
    source: "image://deepin-screensaver/screen/" + Screen.name

    ParticleSystem {
        id: particles
    }

    ImageParticle {
        source: Qt.resolvedUrl("pp/pp.png")
        colorVariation: 0.4
        autoRotation: false
        system: particles
        groups: ["pp"]
        entryEffect: ImageParticle.None
    }

    //  将粒子减速
//    Friction {
//        system: particles
//        anchors.verticalCenter: parent.verticalCenter
//        anchors.left: parent.left
//        anchors.right: parent.horizontalCenter
//        anchors.rightMargin: height / 2
//        height: 200
//        factor: 0.6
//        threshold: 50

//        DebugArea {
//            anchors.fill: parent
//            text: "减速区域"
//        }
//    }

//    Friction {
//        system: particles
//        anchors.horizontalCenter: parent.horizontalCenter
//        anchors.bottom: parent.bottom
//        anchors.top: parent.verticalCenter
//        anchors.topMargin: width / 2
//        width: 200
//        factor: 0.5
//        threshold: 50

//        DebugArea {
//            anchors.fill: parent
//            text: "减速区域"
//        }
//    }

//    // 重力
    Gravity {
        system: particles
        angle: 90
        magnitude: 1
        groups: ["pp"]
    }

    // 气流，放到发射区域，防止泡泡都堵在发射口
    Turbulence {
        id: turbulence

        system: particles
        anchors {
            left: parent.left
            bottom: parent.bottom
        }

        // 不知道为什么，属性绑定对width和height无效，只能在初始化时给定值，后期无法再次设置
        width: Screen.width / 2
        height: Screen.height / 2
        strength: 100
        groups: ["pp"]

//        DebugArea {
//            anchors.fill: parent
//            text: "气流区域"
//            border.color: "blue"
//        }
    }

    // 让粒子在边缘处被反弹
    TheForce {
        id: forceArea
        system: particles
        anchors.fill: parent
        groups: ["pp"]
        particleMargins: 0.32
        safeArea: Qt.rect(0, Screen.height - turbulence.height, turbulence.width, turbulence.height)
        devicePixelRatio: Screen.devicePixelRatio

        onImpacted: {
            p1.green = [p2.red, p2.red = p1.green][0]
            p1.blue = [p2.green, p2.green = p1.blue][0]
            p1.red = [p2.blue, p2.blue = p1.red][0]
        }

//        DebugArea {
//            anchors.fill: parent
//            border.color: "yellow"
//        }
    }

    Emitter {
        id: emitter
        system: particles
        width: size
        height: size
        group: "pp"

        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        emitRate: 10
        lifeSpan: 60000
        size: 150 * Screen.devicePixelRatio
        sizeVariation: size / 15
        velocity: AngleDirection { angle: -30; angleVariation: 20; magnitude: 500; magnitudeVariation: 100 }
        velocityFromMovement: 300
        maximumEmitted: 10

        Timer {
            running: forceArea.lastAffectParticleCount < 40
            repeat: true
            interval: 3000
            onTriggered: {
                emitter.maximumEmitted = -1;
                emitter.enabled = false;
                emitter.burst(5);
            }
        }

//        DebugArea {
//            anchors.fill: parent
//            text: "发射区域"
//        }
    }
}
