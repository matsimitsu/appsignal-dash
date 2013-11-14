//= require jquery
//= require d3

urlParam = (name) ->
  res = new RegExp("[\\?&]#{name}=([^&#]*)").exec(window.location.href)
  res[1] if res != null

getDate = (el) ->
  new Date(el.timestamp * 1000)

renderCounter = (res) ->
  field = urlParam('field')
  postfix = urlParam('postfix')
  subtitle = urlParam('subtitle')

  last = d3.max(res.data, (d) -> d.timestamp)
  point = res.data.filter((x) =>
    x.timestamp == last
  )[0]
  $(".container h1").html("#{point[field]}<span>#{postfix}</span>")
  $(".container h2").html(subtitle)
renderGraph = (res) ->
  full_data = []
  from = new Date(res.from)
  to = new Date(res.to)
  field = urlParam('field')

  top = d3.max(res.data, (d) -> d[field])

  w = $(window).width()
  h = $(window).height()

  x = d3.time.scale().domain([from, to]).range([0, w])
  y = d3.scale.linear().domain([0, top]).range([h, 0])

  scale = d3.time.scale.utc().domain([from, to])
  ticks = scale.ticks(d3.time.minutes, 1)

  for date, i in ticks
    time = date.getTime() /1000
    point = res.data.filter((x) =>
      x.timestamp == time
    )[0]
    if point
      full_data.push(point)
    else
      full_data.push({'timestamp': time})

  # create the area (closed path) that will be the response response time graph
  garea = d3.svg.area()
    .interpolate("basis")
    .x((d) ->
      x(getDate(d))
    )
    .y0(Math.max(h - 1, h))
    .y1((d) ->
      y(d[field])
    )

  line = d3.svg.line()
    .interpolate("basis")
    .x((d) ->
      x(getDate(d))
    )
    .y((d) ->
      y(d[field])
    )

  graph = d3.select('.container').append("svg:svg")
      .attr("width", w)
      .attr("height", h)
      .attr("class", 'graph')
    .append("svg:g")
      .attr("transform", "translate(0,0)")

  # Add the line by appending an svg:path element with the data line we created above
  # do this AFTER the axes above so that the line is above the tick-lines
  #graph.append("svg:path")
  #  .attr("d", garea(full_data))
  #  .attr("class", "area")

  graph.append("svg:path")
    .attr("d", line(full_data))
    .attr("class", "line")

$(document).ready ->
  site_id = urlParam('site_id')
  field = urlParam('field')
  token = urlParam('token')

  $('.container')
    .height($(window).height())
    .width($(window).width())

  endpoint = "https://appsignal.com/api/#{site_id}/graphs.json?fields[]=#{field}&token=#{token}&callback=?"
  renderGraph($('.container').data('json'))
  renderCounter($('.container').data('json'))
  #$.getJSON endpoint, (res) =>
  #  console.log(res)

#/api/50f41e9e0480d50000000004/graphs.json?fields%5B%5D=ex_rate&from=2013-11-13+17%3A08%3A01+%2B0100&mapping%5Bex_rate%5D=Error+rate&token=H3T9riL2TgaxbWND1eUe
