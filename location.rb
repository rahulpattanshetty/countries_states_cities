require 'csv'
class Location
	
	def self.get_country_id(name)
		countries = Location.countries
		countries.each do |country|
			if country["name"] == name
				return country["id"].to_i
			end
		end
	end
	def self.get_state_id(name,country_id)
		states = Location.states(country_id)
		states.each do |state|
			if state["name"] == name
				return state["id"].to_i
			end
		end
	end
	def self.countries
		file = File.read('countries.json')
		data_hash = JSON.parse(file)
		return data_hash["countries"]
	end

	def self.states(country_id)
		file = File.read('states.json')
		data_hash = JSON.parse(file)
		states = []
		data_hash["states"].each do |state|
			if state["country_id"].to_i == country_id.to_i
				states.push(state)
			end
		end
		return states
	end

	def self.cities(state_id)
		file = File.read('cities.json')
		data_hash = JSON.parse(file)
		cities = []
		data_hash["cities"].each do |city|
			if city["state_id"].to_i == state_id.to_i
				cities.push(city)
			end
		end
		return cities
	end


	def self.read_csv
		file = CSV.read('countries_states_cities.csv')
		file.shift
		countries_array = []
		states_array = []
		countries_hash = {countries:[]}
		states_hash = {states:[]}
		cities_hash = {cities:[]}
		country_count = 1
		state_count = 1
		city_count = 1
		file.each do |array|
			unless countries_array.include?array.last
				countries_array << array.last
				countries_hash[:countries] << {id:country_count.to_s,name:array.last}
				country_count += 1
			end
			unless states_array.include?array.second
				states_array << array.second
				country_id = countries_hash[:countries].select{|country| country[:name] == array.last}.first[:id]
				states_hash[:states] << {id:state_count.to_s,name:array.second,country_id:country_id}
				state_count += 1
			end
			state_id = states_hash[:states].select{|state| state[:name] == array.second}.first[:id]
			cities_hash[:cities] << {id:city_count.to_s,name:array.first,state_id:state_id}
			city_count += 1
		end
		Location.write_file("countries.json",countries_hash)
		Location.write_file("states.json",states_hash)
		Location.write_file("cities.json",cities_hash)

	end

	def self.write_file(file_name,data)
		File.open("#{file_name}", "w") do |f|
	 		f.truncate(0)  
			f.write(data.to_json)
			f.close  
		end
	end
end