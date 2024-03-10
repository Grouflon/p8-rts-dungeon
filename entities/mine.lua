mines = {}

function mine(_pos)
  local _e = entity(_pos)
  _e.radius=1
  _e.timer=0.2
  _e.time=0
  _e.isstart=true
  _e.isactived=false
  _e.isboom=false
  _e.hasboom=false
  _e.explosion_radius=5

  _e.added = function(_mine)
    add(mines, _mine)
  end

  _e.removed = function(_mine)
    del(mines, _mine)
  end

  _e.update = function(_m)
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

  _e.draw = function(_mine)
    if (_mine.hasboom) then
     -- circfill(_m.pos.x, _m.pos.y,_m.radius,7)
    elseif (_mine.isboom) then
      pset(_mine.pos.x, _mine.pos.y,8)
      circfill(_mine.pos.x, _mine.pos.y,_mine.explosion_radius,8)
    elseif (_mine.isactived) then
      pset(_mine.pos.x, _mine.pos.y,9)
    else
      pset(_mine.pos.x, _mine.pos.y,10)
    end
  end

  return _e
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