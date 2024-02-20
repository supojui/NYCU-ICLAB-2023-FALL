module Train(
    //Input Port
    clk,
    rst_n,
	in_valid,
	data,

    //Output Port
    out_valid,
	result
);

input        clk;
input 	     in_valid;
input        rst_n;
input  [3:0] data;
output   reg out_valid;
output   reg result; 


reg [3:0]carriage_num;
reg [3:0]data_arr[0:9];

reg [5:0]counter_input;
reg [5:0]counter_cal;
reg [5:0]counter_data_arr;

reg [3:0]A_arr[0:9];
reg [3:0]station_arr[0:9];
reg [3:0]B_arr[0:9];

reg result_comb;

integer i;



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_cal <= 0;
    end
    else begin
        if(counter_input > 0 && !in_valid || counter_cal > 0) begin
            counter_cal <= (counter_data_arr == carriage_num) ? 0 : counter_cal + 1; 
        end
        else begin
            counter_cal <= 0;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for (i = 0; i < 10; i = i + 1) begin
            A_arr[i] <= i + 1;
            station_arr[i] <= 0;
            B_arr[i] <= 0;
        end
        counter_data_arr <= 0;
    end
    else begin
        if(counter_cal >= 1) begin
            if(data_arr[counter_data_arr] == A_arr[0] && counter_data_arr <= carriage_num) begin
                // for (i = 0; i < 9; i = i + 1) begin
                //     B_arr[i+1] <= B_arr[i];
                // end
                B_arr[counter_data_arr] <= A_arr[0];

                for (i = 0; i < 10; i = i + 1) begin
                    A_arr[i] <= A_arr[i+1];
                end
                A_arr[9] <= 0;

                counter_data_arr <= counter_data_arr + 1;
            end
            else begin

                if(station_arr[0] == data_arr[counter_data_arr]) begin
                    // for (i = 0; i < 9; i = i + 1) begin
                    //     B_arr[i+1] <= B_arr[i];
                    // end

                    B_arr[counter_data_arr] <= station_arr[0];

                    for (i = 0; i < 10; i = i + 1) begin
                        station_arr[i] <= station_arr[i+1];
                    end

                    station_arr[9] <= 0;

                    counter_data_arr <= (counter_data_arr >= carriage_num) ? 0 : counter_data_arr + 1;
                end
                else begin
                    for (i = 0; i < 9; i = i + 1) begin
                        station_arr[i+1] <= station_arr[i];
                    end

                    station_arr[0] <= A_arr[0];

                    for (i = 0; i < 10; i = i + 1) begin
                        A_arr[i] <= A_arr[i+1];
                    end
                    A_arr[9] <= 0;

                    counter_data_arr <= (counter_data_arr == carriage_num) ? 0 : (counter_cal >= 60) ? carriage_num : counter_data_arr;
                end
            end
        end
        else begin
            for (i = 0; i < 10; i = i + 1) begin
                A_arr[i] <= i + 1;
                station_arr[i] <= 0;
                B_arr[i] <= 0;
            end
            counter_data_arr <= 0;
        end
    end

end 


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for (i = 0; i < 10; i = i + 1) begin
            data_arr[i] <= 0;
        end
        carriage_num <= 0;
    end
    else begin

        if(in_valid) begin
            carriage_num <= (counter_input == 0) ?  data : carriage_num;
            
            for (i = 0; i < 10; i = i + 1) begin
                data_arr[i] <= data_arr[i];
            end
            case(counter_input) 
                1 : data_arr[0] <= data;
                2 : data_arr[1] <= data;
                3 : data_arr[2] <= data;
                4 : data_arr[3] <= data;
                5 : data_arr[4] <= data;
                6 : data_arr[5] <= data;
                7 : data_arr[6] <= data;
                8 : data_arr[7] <= data;
                9 : data_arr[8] <= data;
                10: data_arr[9] <= data;
            endcase
        end
        else if(out_valid) begin
            carriage_num <= 0;
            for (i = 0; i < 10; i = i + 1) begin
                data_arr[i] <= 0;
            end
        end
        else begin
            carriage_num <= carriage_num;
            for (i = 0; i < 10; i = i + 1) begin
                data_arr[i] <= data_arr[i];
            end
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_input <= 0;
    end
    else begin
        if(in_valid) begin
            counter_input <= counter_input + 1;
        end
        else begin
            counter_input <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        result <= 0;
    end
    else begin
        if(counter_data_arr == carriage_num && counter_cal > 0) begin
            out_valid <= 1;
            if( B_arr[0] == data_arr[0] && B_arr[1] == data_arr[1] && B_arr[2] == data_arr[2] && 
                B_arr[3] == data_arr[3] && B_arr[4] == data_arr[4] && B_arr[5] == data_arr[5] && 
                B_arr[6] == data_arr[6] && B_arr[7] == data_arr[7] && B_arr[8] == data_arr[8] && 
                B_arr[9] == data_arr[9])
                result <= 1;
            else begin
                result <= 0;
            end
        end
        else begin
            out_valid <= 0;
            result <= 0;
        end
    end
end

endmodule