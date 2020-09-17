
let region_select = document.getElementById("region_select");

region_select.onchange = function() {
    console.log("hit onchange!");
    this.form.submit();
};
