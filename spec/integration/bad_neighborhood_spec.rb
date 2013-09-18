require_relative "../fixtures/models"

describe "BadNeighborhood" do
  let(:barbie) { Model.new(name: "Barbie")}  
  let(:bad_guy) {DrugDealer.new(name: "Baddie", product: 'Crank')}
  let(:bad_guy2) {DrugDealer.new(name: "Mcbad", product: 'Glue')}  
  let(:ramona) {Stylist.new(name: 'Ramona')}
  let(:pat) {Stylist.new(name: 'Pat')}

  before do
    %w(Model DrugDealer Stylist).each do |vt|
      Oriented.graph(true).create_vertex_type(vt) unless Oriented.connection.graph.get_vertex_type(vt)
    end
    %w(drug_dealer stylists).each do |vt|
      Oriented.graph(true).create_edge_type(vt) unless Oriented.connection.graph.get_edge_type(vt)
    end
  end
  
  context "create a new drug dealer with multiple clients" do
    before(:each) do
      bad_guy.clients << barbie
      bad_guy.clients << ramona      
    end
    it "should persist the drug dealer and the clients" do

      bad_guy.id.should == nil
      bad_guy.save      
      bad_guy.id.should_not == nil      
      bad_guy.clients.count.should == 2
      bad_guy.clients.each{|c| 
        c.id.should_not == nil 
        c.drug_dealer.id.should == bad_guy.id
      }

      barbie.id.should_not == nil
      ramona.id.should_not == nil
    end
    
    it "should create the relationship from the drug_dealer client to the stylists" do
      ramona.drug_dealer.id.should == nil
      bad_guy.id.should == nil
      ramona.drug_dealer.should == bad_guy
    end
    
    it "should create the relationship from the drug_dealer client to the stylists when persisted" do
      ramona.drug_dealer.id.should == nil      
      ramona.save
      ramona.drug_dealer.id.should_not == nil      
      ramona.drug_dealer.id.should == bad_guy.id
    end
    
    it "should create the relationship from the barbie to the ramona when the bad_guy is persisted with barbie as a client" do
      r = barbie.stylists << pat
      bad_guy.save
      barbie.id.should_not == nil
      barbie.stylists.count.should == 1
      barbie.stylists.first.id.should_not == nil
      barbie.stylists.first.id.should == pat.id
      
    end
    
  end
  # it "lets Barbie get a drug dealer" do
  #   barbie.save    
  #   barbie.drug_dealer = bad_guy
  #   # puts "barbi = #{barbie.inspect}"
  #   # puts "drug dealer = #{barbie.drug_dealer}"
  #   barbie.save
  #   # barbie.drug_dealer = nil
  #   puts "barbie id = #{barbie.drug_dealer}"
  #   # puts "drug dealer now = #{barbie.__java_obj.rels.to_a[0].label}"  
  #   # bad_guy.__java_obj.rels.to_a.each{|b| puts b.start_vertex.id }
  #   puts bad_guy
  #   # bad_guy.clients.to_a[0].save
  #   puts "bad guy clients = #{bad_guy.clients.to_a[0].id}"
  #   puts bad_guy.id
  #   # barbie.drug_dealer.id.should == bad_guy.id.to_s
  # end
  it "lets Barbie have multiple stylists" do
    r = barbie.stylists << ramona
    barbie.stylists << pat
    barbie.stylists.count.should == 2
    
    
    barbie.save
    barbie.stylists.destroy_relationship_to(r)
    barbie.stylists.count.should == 1    
  end
end
