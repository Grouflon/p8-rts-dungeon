function graph(_map_x,_map_y,_w,_h,_wall_flags)
  -- helpers
  function is_wall(_spr)
    return band(fget(_spr), _wall_flags) ~= 0
  end

  -- create all nodes
  local _graph = {
    x=_map_x,
    y=_map_y,
    w=_w,
    h=_h,
    nodes={}
  }
  for _y=0,_h-1 do
    for _x=0,_w-1 do
      add(_graph.nodes, {
        index=_y*_w+_x+1,
        subgraph=-1,
        pos=vec2(_x*8+4,_y*8+4),
        sprite=mget(_map_x+_x,_map_y+_y),
        links={},
      })
    end
  end

  local _free_nodes={}
  -- create links
  for _n in all(_graph.nodes) do
    if not is_wall(_n.sprite) then      
      -- create links
      local _links={
        _graph.nodes[_n.index-_w], -- up
        _graph.nodes[_n.index+_w], -- down
        _graph.nodes[_n.index-1], -- left
        _graph.nodes[_n.index+1], -- right
      }

      for _l in all(_links) do
        if _l~=nil and not is_wall(_l.sprite) then
          add(_n.links,_l)
        end
      end

      -- add to free node list
      add(_free_nodes,_n)
    end
  end

  -- generate sub graph id
  local _current_subgraph=0
  function connect_subgraph(_node, _subgraph_id)
    if _node.subgraph>=0 then
      return
    end

    _node.subgraph=_subgraph_id
    for _l in all(_node.links) do
      connect_subgraph(_l,_subgraph_id)
    end
  end

  for _n in all(_free_nodes) do
    if _n.subgraph<0 then
      connect_subgraph(_n, _current_subgraph)
      _current_subgraph+=1
    end
  end

  return _graph
end

function graph_get_node(_graph, _pos)
  local _clamped_x, _clamped_y = flr(mid(_pos.x/8, 0, _graph.w-1)), flr(mid(_pos.y/8, 0, _graph.h-1))
  return _graph.nodes[_clamped_y*_graph.w+_clamped_x+1]
end

function graph_node_draw_links(_node)
  local _color = {8,9,10,11,12,13,14,15}
  local _n_origin = _node.pos
  for _l in all(_node.links) do
    local _l_origin = _l.pos
    local _c = _color[(_l.subgraph%#_color)+1]
    line(_n_origin.x, _n_origin.y, _l_origin.x, _l_origin.y, _c)
  end
end

function graph_draw_links(_graph)
  for _n in all(_graph.nodes) do
    graph_node_draw_links(_n)
  end
end

function graph_is_wall(_graph, _pos)
  return graph_get_node(_graph,_pos).subgraph < 0
end

function is_line_walkable(_graph, _start, _end, _subgraph) -- add radius?
  local _traj = _end-_start
  local _dir = vec2_normalized(_traj)
  local _len = vec2_len(_traj)
  local _step=4
  local _progress=0
  while _progress < _len do
    _progress=min(_len,_progress+_step)
    local _p = _start+_dir*_progress
    -- pset(_p.x, _p.y, 13)
    local _n= graph_get_node(_graph, _p)
    if (_n.subgraph ~= _subgraph) return false
  end
  return true
end

function find_path(_graph, _start, _end)
  local _start_node = graph_get_node(_graph, _start)
  local _end_node = graph_get_node(_graph, _end)
  local _subgraph = _start_node.subgraph
  assert(_start_node~=nil)
  assert(_end_node~=nil)
  if (_subgraph ~= _end_node.subgraph) return nil
  if (_subgraph < 0) return nil
  if (_start_node == _end_node) return {_start,_end}

  for _n in all(_graph.nodes) do
    _n.cost = 9999
    _n.prev = nil
  end

  local _open_list={_start_node}
  _start_node.cost=0
  while(_open_list[1]~=_end_node) do
    local _n = _open_list[1]
    deli(_open_list,1)

    for _l in all(_n.links) do
      local _cost = _n.cost+8
      if _cost < _l.cost then
        _l.cost = _cost
        _l.h=_cost+vec2_len(_end_node.pos-_l.pos)
        _l.prev=_n
        add(_open_list,_l)
      end
    end

    sort(_open_list, function(_a,_b)
      if (_a.h<_b.h) return -1
      if (_a.h>_b.h) return 1
      return 0
    end)
  end

  local _result = {}
  local _n=_end_node
  repeat
    _result[_n.cost/8+1]=_n.pos
    _n=_n.prev
  until (_n==nil)
  _result[1]=_start
  _result[#_result]=_end

  local _checkpoint=_result[1]
  local _i=2
  while _i<#_result do
    if is_line_walkable(_graph, _checkpoint, _result[_i+1], _subgraph) then
      deli(_result,_i)
    else
      _checkpoint = _result[_i]
      _i+=1
    end
  end

  return _result
end



