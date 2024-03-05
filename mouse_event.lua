poke(0x5f2d, 1) -- enable mouse

mouse={
  pos=vec2(),
  pressed={false,false},
  released={false,false},
  down={false,false}
}
local _selection_start=vec2(mouse.pos)

selection_aabb={
  mouse.pos.x,
  mouse.pos.y,
  mouse.pos.x,
  mouse.pos.y
}

function is_mouse_moved()
  return equals(mouse.pos, _selection_start)
end

function mouse_update()
  mouse.pos=vec2(stat(32),stat(33))
  local _prev_mouse_down={mouse.down[1],mouse.down[2]}
  mouse.down[1]=(stat(34)&1)>0
  mouse.down[2]=(stat(34)&2)>0
  mouse.pressed[1]=not _prev_mouse_down[1] and mouse.down[1]
  mouse.pressed[2]=not _prev_mouse_down[2] and mouse.down[2]
  mouse.released[1]=_prev_mouse_down[1] and not mouse.down[1]
  mouse.released[2]=_prev_mouse_down[2] and not mouse.down[2]

  --selection
  if (mouse.pressed[1]) then 
    _selection_start=vec2(mouse.pos)
  end

  selection_aabb={
    _selection_start.x,
    _selection_start.y,
    mouse.pos.x,
    mouse.pos.y
  }

  selection_aabb={
    min(selection_aabb[1],selection_aabb[3]),
    min(selection_aabb[2],selection_aabb[4]),
    max(selection_aabb[1],selection_aabb[3]),
    max(selection_aabb[2],selection_aabb[4]),
  }
end

function mouse_draw()
  spr(1,mouse.pos.x,mouse.pos.y)

  if (mouse.down[1]) then
    pset(selection_aabb[1], selection_aabb[2], 7)
    fillp(0b0101101001011010.1)
    rect(selection_aabb[1], selection_aabb[2], selection_aabb[3], selection_aabb[4], 7)
    fillp()
  end
end