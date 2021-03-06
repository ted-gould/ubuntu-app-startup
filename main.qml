import QtQuick 2.0 
import Ubuntu.Components 1.1 
import Ubuntu.Components.ListItems 1.0 as ListItem

MainView {
	id: mainview
	automaticOrientation: true
	useDeprecatedToolbar: false
	applicationName: "cx.gould.ted.ubuntu-app-startup"

	width: units.gu(40)
	height: units.gu(70)

	Component.onCompleted: {
		pageStack.push(Qt.resolvedUrl("app-list.qml"))
	}

	PageStack {
		id: pageStack
		anchors.fill: parent
	}
}
