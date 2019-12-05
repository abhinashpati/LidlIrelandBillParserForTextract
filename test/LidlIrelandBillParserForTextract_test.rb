require "test_helper"

class LidlIrelandBillParserForTextractTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LidlIrelandBillParserForTextract::VERSION
  end

  def test_is_text_price_change
    parser = LidlIrelandBillParserForTextract::JsonParser
    assert_equal(true, parser.isTextPriceChange("Price Change") && parser.isTextPriceChange("price some... thing...."))
  end

  def test_is_text_price_change_negate
    parser = LidlIrelandBillParserForTextract::JsonParser
    assert_equal(false, parser.isTextPriceChange("Price") || parser.isTextPriceChange("change"))
  end

  def test_is_line_a_price
    parser = LidlIrelandBillParserForTextract::JsonParser
    assert_equal(true, parser.isLineAPrice("0.29 A") && parser.isLineAPrice("1.32 b") && parser.isLineAPrice("2.0 C") && parser.isLineAPrice("2,0 a"))
  end

  def test_is_line_a_price_negate
    parser = LidlIrelandBillParserForTextract::JsonParser
    assert_equal(false, parser.isLineAPrice("0.29 ") || parser.isLineAPrice("1.32"))
  end

  def test_is_text_discounted_item
    parser = LidlIrelandBillParserForTextract::JsonParser
    assert_equal(true, parser.isTextDiscountedItem("Discounted Item 12.5%") && parser.isTextDiscountedItem("Item Discount 10%") && parser.isTextDiscountedItem("Discount 20%"))
  end

  def test_is_text_discounted_item_negate
    parser = LidlIrelandBillParserForTextract::JsonParser
    assert_equal(false, parser.isTextDiscountedItem("Discounted Item 12.5") || parser.isTextDiscountedItem("10%"))
  end

  def test_is_a_trans_id
    parser = LidlIrelandBillParserForTextract::JsonParser
    assert_equal(true, parser.isATransId("TRN-ID IE20001556464656") && parser.isATransId("TRN-ID: IE20001556464656") && parser.isATransId("wasfdg: IE20001556464656") && parser.isATransId("IE20001556464656"))
  end
  def test_is_a_trans_id_negate
    parser = LidlIrelandBillParserForTextract::JsonParser
    assert_equal(false, parser.isATransId("TRNID IE200056") || parser.isATransId("IE20006") || parser.isATransId("IE2000656 SADedfg"))
  end

end
