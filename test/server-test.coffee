vows=require 'vows'
{equal,isNull}=require 'assert'
io=require 'socket.io-client'
{series,parallel}=require 'async'
Promise=require('events').EventEmitter
options=[
  'http://127.0.0.1:5467'
  {transports:['websocket'],'force new connection':on,'reconnect':no}
  ]
vows.describe('server test').addBatch(
  'start game':
    topic:->
      socket1=io.connect options...
      socket1.once 'connect',->
        socket2=io.connect options...
        parallel [
          (cb)->socket1.once 'start',(r)->cb null,r
          (cb)->socket2.once 'start',(r)->cb null,r
          ],(e,rez)->p.emit 'success',rez,socket1,socket2
      setTimeout (->p.emit 'error','timeout'),10000
      p=new Promise
    'connect and start game':(e,r)->isNull e
    'socket 1 is player 0':(e,[a,b])->equal a.player,0
    'socket 2 is player 1':(e,[a,b])->equal b.player,1
    'line is 5':(e,[a,b])->
      equal a.config.line,5
      equal b.config.line,5
    'side is 10':(e,[a,b])->
      equal a.config.side,10
      equal b.config.side,10
    'step':
      topic:(r,socket1,socket2)->
        socket2.once 'set',(rez)->p.emit 'success',{rez,socket1,socket2}
        socket1.emit 'step',{y:4,x:5}
        setTimeout (->p.emit 'error','timeout'),10000
        p=new Promise
      'step and set':(e,r)->isNull e
      'y is 2':(e,r)->equal r.rez.y,4
      'x is 1':(e,r)->equal r.rez.x,5
      'game':
        topic:({socket1,socket2})->
          parallel [
            (cb)->socket1.once 'end',(r)->cb null,r
            (cb)->socket2.once 'end',(r)->cb null,r
            ],(e,rez)->p.emit 'success',rez
          setTimeout (->p.emit 'error','timeout'),10000
          series [
            (cb)->
              socket1.once 'set',->cb null
              socket2.emit 'step',{y:5,x:5}
            (cb)->
              socket2.once 'set',->cb null
              socket1.emit 'step',{y:3,x:4}
            (cb)->
              socket1.once 'set',->cb null
              socket2.emit 'step',{y:5,x:6}
            (cb)->
              socket2.once 'set',->cb null
              socket1.emit 'step',{y:6,x:5}
            (cb)->
              socket1.once 'set',->cb null
              socket2.emit 'step',{y:4,x:4}
            (cb)->
              socket2.once 'set',->cb null
              socket1.emit 'step',{y:6,x:3}
            (cb)->
              socket1.once 'set',->cb null
              socket2.emit 'step',{y:3,x:6}
            (cb)->
              socket2.once 'set',->cb null
              socket1.emit 'step',{y:2,x:3}
            (cb)->
              socket1.once 'set',->cb null
              socket2.emit 'step',{y:6,x:6}
            (cb)->
              socket2.once 'set',->cb null
              socket1.emit 'step',{y:4,x:6}
            (cb)->
              socket1.once 'set',->cb null
              socket2.emit 'step',{y:3,x:3}
            (cb)->
              socket2.once 'set',->cb null
              socket1.emit 'step',{y:2,x:2}
            ->socket2.emit 'step',{y:7,x:7}
            ]
          p=new Promise
        'game':(e,r)->isNull e
        'in socket 1 scope win socket 2':(e,r)->equal r[0],1
        'in socket 2 scope win socket 2':(e,r)->equal r[1],1
    'disconnect':
      topic:->
        socket1=io.connect options...
        socket1.once 'connect',->
          socket2=io.connect options...
          parallel [
            (cb)->socket1.once 'start',->cb null
            (cb)->socket2.once 'start',->cb null
            ],->
              socket1.once 'end',(rez)->p.emit 'success',rez
              socket2.disconnect()
        setTimeout (->p.emit 'error','timeout'),10000
        p=new Promise
      'disconnect':(e,r)->isNull e
      'socket 1 win':(e,rez)->equal rez,0
      'error set':
        topic:->
          socket1=io.connect options...
          socket2=null
          series [
            (cb)->socket1.once 'connect',->cb null
            (cb)->
              socket2=io.connect options...
              socket2.once 'start',->cb null
            (cb)->
              socket1.once 'set',->cb null
              socket2.emit 'step',{y:5,x:5}
            (cb)->
              socket2.once 'set',->p.emit 'error','error'
              socket1.emit 'step',{y:5,x:5}
            ]
          setTimeout (->p.emit 'success'),100
          p=new Promise
        'error set':(e,r)->isNull e
).export module