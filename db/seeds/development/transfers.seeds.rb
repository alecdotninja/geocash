after 'development:accounts' do
  Account.all.each do |account|
    account.transfers.create!(amount: 100, geocash: Geocash.all.sample, confirmed_at: DateTime.now)
  end
end