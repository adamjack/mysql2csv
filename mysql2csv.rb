require 'mysql2';
require 'csv';

database 	= ARGV[0];
username 	= ARGV[1];
password 	= ARGV[2];
table 		= ARGV[3];

begin
	client = Mysql2::Client.new(:host => "localhost", :username => username, :password => password)
	client.query "USE #{database};"

	# The metadata
	metadataRS = client.query "SELECT GROUP_CONCAT(COLUMN_NAME SEPARATOR ',') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '#{database}' AN
D TABLE_NAME = '#{table}' GROUP BY TABLE_NAME;", :as => :array

	columns = metadataRS.first[0].split(',')

	# The contents...
	rs = client.query "SELECT * FROM #{table}", :as => :array

 	data =	CSV.generate do |csv|
                        csv << columns
                        rs.each do |row|
			row.map { |v| v.nil? ? '' : v }
				csv << row
			end
		end

	puts data
    
rescue Mysql2::Error => e
    puts e.errno
    puts e.error
    
ensure
    client.close if client
end
