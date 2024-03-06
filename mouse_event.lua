poke(0x5f2d, 1) -- enable mouse

mouse={
  pos=vec2(),
  pressed={false,false},
  released={false,false},
  down={false,false},
  selection_start=nil,
  selection_aabb=nil,
}

function mouse_is_box_selecting()
  return mouse.selection_start~=nil and not equals(mouse.pos, mouse.selection_start)
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

  mouse.selection_aabb={
    mouse.pos.x,
    mouse.pos.y,
    mouse.pos.x,
    mouse.pos.y
  }

  if (mouse.pressed[1]) mouse.selection_start=vec2(mouse.pos)
  if (not mouse.down[1] and not mouse.released[1]) mouse.selection_start=nil

  if (mouse.selection_start~=nil) then
    mouse.selection_aabb[1]=mouse.selection_start.x
    mouse.selection_aabb[2]=mouse.selection_start.y
  end
 
  mouse.selection_aabb={
    min(mouse.selection_aabb[1],mouse.selection_aabb[3]),
    min(mouse.selection_aabb[2],mouse.selection_aabb[4]),
    max(mouse.selection_aabb[1],mouse.selection_aabb[3]),
    max(mouse.selection_aabb[2],mouse.selection_aabb[4]),
  }
end

function mouse_draw()
  spr(1,mouse.pos.x,mouse.pos.y)

  if (mouse.down[1]) then
    pset(mouse.selection_aabb[1], mouse.selection_aabb[2], 7)
    fillp(0b0101101001011010.1)
    rect(mouse.selection_aabb[1], mouse.selection_aabb[2], mouse.selection_aabb[3], mouse.selection_aabb[4], 7)
    fillp()
  end
end