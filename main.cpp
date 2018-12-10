#include <QGuiApplication>
#include <QQmlEngine>
#include <QQuickView>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QQuickView window;
    QSurfaceFormat sf = window.format();

    sf.setAlphaBufferSize(8);

    window.setFormat(sf);
    window.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
    window.setColor(Qt::transparent);
    window.showFullScreen();

    return app.exec();
}
