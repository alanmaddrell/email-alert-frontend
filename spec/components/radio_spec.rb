require 'rails_helper'

describe "Radio", type: :view do
  def render_component(locals)
    render file: "components/_radio", locals: locals
  end

  it "renders a radio group with one item" do
    render_component(
      name: "radio-group-frequency",
      items: [
        {
          value: "immediately",
          text: "Immediately"
        }
      ]
    )

    assert_select ".app-c-radio__input[name=radio-group-frequency]"
    assert_select ".app-c-radio:first-child .app-c-radio__label__text", text: "Immediately"
  end

  it "renders multiple items" do
    render_component(
      name: "radio-group-frequency",
      items: [
        {
          value: "immediately",
          text: "Immediately"
        },
        {
          value: "weekly",
          text: "Weekly"
        }
      ]
    )

    assert_select ".app-c-radio:first-child .app-c-radio__label__text", text: "Immediately"
    assert_select ".app-c-radio:last-child .app-c-radio__label__text", text: "Weekly"
  end

  it "renders radio-group with hint text" do
    render_component(
      name: "radio-group-hint-text",
      items: [
        {
          value: "immediately",
          hint_text: "As soon as they happen",
          text: "Immediately"
        },
        {
          value: "daily",
          hint_text: "No more than once a day",
          text: "Daily"
        }
      ]
    )

    assert_select ".app-c-radio__input[name=radio-group-hint-text]"
    assert_select ".app-c-radio:first-child .app-c-radio__label__text", text: "Immediately"
    assert_select ".app-c-radio:first-child .app-c-radio__label__hint", text: "As soon as they happen"
    assert_select ".app-c-radio:last-child .app-c-radio__label__text", text: "Daily"
    assert_select ".app-c-radio:last-child .app-c-radio__label__hint", text: "No more than once a day"
  end

  it "renders radio-group with bold labels" do
    render_component(
      name: "radio-group-bold-labels",
      items: [
        {
          value: "immediately",
          text: "Immediately",
          bold: true
        },
        {
          value: "daily",
          text: "Daily",
          bold: true
        }
      ]
    )

    assert_select ".app-c-radio__input[name=radio-group-bold-labels]"
    assert_select ".app-c-radio .gem-c-label--bold"
  end

  it "renders radio-group with checked option" do
    render_component(
      name: "radio-group-checked-option",
      items: [
        {
          value: "immediately",
          text: "Immediately"
        },
        {
          value: "daily",
          text: "Daily",
          checked: true
        }
      ]
    )

    assert_select ".app-c-radio__input[name=radio-group-checked-option]"
    assert_select ".app-c-radio__input[checked]", value: "daily"
  end
end
