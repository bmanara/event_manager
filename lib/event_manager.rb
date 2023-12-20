# Iteraiton 0 (Not a good way of dea[ling with csv files])
=begin

end

puts "Event Manager Initialized!"

# contents = File.read('event_attendees.csv') #returns a string of all the content
# puts contents

lines = File.readlines('event_attendees.csv') #returns an array of lines
# lines.each do |line|
#   puts line
# end

# Displaying the first names of all the Attendees
lines.each do |line|
  columns = line.split(",")
  name = columns[2]
  p name
end
=end

# Iteration 1 (Parsing with CSV)
require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

# Iteration 2 (Cleaning zipcodes)
def clean_zipcode(zipcode)
  # if zipcode is exactly 5 digits, return original
  # elsif zipcode is more than 5 digits, truncate to 5
  # elsif zipcode is less than 5 digits, add zeros to the front until it has 5 digits
  # if zipcode.nil?
  #   zipcode = "00000"
  # elsif zipcode.length < 5
  #   zipcode = zipcode.rjust(5, '0')
  # elsif zipcode.length > 5
  #   zipcode = zipcode[0..4]
  # end
  zipcode.to_s.rjust(5, '0')[0..4]
end

# Iteration 3 (Using Google's Civic API)
def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )

    legislators = legislators.officials
    legislators
  #   legislators_name = legislators.map do |legislator|
  #     legislator.name
  #   end
  # # legislators_name = legislators.map(&:name) # simplified version of the top

  #   legislators_string = legislators_name.join(",")
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

# Iteration 4 (Saving form letters)
def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

# Automtically deals with the headers for us
contents = CSV.open('event_attendees.csv',
                    headers: true,
                    header_converters: :symbol) # converts headers into symbols
# template_letter = File.read("form_letter.html")
template_letter = File.read("form_letter.erb")
p template_letter
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name] # Note that header was "first_Name"
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  # Iteration 4 (Formatting into a letter)
  # personal_letter = template_letter.gsub('FIRST_NAME', name)
  # personal_letter.gsub!('LEGISLATORS', legislators)
  # There are issues with the above code, for instance, how do we format it into out HTML table?

  # Ruby's ERB
  personal_letter = erb_template.result(binding)
  # Create an output folder, save each form letter to a file based on the id
  save_thank_you_letter(id, personal_letter)
end
