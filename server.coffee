require './public/game'
config=require './config'
class ServerGame extends Game
  constructor:(@games,@users)->
    super config.side,config.line
    @games.push(@)
    @users.forEach ((u,i)->
      u.emit('start',{config,player:i})
      u.on 'step',(e)=>
        if i==@active
          @set(e)
          @users[+!i].emit('set',e)
          if test=@test(e) then @end(test-1)
      ),@
  end:(p)->
    for u in @users then u.emit('end',p)
    @games[@id]=null
  step:()->
class Application
  constructor:->
    @games=[]
  await:null
  onconnect:(socket)=>
    # если в очереди есть клиент - создаем с ним игру, нет - ставим в очередь
    @await=if @await
      new ServerGame(@games,[@await,socket])
      null
    else socket
# создаем сервер и приложение, на подключение клиента весим onconnect приложения
require('socket.io')
  .listen(5467,{'log level':2,'browser client':no})
  .sockets.on 'connection',new Application().onconnect