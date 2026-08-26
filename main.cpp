#include <QCoreApplication>
#include <QGuiApplication>
#include <QQuickView>
#include <QSurfaceFormat>
#include <QUrl>
#include <QtGlobal>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);
    QQuickView window;
    QSurfaceFormat sf = window.format();

    sf.setAlphaBufferSize(8);

    window.setFormat(sf);
    window.setSource(QUrl(QStringLiteral("qrc:/deepin-screensaver/modules/pp.qml")));
    window.setColor(Qt::transparent);
    window.showFullScreen();

    return app.exec();
}
