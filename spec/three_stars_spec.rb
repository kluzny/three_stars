require 'spec_helper'

describe ThreeStars do
  let(:klass) { described_class }

  it 'has a version number' do
    expect(klass::VERSION).not_to be nil
  end

  it 'creates a builder on new' do
    options = { foo: :bar }
    sql = ''
    expect(ThreeStars::Builder).to(
      receive(:new).with(sql, options).and_return(proc {})
    )
    ThreeStars.new(sql, options)
  end
end
