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

function agent_update(_a)
-- if (#_a.actions==0) then
--  if (_a.mode==0) then
--      agent_wait(_a,rnd_range(wait_range[1],wait_range[2]))
--  else
--      agent_goto(_a,rnd_screenpos(30))
--  end
--  _a.mode=(_a.mode+1)%2
-- end
end

function agent_draw(_a)
  pset(_a.pos.x,_a.pos.y,_a.colors[2])
  pset(_a.pos.x,_a.pos.y-1,_a.colors[1])
  pset(_a.pos.x+1,_a.pos.y,1)
end