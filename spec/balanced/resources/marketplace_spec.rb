require "spec_helper"


describe Balanced::Marketplace do
  use_vcr_cassette
  before do
    api_key = Balanced::ApiKey.new.save
    Balanced.configure api_key.secret
    @marketplace = Balanced::Marketplace.new.save
    @bank_account = Balanced::BankAccount.new(
      :account_number => "1234567890",
      :bank_code => "321174851",
      :name => "Jack Q Merchant"
    ).save
    @merchant = @marketplace.create_merchant(
      "merchant@example.org",
      {
        :type => "person",
        :name => "Billy Jones",
        :street_address => "801 High St.",
        :postal_code => "94301",
        :country => "USA",
        :dob => "1842-01",
        :phone_number => "+16505551234",
      },
      @bank_account.uri,
      "Jack Q Merchant",
    )
  end

  describe "create_merchant" do
    use_vcr_cassette

    describe "class" do
      subject { @merchant }
      it { should be_instance_of Balanced::Account }
    end

    describe "attributes" do
      describe "#id" do
        subject { @merchant.id }
        it { should_not be_nil }
        it { should_not be_empty }
      end
      describe "#roles" do
        subject { @merchant.roles }
        it { should include("merchant") }
      end
      describe "#email_address" do
        subject { @merchant.email_address }
        it { should eql "merchant@example.org" }
      end
      describe "#name" do
        subject { @merchant.name }
        it { should eql "Jack Q Merchant" }
      end
      describe "#created_at" do
        subject { @merchant.created_at }
        it { should_not be_nil }
        it { should_not be_empty }
      end
      describe "#uri" do
        subject { @merchant.uri }
        it { should match MERCHANT_URI_REGEX }
      end
      describe "#holds_uri" do
        subject { @merchant.holds_uri }
        it { should match HOLDS_URI_REGEX }
      end
      describe "#bank_accounts_uri" do
        subject { @merchant.bank_accounts_uri }
        it { should match BANK_ACCOUNTS_URI_REGEX }
      end
      describe "#refunds_uri" do
        subject { @merchant.refunds_uri }
        it { should match REFUNDS_URI_REGEX }
      end
      describe "#debits_uri" do
        subject { @merchant.debits_uri }
        it { should match DEBITS_URI_REGEX }
      end
      describe "#transactions_uri" do
        subject { @merchant.transactions_uri }
        it { should match TRANSACTIONS_URI_REGEX }
      end
      describe "#credits_uri" do
        subject { @merchant.credits_uri }
        it { should match CREDITS_URI_REGEX }
      end
      describe "#cards_uri" do
        subject { @merchant.cards_uri }
        it { should match CARDS_URI_REGEX }
      end
    end
  end
end

describe Balanced::Marketplace, '.marketplace_uri' do
  context 'when invoking .my_marketplace' do
    use_vcr_cassette

    it 'sets the marketplace_id after the first call' do
      api_key = Balanced::ApiKey.new.save
      Balanced.configure api_key.secret
      marketplace = Balanced::Marketplace.new.save

      # creating the marketplace sets `Balanced::Marketplace.marketplace_uri`,
      # so we need to clear it out here to get the test in the right state
      Balanced::Marketplace.class_variable_set(:@@marketplace_uri, nil)

      expect {
        Balanced::Marketplace.my_marketplace
      }.to change { Balanced::Marketplace.marketplace_uri }.from(nil).to(marketplace.uri)
    end
  end

  context 'when creating a Balanced::Marketplace resource' do
    use_vcr_cassette

    it 'sets the marketplace_uri' do
      api_key = Balanced::ApiKey.new.save
      Balanced.configure api_key.secret

      res = Balanced::Marketplace.new.save
      Balanced::Marketplace.marketplace_uri.should == res.uri
      Balanced::Marketplace.marketplace_uri.nil?.should be_false
    end
  end
end

describe Balanced::Marketplace, '.marketplace_exists?' do
  it 'returns false when nil' do
    Balanced::Marketplace.stub(:marketplace_uri) { nil }
    Balanced::Marketplace.marketplace_exists?.should == false
  end

  it 'returns true when not nil' do
    Balanced::Marketplace.stub(:marketplace_uri) { 'some uri' }
    Balanced::Marketplace.marketplace_exists?.should == true
  end
end