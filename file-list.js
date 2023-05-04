// JavaScript to grab lists of commonly-tested URLs

// Get absolute files URLs from `/admin/content/files`, run this function in the console.
// To get a list of ALL files, set the View to show all entries (may cause performance issues with > 5000 files)
function getDrupalFiles() {
  let list = [];
  jQuery('tbody .views-field-filename a').each(function() {
    list.push(jQuery(this).attr('href').replace('/sites/default/files/', 'public://'));
  });
  return list;
}

const generateSqlQueries = (filesList) => {
  let query='';
  for (let i=0; i<filesList.length; i++) {
    query += `CALL deleteFileRecord('${filesList[i]}');\n`;
  }
  console.log(query);
  return query;
}

copy(generateSqlQueries(getDrupalFiles()));
