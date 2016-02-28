# coding: utf-8
require 'ansible_spec'

describe "load_targetsの実行" do
  context '正常系:DynamicInventory:1 Group, 1 hosts' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{"databases": {"hosts": ["host1.example.com"],"vars":{"a": true}}}'
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 1 group' do
      expect(@res.length).to eq 1
    end

    it 'exist group' do
      expect(@res.key?('databases')).to be_truthy
    end

    it 'databases host1.example.com' do
      obj = @res['databases'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host1.example.com',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end

  context '正常系:DynamicInventory:1 Group, 2 hosts' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{"databases": {"hosts": ["host1.example.com", "host2.example.com"],"vars":{"a": true}}}'
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 1 group' do
      expect(@res.length).to eq 1
    end

    it 'exist group' do
      expect(@res.key?('databases')).to be_truthy
    end

    it 'databases host1.example.com' do
      obj = @res['databases'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host1.example.com',
                              'port' => 22})
    end

    it 'databases host2.example.com' do
      obj = @res['databases'][1]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host2.example.com',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end
  context '正常系:DynamicInventory:1 Group, 2 hosts. but no vars' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{"webservers": [ "host2.example.com", "host3.example.com" ]}'
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 1 group' do
      expect(@res.length).to eq 1
    end

    it 'exist group' do
      expect(@res.key?('webservers')).to be_truthy
    end

    it 'databases host1.example.com' do
      obj = @res['webservers'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host2.example.com',
                              'port' => 22})
    end

    it 'databases host2.example.com' do
      obj = @res['webservers'][1]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host3.example.com',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end

  context 'Normal Pattern: No vars: DynamicInventory: 6 Groups, 8 hosts, 1 great-great-grandparent, 1 great-grandparent, 1 grandparent, 1 parent, 2 children' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{"atlanta": { "hosts": [ "atlanta-1", "atlanta-2" ] }, "raleigh": [ "raleigh-1", "raleigh-2" ], "southeast": { "hosts": [ "southeast-1", "southeast-2" ], "children": [ "atlanta", "raleigh" ] }, "usa": { "children": [ "southeast" ] }, "country": { "hosts": [ "country-1", "country-2" ], "children": [ "usa" ] }, "world": { "children": [ "country" ] } }'
