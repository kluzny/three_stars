require 'spec_helper'

describe ThreeStars::Lexer do
  let(:klass) { described_class }
  let(:instance) { klass.new(sql) }

  describe '.initialize' do
    let(:sql) { 'select * from users' }
    it 'stores the incoming sql' do
      expect(instance.sql).to eq(sql)
    end

    it 'creates a new parser' do
      expect(instance.parser).to be_a(SQLParser::Parser)
    end

    it 'creates an abstract syntax tree' do
      expect(instance.ast).to_not be_nil
    end

    context 'errors' do
      it 'raises an exception if sql is blank' do
        [nil, '', '   ', "\n"].each do |blank|
          expect { klass.new(blank) }.to raise_exception "SQL can't be blank"
        end
      end
    end
  end

  describe '.tables' do
    let(:sql) { 'select * from users' }
    it 'returns an array of the sql table' do
      expect(instance.tables).to eq(%w(users))
    end
  end

  describe '.selectors' do
    let(:sql) { 'select id,name from users' }
    it 'returns an array of the sql selectors' do
      expect(instance.selectors).to eq(%w(id name))
    end
  end

  describe '.orders' do
    context 'single order' do
      let(:sql) { 'select * from users order by name asc' }
      it 'returns an array of the order clauses' do
        expect(instance.orders).to eq([%w(name asc)])
      end
    end
    context 'multiple orders' do
      let(:sql) { 'select * from users order by name asc, id desc' }
      it 'returns an array of the order clauses' do
        expect(instance.orders).to eq(
          [%w(name asc), %w(id desc)]
        )
      end
    end
  end

  describe '.wheres' do
    let(:sql) { "select * from users where name='ada'" }
    it 'returns an array of the group clauses' do
      expect(instance.wheres).to eq(%w(name))
    end
  end

  describe '.groups' do
    let(:sql) { 'select name, sum(score) from users group by name' }
    it 'returns an array of the group clauses' do
      expect(instance.groups).to eq(%w(name))
    end
  end
end
