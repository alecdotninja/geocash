if Geocash.count == 0
  1..10.times do |i|
    Geocash.create!
  end
end