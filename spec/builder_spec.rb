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
      context 'as an option' do
        let(:options) { { name: 'my_idx' } }
        let(:sql) { 'select id from users' }
        let(:instance) { klass.new(sql, options) }

        it 'creates an explicitly named index' do
          expect(instance.call).to eq 'add_index :users, :id, name: \'my_idx\''
        end
      end

      context 'for many columns' do
        let(:columns) {
          %w(
            foo bar baz
            qux quux quuux
            quuuux quuuuux quuuuuux
            quuuuuuux quuuuuuuux quuuuuuuuux
          ).join(",")
        }
        let(:sql) { "select #{columns} from users" }

        it 'appends _idx to the index name' do
          expect(instance.index_name.slice(-4,4)).to eq("_idx")
        end

        it 'should truncate the name to 47 characters' do
          expect(instance.index_name.length).to eq(47)
        end
      end
    end
  end
end
