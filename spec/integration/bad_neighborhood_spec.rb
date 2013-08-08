require_relative "../fixtures/models"

describe "BadNeighborhood" do
  let(:barbie) { Model.new(name: "Barbie")}  
  let(:bad_guy) {DrugDealer.new(name: "Baddie", product: 'Crank')}
  let(:ramona) {Stylist.new(name: 'Ramona')}
  let(:pat) {Stylist.new(name: 'Pat')}

  before do
    %w(Model DrugDealer Stylist).each do |vt|
      DB.stop_transaction(OrientDB::Conclusion::SUCCESS)
      DB.create_vertex_type(vt) unless DB.get_vertex_type(vt)
    end
    %w(drug_dealer stylists).each do |vt|
      DB.stop_transaction(OrientDB::Conclusion::SUCCESS)
      DB.create_edge_type(vt) unless DB.get_edge_type(vt)
    end
  end
  it "lets Barbie get a drug dealer" do
    barbie.drug_dealer = bad_guy
    # puts bad_guy.__java_obj.id
    barbie.drug_dealer.id.should == bad_guy.id.to_s
  end

  it "lets Barbie have multiple stylists" do
    barbie.stylists << ramona
    barbie.stylists.count.should == 1
    barbie.stylists << pat
    barbie.stylists.count.should == 2
  end
end
