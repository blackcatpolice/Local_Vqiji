# encoding: utf-8
class Todo::TreeNode
  
  attr_accessor :id, :text, :expanded, :children, :has_children, :is_now, :node_url, :executor, :creator
  ## 
  ## children [Todo::TreeNode, Todo::TreeNode] 
  ## parent Todo::TreeNode 
  def initialize opts = {}
    @id = opts[:id]
    @text = opts[:text]
    @expanded = opts[:expanded] || true  #树 默认展开
    @children = opts[:children] || []
    @has_children = opts[:has_children] || false
    @classes = opts[:classes]   #当前项
    @node_url = "/todo/tasks/#{opts[:id]}"
    @creator = opts[:creator]
    @executor = opts[:executor]
  end
  
end