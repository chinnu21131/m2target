def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_hash = {}
  dns_array = dns_raw.reject { |line| line.empty? }.map { |dns_array| dns_array.split(",").map { |data_in_array| data_in_array.strip } }
  dns_array.select { |data_array| data_array.length == 3 }.each { |data_array| dns_hash[data_array[1]] = { :type => data_array[0], :value => data_array[2] } }
  return dns_hash
end

def resolve(dns_records, lookup_chain, domain)
  if (!dns_records.keys.include?(domain))
    puts "Error: record not found for #{domain}"
    exit
  elsif dns_records[domain][:type] == "A"
    lookup_chain.push dns_records[domain][:value]
  elsif dns_records[domain][:type] == "CNAME"
    lookup_chain.push dns_records[domain][:value]
    resolve(dns_records, lookup_chain, dns_records[domain][:value])
  end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
