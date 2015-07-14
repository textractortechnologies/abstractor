Abstractor = {}
Abstractor.AbstractionUI = ->
  $(document).on "click", ".abstractor_abstraction .clear_link", (e) ->
    e.preventDefault()
    that = this
    $.ajax
      type: 'POST'
      data: { format: 'html', '_method': 'put', 'abstractor_abstraction': { } }
      url: $(this).attr('href')
      success: (data) ->
        abstractor_abstraction_group = $(that).closest('.abstractor_abstraction_group')
        $(that).closest(".abstractor_abstraction").html(data)
        abstractor_abstractions = $(abstractor_abstraction_group).find('.abstractor_abstraction')
        set_abstractions = $(abstractor_abstraction_group).find('.abstractor_abstraction input:checkbox:checked').map(->
          $(this).val()
        ).get()
        if abstractor_abstractions.length == set_abstractions.length
          $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').removeClass('abstractor_group_update_workflow_status_link_disabled')
          $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').addClass('abstractor_group_update_workflow_status_link_enabled')
          $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').prop('disabled', false)
        else
          $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').removeClass('abstractor_group_update_workflow_status_link_enabled')
          $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').addClass('abstractor_group_update_workflow_status_link_disabled')
          $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').prop('disabled', true)
        return
    return false

  $(document).on "click", ".abstractor_abstractions .show_hide_abstractor_history_link", (e) ->
    e.preventDefault()
    if $(this).hasClass('show_abstractor_history')
      $(this).removeClass('show_abstractor_history')
      $(this).addClass('hide_abstractor_history')
      $(this).closest(".abstractor_history").find('.abstactor_history_content').removeClass('hide')
      $(this).html('(Hide)')
    else
      $(this).addClass('show_abstractor_history')
      $(this).removeClass('hide_abstractor_history')
      $(this).closest(".abstractor_history").find('.abstactor_history_content').addClass('hide')
      $(this).html('(Show)')
    return false

  $(document).on "click", ".abstractor_abstraction_value a.edit_link", (e) ->
    e.preventDefault()
    abstractor_abstraction_group = $(this).closest('.abstractor_abstraction_group')
    parent_div = $(this).closest(".abstractor_abstraction")
    parent_div.load $(this).attr("href"), ->
      parent_div.find(".combobox").combobox watermark: "a value"
      $(".abstractor_datepicker").datepicker
        altFormat: "yy-mm-dd"
        dateFormat: "yy-mm-dd"
        changeMonth: true
        changeYear: true
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').removeClass('abstractor_group_update_workflow_status_link_enabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').addClass('abstractor_group_update_workflow_status_link_disabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').prop('disabled', true)

      return

    parent_div.addClass "highlighted"
    return

  $(document).on "ajax:success", "form.edit_abstractor_abstraction", (e, data, status, xhr) ->
    abstractor_abstraction_group = $(this).closest('.abstractor_abstraction_group')
    parent_div = $(this).closest(".abstractor_abstraction")
    parent_div.html xhr.responseText
    parent_div.removeClass "highlighted"

    abstractor_abstractions = $(abstractor_abstraction_group).find('.abstractor_abstraction')
    set_abstractions = $(abstractor_abstraction_group).find('.abstractor_abstraction input:checkbox:checked').map(->
      $(this).val()
    ).get()
    if abstractor_abstractions.length == set_abstractions.length
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').removeClass('abstractor_group_update_workflow_status_link_disabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').addClass('abstractor_group_update_workflow_status_link_enabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').prop('disabled', false)
    else
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').removeClass('abstractor_group_update_workflow_status_link_enabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').addClass('abstractor_group_update_workflow_status_link_disabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').prop('disabled', true)
    return

  $(document).on "click", ".edit_abstractor_abstraction input[type='radio']", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false
    return

  $(document).on "click", ".edit_abstractor_abstraction input[type='checkbox']", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false
    $(this).siblings("input[type='text']").prop "value", ""
    autocompleters = $(this).siblings("select.combobox")
    autocompleters.combobox "setValue", ""
    autocompleters.change()
    $.each $(this).siblings("input[type='radio']"), ->
      if $(this).prop("value") is ""
        $(this).prop "checked", true
      else
        $(this).prop "checked", false
      return

    return

  $(document).on "change", ".edit_abstractor_abstraction select.combobox", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false  if $(this).find("option:selected").prop("value").length
    return

  $(document).on "change", ".edit_abstractor_abstraction input[type='text']", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false
    return

  $(document).on "click", ".abstractor_abstraction_source_tooltip_img", (e) ->
    e.preventDefault()
    target = $(this).attr("rel")
    tab = $(target).find('.abstractor_source_tab')
    if tab.length == 1
      tab = $(tab).html().trim()
      $('#' + tab + ' input[type=radio]').prop('checked', true)
      $('#' + tab + ' .abstractor_source_tab_content').unhighlight()
      if $(this).hasClass('highlighted_suggestion')
        highlight = false
        $(this).removeClass('highlighted_suggestion')
      else
        highlight = true
        $('.highlighted_suggestion').removeClass('highlighted_suggestion')
        $(this).addClass('highlighted_suggestion')
      $(target).find('.sentence').each (index) ->
        sentence_match_value = _.unescape($(this).find('.sentence_match_value').html().trim()).replace(/[.^$*+?()[{\\|\]-]/g, '\\$&')
        if highlight
          $(this).find('.match_value').each (index) ->
            match_value = $(this).html().trim()
            $('#' + tab + " .abstractor_source_tab_content .abstractor_highlight:regex('" + sentence_match_value + "')").highlight(match_value)
            $('.abstractor_source_tab_content').scrollTo($('.abstractor_highlight .highlight'))
            return
        else
          $(this).find('.match_value').each (index) ->
            match_value = $(this).html().trim()
            $('#' + tab + " .abstractor_source_tab_content .abstractor_highlight:regex('" + sentence_match_value + "')").unhighlight(match_value)
            return
        return
    return

  $(document).on "change", "select.indirect_source_list", ->
    source_type = $(this).attr("rel")
    value = $(this).find("option:selected").prop("value")
    $(this).siblings(".indirect_source_text").addClass "hidden"
    $(this).siblings("." + source_type + "_" + value).removeClass "hidden"
    return

  return

Abstractor.AbstractionSuggestionUI = ->
  $(document).on "change", ".abstractor_suggestion_status_selection", ->
    $(this).closest("form").submit()
    $('.abstractor_footer').unhighlight()
    return

  $(document).on "ajax:success", "form.edit_abstractor_suggestion", (e, data, status, xhr) ->
    abstractor_abstraction_group = $(this).closest('.abstractor_abstraction_group')
    $(this).closest(".abstractor_abstraction").html xhr.responseText
    abstractor_abstractions = $(abstractor_abstraction_group).find('.abstractor_abstraction')
    set_abstractions = $(abstractor_abstraction_group).find('.abstractor_abstraction input:checkbox:checked').map(->
      $(this).val()
    ).get()
    if abstractor_abstractions.length == set_abstractions.length
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').removeClass('abstractor_group_update_workflow_status_link_disabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').addClass('abstractor_group_update_workflow_status_link_enabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').prop('disabled', false)
    else
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').removeClass('abstractor_group_update_workflow_status_link_enabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').addClass('abstractor_group_update_workflow_status_link_disabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').prop('disabled', true)
    return

    return
  return

Abstractor.AbstractionGroupUI = ->
  validateCardinality = (group_container) ->
    group_cardinality = group_container.find('input[name="abstractor_subject_group_cardinality"]')
    add_group_link    = group_container.find('.abstractor_group_add_link')
    if (group_cardinality.length > 0) && (group_cardinality.val() == group_container.find('.abstractor_abstraction_group_member').length.toString())
      $(add_group_link).hide()
    else
      $(add_group_link).show()

  $(document).on "ajax:success", ".abstractor_abstraction_group .abstractor_group_delete_link", (e, data, status, xhr) ->
    subject_groups_container_div = $(this).closest(".abstractor_subject_groups_container")
    abstraction_group_div = $(this).closest(".abstractor_abstraction_group")
    abstraction_group_div.html xhr.responseText
    validateCardinality(subject_groups_container_div)
    return

  $(document).on "ajax:success", ".abstractor_subject_groups_container .abstractor_group_add_link", (e, data, status, xhr) ->
    parent_div = $(this).closest(".abstractor_subject_groups_container")
    parent_div.find(".abstractor_subject_groups").append xhr.responseText
    validateCardinality(parent_div)
    return

  $(document).on "ajax:success", ".abstractor_abstraction_group .abstractor_group_not_applicable_all_link", (e, data, status, xhr) ->
    parent_div = $(this).closest(".abstractor_abstraction_group")
    parent_div.html xhr.responseText
    return

  $(document).on "ajax:success", ".abstractor_abstraction_group .abstractor_group_unknown_all_link", (e, data, status, xhr) ->
    parent_div = $(this).closest(".abstractor_abstraction_group")
    parent_div.html xhr.responseText
    return

  $(document).on 'ajax:success', '.abstraction_workflow_status_form', (e, data, status, xhr) ->
    parent_div = $(this).closest(".abstractor_abstraction_group")
    parent_div.html xhr.responseText
    return

  return

new Abstractor.AbstractionUI()
new Abstractor.AbstractionSuggestionUI()
new Abstractor.AbstractionGroupUI()