require 'spec_helper'

describe Scamp::IRC::Message do
  let(:adapter) { Scamp::IRC::Adapter.new stub }
  let(:channel) { "nwrug" }
  let(:user) { "User" }
  let(:body) { "Hello" }
  let(:message) { Scamp::IRC::Message.new(adapter, :body => body, :channel => channel, :user => user) }

  describe ".matches?" do
    describe "with string trigger" do
      it "matches with valid trigger" do
        message.matches?("Hello").should be_true
      end

      it "does not match with invalid trigger" do
        message.matches?("Goodbye").should be_false
      end
    end

    describe "with regex trigger" do
      it "matches with valid trigger" do
        message.matches?(/^Hello/).should be_true
      end

      it "does not match with invalid trigger" do
        message.matches?(/^Goodbye/).should be_false
      end
    end

    describe "required prefix" do
      describe "with no prefix" do
        it "matches" do
          message.matches?(/^Hello/).should be_true
        end
      end

      describe "with string prefix" do
        let(:adapter) { Scamp::IRC::Adapter.new stub, :required_prefix => "User: " }

        context "with valid message" do
          let(:body) { "User: Hello" }

          it "matches" do
            message.matches?(/^Hello/).should be_true
          end
        end

        context "with invalid message" do
          let(:body) { "Another User: Hello" }

          it "does not match" do
            message.matches?(/^Hello/).should be_false
          end
        end
      end

      describe "with regex prefix" do
        let(:adapter) { Scamp::IRC::Adapter.new stub, :required_prefix => /^User: / }

        context "with valid prefix" do
          let(:body) { "User: Hello" }

          it "matches" do
            message.matches?(/^Hello/).should be_true
          end
        end

        context "with invalid prefix" do
          let(:body) { "Another User: Hello" }

          it "does not match" do
            message.matches?(/^Hello/).should be_false
          end
        end
      end
    end
  end

  describe ".valid?" do
    describe "ignore messages from self" do
      let(:adapter) { Scamp::IRC::Adapter.new stub, :ignore_self => true }

      context "message from self" do
        before do
          adapter.stub(:user).and_return("User")
        end

        it "is not valid" do
          message.valid?().should be_false
        end
      end

      context "message from another user" do
        before do
          adapter.stub(:user).and_return("Another User")
        end

        it "is valid" do
          message.valid?().should be_true
        end
      end
    end


    describe "matching channel" do
      describe "on no channel condition" do
        it "is valid" do
          message.valid?().should be_true
        end
      end

      describe "on channel name" do
        context "with valid channel" do
          it "is valid with a string" do
            message.valid?(:channel => "nwrug").should be_true
          end

          it "is valid with a symbol" do
            message.valid?(:channel => :nwrug).should be_true
          end

          it "is valid with a string array" do
            message.valid?(:channel => ["nwrug"]).should be_true
          end

          it "is valid with a string array of multiple channels" do
            message.valid?(:channel => ["nwrug", "ruby"]).should be_true
          end
        end

        context "with invalid channel" do
          it "is invalid with a string" do
            message.valid?(:channel => "ruby").should be_false
          end

          it "is invalid with an array of strings" do
            message.valid?(:channel => ["ruby", "rubyonrails"]).should be_false
          end
        end
      end
    end

    describe "matching users" do
      context "on no user condition" do
        it "is valid" do
          message.should be_valid
        end
      end

      context "on user user name" do
        context "with valid user" do
          it "is valid with string" do
            message.valid?(:user => "User").should be_true
          end

          it "is valid with a string array" do
            message.valid?(:user => ["User"]).should be_true
          end

          it "is valid with a string array of multiple users" do
            message.valid?(:user => ["User", "Two"]).should be_true
          end
        end

        context "with invalid user" do
          it "is invalid with string" do
            message.valid?(:user => "Two").should be_false
          end

          it "is invalid with a string array" do
            message.valid?(:user => ["Two"]).should be_false
          end

          it "is invalid with a string array of multiple users" do
            message.valid?(:user => ["Two", "Three"]).should be_false
          end
        end
      end
    end
  end
end
