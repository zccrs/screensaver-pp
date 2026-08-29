QT += quick
CONFIG += c++17

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp

RESOURCES += $$PWD/qml.qrc

PP_RCC = $$OUT_PWD/pp.rcc
pp_rcc.target = $$PP_RCC
pp_rcc.depends = $$PWD/qml.qrc $$PWD/main.qml $$PWD/TheForce.qml $$PWD/DebugArea.qml $$PWD/pp.png $$PWD/pp.svg
pp_rcc.commands = $$[QT_HOST_LIBEXECS]/rcc --binary $$shell_quote($$PWD/qml.qrc) -o $$shell_quote($$PP_RCC)
QMAKE_EXTRA_TARGETS += pp_rcc
PRE_TARGETDEPS += $$PP_RCC
QMAKE_CLEAN += $$PP_RCC

deepin_screensaver.path = /usr/lib/deepin-screensaver/resources
deepin_screensaver.extra = test -d $(INSTALL_ROOT)$$deepin_screensaver.path || mkdir -p $(INSTALL_ROOT)$$deepin_screensaver.path; $(QINSTALL) $$PP_RCC $(INSTALL_ROOT)$$deepin_screensaver.path/pp.rcc
deepin_screensaver.uninstall = $(DEL_FILE) $(INSTALL_ROOT)$$deepin_screensaver.path/pp.rcc

INSTALLS += deepin_screensaver
