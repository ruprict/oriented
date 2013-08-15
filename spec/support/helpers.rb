puts "Defining helpers"
def define_test_class(includes=nil)
  c = Class.new
  c.send(:include, includes) if includes

  class_name = "Class#{rand(999999) +1}"

  case includes.to_s
  when "Oriented::Vertex"
    define_vertex_type(class_name)
  when "Oriented::Edge"
    define_edge_type(class_name)
  end
  Object.const_set(class_name, c)
  Object.const_get(class_name)
end

def define_vertex_type(vt)
  Oriented.graph.stop_transaction(OrientDB::Conclusion::SUCCESS)
  Oriented.graph.create_vertex_type(vt) unless Oriented.connection.graph.get_vertex_type(vt)
end

def define_edge_type(vt)
  Oriented.graph.stop_transaction(OrientDB::Conclusion::SUCCESS)
  Oriented.graph.create_edge_type(vt) unless Oriented.connection.graph.get_edge_type(vt)
end

