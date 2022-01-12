class Event < ApplicationRecord
  has_many :comments

  # below should probably be held in a separate PORO class in a larger scope project

  def parse_event
    # assuming the log inputs are consistently formatted, can get away with reductive regex ops as MVP
    data_map = {}
    begin
      remove_index_tag = raw.split(/^\<\d+?\>/).last
      delimited_sections = remove_index_tag.split("|")
      data_map["eventHeadings"] = delimited_sections[0..-2]
      data_map_string = delimited_sections.last # where the k:v pairs begin
      # gather the keys into array
      data_map_keys = data_map_string.scan(/(\w*)=/m).flatten
      # parse value for every key except last
      data_map_keys[0..-2].each do |key|
        # use current and next key as boundaries, select content in between
        value = data_map_string.match(/(#{key}=)(.+?)(?:\w+?=)/)[2].strip
        value.empty? ? data_map[key] = nil : data_map[key] = value
      end
      # parse value for last key
      last_key = data_map_keys.last
      data_map[last_key] = data_map_string.match(/(#{last_key}=)(.+?$|$)/)[2].strip
      data_map[last_key] = nil if data_map[last_key].empty?
    rescue
      data_map = {"error" => "failed to deserialize raw event string"}
    end
    data_map
  end

  def serialize_report
    map = parse_event
    begin
      src_ip = IPAddr.new(map.dig("src"))
    rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError
      src_ip = nil
    end
    begin
      dst_ip = IPAddr.new(map.dig("dst"))
    rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError
      dst_ip = nil
    end
    return {
      summary: {
        source_ip: map.dig("src"),
        source_ip_valid: !src_ip.nil?,
        source_ip_private: src_ip&.private?,
        destination_ip: map.dig("dst"),
        destination_ip_valid: !dst_ip.nil?,
        destination_ip_private: dst_ip&.private?
      },
      details: map,
      raw: raw,
      id: id,
      added: created_at
    }
  end

end
