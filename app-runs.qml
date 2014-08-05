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
			subText: appId
			progression: true

			onClicked: {
				pageStack.push(Qt.resolvedUrl("run.qml"), {runtime: datetime, tracepoints: tpAverage});
			}
		}
	}

	ListView {
		id: runsView
		model: runsList
		delegate: runsDelegate
		anchors.fill: parent

		function average (inarray) {
			var sum = 0.0
			for (var value in inarray) {
				sum += inarray[value]
			}
			return sum / inarray.length
		}

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

					var builds = {}
					var runsObj = JSON.parse(req.responseText)["data"]

					for (var key in runsObj) {
						var build = builds[runsObj[key].data.build_num]

						if (build) {
							// Add run
							build.appRuns.push(runsObj[key].data.tracepoints[0])
						} else {
							build = {}

							build.id = runsObj[key].id
							build.datetime = runsObj[key].data.datetime
							build.build = runsObj[key].data.build_id
							build.appId = runsObj[key].data.app_id
							build.appRuns = []
							build.appRuns.push(runsObj[key].data.tracepoints[0])
						}

						builds[runsObj[key].data.build_num] = build
					}

					for (var build in builds) {
						var tracepoints = {}
						for (var runindex in builds[build].appRuns) {
							var run = builds[build].appRuns[runindex]

							var starttime = run.libual_start_message_sent
							if (starttime) {
								for (var runtp in run) {
									var tp = tracepoints[runtp]
									var time = run[runtp] - starttime
									if (tp) {
										tp.times.push(time)
									} else {
										tp = {}
										tp.times = []
										tp.times.push(time)
									}

									tracepoints[runtp] = tp
								}
							}
						}

						var tpAv = {}
						for (var tp in tracepoints) {
							tpAv[tp] = {}
							tpAv[tp].time = average(tracepoints[tp].times)
							tpAv[tp].runs = tracepoints[tp].times.length
							console.log("Tracepoint '" + tp + "' average '" + tpAv[tp].time + "'")
						}

						builds[build].tpAverage = tpAv

						runsList.append(builds[build])
					}
					console.log("Sets Count: " + runsList.count)

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
