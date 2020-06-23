	 $(document).ready(function(){

		$('.custom-checkbox').on('change', function(e) {
		    if(document.getElementById(e.target.id).checked) {
		    	alert(e.target.id + ' check ' + e.target.value);
		    }else{
		    	alert(e.target.id + ' uncheck ' + e.target.value);
		    }

            return $.ajax({
                type: "POST",
                url: "/index/set_item_todolist",
                data: "key=1&value=2",
                async: false,
                success: function (result) {
                    alert(result);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) { 
                    alert("Error status: " + textStatus); 
                    alert("Error: " + errorThrown); 
                } 
            });



	    });

	 });	

