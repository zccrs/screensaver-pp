import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Particles 2.0

Item {
    anchors.fill: parent

    ParticleSystem {
        id: particles
    }

    ImageParticle {
        source: Qt.resolvedUrl("qrc:/pp.png")
        colorVariation: 0.4
        autoRotation: false
        system: particles
        groups: ["pp"]
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
        system: particles
        anchors {
            left: parent.left
            bottom: parent.bottom
        }

        width: parent.width / 2
        height: parent.height / 2
        strength: 50
        groups: ["pp"]

//        DebugArea {
//            anchors.fill: parent
//            text: "气流区域"
//            border.color: "blue"
//        }
    }

    // 让粒子在边缘处被反弹
    TheForce {
        system: particles
        anchors.fill: parent
        groups: ["pp"]
        particleMargins: 0.3183183182

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

        emitRate: 0.8
        lifeSpan: 60000
        size: 150
        sizeVariation: 10
        velocity: AngleDirection { angle: -45; angleVariation: 30; magnitude: 300; magnitudeVariation: 50 }
//        maximumEmitted: 3

//        DebugArea {
//            anchors.fill: parent
//            text: "发射区域"
//        }
    }
}
