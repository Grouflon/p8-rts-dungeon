poke(0x5f2d, 1) -- enable mouse

mouse={
  pos=vec2(),
  pressed={false,false},
  released={false,false},
  down={false,false},
}

function mouse_update()
  mouse.pos=vec2(stat(32),stat(33))
  local _prev_mouse_down={mouse.down[1],mouse.down[2]}
  mouse.down[1]=(stat(34)&1)>0
  mouse.down[2]=(stat(34)&2)>0
  mouse.pressed[1]=not _prev_mouse_down[1] and mouse.down[1]
  mouse.pressed[2]=not _prev_mouse_down[2] and mouse.down[2]
  mouse.released[1]=_prev_mouse_down[1] and not mouse.down[1]
  mouse.released[2]=_prev_mouse_down[2] and not mouse.down[2]
end

function mouse_draw()
  spr(1,mouse.pos.x,mouse.pos.y)
end