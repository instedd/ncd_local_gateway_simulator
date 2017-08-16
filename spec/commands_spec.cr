require "spec"
require "../src/simulator"

include Lgwsim

describe Simulator::OneOfCommand do
  it "parses correct message" do
    cmd = Simulator::OneOfCommand.parse("#oneof:1,2,3")
    cmd.should be_a(Simulator::OneOfCommand)
    cmd.not_nil!.choices.should eq(%w(1 2 3))
  end

  it "ignores whitespaces between options" do
    cmd = Simulator::OneOfCommand.parse("#oneof: 1, 2, 3 ")
    cmd.not_nil!.choices.should eq(%w(1 2 3))
  end

  it "ignores other messages" do
    cmd = Simulator::OneOfCommand.parse("foo")
    cmd.should be_nil
  end
end

describe Simulator::NumericCommand do
  it "parsers correct message" do
    cmd = Simulator::NumericCommand.parse("#numeric:10-20").not_nil!
    cmd.min.should eq(10)
    cmd.max.should eq(20)
  end

  it "ignores whitespaces between options" do
    cmd = Simulator::NumericCommand.parse("#numeric: 10 - 20 ").not_nil!
    cmd.min.should eq(10)
    cmd.max.should eq(20)
  end

  it "ignores other messages" do
    cmd = Simulator::NumericCommand.parse("foo")
    cmd.should be_nil
  end
end
