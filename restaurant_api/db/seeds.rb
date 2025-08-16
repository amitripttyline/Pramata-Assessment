# Create admin user
admin_user = User.find_or_create_by(email: 'admin@restaurant.com') do |user|
  user.name = 'Restaurant Admin'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = 'admin'
end

# Create staff user
staff_user = User.find_or_create_by(email: 'staff@restaurant.com') do |user|
  user.name = 'Restaurant Staff'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = 'staff'
end

# Create customer users
customer1 = User.find_or_create_by(email: 'customer1@example.com') do |user|
  user.name = 'John Smith'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = 'customer'
end

customer2 = User.find_or_create_by(email: 'customer2@example.com') do |user|
  user.name = 'Jane Doe'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = 'customer'
end

puts "Created #{User.count} users"

# Create tables
tables_data = [
  { name: 'Table 1', capacity: 2, area: 'indoor', features: 'Window view, Quiet area', price_per_person: 25.0 },
  { name: 'Table 2', capacity: 4, area: 'indoor', features: 'Central location', price_per_person: 30.0 },
  { name: 'Table 3', capacity: 6, area: 'indoor', features: 'Large table, Family friendly', price_per_person: 35.0 },
  { name: 'Patio A', capacity: 2, area: 'outdoor', features: 'Garden view, Fresh air', price_per_person: 28.0 },
  { name: 'Patio B', capacity: 4, area: 'outdoor', features: 'Street view, Covered area', price_per_person: 32.0 },
  { name: 'Private Room 1', capacity: 8, area: 'private_dining', features: 'Soundproof, Projector, Private entrance', price_per_person: 50.0 },
  { name: 'Private Room 2', capacity: 12, area: 'private_dining', features: 'Large windows, Conference setup', price_per_person: 55.0 },
  { name: 'Bar Table 1', capacity: 2, area: 'indoor', features: 'Bar seating, High table', price_per_person: 22.0 },
  { name: 'Bar Table 2', capacity: 3, area: 'indoor', features: 'Bar seating, High table', price_per_person: 25.0 },
  { name: 'Corner Booth', capacity: 4, area: 'indoor', features: 'Cozy booth, Quiet corner', price_per_person: 40.0 }
]

tables_data.each do |table_data|
  table = Table.find_or_create_by(name: table_data[:name]) do |t|
    t.capacity = table_data[:capacity]
    t.area = table_data[:area]
    t.features = table_data[:features]
    t.price_per_person = table_data[:price_per_person]
  end
end

puts "Created #{Table.count} tables"

# Create time slots for the next 30 days
start_date = Date.current
end_date = start_date + 3.days

Table.find_each do |table|
  (start_date..end_date).each do |date|
    # Skip past dates
    next if date < Date.current
    
    # Create morning slots
    morning_slots = [
      { start: '11:00', end: '13:00' },
      { start: '11:30', end: '13:30' }
    ]
    
    # Create afternoon slots  
    afternoon_slots = [
      { start: '13:00', end: '15:00' },
      { start: '13:30', end: '15:30' },
      { start: '14:00', end: '16:00' }
    ]
    
    # Create evening slots
    evening_slots = [
      { start: '18:00', end: '20:00' },
      { start: '18:30', end: '20:30' },
      { start: '19:00', end: '21:00' },
      { start: '19:30', end: '21:30' },
      { start: '20:00', end: '22:00' }
    ]
    
    all_slots = morning_slots + afternoon_slots + evening_slots
    
    all_slots.each do |slot|
      start_datetime = DateTime.parse("#{date} #{slot[:start]}")
      end_datetime = DateTime.parse("#{date} #{slot[:end]}")
      
      TimeSlot.find_or_create_by(
        table: table,
        date: date,
        start_time: start_datetime,
        end_time: end_datetime
      ) do |ts|
        ts.is_available = true
        ts.notes = "Available for booking"
      end
    end
  end
end

puts "Created #{TimeSlot.count} time slots"

# Create some sample reservations
sample_time_slots = TimeSlot.available.limit(5)
sample_time_slots.each_with_index do |time_slot, index|
  customer = index.even? ? customer1 : customer2
  
  reservation = Reservation.create!(
    user: customer,
    time_slot: time_slot,
    party_size: rand(1..time_slot.table.capacity),
    special_requests: ['No allergies', 'Vegetarian options', 'Birthday celebration', 'Anniversary dinner', 'Business meeting'].sample,
    status: 'confirmed',
    reservation_date: DateTime.new(
      time_slot.date.year,
      time_slot.date.month,
      time_slot.date.day,
      time_slot.start_time.hour,
      time_slot.start_time.min
    )
  )
end

puts "Created #{Reservation.count} reservations"

# Create some completed reservations and reviews for past dates
past_date = Date.current - 5.days
past_time_slots = TimeSlot.where(date: past_date).limit(3)

past_time_slots.each do |time_slot|
  # Create a completed reservation
  reservation = Reservation.create!(
    user: customer1,
    time_slot: time_slot,
    party_size: 2,
    special_requests: 'Great evening out',
    status: 'completed',
    reservation_date: DateTime.new(
      time_slot.date.year,
      time_slot.date.month,
      time_slot.date.day,
      time_slot.start_time.hour,
      time_slot.start_time.min
    )
  )
  
  # Create a review for the completed reservation
  Review.create!(
    user: customer1,
    reservation: reservation,
    rating: [4, 5].sample,
    comment: [
      'Excellent food and service! Will definitely come back.',
      'Great atmosphere and delicious meals. Highly recommended!',
      'Perfect place for a romantic dinner. Staff was very attentive.',
      'Outstanding experience from start to finish.'
    ].sample
  )
end

puts "Created #{Review.count} reviews"

puts "\nSeed data creation completed!"
puts "Admin login: admin@restaurant.com / password123"
puts "Staff login: staff@restaurant.com / password123" 
puts "Customer login: customer1@example.com / password123"
puts "Customer login: customer2@example.com / password123"