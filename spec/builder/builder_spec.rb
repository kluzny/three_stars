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

    context 'more complex query' do
      let(:sql) do
        %(
          SELECT "users".*
          FROM "users"
          WHERE "users"."deleted_at" IS NULL AND "users"."name" = 'kyle'
        )
      end

      it 'returns an array of the where clauses' do
        expect(instance.call).to eq 'add_index :users, [:deleted_at, :name]'
      end
    end
  end
end
