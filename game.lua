poke(0x5f2d, 1) -- enable mouse

--constants
skin_color={4,15}
clothes_color={2,3,8,10,11,12,14}

agent_count=4
order_speed=0.3

--variables
agents={}
actions={}

mouse={
  pos=vec2(),
  pressed={false,false},
  released={false,false},
  down={false,false}
}

selection_start=nil
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
  mouse.pos=vec2(stat(32),stat(33))
  local _prev_mouse_down={mouse.down[1],mouse.down[2]}
  mouse.down[1]=(stat(34)&1)>0
  mouse.down[2]=(stat(34)&2)>0
  mouse.pressed[1]=not _prev_mouse_down[1] and mouse.down[1]
  mouse.pressed[2]=not _prev_mouse_down[2] and mouse.down[2]
  mouse.released[1]=_prev_mouse_down[1] and not mouse.down[1]
  mouse.released[2]=_prev_mouse_down[2] and not mouse.down[2]

  --selection
  hovered_agents={}
  local _selectable={}
  local _selection_aabb={
    mouse.pos.x,
    mouse.pos.y,
    mouse.pos.x,
    mouse.pos.y
  }

  if (mouse.pressed[1]) selection_start=vec2(mouse.pos)
  if (selection_start~=nil) then
    _selection_aabb[1]=selection_start.x
    _selection_aabb[2]=selection_start.y
  end
  _selection_aabb={
    min(_selection_aabb[1],_selection_aabb[3]),
    min(_selection_aabb[2],_selection_aabb[4]),
    max(_selection_aabb[1],_selection_aabb[3])+1,
    max(_selection_aabb[2],_selection_aabb[4])+1,
  }

  for _i=1,#agents do
    local _agent=agents[_i]
    local _agent_aabb=agent_aabb(_agent,4)

    if col_aabb_aabb(_selection_aabb,_agent_aabb) then
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
    if (#_selectable>0 and equals(mouse.pos,selection_start)) then -- single click
      
      selected_agents={_selectable[1]}
    else -- drag click or empty click
      selected_agents=_selectable
    end
    selection_start=nil
  end

  -- orders
  if (mouse.pressed[2]) then
    foreach(selected_agents, function(_agent)
      agent_stop_actions(_agent)
      agent_goto(_agent,mouse.pos,order_speed)
      sfx(0)
    end)
  end

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
  
  foreach (hovered_agents, function(_agent)
    local _x,_y=_agent.pos.x,_agent.pos.y
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
  end)

  foreach (selected_agents, function(_agent)
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
  end)

  if (selection_start ~= nil) then
    fillp(0b0101101001011010.1)
    rect(selection_start.x, selection_start.y, mouse.pos.x, mouse.pos.y, 7)
    fillp()
  end

  -- agents
  foreach(agents, agent_draw)
  
  -- cursor
  spr(1,mouse.pos.x-1,mouse.pos.y)

  -- debug
  draw_log()
end
