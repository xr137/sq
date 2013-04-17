io=require 'socket.io'
config=require './config'
{Game}=require './public/game'
class ServerGame extends Game
  constructor:(@users)->
    super config.side,config.line
    # весим события транспорта и сообщаем о начале игры
    @users.forEach (socket,i)=>
      socket.on 'step',(e)=>
        if i==@active and rez=@set e
          @users[+!i].emit 'set',e
          # можно было отдать на откуп клиенту, но что бы тогда от сервера осталось?:)
          @end rez-1 if rez>0
      socket.on 'disconnect',=>@end +!i
      socket.emit 'start',{config,player:i}
  end:(win)->
    socket.emit 'end',win for socket in @users
class Application
  await:null
  onconnect:(socket)=>
    # если в очереди есть клиент - создаем с ним игру, нет - ставим в очередь
    @await=if @await
      new ServerGame [@await,socket]
      null
    else socket
# создаем сервер и приложение, на подключение клиента весим onconnect приложения
io.listen(5467,{'log level':2,'browser client':no})
  .sockets.on 'connection',new Application().onconnect