EOF
      create_file(tmp_hosts, content_h)
      File.chmod(0755, tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'contains 6 groups' do
      expect(@res.length).to eq 6
      expect(@res.key?('atlanta')).to be_truthy
      expect(@res.key?('raleigh')).to be_truthy
      expect(@res.key?('southeast')).to be_truthy
      expect(@res.key?('usa')).to be_truthy
      expect(@res.key?('country')).to be_truthy
      expect(@res.key?('world')).to be_truthy
    end

    it 'atlanta has 2 hosts' do
      expect(@res['atlanta'].length).to eq 2
    end

    1.upto(2) do |n|
      it "atlanta contains atlanta-#{n}" do
        obj = @res['atlanta'][n - 1]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "atlanta-#{n}",
                                'port' => 22})
      end
    end

    it 'raleigh has 2 hosts' do
      expect(@res['raleigh'].length).to eq 2
    end

    1.upto(2) do |n|
      it "raleigh contains raleigh-#{n}" do
        obj = @res['raleigh'][n - 1]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "raleigh-#{n}",
                                'port' => 22})
      end
    end

    it 'southeast has 6 hosts' do
      expect(@res['southeast'].length).to eq 6
    end

    [
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "southeast contains #{group}" do
        obj = @res['southeast'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    it 'usa has 6 hosts' do
      expect(@res['usa'].length).to eq 6
    end

    [
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "usa contains #{group}" do
        obj = @res['usa'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    it 'country has 8 hosts' do
      expect(@res['country'].length).to eq 8
    end

    [
      'country-1',
      'country-2',
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "country contains #{group}" do
        obj = @res['country'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    [
      'country-1',
      'country-2',
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "world contains #{group}" do
        obj = @res['world'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    after do
      File.delete(tmp_hosts)
    end
  end

  context 'Normal Pattern: With vars: DynamicInventory: 6 Groups, 8 hosts, 1 great-great-grandparent, 1 great-grandparent, 1 grandparent, 1 parent, 2 children' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{"atlanta": { "hosts": [ "atlanta-1", "atlanta-2" ], "vars": { "a": true } }, "raleigh": [ "raleigh-1", "raleigh-2" ], "vars": { "a": true }, "southeast": { "hosts": [ "southeast-1", "southeast-2" ], "children": [ "atlanta", "raleigh" ], "vars": { "a": true } }, "usa": { "children": [ "southeast" ], "vars": { "a": true } }, "country": { "hosts": [ "country-1", "country-2" ], "children": [ "usa" ], "vars": { "a": true } }, "world": { "children": [ "country" ], "vars": { "a": true } } }'
EOF
      create_file(tmp_hosts, content_h)
      File.chmod(0755, tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'contains 6 groups' do
      expect(@res.length).to eq 6
      expect(@res.key?('atlanta')).to be_truthy
      expect(@res.key?('raleigh')).to be_truthy
      expect(@res.key?('southeast')).to be_truthy
      expect(@res.key?('usa')).to be_truthy
      expect(@res.key?('country')).to be_truthy
      expect(@res.key?('world')).to be_truthy
    end

    it 'atlanta has 2 hosts' do
      expect(@res['atlanta'].length).to eq 2
    end

    1.upto(2) do |n|
      it "atlanta contains atlanta-#{n}" do
        obj = @res['atlanta'][n - 1]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "atlanta-#{n}",
                                'port' => 22})
      end
    end

    it 'raleigh has 2 hosts' do
      expect(@res['raleigh'].length).to eq 2
    end

    1.upto(2) do |n|
      it "raleigh contains raleigh-#{n}" do
        obj = @res['raleigh'][n - 1]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "raleigh-#{n}",
                                'port' => 22})
      end
    end

    it 'southeast has 6 hosts' do
      expect(@res['southeast'].length).to eq 6
    end

    [
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "southeast contains #{group}" do
        obj = @res['southeast'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    it 'usa has 6 hosts' do
      expect(@res['usa'].length).to eq 6
    end

    [
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "usa contains #{group}" do
        obj = @res['usa'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    it 'country has 8 hosts' do
      expect(@res['country'].length).to eq 8
    end

    [
      'country-1',
      'country-2',
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "country contains #{group}" do
        obj = @res['country'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    [
      'country-1',
      'country-2',
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "world contains #{group}" do
        obj = @res['world'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    after do
      File.delete(tmp_hosts)
    end
  end

  context 'Abnormal Pattern: Circle Children with no vars: DynamicInventory: 6 Groups, 8 hosts, 1 great-great-grandparent, 1 great-grandparent, 1 grandparent, 1 parent, 2 children' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{"atlanta": { "hosts": [ "atlanta-1", "atlanta-2" ] }, "raleigh": [ "raleigh-1", "raleigh-2" ], "southeast": { "hosts": [ "southeast-1", "southeast-2" ], "children": [ "atlanta", "raleigh" ] }, "usa": { "children": [ "southeast", "atlanta" ] }, "country": { "hosts": [ "country-1", "country-2" ], "children": [ "usa", "southeast" ] }, "world": { "children": [ "country" ] } }'
EOF
      create_file(tmp_hosts, content_h)
      File.chmod(0755, tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'contains 6 groups' do
      expect(@res.length).to eq 6
      expect(@res.key?('atlanta')).to be_truthy
      expect(@res.key?('raleigh')).to be_truthy
      expect(@res.key?('southeast')).to be_truthy
      expect(@res.key?('usa')).to be_truthy
      expect(@res.key?('country')).to be_truthy
      expect(@res.key?('world')).to be_truthy
    end

    it 'atlanta has 2 hosts' do
      expect(@res['atlanta'].length).to eq 2
    end

    1.upto(2) do |n|
      it "atlanta contains atlanta-#{n}" do
        obj = @res['atlanta'][n - 1]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "atlanta-#{n}",
                                'port' => 22})
      end
    end

    it 'raleigh has 2 hosts' do
      expect(@res['atlanta'].length).to eq 2
    end

    1.upto(2) do |n|
      it "raleigh contains atlanta-#{n}" do
        obj = @res['raleigh'][n - 1]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "raleigh-#{n}",
                                'port' => 22})
      end
    end

    it 'southeast has 6 hosts' do
      expect(@res['southeast'].length).to eq 6
    end

    [
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "southeast contains #{group}" do
        obj = @res['southeast'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    it 'usa has 6 hosts' do
      expect(@res['usa'].length).to eq 6
    end

    [
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "usa contains #{group}" do
        obj = @res['usa'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    it 'country has 8 hosts' do
      expect(@res['country'].length).to eq 8
    end

    [
      'country-1',
      'country-2',
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "country contains #{group}" do
        obj = @res['country'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    [
      'country-1',
      'country-2',
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "world contains #{group}" do
        obj = @res['world'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    after do
      File.delete(tmp_hosts)
    end
  end

  context 'Abnormal Pattern: Circle Children with vars: DynamicInventory: 6 Groups, 8 hosts, 1 great-great-grandparent, 1 great-grandparent, 1 grandparent, 1 parent, 2 children' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{"atlanta": { "hosts": [ "atlanta-1", "atlanta-2" ], "vars": { "a": true } }, "raleigh": [ "raleigh-1", "raleigh-2" ], "southeast": { "hosts": [ "southeast-1", "southeast-2" ], "children": [ "atlanta", "raleigh" ], "vars": { "a": true } }, "usa": { "children": [ "southeast", "atlanta" ], "vars": { "a": true } }, "country": { "hosts": [ "country-1", "country-2" ], "children": [ "usa", "southeast" ], "vars": { "a": true } }, "world": { "children": [ "country" ], "vars": { "a": true } } }'
EOF
      create_file(tmp_hosts, content_h)
      File.chmod(0755, tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'contains 6 groups' do
      expect(@res.length).to eq 6
      expect(@res.key?('atlanta')).to be_truthy
      expect(@res.key?('raleigh')).to be_truthy
      expect(@res.key?('southeast')).to be_truthy
      expect(@res.key?('usa')).to be_truthy
      expect(@res.key?('country')).to be_truthy
      expect(@res.key?('world')).to be_truthy
    end

    it 'atlanta has 2 hosts' do
      expect(@res['atlanta'].length).to eq 2
    end

    1.upto(2) do |n|
      it "atlanta contains atlanta-#{n}" do
        obj = @res['atlanta'][n - 1]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "atlanta-#{n}",
                                'port' => 22})
      end
    end

    it 'raleigh has 2 hosts' do
      expect(@res['atlanta'].length).to eq 2
    end

    1.upto(2) do |n|
      it "raleigh contains atlanta-#{n}" do
        obj = @res['raleigh'][n - 1]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "raleigh-#{n}",
                                'port' => 22})
      end
    end

    it 'southeast has 6 hosts' do
      expect(@res['southeast'].length).to eq 6
    end

    [
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "southeast contains #{group}" do
        obj = @res['southeast'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    it 'usa has 6 hosts' do
      expect(@res['usa'].length).to eq 6
    end

    [
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "usa contains #{group}" do
        obj = @res['usa'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    it 'country has 8 hosts' do
      expect(@res['country'].length).to eq 8
    end

    [
      'country-1',
      'country-2',
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "country contains #{group}" do
        obj = @res['country'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    [
      'country-1',
      'country-2',
      'southeast-1',
      'southeast-2',
      'atlanta-1',
      'atlanta-2',
      'raleigh-1',
      'raleigh-2'
    ].each_with_index do |group, index|
      it "world contains #{group}" do
        obj = @res['world'][index]
        expect(obj.instance_of?(Hash)).to be_truthy
        expect(obj).to include({'uri' => "#{group}",
                                'port' => 22})
      end
    end

    after do
      File.delete(tmp_hosts)
    end
  end
end
