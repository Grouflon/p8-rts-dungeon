function mine(_p)
  local _mine={
    pos=_p,
    radius=1,
    timer=0.3,
    time=0,
    isstart=true,
    isactived=false,
    isboom=false,
    hasboom=false,
    explosion_radius=8
  }
  return _mine
end

function mine_active(_m)
  _m.isactived = true
  _m.isstart = false
end

function mine_explode(_m)
  for _a in all(agents) do
    if (vec2_len(_a.pos-_m.pos) < _m.explosion_radius) then
      agent_kill(_a)
    end
  end
  for _mn in all(mines) do
    if (_mn.isstart and vec2_len(_mn.pos-_m.pos) < _m.explosion_radius) then
      mine_active(_mn)
    end
  end
  _m.isboom=true
  _m.isactived=false
  _m.time=0
  sfx(1)
end

function mine_update(_m)
  if(_m.isboom) then
    _m.time+=1/60
    if (_m.time>1) then
    _m.isboom = false
    _m.hasboom = true
    end
  end
  if (_m.isstart) then
    for _a in all(agents) do
      if (vec2_len(_a.pos-_m.pos) < _m.radius) then
        mine_active(_m)
      end
    end
  end

  if (_m.isactived) then
    _m.time+=1/60
    if (_m.time>_m.timer) then
      mine_explode(_m)
    end
  end
end

function mine_draw(_m)
  if (_m.hasboom) then
   -- circfill(_m.pos.x, _m.pos.y,_m.radius,7)
  elseif (_m.isboom) then
    pset(_m.pos.x, _m.pos.y,8)
    circfill(_m.pos.x, _m.pos.y,_m.explosion_radius,8)
  elseif (_m.isactived) then
    pset(_m.pos.x, _m.pos.y,9)
  else
    pset(_m.pos.x, _m.pos.y,10)
  end
end