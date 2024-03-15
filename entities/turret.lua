function turret(_pos)
  local _e = entity(_pos)
  _e.pos=_pos
  _e.range=30
  _e.cooldown=20
  _e.cooldown_timer=0
  _e.target=nil

  _e.update = function(_turret)
    if (_turret.cooldown_timer > 0) _turret.cooldown_timer -= 1

    -- drop invalid target
    if _turret.target ~= nil then
      if not _turret.target.is_alive then
        _turret.target = nil
      elseif vec2_len(_turret.target.pos - _turret.pos) > _turret.range then 
        _turret.target = nil
      end
    end

    -- pick target
    if (_turret.target == nil) then
      local _closest_sqrdist = 0
      local _sqr_range = _turret.range*_turret.range
      for _agent in all(agents) do
        if (_agent.is_alive) then
          local _sqrdist = vec2_sqrlen(_turret.pos-_agent.pos)
          if _sqrdist < _sqr_range and (_turret.target == nil or _sqrdist < _closest_sqrdist) then
            _turret.target = _agent
            _closest_sqrdist = _sqrdist
          end
        end
      end
    end

    -- shoot
    if _turret.target ~= nil and _turret.cooldown_timer == 0 then
      local _dir = vec2_normalized(_turret.target.pos - _turret.pos)
      entity_add(bullet(_turret.pos, _dir*bullet_speed, _turret))
      _turret.cooldown_timer = _turret.cooldown
    end
  end

  _e.draw = function(_turret)
    circfill(_turret.pos.x, _turret.pos.y, 3, 9)
    if _turret.target ~= nil then
      circ(_turret.pos.x, _turret.pos.y, _turret.range, 8) -- range

      local _tip = _turret.pos + vec2_normalized(_turret.target.pos - _turret.pos) * 4
      line(_turret.pos.x, _turret.pos.y, _tip.x, _tip.y, 8)
    end
  end

  return _e
end
