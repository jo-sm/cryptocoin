require 'spec_helper'
require 'cryptocoin/script'

describe Cryptocoin::Script do
  describe "#from_s" do
    it 'returns a new Script object when passed a valid Script directive' do
      script = Cryptocoin::Script.from_s('OP_1')
      script.should be_an_instance_of Cryptocoin::Script
    end

    it 'does not return a new Script object when passed an invalid directive' do
      script = Cryptocoin::Script.from_s('Gobbledegook')
      script.should_not be_an_instance_of Cryptocoin::Script
    end

    it 'creates a Script object with an invalid opcode' do
      script = Cryptocoin::Script.from_s('OP_1 OP_CAT OP_MOD')
      script.should be_an_instance_of Cryptocoin::Script
    end
  end
  
  describe "#new" do
    
  end
  
  describe "#subscript!" do
    
  end
  
  describe "#subscript!" do
    
  end
  
  describe "#subscript!" do
    
  end
  
  describe "#subscript!" do
    
  end
  
end
