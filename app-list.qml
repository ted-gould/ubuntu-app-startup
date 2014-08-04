import QtQuick 2.0 
import Ubuntu.Components 1.1 
import Ubuntu.Components.ListItems 1.0 as ListItem

Page {
	title: i18n.tr("Applications")

	ListModel {
		id: appList
	}

	Component {
		id: appDelegate
		ListItem.Standard {
			text: appName
			progression: true
			onClicked: {
				pageStack.push(Qt.resolvedUrl("app-runs.qml"), {name: appName, path: path});
			}
			Component.onCompleted: {
				console.log("Completed: " + path)
			}
		}
	}

	ListView {
		id: appView
		model: appList
		delegate: appDelegate
		anchors.fill: parent

		Component.onCompleted: {
			//create a request and tell it where the json that I want is
			var req = new XMLHttpRequest();
			var location = "http://nfss.ubuntu.com/api/v1/app-startup"

			//tell the request to go ahead and get the json
			req.open("GET", location, true);
			req.send(null);

			//wait until the readyState is 4, which means the json is ready
			req.onreadystatechange = function() {
				if (req.readyState == 4) {
					//turn the text in a javascript object while setting the ListView's model to it
					//console.log("Got data: " + req.responseText)
					//var appArray = []
					appList.clear()
					var appObj = JSON.parse(req.responseText)["tests"]
					for (var key in appObj) {
						var testobj = {}
						console.log("Looking at: " + key)
						testobj.appName = key
						testobj.path = appObj[key].path
						appList.append(testobj)
					}
					console.log("Length: " + appList.count)
				}
			};
		}
	}
}
