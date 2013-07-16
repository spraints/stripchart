$(function() {

  var startTime = new Date();
  var currentTime = function() {
    return ((new Date()) - startTime) / 1000.0;
  };

  var clips = 0;
  function StripChart(container, name) {
    container = container.append('div').attr('class', 'chart');
    container.append('h3').text(name);

    var n = 20.0,
        tickStep = 10.0,
        data = [];

    var margin = {top: 10, right: 10, bottom: 20, left: 70},
        width = 960 - margin.left - margin.right,
        height = 80 - margin.top - margin.bottom;

    var make_x_scale = function() {
      var t = d3.max([currentTime(), n]);
      return d3.scale.linear()
        .domain([0, t])
        .range([0, t * width / n]);
    };
    var x = make_x_scale();

    var y = d3.scale.linear()
        .domain([-1, 1])
        .range([height, 0]);

    var line = d3.svg.line()
        .x(function(d) { return x(d.x); })
        .y(function(d) { return y(d.y); });

    var svg = container.append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var clipId = "clip" + (clips++);
    svg.append("defs").append("clipPath")
        .attr("id", clipId)
      .append("rect")
        .attr("width", width)
        .attr("height", height);

    var xAxis = svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(d3.svg.axis().scale(x).orient("bottom"));

    svg.append("g")
        .attr("class", "y axis")
        .call(d3.svg.axis().scale(y).orient("left"));

    var path = svg.append("g")
        .attr("clip-path", "url(#" + clipId + ")")
      .append("path")
        .data([data])
        .attr("class", "line")
        .attr("d", line);

    var tick = function() {
      x = make_x_scale();

      var t = currentTime();
      var xtrans = x((t > n) ? (n - t) : 0);
      var ticks = [];
      var i;
      for(i = 0; i <= t; i += tickStep) {
        ticks.push(i);
      }
      for(; i <= n; i += tickStep) {
        ticks.push(i);
      }

      xAxis
          .call(d3.svg.axis().scale(x).tickValues(ticks).orient("bottom"))
        .transition().duration(500).ease('linear')
          .attr("transform", "translate(" + xtrans + "," + height + ")");

      path
          .attr("d", line)
        .transition()
          .duration(500)
          .ease("linear")
          .attr("transform", "translate(" + xtrans + ")")
          .each('end', tick);
    }

    tick();

    this.addPoint = function(point) {
      data.push(point);
    };
  }

  var chart = new StripChart(d3.select("body"), "TEST");
  var chart2 = new StripChart(d3.select("body"), "OTHER");
  var random = d3.random.normal(0, 0.2);
  setInterval(function() {
    if (random() < 0.0)
      chart.addPoint({x: currentTime(), y: random()});
    if (random() < 0.1)
      chart2.addPoint({x: currentTime(), y: random()});
  }, 200);

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
