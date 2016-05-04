require_relative 'setup'
ActiveRecord::Schema.define do
  self.verbose = false

  # MIGRATIONS
  create_table :example_users do |t|
    t.string :name
    t.integer :age
  end

  # <-- Your work goes here!
  create_table :events do |t|
    t.string :title, null: false
    t.string :location
    t.text :description, default: 'n/a'
    t.integer :max_attendees
    t.timestamp :created_at
    t.timestamp :updated_at
    t.datetime :when
    t.float :rating
    t.boolean :public, default: true
  end

end


# MODELS
class ExampleUser < ActiveRecord::Base
end

class Event < ActiveRecord::Base
end


# TESTS
class ExampleUserTest < Minitest::Test
  def test_it_has_a_name_which_is_a_string
    user = ExampleUser.new name: 'Jim'
    assert_equal 'Jim', user.name
  end

  def test_it_has_an_age_which_is_an_integer
    user = ExampleUser.new age: 123
    assert_equal 123, user.age
  end
end


class ColumnTypesTest < Minitest::Test
  # Reference:
  #   Migrations:   http://guides.rubyonrails.org/active_record_migrations.html
  #   Column types: http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html

  # Challenge:
  #   Create a migration for a table that stores events Each event needs to have:
  #   * title         string
  #   * location      string
  #   * description   text
  #   * max_attendees integer
  #   * created_at    timestamp
  #   * updated_at    timestamp
  #   * when          datetime
  #   * rating        float
  #   * public        boolean
  #
  # Info: String vs Text:
  #   A string is a short piece of text, though we can't explore this with sqlite, sadly.
  #   It turns into a `varchar` at the database level, meaning "variable number of characters",
  #   but has an upper bound. This allows the database to store the data within the record itself.
  #
  #   Test, however, can be arbitrarily sized. This means they need to store it in a separate
  #   location than the rest of the information in a record. Within the record, they'll just
  #   store the information required to locate the text.
  #
  #   Doing this allows them to store the record in a known amount of information.
  #   Which, in turn, means that they can calculate the location of a given record,
  #   or piece of data within the record. If a record allows up to 10 characters for a string,
  #   where each character takes 4 bytes, and also has 32 bit integer (32/8 = 4 bytes),
  #   then each record is 14 bytes, so the 10th record will be 10*14 = 140 bytes from the
  #   location of the first record.
  #
  # Info: get created_at and updated_at by using timestamps
  #   Timestamps are usually used to record when something happened
  #   they don't have high precision (only down to the second) and they
  #   count the number of seconds since Jan 1 1970  https://en.wikipedia.org/wiki/Unix_time
  #   You can add created_at and updated_at by calling the "timestamps" method when creating a table
  #
  # Info: datetime stores a year/month/day and a time within that day
  #   Use this for arbitrary date/time information
  #
  # Info: boolean types in the database will cause ActiveRecord to create getter methods that end in question marks

  def test_events_have_a_title_which_is_a
    event = Event.new title: 'Christmas party'
    assert_equal 'Christmas party', event.title
  end

  def test_events_have_a_location_which_is_a_string
    event = Event.new location: '123 n main street'
    assert_equal '123 n main street', event.location
  end

  def test_events_have_a_description_which_is_a_text
    text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    event = Event.new description: text
    assert_equal text, event.description
  end

  def test_events_have_a_max_attendees_which_is_a_integer
    event = Event.new max_attendees: 100
    assert_equal 100, event.max_attendees
  end

  def test_events_have_a_created_at_which_is_a_timestamp
    assert_in_delta Time.now, Event.create!(title: '').created_at, 1.second
  end

  def test_events_have_an_updated_at_which_is_a_timestamp
    event = Event.create!(title: '')
    assert_in_delta Time.now, event.updated_at, 1.second
  end

  def test_events_have_a_when_which_is_a_datetime
    time = 5.days.from_now
    event = Event.new when: time
    assert_equal time, event.when
  end

  def test_events_have_a_rating_which_is_a_float
    event = Event.new rating: 4.5
    assert_equal 4.5, event.rating
  end

  def test_events_have_a_public_which_is_a_boolean
    event1 = Event.new public: true
    event2 = Event.new public: false
    assert_equal true,  event1.public?
    assert_equal false, event2.public?
  end


  # Modifiers
  def test_title_may_not_be_nil
    Event.create! title: 'not nil'
    assert_raises(ActiveRecord::StatementInvalid) { Event.create! title: nil }
  end

  def test_public_defaults_to_true
    assert_equal true, Event.new.public?
  end

  def test_description_defaults_to_na
    assert_equal 'n/a', Event.new.description
  end
end
