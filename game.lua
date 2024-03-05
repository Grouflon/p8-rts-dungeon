--constants
skin_color={4,15}
clothes_color={2,3,8,10,11,12,14}

agent_count=4
order_speed=0.3

--variables
agents={}
actions={}

hovered_agents={}
selected_agents={}
level=nil

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

-- SYSTEM
function _init()
  printh("")
  printh("-----INIT-----")

  -- create level
  level=graph(0,0,16,16,0x1)

  -- spawn point
  for _n in all(level.nodes) do
    if _n.sprite==3 then
      local _world_pos=_n.pos*8
      add(agents,agent(1,_world_pos+vec2(3,3)))
      add(agents,agent(2,_world_pos+vec2(6,3)))
      add(agents,agent(3,_world_pos+vec2(6,6)))
      add(agents,agent(4,_world_pos+vec2(3,6)))
      break
    end
  end
end

function _update60()
  --mouse
  mouse_update()

  --selection
  hovered_agents={}
  local _selectable={}

  for _i=1,#agents do
    local _agent=agents[_i]
    local _agent_aabb=agent_aabb(_agent,4)

    if col_aabb_aabb(selection_aabb,_agent_aabb) then
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

  hovered_agents=_selectable
  if (mouse.released[1]) then
    if (#_selectable>0 and is_mouse_moved()) then -- single click
      selected_agents={_selectable[1]}
    else -- drag click or empty click
      selected_agents=_selectable
    end
  end

  -- orders
  if (mouse.pressed[2]) then
    foreach(selected_agents, function(_agent)
      agent_stop_actions(_agent)
      agent_goto(_agent,mouse.pos,order_speed)
      sfx(0)
    end)
  end

  mine_update()

  -- actions
  for i=#actions,1,-1 do
    action_update(actions[i])
  end
  
  -- agents
  foreach(agents,agent_update)
end

function _draw()
  local _bg_color=5
  cls(_bg_color)

  map(level.x,level.y,0,0,level.w,level.h,0x1)
  -- graph_draw_links(level)


  -- mine
  mine_draw()

  -- agents
  foreach(agents, agent_draw)
  foreach (hovered_agents, agent_over_draw)
  foreach (selected_agents, agent_selected_draw)

  mouse_draw()

  -- debug
  draw_log()
end
