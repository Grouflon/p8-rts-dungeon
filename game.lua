--constants
skin_color={4,15}
clothes_color={2,3,8,10,11,12,14}

order_speed=0.4
bullet_speed=2

--variables
agents={}
turrets={}
bullets={}
actions={}
level=nil

function bullet(_pos, _velocity)
  return {
    pos=_pos,
    velocity=_velocity,
  }
end

function bullet_update(_bullet)
  _bullet.pos+=_bullet.velocity
  if (
    (_bullet.pos.x < 0 or _bullet.pos.x > 128) or
    (_bullet.pos.y < 0 or _bullet.pos.y > 128) or
    graph_is_wall(level, _bullet.pos)
  ) then
    del(bullets, _bullet)
    return
  end
end

function bullet_draw(_bullet)
  pset(_bullet.pos.x, _bullet.pos.y, 6)
end

function turret(_pos)
  return {
    pos=_pos,
    range=30,
    cooldown=20,
    cooldown_timer=0,
    target=nil,
  }
end

function turret_update(_turret)
  if (_turret.cooldown_timer > 0) _turret.cooldown_timer -= 1

  -- drop invalid target
  if _turret.target ~= nil then
    if (not _turret.target.is_alive) _turret.target = nil
    if (vec2_len(_turret.target.pos - _turret.pos) > _turret.range) _turret.target = nil
  end

  -- pick target
  if (_turret.target == nil) then
    local _closest_sqrdist = 0
    local _sqr_range = _turret.range*_turret.range
    for _agent in all(agents) do
      local _sqrdist = vec2_sqrlen(_turret.pos-_agent.pos)
      if _sqrdist < _sqr_range and (_turret.target == nil or _sqrdist < _closest_sqrdist) then
        _turret.target = _agent
        _closest_sqrdist = _sqrdist
      end
    end
  end

  -- shoot
  if _turret.target ~= nil and _turret.cooldown_timer == 0 then
    local _dir = vec2_normalized(_turret.target.pos - _turret.pos)
    add(bullets,bullet(_turret.pos, _dir*bullet_speed))
    _turret.cooldown_timer = _turret.cooldown
  end
end

function turret_draw(_turret)
  circfill(_turret.pos.x, _turret.pos.y, 3, 9)
  if _turret.target ~= nil then
    circ(_turret.pos.x, _turret.pos.y, _turret.range, 8) -- range

    local _tip = _turret.pos + vec2_normalized(_turret.target.pos - _turret.pos) * 4
    line(_turret.pos.x, _turret.pos.y, _tip.x, _tip.y, 8)
  end
end

-- SYSTEM
function _init()
  printh("")
  printh("-----INIT-----")

  -- create level
  level=graph(0,0,16,16,0x1)

  for _n in all(level.nodes) do
    -- spawn point
    if _n.sprite==3 then
      local _world_pos=_n.pos
      add(agents,agent(1,_world_pos+vec2(-1,-1)))
      add(agents,agent(2,_world_pos+vec2(2,-1)))
      add(agents,agent(3,_world_pos+vec2(2,2)))
      add(agents,agent(4,_world_pos+vec2(-1,2)))
      break
    end

    -- turret
    if _n.sprite==4 then
      add(turrets,turret(_n.pos+vec2(4,4)))
    end
  end
end

function _update60()
  --mouse
  mouse_update()

  -- selection
  selection_update()

  -- orders
  if (mouse.pressed[2]) then
    for _agent in all(selection.selected_agents) do
      agent_stop_actions(_agent)
      path = find_path(level, _agent.pos, mouse.pos)
      if path ~= nil then
        agent_follow_path(_agent, path, order_speed)
        -- sfx(0)
      end
    end
  end

  mine_update(mine)

  -- actions
  for i=#actions,1,-1 do
    action_update(actions[i])
  end
  
  -- agents
  foreach(agents,agent_update)
  foreach(turrets,turret_update)

  for i=#bullets,1,-1 do
    bullet_update(bullets[i])
  end
end

function _draw()
  local _bg_color=5
  cls(_bg_color)

  foreach (agents, agent_draw_shadow)

  map(level.x,level.y,0,0,level.w,level.h,0x1)
  -- graph_draw_links(level)


  -- mine
  mine_draw(mine)

  -- agents
  foreach (selection.hovered_agents, agent_hover_draw)
  foreach (selection.selected_agents, agent_selected_draw)
  foreach (agents, agent_draw)
  foreach (turrets, turret_draw)
  foreach (bullets, bullet_draw)

  selection_draw()
  mouse_draw()

  -- debug
  draw_log()

  -- if #selected_agents>0 then
  --   path = find_path(level, selected_agents[1].pos, mouse.pos)
  -- else
  --   path = nil
  -- end

  -- if path~=nil then
  --   for i=1,#path-1 do
  --     local _p0, _p1 = path[i], path[i+1]
  --     line(_p0.x, _p0.y, _p1.x, _p1.y, 12)
  --   end
  -- end
end
