function action_start(_definition,_agents,_p0,_p1,_p2,_p3)
  assert(_agents~=nil)
  _definition = _definition or {}
  _definition.start = _definition.start or function() end 
  _definition.stop = _definition.stop or function() end 
  if (_agents[1]==nil) _agents = {_agents} -- turn single value into arrays
  local _act={
    definition=_definition,
    co=cocreate(_definition.start),
    agents=_agents,
    args={_p0,_p1,_p2,_p3},
    alive=true,
  }
  foreach(_agents,function(_a)
    add(_a.actions,_act)
  end)
  add(actions,_act)
  return _act
end

function action_isalive(_act)
  if (not _act) return false
  if (not _act.alive) return false
  if (costatus(_act.co) == "dead") return false
  return true
end

function action_update(_act)
  if (not _act) return
  coresume(_act.co,_act,_act.args[1],_act.args[2],_act.args[3],_act.args[4])
  if (action_isalive(_act)) return

  action_stop(_act)
end

function action_stop(_act)
  if (not _act) return
  _act.definition.stop(_act)
  foreach(_act.agents,function(_a) del(_a.actions,_act) end)
  del(actions,_act)
  _act.alive=false
end