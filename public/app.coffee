class ClientGame extends Game
  constructor:(init)->
    {side:@side,line:@line,square:@R}=init.config
    super @side,@line
    @player=init.player
    # весим события транспорта
    socket.on 'set',@set
    socket.on 'end',@onend
    socket.on 'disconnect',@status.bind(@,'Подключение разорвано')
    # работаем с DOM и канвой
    canvas=document.createElement('canvas')
    canvas.width=canvas.height=@side*@R
    canvas.onclick=@onclick
    @C=canvas.getContext('2d')
    @drawGrid()
    document.getElementById('layout').appendChild(canvas)
    @status()
  status:do->
    info=document.getElementById('info')
    (d)->info.innerText=d || if @active==@player then 'Ваш ход' else 'Ждем противника'
  set:(d)=>
    super d
    @draw d
    @status()
  onend:(d)=>
    alert 'Вы '+if d==@player then 'победили!' else 'проиграли!'
    location.reload()
  onclick:(e)=>
    x=(if e.layerX? then e.layerX else e.offsetX)/@R|0
    y=(if e.layerY? then e.layerY else e.offsetY)/@R|0
    unless @active!=@player or @field[y]?[x]
      @set {y,x}
      socket.emit 'step',{y,x}
    no
  # методы прорисовки
  drawGrid:()->
    C=@C
    R=@R
    for i in [0..@side]
      C.beginPath()
      C.strokeStyle='#777'
      C.lineWidth=1
      C.moveTo(0,i*R)
      C.lineTo(@side*R,i*R)
      C.moveTo(i*R,0)
      C.lineTo(i*R,@side*R)
      C.stroke()
  draw:({y,x})->
    C=@C
    R=@R
    switch @field[y]?[x]
      when 1
        C.strokeStyle='#f00'
        C.lineWidth=R/10
        C.beginPath()
        C.moveTo(x*R+R/6,y*R+R/6)
        C.lineTo(x*R+R-R/6,y*R+R-R/6)
        C.moveTo(x*R+R/6,y*R+R-R/6)
        C.lineTo(x*R+R-R/6,y*R+R/6)
        C.stroke()
        C.closePath()
      when 2
        C.strokeStyle='#00f'
        C.lineWidth=R/10
        C.beginPath()
        C.arc(x*R+R/2,y*R+R/2,R/3,0,Math.PI*2)
        C.closePath()
        C.stroke()
        C.closePath()
socket=io.connect "http://#{location.host}:5467"
socket.on 'start',((d)->new ClientGame(d))