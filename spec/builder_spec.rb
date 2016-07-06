require 'spec_helper'

describe ThreeStars::Builder do
  let(:klass) { described_class }
  let(:instance) { klass.new(sql) }
  let(:sql) { 'select * from users' }

  describe '.initialize' do
    it 'creates a new lexer' do
      expect(instance.lexer).to be_a(ThreeStars::Lexer)
    end
  end

  describe '.call' do
    context 'simple' do
      let(:sql) { 'select id from users' }

      it 'creates a sql index' do
        expect(instance.call).to eq 'add_index :users, :id'
      end
    end

    context 'simple where' do
      let(:sql) { 'select id from users where name="linus"' }

      it 'creates a sql index' do
        expect(instance.call).to eq 'add_index :users, [:name, :id]'
      end
    end

    context 'simple where multiple select' do
      let(:sql) { 'select id, name from users where name="linus"' }

      it 'creates a sql index' do
        expect(instance.call).to eq 'add_index :users, [:name, :id]'
      end
    end

    context 'simple where multiple select, simple order' do
      let(:sql) do
        'select id, name from users where name="linus" order by commits'
      end

      it 'creates a sql index' do
        expect(instance.call).to eq 'add_index :users, [:commits, :name, :id]'
      end
    end

    context 'index name' do
      let(:options) { { name: 'my_idx' } }
      let(:sql) { 'select id from users' }
      let(:instance) { klass.new(sql, options) }

      it 'allows a name to be passed in as an option' do
        expect(instance.call).to eq 'add_index :users, :id, name: \'my_idx\''
      end
    end
  end
end
