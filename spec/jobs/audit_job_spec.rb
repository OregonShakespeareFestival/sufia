require 'spec_helper'

describe AuditJob do
  before do
    @user = FactoryGirl.find_or_create(:jill)
    @inbox = @user.mailbox.inbox
    @file = GenericFile.new
    @file.apply_depositor_metadata(@user)
    @file.save
  end
  describe "passing audit" do
    it "should not send passing mail" do
      skip "skipping audit for now"
      GenericFileRdfDatastream.any_instance.stub(:dsChecksumValid).and_return(true)
      AuditJob.new(@file.pid, "descMetadata", @file.descMetadata.versionID).run
      @inbox = @user.mailbox.inbox
      @inbox.count.should == 0
    end
  end
  describe "failing audit" do
    it "should send failing mail" do
      skip "skipping audit for now"
      GenericFileRdfDatastream.any_instance.stub(:dsChecksumValid).and_return(false)
      AuditJob.new(@file.pid, "descMetadata", @file.descMetadata.versionID).run
      @inbox = @user.mailbox.inbox
      @inbox.count.should == 1
      @inbox.each { |msg| msg.last_message.subject.should == AuditJob::FAIL }
    end
  end
end
