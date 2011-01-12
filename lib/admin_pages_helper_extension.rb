module AdminPagesHelperExtension
  def permission_check_box(user, page, action, label_text)
    name = "page[permissions][]"
    check_box_tag(name, [user.id, action].join(","), user.can?(action, page)) + \
    label_tag(name, label_text) + \
    hidden_field_tag(name, '')
  end
end
