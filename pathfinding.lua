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
        pos=vec2(_x,_y),
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

function graph_get_node(_graph,_x,_y)
  return _graph.nodes[_y*_graph.w+_x+1]
end

function graph_node_draw_links(_node)
  local _color = {8,9,10,11,12,13,14,15}
  local _n_origin = _node.pos*8+vec2(4,4)
  for _l in all(_node.links) do
    local _l_origin = _l.pos*8+vec2(4,4)
    local _c = _color[(_l.subgraph%#_color)+1]
    line(_n_origin.x, _n_origin.y, _l_origin.x, _l_origin.y, _c)
  end
end

function graph_draw_links(_graph)
  for _n in all(_graph.nodes) do
    graph_node_draw_links(_n)
  end
end





