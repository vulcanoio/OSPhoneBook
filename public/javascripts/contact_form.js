Event.observe(document, 'dom:loaded', function() {
    new Autocomplete('company_search_field', {
        serviceUrl: '/company_search',
        minChars: 1,
        maxHeight: 400,
        width: 390,
        deferRequestBy: 200,
        onSelect: function(value, data) {
            $('company_search_field').value = data;
            focusNextField('company_search_field');
        }
    });

    new Autocomplete('add_tag', {
        serviceUrl: '/tag_search',
        minChars: 1,
        maxHeight: 400,
        width: 390,
        deferRequestBy: 200,
        onSelect: function(value, data) {
            $('company_search_field').value = "";
            updateFormTags(data);
        }
    });

    $('company_search_field').observe('keypress', function(e) {
        if (e.keyCode == Event.KEY_RETURN) {
            e.stop();
        }
    });

    $('add_tag').observe('keypress', function(e) {
        if (e.keyCode == Event.KEY_RETURN) {
            e.stop();
        }
    });

    if ($("contact_name").value.length > 0) {
        $("company_search_field").focus();
    } else {
        $("contact_name").focus();
    }
});

function focusNextField(id) {
    var element = $(id);
    var form = element.form;
    var next_id = 0;
    for (var i = 0; i < form.elements.length; i++) {
        if (form.elements[i] == element) {
            next_id = i + 1;
        }
    }
    var next_element = form.elements[next_id];
    if (next_element) {
        next_element.focus();
    }
}

function remove_tag(container) {
    $(container).up(".tag").remove();
}

function updateFormTags(newTag) {
    new Ajax.Updater({success: 'tags'}, '/set_tags', {
        parameters: {
            add_tag: newTag,
            'tags[]': $$(".tag input[type='hidden']").pluck('value')
        },
        asynchronous:true,
        evalScripts:true,
        onSuccess: function (response) {
            $('add_tag').value = "";
        }
    });
    return false;
}
