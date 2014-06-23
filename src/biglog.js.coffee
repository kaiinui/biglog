window.BigLog = {}
SAMPLE_RATE = 25
sample_i = 0
BigLog._queue = ""

BigLog.onready = ->
  BigLog._log ["ready", location.href]
  $("a").on 'click', (e)->
    BigLog._log ["a", getXPath(this)]
  $(".scrollable").on 'scroll', ->
    xpath = getXPath(this)
    $el = $(this)
    BigLog._sample =>
      BigLog._log ["scroll", xpath, $el.scrollLeft()]
  $(document).on 'scroll', ->
    $el = $(this)
    BigLog._sample =>
      BigLog._log ["scroll", "window", _scroll()]
  $(document).on 'keypress', (e)->
    BigLog._log ["key", e.keyCode]

  setInterval ->
    BigLog._write_queue() if BigLog._queue
  , 1000

BigLog._sample = (f)->
  sample_i+=1
  if sample_i < SAMPLE_RATE
    return
  sample_i=0
  f.call()

BigLog._log = (array)->
  array.unshift _now()
  console.log array
  BigLog._queue += "#{array.join(";")}<>"

BigLog._write_queue = ->
  prev = localStorage.getItem "BIGLOG_QUEUE"
  prev = "" if prev is null
  localStorage.setItem "BIGLOG_QUEUE", "#{prev}#{BigLog._queue}"
  BigLog._queue = ""

performance_compatible = !!(window.performance && window.performance.timing)
_now = ->
  if false # Now we do not use performance.now() due to difficulty to compare performance.now() and Date.getTime()
    performance.now()
  else
    (new Date()).getTime() - start_time

_scroll = ->
  if(typeof pageYOffset!= 'undefined')
    pageYOffset
  else
    b = document.body #IE 'quirks'
    d = document.documentElement #IE with doctype
    d = (d.clientHeight)? d: b
    d.scrollTop