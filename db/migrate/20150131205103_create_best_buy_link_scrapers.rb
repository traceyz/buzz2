class CreateBestBuyLinkScrapers < ActiveRecord::Migration
  def change
    create_table :best_buy_link_scrapers do |t|

      t.timestamps
    end
  end
end
