--constants
skin_color={4,15}
clothes_color={2,3,8,10,11,12,14}

agent_count=4
order_speed=0.4

--variables
agents={}
actions={}

hovered_agents={}
selected_agents={}
level=nil

collisions={}

updates={}

draw_entities={}
draw_hovers={}
draw_selections={}

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
      break
    end
  end

  add(collisions, agents_collision)

  add(updates, agents_update)
  add(updates, mine_update)

  add(draw_entities, arrow_function(foreach,agents,agent_draw))
  add(draw_entities, mine_draw)
  add(draw_hovers, arrow_function(foreach,hovered_agents,agent_hover_draw))
  add(draw_selections, arrow_function(foreach,selected_agents,agent_selected_draw))
end

function _update60()
  --mouse
  mouse_update()

  clear(hovered_agents)

  do_funcs(collisions)
  do_funcs(updates)
end

function _draw()
  local _bg_color=5
  cls(_bg_color)

  map(level.x,level.y,0,0,level.w,level.h,0x1)
  -- graph_draw_links(level)

  do_funcs(draw_entities)
  do_funcs(draw_hovers)
  do_funcs(draw_selections)

  mouse_draw()

  -- debug
  draw_log()

end