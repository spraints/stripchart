$(function() {

  var margin = {top: 5, right: 20, bottom: 20, left: 70};
  var chartWidth  = 960 - margin.left - margin.right;
  var chartHeight =  80 - margin.top  - margin.bottom;

  var clips = 0;
  function StripChart(container, name) {
    container = container.append('div').attr('class', 'chart');
    container.append('h3').text(name);

    var x = d3.scale.linear().range([0, chartWidth]);
    var y = d3.scale.linear().range([chartHeight, 0]);

    var xAxis = d3.svg.axis().scale(x).ticks(50).orient("bottom");
    var yAxis = d3.svg.axis().scale(y).ticks(5).orient("left");

    var line = d3.svg.line().x(function(d) { return x(d.x); }).y(function(d) { return y(d.y); });

    var svg = container.append('svg')
          .attr('width', chartWidth + margin.left + margin.right)
          .attr('height', chartHeight + margin.top + margin.bottom)
        .append("g")
          .attr('transform', 'translate(' + margin.left + ', ' + margin.right + ')');

    var clipId = "clip" + (clips++);
    svg.append("defs").append("clipPath")
        .attr("id", clipId)
      .append("rect")
        .attr("width", chartWidth)
        .attr("height", chartHeight);
     
    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + chartHeight + ")")
        .call(d3.svg.axis().scale(this.x).orient("bottom"));
     
    svg.append("g")
        .attr("class", "y axis")
        .call(d3.svg.axis().scale(this.y).orient("left"));
     
    var data = [];
    var path = svg.append("g")
        .attr("clip-path", "url(#" + clipId + ")")
      .append("path")
        .data([data])
        .attr("class", "line")
        .attr("d", line);

    this.addPoint = function(point) {
      data.push(point);
      path.attr("d", line);
    };
  }

  var chart = new StripChart(d3.select("body"), "TEST");
  var random = d3.random.normal(0, 0.2);
  var offset = 0;
  setInterval(function() {
    chart.addPoint({x: offset++, y: random()});
  }, 300);

  //ws.onmessage(function(data) {
  //  var i;
  //  for (i = 0; i < data.samples.length; i++) {
  //    var sample = data.samples[i];
  //    var chart = charts[sample.name];
  //    if (!chart) {
  //      chart = charts[sample.name] = new StripChart(d3.select('body'), sample.name);
  //    }
  //    chart.addPoint(sample.point);
  //  }
  //});

});
