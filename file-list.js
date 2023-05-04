// JavaScript to grab lists of commonly-tested URLs

// Get absolute files URLs from `/admin/content/files`, run this function in the console
function getDrupalFiles() {
  let list = '';
  jQuery('tbody .views-field-filename a').each(function() {
    list += jQuery(this).attr('href') + '\n';
  });
  console.log(list);
  copy(list);
}
