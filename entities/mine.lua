mine={}
mine.pos=vec2()
mine.pos.x=50
mine.pos.y=50
mine.radius=1
mine.timer=0
mine.time=0
mine.isstart=true
mine.isactived=false
mine.isboom=false
mine.hasboom=false
mine.explosion_radius=1

function mine_update(_m)
  if(_m.isboom) then
    _m.isboom = false
    _m.hasboom = true
  end
  if (_m.isstart) then
    for _a in all(agents) do
      if (vec2_len(_a.pos-_m.pos) < _m.radius) then
        _m.isactived = true
        _m.isstart = false
      end
    end
  end

  if (_m.isactived) then
    _m.time+=1/60
    if (_m.time>_m.timer) then
      for _a in all(agents) do
        if (vec2_len(_a.pos-_m.pos) < _m.explosion_radius) then
          agent_kill(_a)
        end
      end
      _m.isboom=true
      _m.isactived=false
    end
  end
end

function mine_draw(_m)
  if (_m.hasboom) then
   -- circfill(_m.pos.x, _m.pos.y,_m.radius,7)
  elseif (_m.isboom) then
    pset(_m.pos.x, _m.pos.y,8)
    circfill(_m.pos.x, _m.pos.y,_m.radius,8)
  elseif (_m.isactived) then
    pset(_m.pos.x, _m.pos.y,9)
  else
    pset(_m.pos.x, _m.pos.y,10)
  end
end