vows=require 'vows'
assert={equal}=require 'assert'
{Game}=require '../public/game'
vows.describe('game test').addBatch(
  'when game create with 10,5':
    topic:->new Game 10,5
    'line is 5':(g)->equal g.line,5
    'side is 10':(g)->equal g.side,10
    'active is 0':(g)->equal g.active,0
    'field is array':(g)->assert.isArray g.field
    'field lines are arrays':(g)->assert g.field.every Array.isArray
    'error set 1':(g)->equal 0,g.set {y:-1,x:-1}
    'active is still 0':(g)->equal g.active,0
    'error set 2':(g)->equal 0,g.set {y:10,x:0}
    'normal set':(g)->equal -1,g.set {y:9,x:9}
    'now active is 1':(g)->equal g.active,1
    'error set 3':(g)->equal 0,g.set {y:9,x:9}
    'error set 4':(g)->equal 0,g.set()
  'simple game #1':
    topic:->new Game 5,3
    'step 1':(g)->equal -1,g.set {y:1,x:1}
    'step 2':(g)->equal -1,g.set {y:2,x:3}
    'step 3':(g)->equal -1,g.set {y:1,x:2}
    'step 4':(g)->equal -1,g.set {y:1,x:0}
    'step 5 and win':(g)->equal 1,g.set {y:1,x:3}
  'simple game #2':
    topic:->new Game 5,4
    'step 1':(g)->equal -1,g.set {y:2,x:2}
    'step 2':(g)->equal -1,g.set {y:3,x:3}
    'step 3':(g)->equal -1,g.set {y:2,x:3}
    'step 4':(g)->equal -1,g.set {y:2,x:1}
    'step 5':(g)->equal -1,g.set {y:3,x:4}
    'step 6':(g)->equal -1,g.set {y:1,x:0}
    'step 7':(g)->equal -1,g.set {y:0,x:0}
    'step 8':(g)->equal -1,g.set {y:4,x:3}
    'step 9':(g)->equal -1,g.set {y:2,x:0}
    'step 10 and win':(g)->equal 2,g.set {y:3,x:2}
  'simple game #3':
    topic:->new Game 10,5
    'step 1':(g)->equal -1,g.set {y:4,x:5}
    'error set':(g)->equal 0,g.set {y:4,x:5}
    'step 2':(g)->equal -1,g.set {y:5,x:5}
    'step 3':(g)->equal -1,g.set {y:3,x:4}
    'step 4':(g)->equal -1,g.set {y:5,x:6}
    'step 5':(g)->equal -1,g.set {y:6,x:5}
    'step 6':(g)->equal -1,g.set {y:4,x:4}
    'step 7':(g)->equal -1,g.set {y:6,x:3}
    'step 8':(g)->equal -1,g.set {y:3,x:6}
    'step 9':(g)->equal -1,g.set {y:2,x:3}
    'step 10':(g)->equal -1,g.set {y:6,x:6}
    'step 11':(g)->equal -1,g.set {y:4,x:6}
    'step 12':(g)->equal -1,g.set {y:3,x:3}
    'step 13':(g)->equal -1,g.set {y:2,x:2}
    'step 14 and win':(g)->equal 2,g.set {y:7,x:7}
).export module