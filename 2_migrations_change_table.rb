require_relative 'setup'
ActiveRecord::Schema.define do
  self.verbose = false

  # MIGRATIONS
  create_table :example_tables do |t|
    t.string  :name
    t.integer :price
    t.integer :number_of_legs
  end

  execute "
    insert into example_tables (name, price, number_of_legs)
    values ('table1', 12399, 4);
  "

  change_table :example_tables do |t|
    t.remove :number_of_legs
    t.rename :price, :price_in_pennies
    t.change_default :price_in_pennies, 0
    t.integer :quantity, default: 0
  end



  create_table :items do |t|
    t.string :name
    t.integer :how_many
    t.boolean :sold_out, default: false
    t.integer :seller_id
  end

  execute "
    -- the boolean field is entered as 0 for false, and 1 for true
    insert into items (name, how_many, sold_out, seller_id)
    values ('backpack', 23, 0, 4),
           ('lunchbox', 0,  1,  3);
  "
  change_table :items do |t|
    t.text :description, default: ''
    t.rename :how_many, :quantity
    t.change_default :quantity, 1
    t.rename :sold_out, :in_stock
    t.change_default :in_stock, :true
    t.remove :seller_id
  end
  # <-- Your work goes here!
  execute "
  UPDATE items SET in_stock = not(in_stock);
  "
end


# MODELS
class ExampleTable < ActiveRecord::Base
end

class Item < ActiveRecord::Base
end


# TESTS
class ExampleTableTest < Minitest::Test
  def test_it_has_a_name
    assert_equal 'Table model 5', ExampleTable.new(name: 'Table model 5').name
  end

  def test_price_was_renamed_to_price_in_pennies
    assert_equal 12399, ExampleTable.first.price_in_pennies
  end

  def test_price_in_pennies_defaults_to_0
    assert_equal 0, ExampleTable.new.price_in_pennies
  end

  def test_number_of_legs_was_removed
    assert_raises(NoMethodError) { ExampleTable.new.number_of_legs }
  end

  def test_quantity_was_added_and_defaults_to_0
    assert_equal 0, ExampleTable.first.quantity
    assert_equal 43, ExampleTable.new(quantity: 43).quantity
  end
end


class ItemTest < Minitest::Test
  def test_it_has_a_name
    assert_equal 'Table model 5', Item.new(name: 'Table model 5').name
  end

  def test_description_was_added
    assert_equal 'some desc', Item.new(description: 'some desc').description
  end

  def test_description_defaults_to_an_empty_string
    assert_equal '', Item.new.description
  end

  def test_how_many_was_renamed_to_quantity
    assert_equal 23, Item.first.quantity
  end

  def test_quantity_defaults_to_1
    assert_equal 1, Item.new.quantity
  end

  def test_sold_out_was_renamed_to_in_stock
    assert_equal true,  Item.new(in_stock: true).in_stock?
    assert_equal false, Item.new(in_stock: false).in_stock?
  end

  def test_in_stock_defaults_to_true
    assert_equal true, Item.new.in_stock?
  end

  def test_items_that_were_sold_out_have_their_value_updated_to_make_sense_for_the_name_in_stock
    # NOTE: do this by executing a sql update:
    # https://academy.vertabelo.com/course/operating-on-data-in-sql/update/update/update
    assert_equal true,  Item.find_by(name: 'backpack').in_stock?
    assert_equal false, Item.find_by(name: 'lunchbox').in_stock?
  end

  def test_seller_id_was_removed
    assert_raises(NoMethodError) { Item.new.seller_id }
  end
end
