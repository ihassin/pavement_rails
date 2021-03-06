class Reading < ActiveRecord::Base
	include StatisticsHelper

	belongs_to :ride

  validates_numericality_of :ride_id
  validates_presence_of :ride_id
  validates_uniqueness_of :ride_id

	def sd_packet
		{
			start_location: [start_lat,start_lon],
			end_location: [end_lat,end_lon],
			roughness: get_sd_roughness
			# speed: get_speed
		}
	end

	def mean_packet
		{
			start_location: [start_lat,start_lon],
			end_location: [end_lat,end_lon],
			roughness: get_mean_roughness
			# speed: get_speed
		}
	end

	def adjusted_mean_packet
		{
			start_location: [start_lat,start_lon],
			end_location: [end_lat,end_lon],
			roughness: mean_roughness_adjusted_for_speed
			# speed: get_speed
		}
	end

	def get_sd_roughness
		standard_deviation accel_as_array
	end

	def get_mean_roughness
		mean accel_as_array.map(&:magnitude)
	end

	def mean_roughness_adjusted_for_speed
		# pretty arbitrary right here would be nice to get an actual regression on speed v roughness
		# just messed around w it until adjusted values on same pavement w diff speeds came p close
		if speed > 4.0 then
      (get_mean_roughness / (((square(speed - 4.0)) / speed) + 1.0))
    else
        get_mean_roughness
    end
	end

	def accel_as_array
		acceleration.split.map(&:to_f)
	end

	def has_accel?
		!acceleration.empty?
	end

	def distance_meters
		GeoDistance.default_algorithm = :haversine
  	GeoDistance.distance(start_lat, start_lon, end_lat, end_lon).meters.number
	end

	def speed # meters per second
  	time = end_time - start_time
  	if time != 0
      distance_meters / time
    else
      0
    end
	end
end

# == Schema Information
#
# Table name: readings
#
#  id           :integer          not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  start_lat    :float
#  start_lon    :float
#  end_lat      :float
#  end_lon      :float
#  acceleration :string
#  ride_id      :integer
#  start_time   :float
#  end_time     :float
#
