import QtQuick 2.0 
import Ubuntu.Components 1.1 
import Ubuntu.Components.ListItems 1.0 as ListItem

Page {
	id: run
	title: "Run on " + runtime

	property string runtime
	property variant tracepoints

	Component {
		id: traceItem
		ListItem.Subtitled {
			text: name
			subText: time
		}
	}

	ListModel {
		id: traceModel
	}

	ListView {
		id: traceView
		model: traceModel
		delegate: traceItem
		anchors.fill: parent
	}

	Component.onCompleted: {
		for (var item in tracepoints) {
			var traceobj = {}
			traceobj.name = item
			traceobj.time = tracepoints[item]
			traceModel.append(traceobj)
		}

		console.log("Trace count: " + traceModel.count)
	}
}
