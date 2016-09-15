require 'spec_helper'

describe ThreeStars::Builder do
  let(:klass) { described_class }
  let(:options) { {} }
  let(:sql) { 'select id from users' }
  let(:instance) { klass.new(sql, options) }

  describe '.index_name' do
    subject { instance.index_name }

    context 'when provided options' do
      let(:name) { 'best_idx' }
      let(:options) { { name: name } }

      it 'creates an explicitly named index' do
        expect(subject).to eq name
      end
    end

    context 'when not provided options' do
      context 'short index name' do
        it 'lets rails generate the index name' do
          allow(instance).to receive(:index_name_too_long?).and_return(false)
          expect(instance).to_not receive(:generate_index_name)
          expect(subject).to be_nil
        end
      end

      context 'long index name' do
        it 'generates a truncated index name' do
          allow(instance).to receive(:index_name_too_long?).and_return(true)
          expect(instance).to receive(:generate_index_name)
          subject
        end
      end
    end
  end

  describe '.rails_style_index_names' do
    subject { instance.rails_style_index_name }

    it 'creates an index in the style of rails add_index' do
      allow(instance).to receive(:index_table).and_return('foo')
      allow(instance).to receive(:index_fields).and_return(%w(bar baz))
      expect(subject).to eq 'foo_bar_baz_idx'
    end
  end

  describe '.index_name_too_long?' do
    subject { instance.index_name_too_long? }
    it 'is false for short names' do
      allow(instance).to receive(:rails_style_index_name).and_return(
        'moderately_descriptive_index_name'
      )
      expect(subject).to eq false
    end

    it 'is true for long names' do
      allow(instance).to receive(:rails_style_index_name).and_return(
        'something_really_long_that_most_sql_servers_dont_accept_as_an_index'
      )
      expect(subject).to eq true
    end
  end

  describe '.generate_index_name' do
    subject { instance.generate_index_name }
    before { allow(instance).to receive(:index_table).and_return('table') }

    context 'with few columns' do
      it 'generates a rails style index with the column names truncated' do
        allow(instance).to receive(:index_fields).and_return(%w(id foo name))
        expect(subject).to eq 'table_id_foo_nam_idx'
      end
    end

    context 'too many columns' do
      it 'generates a rails style index with the column names truncated' do
        allow(instance).to receive(:index_fields).and_return(
          %w(
            foo bar baz
            qux quux quuux
            quuuux quuuuux quuuuuux
            quuuuuuux quuuuuuuux quuuuuuuuux
            never gonna give you up
          )
        )
        expect(subject).to eq(
          'table_foo_bar_baz_qux_quu_quu_quu_quu_quu_idx'
        )
        expect(subject.length).to be <= klass::MAX_INDEX_NAME_LENGTH
      end
    end
  end
end
