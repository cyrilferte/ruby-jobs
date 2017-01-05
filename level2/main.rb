require "json"



class Worker
  attr_accessor :id, :first_name, :status, :price
    def initialize(id, first_name, status)
        @id = id
        @first_name = first_name
        @status = status
         status == "medic" ? @price = 270  : @price = 126
         
    end
end
class Shift
  attr_accessor :id, :planning_id, :user_id, :start_date
    def initialize(id, planning_id, user_id, start_date)
        @id = id
        @planning_id = planning_id
        @user_id = user_id
        @start_date = start_date
    end
end
def import
    file = File.read('data.json')
    data = JSON.parse(file)
    @workers_data = data['workers']
    @shifts_data = data['shifts']
    @workers = data['workers'].map { |w| Worker.new(w['id'], w['first_name'], w['status']) }
    @shifts = data['shifts'].map { |w| Shift.new(w['id'], w['planning_id'], w['user_id'], w['start_date']) }
    @workers_output = { }
end
def calcul
    i=0
    loop do 
        @workers_data.each { |v| v["count"] = 0 }
        @workers_data.each { |v| v["price_per_shift"] = v["status"] == "medic" ? @price = 270  : @price = 126 }
        @shifts_data.each { |shift| add= @workers_data.detect {|f| f["id"] == shift["user_id"] }; add["count"] += 1 }
        i+=1
        @workers_output[i-1] = {id: @workers_data[i-1]["id"], price: @workers_data[i-1]["price_per_shift"] * @workers_data[i-1]["count"]}
    break if i>= @workers_data.length
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