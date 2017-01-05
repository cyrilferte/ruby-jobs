require "json"

# your code

    def import
        file = File.read('data.json')
        data_hash = JSON.parse(file)
        @workers = data_hash['workers']
        @shifts = data_hash['shifts']
        @workers_output={}
    end

    def calcul
        i=0
        loop do 
            @workers.each { |v| v["count"] = 0 }
            @shifts.each { |shift| add= @workers.detect {|f| f["id"] == shift["user_id"] }; add["count"] += 1 }
            i+=1
            @workers_output[i-1] = {id: @workers[i-1]["id"], price: @workers[i-1]["price_per_shift"] * @workers[i-1]["count"]}
        break if i>= @workers.length
        end 
    end
    
    def export
        
        File.open("output_test.json", "w") do |f|
            @workers_output.each_value do |out_hash|
                f.write( out_hash.to_json ) 
            end
        end
    end
    

import
calcul
export

