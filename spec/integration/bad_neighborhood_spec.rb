require_relative "../fixtures/models"

describe "BadNeighborhood" do
  let(:barbie) { Model.new(name: "Barbie")}  
  let(:bad_guy) {DrugDealer.new(name: "Baddie", product: 'Crank')}
  let(:ramona) {Stylist.new(name: 'Ramona')}
  let(:pat) {Stylist.new(name: 'Pat')}

  it "lets Barbie get a drug dealer" do
    barbie.drug_dealer = bad_guy
    barbie.drug_dealer.id.should == bad_guy.id
  end

  it "lets Barbie have multiple stylists" do
    barbie.stylists << ramona
    barbie.stylists.count.should == 1
    barbie.stylists << pat
    barbie.stylists.count.should == 2
  end
end
