entities={}

function entity(_pos)
  return {
    pos=_pos,
    priority=0,
    -- functions
    added=nil,
    removed=nil,
    update=nil,
    draw=nil,
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
    if (_entity.update ~= nil) _entity.update(_entity)
  end
end

function entities_draw()
  sort(entities, function(_a, _b)
    return -compare(_a.pos.y, _b.pos.y)
  end)

  for _entity in all(entities) do
    if (_entity.draw ~= nil) _entity.draw(_entity)
  end
end
