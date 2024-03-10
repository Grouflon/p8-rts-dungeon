--constants
skin_color={4,15}
clothes_color={2,3,8,10,11,12,14}

order_speed=0.4

--variables
mines={}
agents={}
actions={}
level=nil

-- SYSTEM
function _init()
  printh("")
  printh("-----INIT-----")

  -- create level
  level=graph(0,0,16,16,0x1)

  -- spawn point
  for _n in all(level.nodes) do
    if _n.sprite==3 then
      local _world_pos=_n.pos
      add(agents,agent(1,_world_pos+vec2(-1,-1)))
      add(agents,agent(2,_world_pos+vec2(2,-1)))
      add(agents,agent(3,_world_pos+vec2(2,2)))
      add(agents,agent(4,_world_pos+vec2(-1,2)))
    elseif(_n.sprite!=2 and rnd(20) >= 10) then
      local x = rnd(8)-4
      local y = rnd(8)-4
      if (rnd(1)>0) x*=-1
      if (rnd(1)>0) y*=-1
      add(mines, mine(_n.pos+vec2(x, y)))
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
        sfx(0)
      end
    end
  end

  foreach(mines,mine_update)
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

  foreach (agents, agent_draw_shadow)

  map(level.x,level.y,0,0,level.w,level.h,0x1)
  -- graph_draw_links(level)


  -- mine
  foreach (mines, mine_draw)

  -- agents
  foreach (selection.hovered_agents, agent_hover_draw)
  foreach (selection.selected_agents, agent_selected_draw)
  foreach (agents, agent_draw)

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
