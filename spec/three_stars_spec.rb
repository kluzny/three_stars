require 'spec_helper'

describe ThreeStars do
  let(:klass) { described_class }

  it 'has a version number' do
    expect(klass::VERSION).not_to be nil
  end
end
