require File.expand_path('../../../spec_helper', __FILE__)

ruby_version_is "2.5" do
  describe "Hash#transform_keys" do
    before :each do
      @hash = { a: 1, b: 2, c: 3 }
    end

    it "returns new hash" do
      ret = @hash.transform_keys(&:succ)
      ret.should_not equal(@hash)
      ret.should be_an_instance_of(Hash)
    end

    it "sets the result as transformed keys with the given block" do
      @hash.transform_keys(&:succ).should ==  { b: 1, c: 2, d: 3 }
    end

    context "when no block is given" do
      it "returns a sized Enumerator" do
        enumerator = @hash.transform_keys
        enumerator.should be_an_instance_of(Enumerator)
        enumerator.size.should == @hash.size
        enumerator.each(&:succ).should == { b: 1, c: 2, d: 3 }
      end
    end

    it "returns a Hash instance, even on subclasses" do
      klass = Class.new(Hash)
      h = klass.new
      h[:foo] = 42
      r = h.transform_keys{|v| :"x#{v}"}
      r.keys.should == [:xfoo]
      r.class.should == Hash
    end
  end

  describe "Hash#transform_keys!" do
    before :each do
      @hash = { a: 1, b: 2, c: 3, d: 4 }
      @initial_pairs = @hash.dup
    end

    it "returns self" do
      @hash.transform_keys!(&:succ).should equal(@hash)
    end

    # it "updates self as transformed values with the given block" do
    #   @hash.transform_keys!(&:succ)
    #   @hash.should ==  ?
    # end

    # it "partially modifies the contents if we broke from the block" do
    #   @hash.transform_keys! do |v|
    #     break if v == :c
    #     v.succ
    #   end
    #   @hash.should == ?
    # end

    context "when no block is given" do
      it "returns a sized Enumerator" do
        enumerator = @hash.transform_keys!
        enumerator.should be_an_instance_of(Enumerator)
        enumerator.size.should == @hash.size
        enumerator.each(&:succ)
        # @hash.should == ?
      end
    end

    describe "on frozen instance" do
      before :each do
        @hash.freeze
      end

      it "raises a RuntimeError on an empty hash" do
        ->{ {}.freeze.transform_keys!(&:succ) }.should raise_error(RuntimeError)
      end

      it "keeps pairs and raises a RuntimeError" do
        ->{ @hash.transform_keys!(&:succ) }.should raise_error(RuntimeError)
        @hash.should == @initial_pairs
      end

      context "when no block is given" do
        it "does not raise an exception" do
          @hash.transform_keys!.should be_an_instance_of(Enumerator)
        end
      end
    end
  end
end
