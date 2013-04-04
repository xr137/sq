# amd на клиент тянуть не хочется, поизвращаемся с глобальным объектом, втч на ноде
(if typeof window=='undefined' then global else window).Game=class
  constructor:(@side,@line)->
    # генерируем пустое поле
    @field=for a in [0...@side] then for b in [0...@side] then 0
  # активный игрок
  active:0
  # ставим флаг и меняем активного игрока
  set:({y,x})->
    @field[y]?[x]=@active+1
    @active=+!@active
  # проверяем, победил ли ходивший
  test:({y,x})->
    point=@field[y][x]
    num=[0,0,0,0]
    for i in [1-@line...@line]
      if @field[y+i]?[x]==point then ++num[0] else num[0]=0
      if @field[y]?[x+i]==point then ++num[1] else num[1]=0
      if @field[y+i]?[x+i]==point then ++num[2] else num[2]=0
      if @field[y+i]?[x-i]==point then ++num[3] else num[3]=0
      if @line in num then return point
    no