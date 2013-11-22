module Oriented
  module Core
    describe Transaction do

      describe ".run" do

        context "failure" do

          before do
            @conn_mock = double("connection")
            Oriented.stub(:connection) {@conn_mock}
            @conn_mock.stub(:transaction_active?).and_return(true)
          end

          it "rollbacks the transaction" do
            @conn_mock.stub(:close)
            @conn_mock.should_receive(:rollback)
            begin
              described_class.run  do
                raise StandardError
              end
            rescue
              nil
            end
          end
            
          it "raises the error" do
            @conn_mock.stub(:close)
            @conn_mock.should_receive(:rollback)
            raised = false
            begin
              described_class.run  do
                raise StandardError
              end
            rescue
              raised = true
            end
            raised.should be_true
          end

          it "closes the connection" do
            @conn_mock.stub(:rollback)
            @conn_mock.should_receive(:close)
            begin
              described_class.run  do
                raise StandardError
              end
            rescue 
              nil 
            end

          end
        end

        context "success" do
          before do
            @conn_mock = double("connection")
            Oriented.stub(:connection) {@conn_mock}
            @conn_mock.stub(:transaction_active?).and_return(true)
          end

        end
      end
    end
  end
end
