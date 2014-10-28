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
			text: name == "exec_pre_exec" ? name + " (time on graph)" : name
			subText: (time / 1000000) + " ms  (n = " + runCount + ")"
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
			traceobj.time = tracepoints[item].time
			traceobj.runCount = tracepoints[item].runs
			traceModel.append(traceobj)
		}

		// Ugly sort
		var n;
		var i;
		for (n=0; n < traceModel.count; n++)
			for (i=n+1; i < traceModel.count; i++) {
				if (traceModel.get(n).time > traceModel.get(i).time) {
					traceModel.move(i, n, 1);
					n=0;
				}
			}

		console.log("Trace count: " + traceModel.count)
	}
}
