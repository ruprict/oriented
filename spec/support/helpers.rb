puts "Defining helpers"
def define_test_class(includes=nil)
  c = Class.new
  c.send(:include, includes) if includes
  class_name = "Class#{rand(999999) +1}"
  Object.const_set(class_name, c)
  Object.const_get(class_name)
end
