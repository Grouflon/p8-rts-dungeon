selection={
  hovered_agents={},
  selected_agents={},
  start=nil,
  aabb=nil,
}

function selection_update()

  function is_box_selecting()
    return selection.start~=nil and not equals(mouse.pos, selection.start)
  end

  selection.aabb={
    mouse.pos.x,
    mouse.pos.y,
    mouse.pos.x,
    mouse.pos.y
  }

  if (mouse.pressed[1]) selection.start=vec2(mouse.pos)
  if (not mouse.down[1] and not mouse.released[1]) selection.start=nil

  if (selection.start~=nil) then
    selection.aabb[1]=selection.start.x
    selection.aabb[2]=selection.start.y
  end
 
  selection.aabb={
    min(selection.aabb[1],selection.aabb[3]),
    min(selection.aabb[2],selection.aabb[4]),
    max(selection.aabb[1],selection.aabb[3]),
    max(selection.aabb[2],selection.aabb[4]),
  }

  selection.hovered_agents={}
  local _selectable={}

  for _i=1,#agents do
    local _agent=agents[_i]
    local _agent_aabb=agent_aabb(_agent,4)

    if (_agent.is_alive) then
      if col_aabb_aabb(selection.aabb,_agent_aabb) then
        add(_selectable,_agent)
      end
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
    if is_box_selecting() then
      selection.hovered_agents=_selectable
    else
      selection.hovered_agents={_selectable[1]}
    end
  end
  if mouse.released[1] then
    selection.selected_agents=selection.hovered_agents
  end
end

function selection_draw()
    if (selection.start ~= nil) then
      pset(selection.aabb[1], selection.aabb[2], 7)
      fillp(0b0101101001011010.1)
      rect(selection.aabb[1], selection.aabb[2], selection.aabb[3], selection.aabb[4], 7)
    fillp()
  end
end