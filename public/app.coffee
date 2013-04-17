class ClientGame extends Game
  @start:=>
    @_game?.socket.disconnect()
    @_game=new @ if CanvasRenderingContext2D?
  constructor:()->
    @socket=io.connect "http://#{location.host}:5467",{'reconnect':no,'force new connection':on}
    @socket.on 'error',=>@status 'Ошибка'
    @status 'Ожидаем начала игры...'
    @socket.on 'start',(init)=>
      {config:{side,line,square:@R},player:@player}=init
      super side,line
      # весим на события транспорта
      @socket.on 'set',@set
      @socket.once 'end',@end
      @socket.on 'disconnect',=>@status 'Подключение разорвано'
      # работаем с DOM и канвой
      canvas=document.createElement 'canvas'
      canvas.width=canvas.height=side*@R
      canvas.onclick=@onclick
      @context=canvas.getContext '2d'
      @drawGrid()
      @_layout.innerHTML=''
      @_layout.appendChild canvas
      @status()
  _layout:document.getElementById 'layout'
  _info:document.getElementById 'info'
  status:(d)=>
    @_info.innerHTML=d || if @active==@player then 'Ваш ход' else 'Ждем противника'
  set:(d)=>
    super d
    @draw d
    @status()
  end:(d)=>
    @socket.disconnect()
    alert 'Вы '+if d==@player then 'победили!' else 'проиграли!'
  onclick:(e)=>
    pos=@getXY e
    if @active==@player and @set pos
      @socket.emit 'step',pos
    no
  getXY:(ev)->
    if ev.offsetY then {y:ev.offsetY/@R|0,x:ev.offsetX/@R|0}
    else
      y:(window.pageYOffset+ev.clientY-ev.target.offsetTop)/@R|0
      x:(window.pageXOffset+ev.clientX-ev.target.offsetLeft)/@R|0
  # методы прорисовки
  drawGrid:()->
    C=@context
    R=@R
    for i in [0..@side]
      C.beginPath()
      C.strokeStyle='#777'
      C.lineWidth=1
      C.moveTo 0,i*R
      C.lineTo @side*R,i*R
      C.moveTo i*R,0
      C.lineTo i*R,@side*R
      C.stroke()
  draw:({y,x}={})->
    C=@context
    R=@R
    switch @field[y]?[x]
      when 1
        C.beginPath()
        C.strokeStyle='#f00'
        C.lineWidth=R/10
        C.moveTo x*R+R/6,y*R+R/6
        C.lineTo x*R+R-R/6,y*R+R-R/6
        C.moveTo x*R+R/6,y*R+R-R/6
        C.lineTo x*R+R-R/6,y*R+R/6
        C.stroke()
      when 2
        C.beginPath()
        C.strokeStyle='#00f'
        C.lineWidth=R/10
        C.arc x*R+R/2,y*R+R/2,R/3,0,Math.PI*2
        C.stroke()
document.getElementById('start').onclick=ClientGame.start