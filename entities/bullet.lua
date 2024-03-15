function bullet(_pos, _velocity, _owner)
  local _e = entity(_pos)
  _e.velocity = _velocity
  _e.name = "bullet"
  _e.owner =_owner

  _e.collide = function(_bullet, _entities)
    entity_remove(_bullet)
  end

  _e.update = function(_bullet)
    _bullet.pos+=_bullet.velocity
    if (
      (_bullet.pos.x < 0 or _bullet.pos.x > 128) or
      (_bullet.pos.y < 0 or _bullet.pos.y > 128) or
      graph_is_wall(level, _bullet.pos) 
    ) then
      entity_remove(_bullet)
      return
    end
  end

  _e.draw = function(_bullet)
    pset(_bullet.pos.x, _bullet.pos.y, 6)
  end
  
  return _e
end