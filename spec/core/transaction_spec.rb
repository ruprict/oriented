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
            described_class.run  do
              raise StandardError
            end
          end

          it "closes the connection" do
            @conn_mock.stub(:rollback)
            @conn_mock.should_receive(:close)
            described_class.run  do
              raise StandardError
            end

          end
        end

        context "success" do
          before do
            @conn_mock = double("connection")
            Oriented.stub(:connection) {@conn_mock}
            @conn_mock.stub(:transaction_active?).and_return(true)
          end
        
          it "commits" do
            @conn_mock.stub(:close)
            @conn_mock.should_receive(:commit)
            described_class.run  do
              #doesn't matter
            end
          end          

          it "closes" do
            @conn_mock.should_receive(:close)
            @conn_mock.stub(:commit)
            described_class.run  do
              #doesn't matter
            end
          end          
        
        end
      end
    end
  end
end
