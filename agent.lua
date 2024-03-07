function agent(_id,_pos)
  local _seed=rnd()
  srand(_seed)
  local _a={
    id=_id,
    seed=_seed,
    pos=vec2(_pos),
    colors={
      rnd(skin_color),
      rnd(clothes_color)
    },
    actions={},
-- mode=0
}
return _a
end

--AGENT ACTIONS
function agent_goto(_agent,_target,_speed)
  local _goto_action={
    start=function(_action,_target,_speed)
      local _a=_action.agents[1]
      _speed=_speed or wander_speed
      _target=vec2(_target)
      local _origin=vec2(_a.pos)
      local _traj=_target-_a.pos
      local _timer=0
      local _time=0
      if (_speed>0) _time=vec2_len(_traj)/_speed
      local _t=0
      if (_time<=0) _t=1
      repeat
        _t=_timer/_time
        _a.pos=vec2_lerp(_origin,_target,_t)
        _timer+=1
        yield()
      until (_t>=1)
    end
  }
  action_start(_goto_action,_agent,_target,_speed)
end

function agent_follow_path(_agent,_path,_speed)
  local _goto_action={
    start=function(_action,_path,_speed)
      local _dist=0
      for _i=1,#_path-1 do
        local _start, _end = _path[_i], _path[_i+1]
        assert(_start ~= nil)
        assert(_end ~= nil)
        local _traj=_end-_start
        local _len=vec2_len(_traj)
        local _dir=vec2_normalized(_traj)
        while _dist < _len do
          _agent.pos=_start+_dir*_dist
          yield()
          _dist+=_speed
        end
        _dist-=_len
      end
      _agent.pos=_path[#_path]
    end
  }
  action_start(_goto_action,_agent,_path,_speed)
end

function agent_wait(_agent,_time)
  local _wait_action={
    start=function(_action,_time)
      local _timer=_time
      while(_timer>0) do
        _timer-=1
        yield()
      end
    end
  }
  action_start(_wait_action,_agent,_time)
end


function agent_stop_actions(_a)
  for i=#_a.actions,1,-1 do
    action_stop(_a.actions[i])
  end
end

function agent_aabb(_a,_margin)
  _margin=_margin or 0
  return {
    _a.pos.x-_margin,
    _a.pos.y-1-_margin,
    _a.pos.x+1+_margin,
    _a.pos.y+_margin
  }
end

function agents_collision()
  local _selectable={}

  for _i=1,#agents do
    local _agent=agents[_i]
    local _agent_aabb=agent_aabb(_agent,4)

    if col_aabb_aabb(mouse.selection_aabb,_agent_aabb) then
      add(_selectable,_agent)
    end
  end
  -- sort by distance to the mouse
  sort(_selectable, function(_a, _b)
    local _a_dist=vec2_sqrlen(mouse.pos-_a.pos)
    local _b_dist=vec2_sqrlen(mouse.pos-_b.pos)
    if (_a_dist<_b_dist) return -1
    if (_a_dist>_b_dist) return 1
    return 0
  end)

  if #_selectable>0 then
    if mouse_is_box_selecting() then
      apply(hovered_agents,_selectable)
    else
      apply(hovered_agents,{_selectable[1]})
    end
  end
  if mouse.released[1] then
    apply(selected_agents,hovered_agents)
  end
end

function agents_update()
  -- orders
  if (mouse.pressed[2]) then
    for _agent in all(selected_agents) do
      agent_stop_actions(_agent)
      path = find_path(level, _agent.pos, mouse.pos)
      if path ~= nil then
        agent_follow_path(_agent, path, order_speed)
        sfx(0)
      end
    end
  end

  -- actions
  for i=#actions,1,-1 do
    action_update(actions[i])
  end

  -- agents
  foreach(agents,agent_update)
end

function agent_update(_a)
end

function agent_draw(_a)
  pset(_a.pos.x,_a.pos.y,_a.colors[2])
  pset(_a.pos.x,_a.pos.y-1,_a.colors[1])
  pset(_a.pos.x+1,_a.pos.y,1)
end

function agent_hover_draw(_a)
  local _x,_y=_a.pos.x,_a.pos.y
  local _c=6
  if (mouse.down[1]) _c=7
  pset(_x,  _y-3,_c)
  pset(_x-2,_y-3,_c)
  pset(_x+2,_y-3,_c)
  pset(_x  ,_y+3,_c)
  pset(_x-2,_y+3,_c)
  pset(_x+2,_y+3,_c)
  pset(_x-4,_y-1,_c)
  pset(_x-4,_y+1,_c)
  pset(_x+4,_y-1,_c)
  pset(_x+4,_y+1,_c)
end

function agent_selected_draw(_agent)
  local _hw=4
  local _hh=3
  color(6)
  if (contains(hovered_agents,_agent)) color(7)
  oval(
    _agent.pos.x-_hw,
    _agent.pos.y-_hh,
    _agent.pos.x+_hw,
    _agent.pos.y+_hh
  )
end