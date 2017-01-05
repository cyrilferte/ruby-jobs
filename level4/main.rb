require "json"
require 'date'


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
    @nb_error = 0
    file = File.read('data.json')
    data = JSON.parse(file)
    @workers_data = data['workers']
    @shifts_data = data['shifts']
    clean
    @workers = data['workers'].map { |w| Worker.new(w['id'], w['first_name'], w['status']) }
    @shifts = data['shifts'].map { |w| Shift.new(w['id'], w['planning_id'], w['user_id'], w['start_date']) }
    @workers_output = { }
end
def calcul
    i=0
    @nb_interim=0
    loop do 
        @workers_data.each { |v| v["count"] = 0 }
        @shifts_data.each { |v| v["day"] = "" ; d = DateTime.parse(v['start_date']) ; v["day"]= d.strftime('%A') }
        @workers_data.each { |v|  if v["status"] == "medic" then v["price_per_shift"] = 270  elsif v["status"] == "interne" then v["price_per_shift"] = 126 elsif v["status"] == "interim" then v["price_per_shift"] = 480  end }
        @shifts_data.each { |shift|  add= @workers_data.detect {|f| f["id"] == shift["user_id"] } ; add["count"] += 1 ; if shift['day'] == "Saturday" || shift['day'] == "Sunday" then add["count"] += 1 end  ; }
        i+=1
        @workers_output[i-1] = {id: @workers_data[i-1]["id"], price: @workers_data[i-1]["price_per_shift"] * @workers_data[i-1]["count"]}
    break if i>= @workers_data.length - @nb_error
    end 
end
def export
        @workers_data.each do |workers_data|
            if workers_data['status'] == "interim" then  @nb_interim += workers_data['count']end
        end 
        
        
        @commition = 0
        @workers_output.each_value do |v|
            val_com = v[:price].to_f
            @commition +=  val_com * 0.05 
        end
        @commition +=  @nb_interim * 80.00
    File.open("output_test.json", "w") do |f|
        @workers_output.each_value do |out_hash|
            f.write( out_hash.to_json ) 
        end
        f.write( " Commission :" + @commition.to_json + " nb interim :" + @nb_interim.to_json )
    end
end
def clean
    @shifts_data.delete_if { |v| v['user_id'].nil?    }
    @shifts_data.delete_if { |v| v['planning_id'].nil?   }
    @shifts_data.delete_if { |v| v['start_date'].nil?   }
    @shifts_data.delete_if { |v| v['id'].nil? }
end
import
calcul
export