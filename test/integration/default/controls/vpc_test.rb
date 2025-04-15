control 'aws-vpc-basic' do
  impact 1.0
  title 'Ensure VPC exists and has expected properties'
  desc 'Validates the existence, CIDR block, and tags of the primary VPC'

  describe aws_vpc(vpc_id: input('vpc_id')) do
    it { should exist }
    its('cidr_block') { should eq ('192.168.0.0/16') }
    its('tags') { should include('Name' => 'vpc-gabriel-p') }
  end
end