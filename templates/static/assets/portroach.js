var fproc = null;

function FilterResults() {
	if (!fproc) {
		var button = document.getElementById('submitbutton');

		if (!button)
			return;

		button.setAttribute('disabled', 'disabled');
		button.value = 'Processing...';

		fproc = setTimeout(DoFilter, 100);
	}
}

function DoFilter() {
	var outofdate  = document.getElementById('filter_ood');
	var port       = document.getElementById('filter_port');
	var maintainer = document.getElementById('filter_maintainer');
	var results    = document.getElementById('results');
	var button     = document.getElementById('submitbutton');
	var regex;
	var filter;

	if (!port)
		filter = maintainer;

	if (!maintainer)
		filter = port;

	if (!outofdate || !results || !button || !filter)
		return;

	regex = new RegExp(filter.value, 'i');

	for (var i = 0; i < results.childNodes.length; i++) {
		var row, row_filter, row_withnew;
		row = results.childNodes[i];
		if (row.tagName != 'TR' || row.className == 'resultshead')
			continue;

		if (!row.childNodes[0] || !row.childNodes[0].childNodes[0])
			continue;

		row_filter    = row.childNodes[0].childNodes[0].innerHTML;
		row_withnew = parseInt(row.childNodes[3].childNodes[0].innerHTML);

		if (!regex.test(row_filter)) {
			row.style.display = 'none';
		} else if (outofdate.checked && row_withnew == 0) {
			row.style.display = 'none';
		} else {
			try {
				row.style.display = 'table-row';
			} catch(e) {
				row.style.display = 'block';
			}
		}
	}

	fproc = null;

	button.value = 'Apply';
	button.removeAttribute('disabled');
}
