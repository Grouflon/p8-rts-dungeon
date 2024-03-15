entities={}

function entity(_pos)
  return {
    pos=_pos,
    pos_old=_pos,
    priority=0,
    -- functions
    added=nil,
    removed=nil,
    start=nil,
    collide=nil,
    update=nil,
    draw=nil,
    collider={},
    owner=nil
  }
end

function entity_add(_entity)
  assert(_entity ~= nil)
  if (_entity.added ~= nil) _entity.added(_entity)
  add(entities, _entity)
end

function entity_remove(_entity)
  assert(_entity ~= nil)
  local _ret = del(entities, _entity)
  assert(_ret == _entity)
  if (_entity.removed ~= nil) _entity.removed(_entity)
end

function entities_update()
  sort(entities, function(_a, _b)
    return compare(_a.priority, _b.priority)
  end)

  for i=#entities,1,-1 do
    local _entity=entities[i]
    if (_entity.start ~= nil) then
      _entity.start(_entity)
      _entity.start = nil
    end
  end
  
  for i=#entities,1,-1 do
    local _entity=entities[i]
    if (_entity.update ~= nil) then
      _entity.pos_old = _entity.pos
      _entity.update(_entity)
      _entity.collider = {}
    end
  end

  for i=#entities,1,-1 do
    local _entity=entities[i]
    for u=i-1,1,-1 do 
      if (col(_entity, entities[u])) then
        add(_entity.collider, entities[u])
        add(entities[u].collider, _entity)
      end
    end
  end

  for i=#entities,1,-1 do
    local _entity=entities[i]
    if (_entity.collide ~= nil and #_entity.collider > 0) then 
      _entity.collide(_entity, _entity.collider)
    end
  end
end

function col(a, b)
  local AB = a.pos - a.pos_old
  local BC = b.pos - a.pos
  local AC = b.pos - a.pos_old
  
  if ((a.owner ~= nil) and (a == b.owner or a.owner == b or a.owner == b.owner)) then
    return false
  end

  return (
     ((vec2_cross(AB, BC) == 0 and
      vec2_dot(AB,AC) > 0 and
      vec2_dot(AB,BC) < 0) or
      vec2_len(BC) < 1))
end

function entities_draw()
  sort(entities, function(_a, _b)
    return -compare(_a.pos.y, _b.pos.y)
  end)

  for _entity in all(entities) do
    if (_entity.draw ~= nil) _entity.draw(_entity)
  end
end
