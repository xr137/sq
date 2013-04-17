(if window? then window else exports).Game=class
  constructor:(@side,@line)->
    # генерируем пустое поле
    @field=(0 for [1..@side] for [1..@side])
  # активный игрок
  active:0
  set:({y,x}={})->
    field=@field
    # если ошибка - координаты не верны или клетка занята - возвращаем 0
    return 0 unless field[y]?[x]==0
    # ставим флаг
    point=field[y][x]=@active+1
    # меняем активного игрока
    @active=+!@active
    # проверяем, победил ли ходивший, если победил - возвращаем код игрока+1
    num=[0,0,0,0]
    for i in [1-@line...@line]
      if field[y][x+i]==point then ++num[0] else num[0]=0
      if field[y+i]?[x]==point then ++num[1] else num[1]=0
      if field[y+i]?[x+i]==point then ++num[2] else num[2]=0
      if field[y+i]?[x-i]==point then ++num[3] else num[3]=0
      return point if @line in num
    # нет - -1
    -1