     function LoadTableRows(filter, limit, tot_page, current_page)
     {
        $('#dataTable tbody').empty();

        $('p#dataTable_info').text('');

        var page_number = current_page;
        var page_count  = current_page;
        var i           = 0;

        return $.ajax({
            type: "POST",
            url: "/table/load_data_table/",
            data: "max_records=35&filter=" + filter + "&limit=" + limit + "&page=" + current_page,
            async: true,
            success: function (result) {
                var myjson = JSON.parse(JSON.stringify(result)); 
                page_number = myjson.page_number;
                page_count  = myjson.page_count;
                $('p#dataTable_info').text('Records count: ' + myjson.record_count + ' -- ' + 'Pag. ' + page_number + ' of ' + page_count);  
                var myrs   = JSON.parse(myjson.recordset); 

                for (i in myrs) {
                    $('#dataTable tbody').append('<tr><td>#' + myrs[i][0] + '</td><td>' + myrs[i][1] + '</td><td>' + myrs[i][2] + '</td><td>' + myrs[i][3] + '</td><td>' + myrs[i][4] + '</td><td>' + myrs[i][5] + '</td></tr>');
                }          


                //destroy current list page
                $('li#page_first').remove();
                for(i = 1; i<=tot_page; i++)
                {
                    $('li#page' + i).remove();   
                }            
                $('li#page_last').remove();
                //add new list page      

                if (page_number==1)
                {
                    $('#list_page').append('<li id="page_first" class="page-item disabled"><a class="page-link" aria-label="Previous" href="#" page_value="1"><span aria-hidden="true">«</span></a></li>');
                }else{
                    $('#list_page').append('<li id="page_first" class="page-item"><a class="page-link" aria-label="Previous" href="#" page_value="1"><span aria-hidden="true">«</span></a></li>');                    
                }
                for(i = 1; i<=page_count; i++)
                {
                    if (i==page_number)
                    {
                        $('#list_page').append('<li id="page' + i + '" class="page-item active"><a class="page-link" page_value="' + i + '">' + i + '</a></li>');
                    }else{
                        $('#list_page').append('<li id="page' + i + '" class="page-item"><a class="page-link" href="#" page_value="' + i + '">' + i + '</a></li>');
                    }
                } 
                if (page_number==page_count)
                {
                    $('#list_page').append('<li id="page_last" class="page-item disabled"><a class="page-link" aria-label="Previous" href="#" page_value="' + page_count + '"><span aria-hidden="true">»</span></a></li>'); 
                }else{
                    $('#list_page').append('<li id="page_last" class="page-item"><a class="page-link" aria-label="Previous" href="#" page_value="' + page_count + '"><span aria-hidden="true">»</span></a></li>'); 
                }
              
                   
            },
    		error: function(XMLHttpRequest, textStatus, errorThrown) { 
        		alert("Error status: " + textStatus); 
        		alert("Error: " + errorThrown); 
    		} 
        });
        
        return page_number;
     }   


     $(document).ready(function(){

        var filter       = '';
        var limit        = 10;
        var tot_page     = $("#list_page").find("li").length;
        var current_page = 1;

        

        current_page = LoadTableRows(filter, limit, tot_page, current_page);
        
        $('#mysearch').on('change', function(e) {
            filter = e.target.value;
            current_page = LoadTableRows(filter, limit, tot_page, current_page);
        });

        $('#dataTable_length').on('change', function(e) {
            limit = e.target.value;
            current_page = LoadTableRows(filter, limit, tot_page, current_page);
        });

        $('body').on('click', '.page-link',function(e) {
            current_page = $(this).attr('page_value');
            current_page = LoadTableRows(filter, limit, tot_page,current_page);
            return false; //disable link click
        });

     });
