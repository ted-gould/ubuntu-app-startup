import QtQuick 2.0 
import Ubuntu.Components 1.1 
import Ubuntu.Components.ListItems 1.0 as ListItem

MainView {
	id: mainview
	automaticOrientation: true

	Component.onCompleted: {
		pageStack.push(Qt.resolvedUrl("app-list.qml"))
	}

	PageStack {
		id: pageStack
		anchors.fill: parent
	}
}
