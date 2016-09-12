require 'spec_helper'

describe ThreeStars::Lexer do
  let(:klass) { described_class }
  let(:instance) { klass.new(sql) }

  describe '.wheres' do
    subject { instance.wheres }

    context 'no wheres' do
      let(:sql) { 'select * from users' }
      it 'does not throw an error' do
        expect { subject }.to_not raise_error
        expect(subject).to eq []
      end
    end

    context 'single where equals' do
      let(:sql) { "select * from users where name='ada'" }
      it 'returns an array of the where clauses' do
        expect(subject).to eq(%w(name))
      end
    end

    context 'where equals joined by ands ' do
      let(:sql) do
        "select * from users where name='ada' and last_name='lovelace'"
      end
      it 'returns an array of the where clauses' do
        expect(subject).to eq(%w(name last_name))
      end
    end

    context 'where equals joined by more ands' do
      let(:sql) do
        %(
          select *
          from users
          where name='ada' and last_name='lovelace' and company='tesla'
        )
      end
      it 'returns an array of the where clauses' do
        expect(subject).to eq(%w(name last_name company))
      end
    end

    context 'where equals joined by more ands with parenthesis' do
      let(:sql) do
        %(
          select *
          from users
          where (name='ada' and last_name='lovelace') and company='tesla'
        )
      end
      it 'returns an array of the where clauses' do
        expect(subject).to eq(%w(name last_name company))
      end
    end

    context 'where using a NULL deleted_at field' do
      let(:sql) do
        %(
          SELECT "users".*
          FROM "users"
          WHERE "users"."deleted_at" IS NULL AND "users"."name" = 'kyle'
        )
      end
      it 'returns an array of the where clauses' do
        expect(subject).to eq(%w(deleted_at name))
      end
    end
  end
end
