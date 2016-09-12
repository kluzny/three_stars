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
      expect(instance.parser).to be_a(PgQuery)
    end

    it 'creates an syntax tree' do
      expect(instance.tree).to_not be_nil
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
    subject { instance.tables }

    let(:sql) { 'select * from users' }
    it 'returns an array of the sql table' do
      expect(subject).to eq(%w(users))
    end
  end

  describe '.selectors' do
    subject { instance.selectors }

    context 'single selector' do
      let(:sql) { 'select id from users' }
      it 'returns an array of the sql selectors' do
        expect(subject).to eq(%w(id))
      end
    end

    context 'multiple selectors' do
      let(:sql) { 'select id,name from users' }
      it 'returns an array of the sql selectors' do
        expect(subject).to eq(%w(id name))
      end
    end
  end

  describe '.orders' do
    subject { instance.orders }

    context 'single order' do
      let(:sql) { 'select * from users order by name asc' }
      it 'returns an array of the order clauses' do
        expect(subject).to eq([%w(name ASC)])
      end
    end

    context 'single order no direction' do
      let(:sql) { 'select * from users order by name' }
      it 'returns an array of the order clauses' do
        expect(subject).to eq([%w(name DESC)])
      end
    end

    context 'multiple orders' do
      let(:sql) { 'select * from users order by name asc, id desc' }
      it 'returns an array of the order clauses' do
        expect(subject).to eq([%w(name ASC), %w(id DESC)])
      end
    end
  end

  describe '.groups' do
    subject { instance.groups }

    let(:sql) { 'select name, sum(score) from users group by name' }
    it 'returns an array of the group clauses' do
      expect(subject).to eq(%w(name))
    end
  end
end
