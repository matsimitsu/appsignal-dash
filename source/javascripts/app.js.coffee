//= require jquery
//= require d3
//= require moment

urlParam = (name) ->
  res = new RegExp("[\\?&]#{name}=([^&#]*)").exec(window.location.href)
  res[1] if res != null

getDate = (el) ->
  new Date(el.timestamp * 1000)

renderCounter = (res) ->
  field = urlParam('field')
  postfix = urlParam('postfix') || ''
  subtitle = urlParam('subtitle') || ''

  point = res.data.sort((a, b) -> return b - a )[1]
  $(".container h1").html("#{Math.round(point[field])}<span>#{unescape(postfix)}</span>")
  $(".container h2").html(unescape(subtitle))

renderGraph = (res) ->
  full_data = []
  from = new Date(res.from)
  to = new Date(res.to)
  field = urlParam('field')

  top = d3.max(res.data, (d) -> d[field])

  w = $(window).width()
  h = Math.round($(window).height() / 3) * 2

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

  line = d3.svg.line()
    .interpolate("basis")
    .x((d) ->
      x(getDate(d))
    )
    .y((d) ->
      y(d[field])
    )

  $('.container svg').remove()
  graph = d3.select('.container').append("svg:svg")
      .attr("width", w)
      .attr("height", h)
      .attr("class", 'graph')
    .append("svg:g")
      .attr("transform", "translate(0,0)")

  graph.append("svg:path")
    .attr("d", line(full_data))
    .attr("class", "line")

getJSON = (endpoint) ->

  $.getJSON endpoint, (res) =>
    renderCounter(res)
    renderGraph(res)

  setTimeout ( ->
    getJSON(endpoint)
  ), 60000

$(document).ready ->
  site_id = urlParam('site_id')
  field = urlParam('field')
  token = urlParam('token')
  color = urlParam('color') || 'ffffff'
  bg_color = urlParam('bg_color') || '967cac'

  four_hours_ago = moment().subtract('hours', 4).format()
  endpoint = "https://appsignal.com/api/#{site_id}/graphs.json?fields[]=#{field}&token=#{token}&from=#{four_hours_ago}&callback=?"

  $('.container')
    .height($(window).height())
    .width($(window).width())
    .css('color', "##{color}")
    .css('background-color', "##{bg_color}")

  getJSON(endpoint)
