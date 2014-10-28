import QtQuick 2.0 
import QtQml 2.2
import Ubuntu.Components 1.1 
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Web 0.2

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
			text: datetime.toLocaleString()
			subText: appId
			progression: true

			onClicked: {
				pageStack.push(Qt.resolvedUrl("run.qml"), {runtime: datetime.toLocaleString(), tracepoints: tpAverage});
			}
		}
	}

	Component {
		id: webviewComponent
		ListItem.SingleControl {
			id: webviewControl
			control: WebView {
				id: webview
				visible: false
				width: appRuns.width
				height: appRuns.width / 3 * 2

				function setWebView (data) {
					if (!data) {
						webview.visible = false
						webview.loadHtml("
<!DOCTYPE html>
<meta charset=\"utf-8\">
<style>
body {
  background-color: #CCCCCC;
}
</style>
<body>
<script src=\"http://d3js.org/d3.v3.min.js\"></script>
</body>");
						return
					}

					webview.loadHtml("
<!DOCTYPE html>
<meta charset=\"utf-8\">
<style>

body {
  background-color: #CCCCCC;
}

.bar {
  fill: " + UbuntuColors.orange + ";
}

.axis {
  font: 10px Ubuntu;
}

.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.x.axis path {
  display: none;
}

</style>
<body>
<script src=\"http://d3js.org/d3.v3.min.js\"></script>
<script>

var margin = {top: " + units.gu(4) + ", right: " + units.gu(4) + ", bottom: " + units.gu(4) + ", left: " + units.gu(6) + "},
    width = " + (webview.width - units.gu(3)) + " - margin.left - margin.right,
    height = " + (webview.height - units.gu(3)) + " - margin.top - margin.bottom;

var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

var y = d3.scale.linear()
    .range([height, 0]);

var xAxis = d3.svg.axis()
    .scale(x)
    .orient(\"bottom\");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient(\"left\")
    .ticks(5, \" ms\");

var data =" + JSON.stringify(data) + "; 

var svg = d3.select(\"body\").append(\"svg\")
    .attr(\"width\", width + margin.left + margin.right)
    .attr(\"height\", height + margin.top + margin.bottom)
  .append(\"g\")
    .attr(\"transform\", \"translate(\" + margin.left + \",\" + margin.top + \")\");

  x.domain(data.map(function(d) { return d.date; }));
  y.domain([0, d3.max(data, function(d) { return d.time; })]);

  svg.append(\"g\")
      .attr(\"class\", \"x axis\")
      .attr(\"transform\", \"translate(0,\" + height + \")\")
      .call(xAxis);

  svg.append(\"g\")
      .attr(\"class\", \"y axis\")
      .call(yAxis)
    .append(\"text\")
      .attr(\"transform\", \"rotate(-90)\")
      .attr(\"y\", 6)
      .attr(\"dy\", \".71em\")
      .style(\"text-anchor\", \"end\")
      .text(\"Time\");

  svg.selectAll(\".bar\")
      .data(data)
    .enter().append(\"rect\")
      .attr(\"class\", \"bar\")
      .attr(\"x\", function(d) { return x(d.date); })
      .attr(\"width\", x.rangeBand())
      .attr(\"y\", function(d) { return y(d.time); })
      .attr(\"height\", function(d) { return height - y(d.time); });

</script>
</body>
");
					webview.visible = true
				}
			}
		}
	}

	ListView {
		id: runsView
		model: runsList
		delegate: runsDelegate
		anchors.fill: parent
		header: webviewComponent

		function average (inarray) {
			var sum = 0.0
			for (var value in inarray) {
				sum += inarray[value]
			}
			return sum / inarray.length
		}

		function day2str (day) {
			var days = [
				"Sun",
				"Mon",
				"Tue",
				"Wed",
				"Thr",
				"Fri",
				"Sat"
			]
			return days[day]
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
							build.datetime = new Date(runsObj[key].data.datetime)
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

							var starttime = run.libual_start
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

					var data = []
					for (n = 0; n < 5 && n < runsList.count; n++) {
						var obj = {}
						obj.date = day2str(runsList.get(n).datetime.getDay())
						obj.time = runsList.get(n).tpAverage["exec_pre_exec"].time

						obj.time = obj.time / 1000000 /* ms */

						data.push(obj)
					}

					headerItem.control.setWebView(data)
				}
			};
		}
	}
}
