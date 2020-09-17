
let region_select = document.getElementById("default_region_select");

region_select.onchange = function() {
    this.form.submit();
};
