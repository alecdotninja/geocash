after 'development:geocash' do
  if Account.count == 0
    1..10.times do |i|
      Account.create!
    end
  end
end
