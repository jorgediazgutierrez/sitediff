require "spec_helper"
require 'nokogiri'

describe SiteDiff::Util::Sanitize do
  describe '::remove_spacing' do
    it 'normalizes space but only within text nodes' do
      doc = Nokogiri::HTML('<html><body  class="x  y">  z  </body></html>')
      SiteDiff::Util::Sanitize::remove_spacing(doc)
      expect(doc.to_s).to include '<html><body class="x  y"> z </body></html>'
    end
  end

  describe '::sanitize' do
    it "doesn't strip HTML entities" do
      input = '<p>&mdash;</p>'
      output = SiteDiff::Util::Sanitize.sanitize(input, {})
      expect(output).to include "\u2014"
    end

    it "can perform a simple regex rule" do
      input = '<p>test something</p>'
      config = { 'sanitization' => [ { 'pattern' => 'something' } ] }
      expect(SiteDiff::Util::Sanitize.sanitize(input, config)).to include(
        '<p>test </p>')
    end
    it "can perform a more complex regex " do
      input = '<input type="hidden" name="form_build_id" value="form-1cac6b5b6141a72b2382928249605fb1"/>'
      config = { 'sanitization' => [ {
        'pattern' => '<input type="hidden" name="form_build_id" value="form-[a-zA-Z0-9_-]+" *\/?>',
        'selector' => 'input',
        'substitute' => '<input type="hidden" name="form_build_id" value="__form_build_id__">'
      } ] }
      expect(SiteDiff::Util::Sanitize.sanitize(input, config)).to include(
        '<input type="hidden" name="form_build_id" value="__form_build_id__"/>')
    end
  end

  # TODO:
  # regex captures, regex selectors
  # selector
  # transforms (unwrap, unwrap_root, remove_class, remove)
  # overall checks
  # spec out whether 'body' should be added? Frag vs Doc
end
