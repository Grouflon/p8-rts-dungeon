teslas={}
function tesla(_pos)
  local _e = entity(_pos)
  _e.target=nil
  _e.target_pos=vec2()
  _e.cooldown=20
  _e.cooldown_timer=0
  _e.name = "tesla"

  _e.added = function(_tesla)
    add(teslas, _tesla)
  end

  _e.removed = function(_tesla)
    del(teslas, _tesla)
  end

  _e.actions={}

  _e.start = function(_tesla)
   -- _tesla.cooldown_timer = rnd(20)
  end

  _e.update = function(_tesla)
    _tesla.cooldown_timer -= 1
    if (_tesla.cooldown_timer > 0) return
    _tesla.cooldown_timer = 10+rnd(10)

    for _t in all(teslas) do
      if (_tesla ~= _t) then

        local _dir = vec2_normalized(_t.pos - _tesla.pos)
        local a = bullet(_tesla.pos, _dir*1, _tesla)
        entity_add(a)
      end
    end
  end

  _e.draw = function(_entity)
    pset(_entity.pos.x, _entity.pos.y, 0)
  end
  return _e
end