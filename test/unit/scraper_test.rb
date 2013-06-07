require 'test_helper'

class ScraperTest < ActiveSupport::TestCase

  describe Scraper do
    describe '.unescape' do
      it 'should remove entities' do
        Scraper.unescape("John &amp; Martha").should == "John & Martha"
      end
    end
  end

end
