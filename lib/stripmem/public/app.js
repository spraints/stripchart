$(function() {

  var clips = 0;
  function StripChart(container, name) {
    container = container.append('div').attr('class', 'chart');
    container.append('h3').text(name);

    var n = 40,
        random = d3.random.normal(0, .2),
        data = d3.range(n).map(random);
     
    var margin = {top: 10, right: 10, bottom: 20, left: 40},
        width = 960 - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;
     
    var x = d3.scale.linear()
        .domain([0, n - 1])
        .range([0, width]);
     
    var y = d3.scale.linear()
        .domain([-1, 1])
        .range([height, 0]);
     
    var line = d3.svg.line()
        .x(function(d, i) { return x(i); })
        .y(function(d, i) { return y(d); });
     
    var svg = container.append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
     
    svg.append("defs").append("clipPath")
        .attr("id", "clip")
      .append("rect")
        .attr("width", width)
        .attr("height", height);
     
    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(d3.svg.axis().scale(x).orient("bottom"));
     
    svg.append("g")
        .attr("class", "y axis")
        .call(d3.svg.axis().scale(y).orient("left"));
     
    var path = svg.append("g")
        .attr("clip-path", "url(#clip)")
      .append("path")
        .data([data])
        .attr("class", "line")
        .attr("d", line);
     
    //tick();
     
    this.tick = function() {
     
      // push a new data point onto the back
      data.push(random());
     
      // redraw the line, and slide it to the left
      path
          .attr("d", line)
          .attr("transform", null)
        .transition()
          .duration(500)
          .ease("linear")
          .attr("transform", "translate(" + x(-1) + ")")
     
      // pop the old data point off the front
      data.shift();
     
    }

    this.addPoint = function(point) {
      data.push(point);
      path.attr("d", line);
    };
  }

  var chart = new StripChart(d3.select("body"), "TEST");
  var random = d3.random.normal(0, 0.2);
  var offset = 0;
  setInterval(function() {
    chart.tick();
    //chart.addPoint({x: offset++, y: random()});
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
