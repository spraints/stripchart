$(function() {

  var startTime = new Date();
  var lastOffset = 1.0;
  var currentTime = function() {
    return lastOffset;
  };

  var chartSize = {n: 15.0, step: 5.0};

  $('body').on('click', '.js-adjust-window', function() {
    chartSize = $(this).data();
  });

  $('body').on('click', '.chart', function() {
    $(this).data('chart').toggleSize();
  });

  var clips = 0;
  function StripChart(container, name) {
    container = container.append('div').attr('class', 'chart');
    $(container[0][0]).data('chart', this);
    container.append('h3').text(name);

    var data = [];

    var margin = {top: 10, right: 10, bottom: 20, left: 70},
        width = 960 - margin.left - margin.right,
        lgHeight = 500 - margin.top - margin.bottom,
        smHeight = 80 - margin.top - margin.bottom,
        height = smHeight;

    var make_x_scale = function() {
      var t, range;
      if (chartSize.all) {
        t = currentTime();
        range = width;
      } else {
        t = d3.max([currentTime(), chartSize.n]);
        range = t * width / chartSize.n;
      }
      return d3.scale.linear()
        .domain([0, t])
        .range([0, range]);
    };
    var x = make_x_scale();

    var make_y_scale = function() {
      return d3.scale.linear()
        .domain(d3.extent(data, function(d) { return d.y; }))
        .range([height, 0]);
    };
    var y = make_y_scale();

    var line = d3.svg.line()
        .x(function(d) { return x(d.x); })
        .y(function(d) { return y(d.y); });

    var svgElement = container.append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
    var svg = svgElement.append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var clipId = "clip" + (clips++);
    var clipRect = svg.append("defs").append("clipPath")
        .attr("id", clipId)
      .append("rect")
        .attr("width", width)
        .attr("height", height);

    var make_x_axis = function() {
      var baseAxis = d3.svg.axis().scale(x).orient("bottom");
      if (chartSize.all) {
        return baseAxis.ticks(10);
      } else {
        var t = currentTime();
        var ticks = [];
        var i;
        for(i = 0; i <= t; i += chartSize.step) {
          ticks.push(i);
        }
        for(; i <= chartSize.n; i += chartSize.step) {
          ticks.push(i);
        }
        return baseAxis.tickValues(ticks);
      }
    };
    var xAxis = svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(d3.svg.axis().scale(x).orient("bottom"));

    var make_y_axis = function() {
      return d3.svg.axis().scale(y).ticks(4).orient("left");
    };
    var yAxis = svg.append("g")
        .attr("class", "y axis")
        .call(make_y_axis());

    var yGrid = svg.append("g")
        .attr("class", "grid")
        .call(make_y_axis().tickSize(-width, 0, 0).tickFormat(""));

    var path = svg.append("g")
        .attr("clip-path", "url(#" + clipId + ")")
      .append("path")
        .data([data])
        .attr("class", "line")
        .attr("d", line);

    var updateInterval = 500;
    var tick = function() {
      x = make_x_scale();
      y = make_y_scale();

      var t = currentTime();
      var xtrans = x((!chartSize.all && t > chartSize.n) ? (chartSize.n - t) : 0);

      svgElement.attr("height", height + margin.top + margin.bottom);
      clipRect.attr("height", height);

      xAxis
          .call(make_x_axis())
        .transition().duration(updateInterval).ease('linear')
          .attr("transform", "translate(" + xtrans + "," + height + ")");

      yAxis.call(make_y_axis());
      yGrid.call(make_y_axis().tickSize(-width, 0, 0).tickFormat(""));

      path
          .attr("d", line)
        .transition()
          .duration(updateInterval)
          .ease("linear")
          .attr("transform", "translate(" + xtrans + ")")
          .each('end', tick);
    }

    tick();

    this.addPoint = function(point) {
      data.push(point);
    };

    this.toggleSize = function() {
      height = (height == lgHeight) ? smHeight : lgHeight;
    };
  }

  var charts = {};
  var ws = new WebSocket($('body').data('websocket'));
  ws.onmessage = function(e) {
    var data = JSON.parse(e.data);
    var i;
    for (i = 0; i < data.samples.length; i++) {
      var sample = data.samples[i];
      var chart = charts[sample.name];
      lastOffset = data.offset;
      if (!chart)
        chart = charts[sample.name] = new StripChart(d3.select('body'), sample.name);
      chart.addPoint({x: data.offset, y: sample.value});
    }
  };

});
