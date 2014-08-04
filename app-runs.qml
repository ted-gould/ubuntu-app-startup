import QtQuick 2.0 
import Ubuntu.Components 1.1 
import Ubuntu.Components.ListItems 1.0 as ListItem

Page {
	id: appRuns
	title: "Runs for " + name

	property string name
	property string path

	ListModel {
		id: runsList
	}

	Component {
		id: runsDelegate
		ListItem.Subtitled {
			text: datetime
			subText: build
			progression: true
			onClicked: {
				pageStack.push(Qt.resolvedUrl("run.qml"), {tracepoints: data.tracepoints});
			}
		}
	}

	ListView {
		id: runsView
		model: runsList
		delegate: runsDelegate
		anchors.fill: parent

		Component.onCompleted: {
			//create a request and tell it where the json that I want is
			var req = new XMLHttpRequest();
			var location = "http://nfss.ubuntu.com/" + path

			//tell the request to go ahead and get the json
			req.open("GET", location, true);
			req.send(null);

			//wait until the readyState is 4, which means the json is ready
			req.onreadystatechange = function() {
				if (req.readyState == 4) {
					//turn the text in a javascript object while setting the ListView's model to it
					runsList.clear()
					var runsObj = JSON.parse(req.responseText)["data"]
					for (var key in runsObj) {
						var testobj = {}
						testobj.id = runsObj[key].id
						testobj.datetime = runsObj[key].data.datetime
						testobj.build = runsObj[key].data.build_id
						testobj.tracepoints = runsObj[key].data.tracepoints
						runsList.append(testobj)
					}
					console.log("Runs Count: " + runsList.count)

					// Ugly sort
					var n;
					var i;
					for (n=0; n < runsList.count; n++)
						for (i=n+1; i < runsList.count; i++) {
							if (runsList.get(n).id < runsList.get(i).id) {
								runsList.move(i, n, 1);
								n=0;
							}
						}
				}
			};
		}
	}
}
