require 'cryptocoin/digest'
require 'cryptocoin/core_ext/string'

module Cryptocoin
  class MerkleTree
    def initialize(arr, hashed=true)
      # Build the merkle tree!
      @children = []
      create_tree(arr)
    end

    def root
      if @children.first.children.count == 1 # only child has one child, which means it's got one leaf
        @children.first.children.first.digest
      else
        @children.first.digest
      end
    end

    def children
      @children
    end
        
    # Each child is either the product of two children or one/two leaves
    class Child
      attr_reader :children
      
      def initialize(children)
        @children = children
      end
      
      def digest
        if @children.count == 1
          return @children.first.digest if @children.first.initially_hashed?
          @digest ||= Cryptocoin::Digest.new(@children.first.digest.reverse_every(2), :string).double_sha256.reverse_every(2)
        else
          @digest ||= Cryptocoin::Digest.new((@children.last.digest + @children.first.digest).reverse_every(2), :string).double_sha256.reverse_every(2)
        end
      end
      
      def initially_hashed?
        false
      end
    end
    
    # The base element of a merkle tree
    class Leaf
      attr_reader :value
      def initialize(val, hashed=false)
        @value = val
        @hashed = hashed
      end
      
      def digest
        return @value if initially_hashed?
        Cryptocoin::Digest.new(@value, :string).double_sha256.reverse_every(2)
      end
      
      def initially_hashed?
        !!@hashed
      end
    end
    
    private
    
    def create_tree(arr)
      return @children = [Child.new([Leaf.new(arr[0], truee)])] if arr.length == 1
      children = arr.map{|e| Leaf.new(e, true)}
      until children.length == 1
        children.push(children.last) if children.length % 2 == 1
        children = children.each_slice(2).map {|a,b|
          Child.new([a,b])
        }
      end
      @children = children
    end
  end
end